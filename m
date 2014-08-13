From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 00/26] BPF syscall, maps, verifier,
 samples, llvm
Date: Wed, 13 Aug 2014 16:25:16 -0700 (PDT)
Message-ID: <20140813.162516.1876660483788283579.davem@davemloft.net>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<063D6719AE5E284EB5DD2968C1650D6D174760F3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174760F3-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Date: Wed, 13 Aug 2014 08:52:30 +0000

> From: Of Alexei Starovoitov
>> one more RFC...
>> 
>> Major difference vs previous set is a new 'load 64-bit immediate' eBPF insn.
>> Which is first 16-byte instruction. It shows how eBPF ISA can be extended
>> while maintaining backward compatibility, but mainly it cleans up eBPF
>> program access to maps and improves run-time performance.
> 
> Wouldn't it be more sensible to follow the scheme used by a lot of cpus
> and add a 'load high' instruction (follow with 'add' or 'or').
> It still takes 16 bytes to load a 64bit immediate value, but the instruction
> size remains constant.
> There is nothing to stop any JIT software detecting the instruction pair.

The opposite argument is that JITs can expand the IMM64 load into whatever
sequence of instructions is most optimal.

My only real gripe with IMM64 loads is that it's not mainly for
loading an immediate, it's for loading a pointer.  And this
distinction is important for some JITs.

For example, on sparc64 all symbol based addresses are actually 32-bit
because of the code model we use to compile the kernel and all modules.
So if we knew this is a pointer load and it's to a symbol in a kernel
or module image, we could do a 32-bit load.
