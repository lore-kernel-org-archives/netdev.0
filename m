From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Issue with connector/netlink
Date: Fri, 30 Mar 2007 12:20:16 +0400
Message-ID: <20070330082015.GC20739@2ka.mipt.ru>
References: <200703292047.19208.philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33447 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322AbXC3IVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 04:21:25 -0400
Content-Disposition: inline
In-Reply-To: <200703292047.19208.philipp.reisner@linbit.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 08:47:18PM +0200, Philipp Reisner (philipp.reisner@linbit.com) wrote:
> RIP: 0010:[<ffffffff8024f904>]  [<ffffffff8024f904>] netlink_broadcast+0x123/0x2de
> RSP: 0018:ffff8100379bddc0  EFLAGS: 00010297
> RAX: 656b736968772d31 RBX: ffff810079d7f800 RCX: 0000000000000004
> RDX: ffff81007e113000 RSI: ffff810079d68280 RDI: ffffffff804c6a80
> RBP: ffff810079d68280 R08: 00000000000000d0 R09: ffff810079d68280
> R10: 0000000000000002 R11: ffff81007fd6fac0 R12: 0000000000000020
> R13: 0000000000000000 R14: ffff810079d7f818 R15: 0000000000000003
> FS:  0000000000000000(0000) GS:ffffffff804d6000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 00002b2acc1ecb40 CR3: 0000000079ac1000 CR4: 00000000000026e0
> Process cqueue/0 (pid: 1948, threadinfo ffff8100379bc000, task ffff810037fd8040)
> Stack:  ffff810079d7f400 00000000000000d0 ffff81007e113000 000000007e069a24
>  0000000000000000 0000000000000100 ffff810079d7f400 ffff81007e069a10
>  ffff81007e069a24 ffffffff881e9d00 ffff81007cf07800 ffffffff881d5c23

...

> Code;  ffffffff8024f904 <netlink_broadcast+123/2de>   <=====
>    0:   44 0f a3 38               bt     %r15d,(%rax)   <=====

%rax contains 0x656b736968772d31
In my x86_64 it is obtained from %rbx, which seems to be correct, so I'm
a bit stuck, something has rewritten internals of the socket structure,
and it does not look like free poisoning.

0xffffffff8024ea14 <netlink_broadcast+289>:     mov    0x268(%rbx),%rax
0xffffffff8024ea1b <netlink_broadcast+296>:     bt     %r15d,(%rax)

Can you describe your load? Is it too high to put a debug printk there?
Can you enable as much debug options as possible?

-- 
	Evgeniy Polyakov
