From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 21:30:26 +0200
Message-ID: <20080721193026.GA30471@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:49576 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753560AbYGUTa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:30:56 -0400
Content-Disposition: inline
In-Reply-To: <20080721184616.GA8442@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> ok, have updated the testboxes to your latest push.

and indeed i got the new warning:

[   24.460170] ieee1394: selfid_complete called with successful SelfID stage ... irm_id: 0xFFC0 node_id: 0xFFC0
[   24.460170] ieee1394: NodeMgr: Processing reset for host 0
[   24.460170] ------------[ cut here ]------------
[   24.460170] WARNING: at net/core/dev.c:1330 __netif_schedule+0xc6/0xe0()
[   24.460170] Pid: 6, comm: events/0 Not tainted 2.6.26-tip-05989-g5172ce5-dirty #13279
[   24.460170] 
[   24.460170] Call Trace:
[   24.460170]  <IRQ>  [<ffffffff8024461a>] warn_on_slowpath+0x5a/0x90
[   24.460170]  [<ffffffff80264c4d>] ? trace_hardirqs_off+0xd/0x10
[   24.460170]  [<ffffffff80ba98ca>] ? _spin_unlock_irqrestore+0x4a/0x70
[   24.460170]  [<ffffffff8088b501>] ? ether1394_reset_priv+0x121/0x140
[   24.460170]  [<ffffffff809f5db6>] __netif_schedule+0xc6/0xe0
[   24.460170]  [<ffffffff8088b62a>] ether1394_host_reset+0x10a/0x120
[   24.460170]  [<ffffffff808719fe>] highlevel_host_reset+0x3e/0x80
[   24.460170]  [<ffffffff8086fe7c>] hpsb_selfid_complete+0x25c/0x330
[   24.460170]  [<ffffffff8087e1eb>] ohci_irq_handler+0x82b/0xbc0
[   24.460170]  [<ffffffff80276e4b>] handle_IRQ_event+0x3b/0x70
[   24.460170]  [<ffffffff80278de9>] handle_level_irq+0xa9/0x130
[   24.460170]  [<ffffffff80210d98>] do_IRQ+0xc8/0x1b0
[   24.460170]  [<ffffffff8020ce13>] ret_from_intr+0x0/0x2e
[   24.460170]  <EOI>  [<ffffffff80ba98df>] ? _spin_unlock_irqrestore+0x5f/0x70
[   24.460170]  [<ffffffff80879bd6>] ? set_phy_reg+0x86/0xd0
[   24.460170]  [<ffffffff80871000>] ? delayed_reset_bus+0x0/0xf0
[   24.460170]  [<ffffffff8087a3c3>] ? ohci_devctl+0x153/0x240
[   24.460170]  [<ffffffff8086e762>] ? hpsb_reset_bus+0x22/0x30
[   24.460170]  [<ffffffff808710ac>] ? delayed_reset_bus+0xac/0xf0
[   24.460170]  [<ffffffff802562f9>] ? run_workqueue+0x179/0x220
[   24.460170]  [<ffffffff80256f04>] ? worker_thread+0xa4/0x110
[   24.460170]  [<ffffffff8025a320>] ? autoremove_wake_function+0x0/0x40
[   24.460170]  [<ffffffff80256e60>] ? worker_thread+0x0/0x110
[   24.460170]  [<ffffffff80259eed>] ? kthread+0x4d/0x80
[   24.460170]  [<ffffffff8020dca9>] ? child_rip+0xa/0x11
[   24.460170]  [<ffffffff8020cf3e>] ? restore_args+0x0/0x30
[   24.460170]  [<ffffffff80259ea0>] ? kthread+0x0/0x80
[   24.460170]  [<ffffffff8020dc9f>] ? child_rip+0x0/0x11
[   24.460170] 
[   24.460170] ---[ end trace 7b0ee76e032c9e07 ]---
[   24.717334] ohci1394: fw-host0: Single packet rcv'd
[   24.717334] ohci1394: fw-host0: Got phy packet ctx=0 ... discarded
[   24.728466] Registering platform device 'i8042'. Parent at platform
[   24.735133] device: 'i8042': device_add
[   24.741452] bus: 'platform': add device i8042
[   24.745331] PM: Adding info for platform:i8042

but otherwise the box has booted up just fine. (and even ohci1394 seemed 
to continue fine after that warning)

	Ingo
