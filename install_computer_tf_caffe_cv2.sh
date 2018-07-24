
# The script should be run a fresh Ubuntu 16 with CUDA and Nvidia. 
# It installs tensorflow, opencv, blast, Caffe 


export  APT_INSTALL="sudo apt-get install -y --no-install-recommends" && \
export PIP_INSTALL="sudo python -m pip --no-cache-dir install --upgrade" && \
export GIT_CLONE="git clone --depth 10" 

rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

sudo apt-get update && \


# ==================================================================
# tools
# ------------------------------------------------------------------

    $APT_INSTALL \
        build-essential \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
        && \


# ==================================================================
# Install lfs for git:
# ------------------------------------------------------------------
git clone https://github.com/git-lfs/git-lfs.git
cd git-lgs
sudo git lfs install
cd -
#curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash


# ==================================================================
# Install Nvidia driver, CUDA9, CUDNN7
# ------------------------------------------------------------------

lspci | grep -i nvidia
sudo apt-get install gcc
sudo apt-get install linux-headers-$(uname -r)
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.0.5.15-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7-dev_7.0.5.15-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libnccl2_2.1.4-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libnccl-dev_2.1.4-1+cuda9.0_amd64.deb

sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i libcudnn7_7.0.5.15-1+cuda9.0_amd64.deb
sudo dpkg -i libcudnn7-dev_7.0.5.15-1+cuda9.0_amd64.deb
sudo dpkg -i libnccl2_2.1.4-1+cuda9.0_amd64.deb
sudo dpkg -i libnccl-dev_2.1.4-1+cuda9.0_amd64.deb

sudo apt-get update
sudo apt-get install cuda
sudo apt-get install libcudnn7-dev
sudo apt-get install libnccl-dev
# ==================================================================
# python
# ------------------------------------------------------------------

    $APT_INSTALL \
		software-properties-common \
		&& \
	    sudo add-apt-repository ppa:deadsnakes/ppa && \
	    sudo apt-get update && \
    $APT_INSTALL \
		python3.6 \
		python3.6-dev \
		&& \
    wget -O ~/get-pip.py \
		https://bootstrap.pypa.io/get-pip.py && \
    python3.6 ~/get-pip.py && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        scikit-learn \
        matplotlib \
        Cython \
        && \

# ==================================================================
# boost
# ------------------------------------------------------------------

    wget -O ~/boost.tar.gz https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz && \
    tar -zxf ~/boost.tar.gz -C ~ && \
    cd ~/boost_* && \
    ./bootstrap.sh --with-python=python3.6 && \
    sudo ./b2 install --prefix=/usr/local && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorflow-gpu==1.7 \
        && \

# ==================================================================
# opencv
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        libatlas-base-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        && \

    $GIT_CLONE --branch 3.4.1 https://github.com/opencv/opencv ~/opencv && \
    mkdir -p ~/opencv/build && cd ~/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_OPENCL=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          .. && \
    sudo make -j"$(nproc)" install && \

# ==================================================================
# caffe
# ------------------------------------------------------------------

    $GIT_CLONE https://github.com/NVIDIA/nccl ~/nccl && \
    cd ~/nccl && \
    sudo make -j"$(nproc)" install && \

    $GIT_CLONE https://github.com/BVLC/caffe ~/caffe && \
    cp ~/caffe/Makefile.config.example ~/caffe/Makefile.config && \
    sed -i 's/# USE_CUDNN/USE_CUDNN/g' ~/caffe/Makefile.config && \
    sed -i 's/# PYTHON_LIBRARIES/PYTHON_LIBRARIES/g' ~/caffe/Makefile.config && \
    sed -i 's/# WITH_PYTHON_LAYER/WITH_PYTHON_LAYER/g' ~/caffe/Makefile.config && \
    sed -i 's/# OPENCV_VERSION/OPENCV_VERSION/g' ~/caffe/Makefile.config && \
    sed -i 's/# USE_NCCL/USE_NCCL/g' ~/caffe/Makefile.config && \
    sed -i 's/-gencode arch=compute_20,code=sm_20//g' ~/caffe/Makefile.config && \
    sed -i 's/-gencode arch=compute_20,code=sm_21//g' ~/caffe/Makefile.config && \
    sed -i 's/2\.7/3\.6/g' ~/caffe/Makefile.config && \
    sed -i 's/3\.5/3\.6/g' ~/caffe/Makefile.config && \
    sed -i 's/\/usr\/lib\/python/\/usr\/local\/lib\/python/g' ~/caffe/Makefile.config && \
    sed -i 's/\/usr\/local\/include/\/usr\/local\/include \/usr\/include\/hdf5\/serial/g' ~/caffe/Makefile.config && \
    sed -i 's/hdf5/hdf5_serial/g' ~/caffe/Makefile && \
    cd ~/caffe && \
    sudo make -j"$(nproc)" -Wno-deprecated-gpu-targets distribute && \

    # fix ValueError caused by python-dateutil 1.x
    sed -i 's/,<2//g' ~/caffe/python/requirements.txt && \

    $PIP_INSTALL \
        -r ~/caffe/python/requirements.txt && \

    cd ~/caffe/distribute/bin && \
    sudo for file in *.bin; do mv "$file" "${file%%.bin}"; done && \
    cd ~/caffe/distribute && \
    sudo cp -r bin include lib proto /usr/local/ && \
    sudo cp -r python/caffe /usr/local/lib/python3.6/dist-packages/ && \

# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

    ldconfig && \
    sudo apt-get clean && \
    sudo apt-get autoremove && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* ~/*

