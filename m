From: sdrb@onet.eu
Subject: Calltrace in process_backlog()
Date: Thu, 18 Sep 2014 11:53:32 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1409181138160.5266@127.0.0.1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo11.poczta.onet.pl ([213.180.142.142]:58044 "EHLO
	smtpo11.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064AbaIRKDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 06:03:45 -0400
Received: from flyc060.flytronic.local (unknown [91.217.224.228])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: sdrb@onet.eu)
	by smtp.poczta.onet.pl (Onet) with ESMTPSA id 3hzD4v2KFzz9vXWT
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 11:53:02 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm writing some network driver for Linux 3.3.8 and I've got problems with 
it. I get following calltrace:


[K 3120.810795] Unable to handle kernel paging request at virtual address 
00100104
[K 3120.818189] pgd = c0004000
[K 3120.821002] [00100104] *pgd=00000000
[K 3120.824700] Internal error: Oops: 817 [#1]
[K 3120.828919] Modules linked in: (...) ebt_among ebt_802_3 ebtable_nat 
[K 3120.913717] CPU: 0    Tainted: G           O 
(3.3.8 #6)
[K 3120.919190] PC is at process_backlog+0x108/0x148
[K 3120.923938] LR is at __kfree_skb+0x80/0xc8
[K 3120.928168] pc : [<c016a6f8>]    lr : [<c01631c4>]    psr: 80000093
[K 3120.928179] sp : c0299e70  ip : c0299e00  fp : c0299e94
[K 3120.939946] r10: c02b3974  r9 : c02da548  r8 : 00000000
[K 3120.945313] r7 : c02b3994  r6 : 00000028  r5 : 00000027  r4 : c02b39a0
[K 3120.951994] r3 : 00000000  r2 : 00200200  r1 : 00100100  r0 : 00100100
[K 3120.958676] Flags: Nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM 
Segment kernel
[K 3120.966233] Control: 000039ff  Table: 06be8000  DAC: 00000017
[K 3120.972123] Process swapper (pid: 0, stack limit = 0xc0298270)
[K 3120.978104] Stack: (0xc0299e70 to 0xc029a000)
[K 3120.982600] 9e60:                                     c02b39a0 
c02b3960 00000001 00000040
[K 3120.990960] 9e80: 0000012c c02b3968 c0299ecc c0299e98 c016c81c 
c016a5fc 00000003 00044de2
[K 3120.999323] 9ea0: c02d4880 c02d48b0 c0298000 00000001 00000100 
c02d4880 00000009 00000003
[K 3121.007681] 9ec0: c0299f04 c0299ed0 c001a59c c016c7b0 c0299eec 
c0299ee0 c004722c 00000005
[K 3121.016044] 9ee0: 00000000 0000001f c0299f74 00004000 69054041 
002926a0 c0299f14 c0299f08
[K 3121.024401] 9f00: c001a9bc c001a524 c0299f2c c0299f18 c0009930 
c001a980 c0009a8c 60000013
[K 3121.032765] 9f20: c0299f3c c0299f30 c00081d0 c00098d0 c0299f94 
c0299f40 c0008c70 c00081cc
[K 3121.041129] 9f40: 00000000 c02aa630 c0299f88 60000013 c0298000 
c029d0a4 c02b3ae8 c029d09c
[K 3121.049493] 9f60: 00004000 69054041 002926a0 c0299f94 c0299f98 
c0299f88 c0009c30 c0009a8c
[K 3121.057858] 9f80: 60000013 ffffffff c0299fb4 c0299f98 c0009c30 
c0009a70 c029c458 c029a0b0
[K 3121.066222] 9fa0: c02b3ab4 c0293f4c c0299fc4 c0299fb8 c01e373c 
c0009bd8 c0299ff4 c0299fc8
[K 3121.074585] 9fc0: c027a79c c01e36e8 c027a1a8 00000000 00000000 
c0293f4c 00000000 000039fd
[K 3121.082940] 9fe0: c029a034 c0293f48 00000000 c0299ff8 00008040 
c027a504 00000000 00000000
[K 3121.091281] Backtrace:
[K 3121.093853] [<c016a5f0>] (process_backlog+0x0/0x148) from [<c016c81c>] 
(net_rx_action+0x78/0x190)
[K 3121.102914] [<c016c7a4>] (net_rx_action+0x0/0x190) from [<c001a59c>] 
(__do_softirq+0x84/0x11c)
[K 3121.111714] [<c001a518>] (__do_softirq+0x0/0x11c) from [<c001a9bc>] 
(irq_exit+0x48/0x54)
[K 3121.119985] [<c001a974>] (irq_exit+0x0/0x54) from [<c0009930>] 
(handle_IRQ+0x6c/0x8c)
[K 3121.127997] [<c00098c4>] (handle_IRQ+0x0/0x8c) from [<c00081d0>] 
(asm_do_IRQ+0x10/0x14)
[K 3121.136176]  r5:60000013 r4:c0009a8c
[K 3121.139894] [<c00081c0>] (asm_do_IRQ+0x0/0x14) from [<c0008c70>] 
(__irq_svc+0x30/0xa0)
[K 3121.147977] Exception stack(0xc0299f40 to 0xc0299f88)
[K 3121.153180] 9f40: 00000000 c02aa630 c0299f88 60000013 c0298000 
c029d0a4 c02b3ae8 c029d09c
[K 3121.161544] 9f60: 00004000 69054041 002926a0 c0299f94 c0299f98 
c0299f88 c0009c30 c0009a8c
[K 3121.169896] 9f80: 60000013 ffffffff
[K 3121.173511] [<c0009a64>] (default_idle+0x0/0x2c) from [<c0009c30>] 
(cpu_idle+0x64/0xac)
[K 3121.181697] [<c0009bcc>] (cpu_idle+0x0/0xac) from [<c01e373c>] 
(rest_init+0x60/0x78)
[K 3121.189608]  r6:c0293f4c r5:c02b3ab4 r4:c029a0b0 r3:c029c458
[K 3121.195449] [<c01e36dc>] (rest_init+0x0/0x78) from [<c027a79c>] 
(start_kernel+0x2a4/0x2f8)
[K 3121.203937] [<c027a4f8>] (start_kernel+0x0/0x2f8) from [<00008040>] 
(0x8040)
[K 3121.211156] Code: e1530002 2a000007 e8940006 e59f0034 (e5812004)
[K 3121.218336] ---[ end trace 2f3f1c237d8fec1f ]---
[K 3121.223119] Kernel panic - not syncing: Fatal exception in interrupt
[K 3121.229630] Rebooting in 3 seconds..+No devices on IDE controller 0


Hovewer the calltrace occures in kernel - I suspect that this problem relates
somehow to my driver. Unfortunately I cannot find where the problem is.

Symbol with offset "process_backlog+0x108" points to following line:
 	list_del(&napi->poll_list);
in process_backlog().

I know that the this problem occures because there is napi->poll_list 
freed twice. But I cannot find out where in my code is the source
of the problem. How can I find it?

The system bases on single core ARM.

Any suggestions?
