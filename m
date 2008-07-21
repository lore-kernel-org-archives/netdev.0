From: Ingo Molnar <mingo@elte.hu>
Subject: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 20:23:18 +0200
Message-ID: <20080721182318.GA20940@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:45481 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYGUSXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 14:23:42 -0400
Content-Disposition: inline
In-Reply-To: <20080721134506.GA27598@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


another one:

[   24.426510] bus: 'platform': add device i8042
[   24.430389] PM: Adding info for platform:i8042
[   24.434799] ohci1394: fw-host0: IntEvent: 00030010
[   24.434799] ohci1394: fw-host0: irq_handler: Bus reset requested
[   24.434799] ohci1394: fw-host0: Cancel request received
[   24.434799] ohci1394: fw-host0: Got RQPkt interrupt status=0x00008409
[   24.434799] ohci1394: fw-host0: SelfID interrupt received (phyid 0, root)
[   24.434799] ohci1394: fw-host0: SelfID packet 0x807f8c56 received
[   24.434799] ieee1394: Including SelfID 0x568c7f80
[   24.434799] ohci1394: fw-host0: SelfID for this node is 0x807f8c56
[   24.434799] ohci1394: fw-host0: SelfID complete
[   24.434799] ohci1394: fw-host0: PhyReqFilter=ffffffffffffffff
[   24.434799] ieee1394: selfid_complete called with successful SelfID stage ... irm_id: 0xFFC0 node_id: 0xFFC0
[   24.434799] ieee1394: NodeMgr: Processing reset for host 0
[   24.434799] ------------[ cut here ]------------
[   24.434799] kernel BUG at net/core/dev.c:1328!
[   24.434799] invalid opcode: 0000 [1] SMP 
[   24.434799] CPU 0 
[   24.434799] Pid: 6, comm: events/0 Not tainted 2.6.26-tip-05790-gcad008f-dirty #13278
[   24.434799] RIP: 0010:[<ffffffff809f5a9d>]  [<ffffffff809f5a9d>] __netif_schedule+0x9d/0xb0
[   24.434799] RSP: 0018:ffffffff812f6de8  EFLAGS: 00010046
[   24.434799] RAX: 00000000ffffffff RBX: ffffffff81021d80 RCX: 0000000000000000
[   24.434799] RDX: ffff88003c894930 RSI: 0000000000000000 RDI: ffffffff81021d80
[   24.434799] RBP: ffffffff812f6df8 R08: 0000000000000000 R09: 0000000000000001
[   24.434799] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88003c884000
[   24.434799] R13: 0000000000000086 R14: ffff88003c8959d8 R15: ffff88003c886410
[   24.434799] FS:  0000000000000000(0000) GS:ffffffff8115af80(0000) knlGS:0000000000000000
[   24.434799] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[   24.434799] CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
[   24.434799] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   24.434799] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   24.434799] Process events/0 (pid: 6, threadinfo ffff88003f676000, task ffff88003f674180)
[   24.434799] Stack:  ffff88003c8958c0 ffff88003c884000 ffffffff812f6e48 ffffffff8088b66a
[   24.434799]  ffff88003c8959e0 ffff88003c895000 0000000000010000 ffffffff80fe7040
[   24.434799]  ffff88003c884000 0000000000000086 0000000000010000 ffff88003c886410
[   24.434799] Call Trace:
[   24.434799]  <IRQ>  [<ffffffff8088b66a>] ether1394_host_reset+0x10a/0x120
[   24.434799]  [<ffffffff80871a3e>] highlevel_host_reset+0x3e/0x80
[   24.434799]  [<ffffffff8086febc>] hpsb_selfid_complete+0x25c/0x330
[   24.434799]  [<ffffffff8087e22b>] ohci_irq_handler+0x82b/0xbc0
[   24.434799]  [<ffffffff80276e4b>] handle_IRQ_event+0x3b/0x70
[   24.434799]  [<ffffffff80278de9>] handle_level_irq+0xa9/0x130
[   24.434799]  [<ffffffff80210d98>] do_IRQ+0xc8/0x1b0
[   24.434799]  [<ffffffff8020ce13>] ret_from_intr+0x0/0x2e
[   24.434799]  <EOI>  [<ffffffff80ba981f>] ? _spin_unlock_irqrestore+0x5f/0x70
[   24.434799]  [<ffffffff80879c16>] ? set_phy_reg+0x86/0xd0
[   24.434799]  [<ffffffff80871040>] ? delayed_reset_bus+0x0/0xf0
[   24.434799]  [<ffffffff8087a403>] ? ohci_devctl+0x153/0x240
[   24.434799]  [<ffffffff8086e7a2>] ? hpsb_reset_bus+0x22/0x30
[   24.434799]  [<ffffffff808710ec>] ? delayed_reset_bus+0xac/0xf0
[   24.434799]  [<ffffffff802562f9>] ? run_workqueue+0x179/0x220
[   24.434799]  [<ffffffff80256f04>] ? worker_thread+0xa4/0x110
[   24.434799]  [<ffffffff8025a320>] ? autoremove_wake_function+0x0/0x40
[   24.434799]  [<ffffffff80256e60>] ? worker_thread+0x0/0x110
[   24.434799]  [<ffffffff80259eed>] ? kthread+0x4d/0x80
[   24.434799]  [<ffffffff8020dca9>] ? child_rip+0xa/0x11
[   24.434799]  [<ffffffff8020cf3e>] ? restore_args+0x0/0x30
[   24.434799]  [<ffffffff80259ea0>] ? kthread+0x0/0x80
[   24.434799]  [<ffffffff8020dc9f>] ? child_rip+0x0/0x11
[   24.434799] 
[   24.434799] 
[   24.434799] Code: 15 4c 89 e7 57 9d 66 0f 1f 44 00 00 e8 bd f1 86 ff 5b 41 5c c9 c3 e8 13 16 87 ff 4c 89 e7 57 9d 66 0f 1f 44 00 00 5b 41 5c c9 c3 <0f> 0b eb fe 66 66 66 90 66 66 66 90 66 66 66 90 66 66 90 55 48 
[   24.434799] RIP  [<ffffffff809f5a9d>] __netif_schedule+0x9d/0xb0
[   24.434799]  RSP <ffffffff812f6de8>
[   24.434799] Kernel panic - not syncing: Fatal exception in interrupt
[   24.434799] Pid: 6, comm: events/0 Tainted: G      D   2.6.26-tip-05790-gcad008f-dirty #13278

with this config:

  http://redhat.com/~mingo/misc/config-Mon_Jul_21_20_05_45_CEST_2008.bad

(since this seems to have impacted ieee1394, Stefan Cc:-ed)

Should i spend time on bisecting this, or is this known already?

	Ingo
