From: Ingo Molnar <mingo@elte.hu>
Subject: forcedeth 0000:00:0a.0: DMA-API: device driver frees DMA memory
	with wrong function [device address=0x0000000035992232] [size=42
	bytes] [mapped as single] [unmapped as page]
Date: Wed, 18 Mar 2009 15:21:26 +0100
Message-ID: <20090318142126.GA24970@elte.hu>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com> <20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu> <20090318115615.GS6159@amd.com> <20090318120458.GA1601@elte.hu> <36697.89.102.207.186.1237380871.squirrel@mail.v3.sk> <20090318140949.GA20852@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net,
	Ingo Molnar <mingo@redhat.com>,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55560 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbZCROWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 10:22:14 -0400
Content-Disposition: inline
In-Reply-To: <20090318140949.GA20852@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There's a similar-looking warning triggering for the forcedeth 
driver as well on another test-system (see the details below).

Does anyone know whether there's a fix for this too, or is it a
new warning?

	Ingo

----- Forwarded message from Ingo Molnar <mingo@elte.hu> -----

Date: Wed, 18 Mar 2009 12:20:26 +0100
From: Ingo Molnar <mingo@elte.hu>
To: Joerg Roedel <joerg.roedel@amd.com>
Subject: forcedeth 0000:00:0a.0: DMA-API: device driver frees DMA memory
	with wrong function [device address=0x0000000035992232] [size=42
	bytes] [mapped as single] [unmapped as page]
Cc: Ingo Molnar <mingo@redhat.com>, iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org


-tip testing found this DMA-debug assert:

[   19.648023] eth0: no link during initialization.
[   21.952553] eth0: link up.
[   22.684073] ------------[ cut here ]------------
[   22.688023] WARNING: at lib/dma-debug.c:562 check_unmap+0x30e/0x4b4()
[   22.688023] Hardware name: System Product Name
[   22.688023] 
forcedeth 0000:00:0a.0: DMA-API: device driver frees DMA memory with wrong function [device address=0x0000000035992232] [size=42 bytes] [mapped as single] [unmapped as page]
[   22.688023] Modules linked in:
[   22.688023] Pid: 1523, comm: arping Not tainted 2.6.29-rc8-tip #20999
[   22.688023] Call Trace:
[   22.688023]  [<c0140eae>] warn_slowpath+0x76/0xad
[   22.688023]  [<c0293a0b>] ? add_dma_entry+0x4b/0x51
[   22.688023]  [<c015eec5>] ? mark_lock+0x1c/0x16f
[   22.688023]  [<c015f1a4>] ? __lock_acquire+0x18c/0x296
[   22.688023]  [<c03473cc>] ? nv_start_xmit_optimized+0x3bd/0x3eb
[   22.688023]  [<c015eec5>] ? mark_lock+0x1c/0x16f
[   22.688023]  [<c015f1a4>] ? __lock_acquire+0x18c/0x296
[   22.688023]  [<c0293572>] check_unmap+0x30e/0x4b4
[   22.688023]  [<c055f7c3>] ? _spin_lock+0x27/0x2f
[   22.688023]  [<c0145ba1>] ? _local_bh_enable_ip+0xa1/0xa7
[   22.688023]  [<c049e0f8>] ? dev_queue_xmit+0x325/0x359
[   22.688023]  [<c0188922>] ? trace_hardirqs_on+0x21/0x23
[   22.688023]  [<c0145ba1>] ? _local_bh_enable_ip+0xa1/0xa7
[   22.688023]  [<c0145bc6>] ? local_bh_enable+0x10/0x12
[   22.688023]  [<c050225c>] ? packet_sendmsg+0x1b7/0x20a
[   22.688023]  [<c02939b8>] debug_dma_unmap_page+0x59/0x61
[   22.688023]  [<c034421f>] pci_unmap_page+0x5b/0x66
[   22.688023]  [<c03446fd>] nv_tx_done_optimized+0x46/0x1c5
[   22.688023]  [<c0345922>] nv_nic_irq_optimized+0xa7/0x233
[   22.688023]  [<c017706e>] handle_IRQ_event+0x85/0xdf
[   22.688023]  [<c01785df>] handle_fasteoi_irq+0x79/0xb9
[   22.688023]  [<c0119973>] handle_irq+0x1f/0x24
[   22.688023]  [<c0119332>] do_IRQ+0x45/0x88
[   22.688023]  [<c0118455>] common_interrupt+0x35/0x40
[   22.688023]  [<c0144515>] ? do_setitimer+0x160/0x2d9
[   22.688023]  [<c055f69b>] ? _spin_unlock_irq+0x29/0x2b
[   22.688023]  [<c0144515>] do_setitimer+0x160/0x2d9
[   22.688023]  [<c04926fa>] ? sys_socketcall+0xed/0x188
[   22.688023]  [<c014473b>] alarm_setitimer+0x39/0x58
[   22.688023]  [<c0149776>] sys_alarm+0x10/0x12
[   22.688023]  [<c0117d47>] sysenter_do_call+0x12/0x32
[   22.688023] ---[ end trace bf7fa25698012db6 ]---
[   22.688023] Mapped at:
[   22.688023]  [<c0293cc1>] debug_dma_map_page+0x6c/0x128
[   22.688023]  [<c0345bd0>] pci_map_single+0xb5/0xc1
[   22.688023]  [<c0347147>] nv_start_xmit_optimized+0x138/0x3eb
[   22.688023]  [<c049dc7c>] dev_hard_start_xmit+0x123/0x18f
[   22.688023]  [<c04acbb9>] __qdisc_run+0xd0/0x1b3
[   23.700081] arping used greatest stack depth: 5988 bytes left
[   24.545512] Adding 3911816k swap on /dev/sda2.  Priority:-1 extents:1 across:3911816k 

Config and full bootlog attached.

	Ingo

