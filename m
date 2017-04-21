From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 11:49:37 -0700
Message-ID: <20170421184935.GA86324@ast-mbp.thefacebook.com>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
 <58F50D13.3090001@iogearbox.net>
 <20170421.124640.1134810340055330244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, sparclinux@vger.kernel.org,
        netdev@vger.kernel.org, ast@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170421.124640.1134810340055330244.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 12:46:40PM -0400, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Mon, 17 Apr 2017 20:44:35 +0200
> 
> > There is samples/bpf/sockex3_kern.c, which exercises it. To
> > run it, it would be (clang/llvm needed due to BPF backend not
> > available in gcc):
> > 
> > # cd samples/bpf
> > # make
> > # ./sockex3
> > IP     src.port -> dst.port               bytes      packets
> > 127.0.0.1.12865 -> 127.0.0.1.49711          148            2
> > 127.0.0.1.49711 -> 127.0.0.1.12865          108            2
> > [...]
> > 
> > Inside parse_eth_proto(), it will do tail calls based on the
> > eth protocol. Over time, we'll move such C based tests over to
> > tools/testing/selftests/bpf/.
> 
> Ok, after a lot of work setting up an LLVM/CLANG environment and other
> things, 

was it painful because of sparc environment?
fedora/ubuntu on x86 ship with modern clang already and bpf backend
is compiled-in by default.
redhat folks have been back and forth on adding bpf support to gcc.
The backend itself was fully functional before it was abandoned.
Last time we discussed it the lack of integrated asm in gcc was the main blocker.
Can we bend gcc rules and let bpf backend emit custom binary and/or elf?

