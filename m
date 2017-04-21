From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 15:02:26 -0400 (EDT)
Message-ID: <20170421.150226.825217448288272000.davem@davemloft.net>
References: <58F50D13.3090001@iogearbox.net>
        <20170421.124640.1134810340055330244.davem@davemloft.net>
        <20170421184935.GA86324@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, sparclinux@vger.kernel.org,
        netdev@vger.kernel.org, ast@kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170421184935.GA86324@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 21 Apr 2017 11:49:37 -0700

> On Fri, Apr 21, 2017 at 12:46:40PM -0400, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Mon, 17 Apr 2017 20:44:35 +0200
>> 
>> > There is samples/bpf/sockex3_kern.c, which exercises it. To
>> > run it, it would be (clang/llvm needed due to BPF backend not
>> > available in gcc):
>> > 
>> > # cd samples/bpf
>> > # make
>> > # ./sockex3
>> > IP     src.port -> dst.port               bytes      packets
>> > 127.0.0.1.12865 -> 127.0.0.1.49711          148            2
>> > 127.0.0.1.49711 -> 127.0.0.1.12865          108            2
>> > [...]
>> > 
>> > Inside parse_eth_proto(), it will do tail calls based on the
>> > eth protocol. Over time, we'll move such C based tests over to
>> > tools/testing/selftests/bpf/.
>> 
>> Ok, after a lot of work setting up an LLVM/CLANG environment and other
>> things, 
> 
> was it painful because of sparc environment?

Yes, primarily this was the reason.

It wasn't just a matter of building llvm/clang, I had to install a
whole new version of gcc because of llvm/clang build requirements.

Also, it isn't clear what is supposed to happen when the system
include files are older than the one in the kernel tree.  I thought it
should just work and the selftests and samples would pick up the ones
in the tree properly.

> redhat folks have been back and forth on adding bpf support to gcc.
> The backend itself was fully functional before it was abandoned.
> Last time we discussed it the lack of integrated asm in gcc was the main blocker.
> Can we bend gcc rules and let bpf backend emit custom binary and/or elf?

I don't see why you can't just do a proper GNU as/ld port.

Frankly I would love to write foo.s BFD assembler files just like for
any other target and them feed them to binutils.

And then once you have BFD support for BPF ELF you get lots of tooling
and you can start going for gdb support.
