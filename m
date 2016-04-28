From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V4 3/5] samples/bpf: add a README file to get
 users started
Date: Thu, 28 Apr 2016 19:07:45 +0530
Message-ID: <20160428133740.GC7880@naverao1-tp.in.ibm.com>
References: <20160428121949.16807.84828.stgit@firesoul>
 <20160428122103.16807.41837.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160428122103.16807.41837.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/04/28 02:21PM, Jesper Dangaard Brouer wrote:
> Getting started with using examples in samples/bpf/ is not
> straightforward.  There are several dependencies, and specific
> versions of these dependencies.
> 
> Just compiling the example tool is also slightly obscure, e.g. one
> need to call make like:
> 
>  make samples/bpf/
> 
> Do notice the "/" slash after the directory name.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

> ---
>  samples/bpf/README.rst |   64 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 64 insertions(+)
>  create mode 100644 samples/bpf/README.rst
> 
> diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
> new file mode 100644
> index 000000000000..993d280184fa
> --- /dev/null
> +++ b/samples/bpf/README.rst
> @@ -0,0 +1,64 @@
> +eBPF sample programs
> +====================
> +
> +This directory contains a mini eBPF library, test stubs, verifier
> +test-suite and examples for using eBPF.
> +
> +Build dependencies
> +==================
> +
> +Compiling requires having installed:
> + * clang >= version 3.4.0
> + * llvm >= version 3.7.1
> +
> +Note that LLVM's tool 'llc' must support target 'bpf', list version
> +and supported targets with command: ``llc --version``
> +
> +Kernel headers
> +--------------
> +
> +There are usually dependencies to header files of the current kernel.
> +To avoid installing devel kernel headers system wide, as a normal
> +user, simply call::
> +
> + make headers_install
> +
> +This will creates a local "usr/include" directory in the git/build top
> +level directory, that the make system automatically pickup first.
> +
> +Compiling
> +=========
> +
> +For building the BPF samples, issue the below command from the kernel
> +top level directory::
> +
> + make samples/bpf/
> +
> +Do notice the "/" slash after the directory name.
> +
> +Manually compiling LLVM with 'bpf' support
> +------------------------------------------
> +
> +Since version 3.7.0, LLVM adds a proper LLVM backend target for the
> +BPF bytecode architecture.
> +
> +By default llvm will build all non-experimental backends including bpf.
> +To generate a smaller llc binary one can use::
> +
> + -DLLVM_TARGETS_TO_BUILD="BPF"
> +
> +Quick sniplet for manually compiling LLVM and clang
> +(build dependencies are cmake and gcc-c++)::
> +
> + $ git clone http://llvm.org/git/llvm.git
> + $ cd llvm/tools
> + $ git clone --depth 1 http://llvm.org/git/clang.git
> + $ cd ..; mkdir build; cd build
> + $ cmake .. -DLLVM_TARGETS_TO_BUILD="BPF;X86"
> + $ make -j $(getconf _NPROCESSORS_ONLN)
> +
> +It is also possible to point make to the newly compiled 'llc' command
> +via redefining LLC on the make command line::
> +
> + make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> +
> 

