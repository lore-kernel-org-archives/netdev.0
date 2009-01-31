From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SMC911X driver Suspend-Resume Failures
Date: Fri, 30 Jan 2009 21:09:45 -0800
Message-ID: <20090130210945.46915259.akpm@linux-foundation.org>
References: <8bf247760901300435s56024125o9aae1a112196c9a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: Sriram V <vshrirama@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54537 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750765AbZAaFKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 00:10:15 -0500
In-Reply-To: <8bf247760901300435s56024125o9aae1a112196c9a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009 18:05:27 +0530 Sriram V <vshrirama@gmail.com> wrote:

> Hi,
>    I am using 2.6.28 and am testing PM on my arm target. I am using
> smc911x.c driver.
>    I get the error when i try to resume from suspend:
> 
>    has anyone seen this error before.
> 

Is this the entire output?  Was there any additional information
preceding the first line which you quoted?

> 
> 
> CPU: 0    Not tainted  (2.6.28-omap1-00248-g3fd6c57-dirty #22)
> PC is at rt_cache_flush+0x80/0xb8
> LR is at rt_cache_flush+0x7c/0xb8
> pc : [<c01dd728>]    lr : [<c01dd724>]    psr: a0000013
> sp : cf829ea0  ip : cf829ea0  fp : cf829ebc
> r10: 00000000  r9 : 00000000  r8 : 00000004
> r7 : 00000000  r6 : 0000027f  r5 : cf828000  r4 : 80000000
> r3 : 00000000  r2 : cf828000  r1 : c01dcf24  r0 : 80000000
> Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: 10c5387d  Table: 8f990018  DAC: 00000017
> Process events/0 (pid: 5, stack limit = 0xcf8282e8)
> Stack: (0xcf829ea0 to 0xcf82a000)
> 9ea0: c031f5fc fffffffa 00000000 cf888800 cf829ed4 cf829ec0 c020a5d4 c01dd6b4
> 9ec0: c031f5fc fffffffa cf829efc cf829ed8 c0069720 c020a550 cf888800 00000002
> 9ee0: 00000000 00000000 00000000 00000000 cf829f14 cf829f00 c0069824 c00696f8
> 9f00: 00000000 00000000 cf829f2c cf829f18 c006984c c0069814 00000000 cf888800
> 9f20: cf829f3c cf829f30 c01c9d38 c0069838 cf829f54 cf829f40 c01ca200 c01c9d28
> 9f40: cf888800 00000002 cf829f74 cf829f58 c01d5534 c01ca1e4 cf801940 cf828000
> 9f60: c01d557c cf801940 cf829f84 cf829f78 c01d55a8 c01d53f4 cf829fa4 cf829f88
> 9f80: c006183c c01d5588 cf829fb8 cf81e880 cf828000 cf801940 cf829fdc cf829fa8
> 9fa0: c00623d8 c00617a4 00000000 00000000 cf81e880 c006563c cf829fb8 cf829fb8
> 9fc0: cf801940 c00622e8 00000000 00000000 cf829ff4 cf829fe0 c006516c c00622f4
> 9fe0: 00000000 00000000 00000000 cf829ff8 c00549f0 c0065124 00000000 00000000
> Backtrace:
> [<c01dd6a8>] (rt_cache_flush+0x0/0xb8) from [<c020a5d4>]
> (fib_netdev_event+0x90/0x9c)
>  r7:cf888800 r6:00000000 r5:fffffffa r4:c031f5fc
> [<c020a544>] (fib_netdev_event+0x0/0x9c) from [<c0069720>]
> (notifier_call_chain+0x34/0x78)
>  r5:fffffffa r4:c031f5fc
> [<c00696ec>] (notifier_call_chain+0x0/0x78) from [<c0069824>]
> (__raw_notifier_call_chain+0x1c/0x24)
>  r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:00000002
> r4:cf888800
> [<c0069808>] (__raw_notifier_call_chain+0x0/0x24) from [<c006984c>]
> (raw_notifier_call_chain+0x20/0x28)
> [<c006982c>] (raw_notifier_call_chain+0x0/0x28) from [<c01c9d38>]
> (call_netdevice_notifiers+0x1c/0x24)
> [<c01c9d1c>] (call_netdevice_notifiers+0x0/0x24) from [<c01ca200>]
> (netdev_state_change+0x28/0x3c)
> [<c01ca1d8>] (netdev_state_change+0x0/0x3c) from [<c01d5534>]
> (__linkwatch_run_queue+0x14c/0x194)
>  r5:00000002 r4:cf888800
> [<c01d53e8>] (__linkwatch_run_queue+0x0/0x194) from [<c01d55a8>]
> (linkwatch_event+0x2c/0x3c)
>  r7:cf801940 r6:c01d557c r5:cf828000 r4:cf801940
> [<c01d557c>] (linkwatch_event+0x0/0x3c) from [<c006183c>]
> (run_workqueue+0xa4/0x120)
> [<c0061798>] (run_workqueue+0x0/0x120) from [<c00623d8>]
> (worker_thread+0xf0/0x104)
>  r7:cf801940 r6:cf828000 r5:cf81e880 r4:cf829fb8
> [<c00622e8>] (worker_thread+0x0/0x104) from [<c006516c>] (kthread+0x54/0x80)
>  r7:00000000 r6:00000000 r5:c00622e8 r4:cf801940
> [<c0065118>] (kthread+0x0/0x80) from [<c00549f0>] (do_exit+0x0/0x6ac)
>  r5:00000000 r4:00000000
> Code: e7924106 e7823106 ebf9e679 ea000001 (e5944084)
> ---[ end trace 5d3b9d1bfba9fc73 ]---
> eth0: link up, 100Mbps, full-duplex, lpa 0x05E1
> nfs: server 192.168.13.144 not responding, still trying

