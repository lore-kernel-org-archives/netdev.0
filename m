From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 3/4] samples/bpf: add a README file to get users
 started
Date: Tue, 26 Apr 2016 07:34:12 -0700
Message-ID: <20160426143410.GA39797@ast-mbp.thefacebook.com>
References: <20160426110828.20716.13392.stgit@firesoul>
 <20160426110927.20716.89620.stgit@firesoul>
 <571F5486.7090902@iogearbox.net>
 <20160426135647.7faf9a87@redhat.com>
 <571F61D6.50101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	bblanco@plumgrid.com, borkmann@iogearbox.net,
	linux-kbuild@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <571F61D6.50101@iogearbox.net>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 02:40:54PM +0200, Daniel Borkmann wrote:
> On 04/26/2016 01:56 PM, Jesper Dangaard Brouer wrote:
> >>>+Compiling requires having installed:
> >>>+ * clang
> >>>+ * llvm >= version 3.7.0

please change it to 3.7.1, since 3.7.0 had several bugs.
They're rare, but better to avoid the issue.

> >>>+
> >>>+Note that LLVM's tool 'llc' must support target 'bpf', list with command::
> >>>+
> >>>+ $ llc --version
> >>>+ LLVM (http://llvm.org/):
> >>>+  LLVM version 3.x.y
> >>>+  [...]
> >>>+  Host CPU: xxx
> >>>+
> >>>+  Registered Targets:
> >>>+    [...]
> >>>+    bpf        - BPF (host endian)
> >>>+    bpfeb      - BPF (big endian)
> >>>+    bpfel      - BPF (little endian)

there always be 3 targets for bpf, since some folks need to cross-compile.

> >>>+Manually compiling LLVM with 'bpf' support
> >>>+------------------------------------------
> >>>+
> >>>+In some LLVM versions the BPF target were marked experimental.  To
> >>>+compile LLVM manually and enable BPF target run (build dependencies
> >>>+are cmake and gcc-c++)::
> >>>+
> >>>+ $ git clone http://llvm.org/git/llvm.git
> >>>+ $ cd llvm
> >>>+ $ mkdir build; cd build
> >>>+ $ cmake .. -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=BPF
> >>>+ $ make
> >>
> >>That's perhaps a bit misleading in the sense that when you clone the
> >>tree from git, you'd nowadays invoke cmake normally with LLVM_TARGETS_TO_BUILD
> >>instead of LLVM_EXPERIMENTAL_TARGETS_TO_BUILD for BPF, as BPF is not an
> >>experimental target anymore. It's probably also recommended to clone
> >>clang into tools/ dir as well under your llvm/ repo when you compile
> >>from scratch anyways.

yes. LLVM_EXPERIMENTAL_TARGETS_TO_BUILD is the thing of the past
when bpf was just merged into llvm < 3.7
By default llvm will build all non-experimental backends including bpf.
If you need to make llc binary smaller you can use:
-DLLVM_TARGETS_TO_BUILD="BPF;X86"

Also fedora and ubuntu ship with llvm that has bpf support.

> >Can you come up with a formulation/desc I can use instead then?
> 
> You mean how to build with clang? There are various docs/snippets out
> there, for example, see the 'Build LLVM and Clang development libs'
> part of [1], that you can tweak for your README with.
> 
>   [1] https://gist.github.com/brendangregg/cfa482acb71aa577789c

yep. +1 for the link.

