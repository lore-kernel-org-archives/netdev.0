From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V3 3/5] samples/bpf: add a README file to get
 users started
Date: Wed, 27 Apr 2016 14:05:22 +0530
Message-ID: <20160427083522.GA15073@naverao1-tp.in.ibm.com>
References: <20160427072855.29959.70252.stgit@firesoul>
 <20160427073023.29959.17816.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([125.16.236.8]:52949 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbcD0Ife (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 04:35:34 -0400
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Wed, 27 Apr 2016 14:05:31 +0530
Content-Disposition: inline
In-Reply-To: <20160427073023.29959.17816.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/04/27 09:30AM, Jesper Dangaard Brouer wrote:
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
> ---
>  samples/bpf/README.rst |   75 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 75 insertions(+)
>  create mode 100644 samples/bpf/README.rst

Thanks for adding this! A few nits...

> 
> diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
> new file mode 100644
> index 000000000000..1fa157db905b
> --- /dev/null
> +++ b/samples/bpf/README.rst
> @@ -0,0 +1,75 @@
> +eBPF sample programs
> +====================
> +
> +This kernel samples/bpf directory contains a mini eBPF library, test
	^^^^^^^^^^^^^^^^^^
'This directory contains' should suffice.

> +stubs, verifier test-suite and examples for using eBPF.
> +
> +Build dependencies
> +==================
> +
> +Compiling requires having installed:
> + * clang >= version 3.4.0
> + * llvm >= version 3.7.1
> +
> +Note that LLVM's tool 'llc' must support target 'bpf', list with command::
> +
> + $ llc --version

'llc --version | grep bpf' is probably simpler?

> + LLVM (http://llvm.org/):
> +  LLVM version 3.x.y
> +  [...]
> +  Host CPU: xxx
> +
> +  Registered Targets:
> +    [...]
> +    bpf        - BPF (host endian)
> +    bpfeb      - BPF (big endian)
> +    bpfel      - BPF (little endian)
> +    [...]
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
> +For compiling goto kernel top level build directory and run make like::

For building the BPF samples, issue the below command from the kernel 
root directory:

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
> + -DLLVM_TARGETS_TO_BUILD="BPF;X86"

Is the X86 target really needed?

> +
> +Quick sniplet for manually compiling LLVM and clang
> +(build dependencies are cmake and gcc-c++)::
> +
> + $ git clone http://llvm.org/git/llvm.git
> + $ cd llvm/tools
> + $ git clone --depth 1 http://llvm.org/git/clang.git
> + $ cd ..; mkdir build; cd build
> + $ cmake .. -DLLVM_TARGETS_TO_BUILD="BPF;X86"
					    ^^^
Here too.

- Naveen

> + $ make -j $(getconf _NPROCESSORS_ONLN)
> +
> +It is also possible to point make to the newly compiled 'llc' command
> +via redefining LLC on the make command line::
> +
> + make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> +
> 
