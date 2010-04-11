From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Sun, 11 Apr 2010 23:38:46 +0300
Message-ID: <201004112338.47019.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_XNjwLyIfshC+m2Z"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57255 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891Ab0DKUkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 16:40:22 -0400
Received: from home.localnet (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id B79D71A431B
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 23:40:13 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_XNjwLyIfshC+m2Z
Content-Type: Text/Plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit

Hi

Got recently NULL pointer dereference
Note - it seems in 32-bit i didn't experience this issue.

Router with NAT, HFSC shapers terminated with bfifo qdiscs (some attached to 
802.1Q vlan's), userspace application using tun.
Hardware - network cards e1000e, Core 2 based architecture (two Quad Xeon), 

full message received over netconsole attached
More info can provide on request

--Boundary-00=_XNjwLyIfshC+m2Z
Content-Type: text/plain;
  charset="koi8-r";
  name="BUG"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="BUG"

Apr 11 23:28:52 ROUTER kernel: [21095.453138] BUG: unable to handle kernel NULL pointer dereference at (null)
Apr 11 23:28:52 ROUTER kernel: [21095.453334] IP: [<ffffffff811e5877>] dev_queue_xmit+0x284/0x465
Apr 11 23:28:52 ROUTER kernel: [21095.453522] PGD 20b247067 PUD 20b24c067 PMD 0 
Apr 11 23:28:52 ROUTER kernel: [21095.453704] Oops: 0000 [#1] SMP 
Apr 11 23:28:52 ROUTER kernel: [21095.453880] last sysfs file: /sys/devices/virtual/misc/tun/dev
Apr 11 23:28:52 ROUTER kernel: [21095.454001] CPU 0 
Apr 11 23:28:52 ROUTER kernel: [21095.454001] Pid: 2864, comm: globax Not tainted 2.6.33.2-build-0051-64 #4         /        
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RIP: 0010:[<ffffffff811e5877>]  [<ffffffff811e5877>] dev_queue_xmit+0x284/0x465
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RSP: 0000:ffff880028203db0  EFLAGS: 00010202
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RAX: 0000000000002000 RBX: 0000000000000000 RCX: ffff8802087d8d00
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RDX: ffff88021d818000 RSI: 0000000000000000 RDI: ffff8802135850e8
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RBP: ffff880028203de0 R08: ffff88021c01d89c R09: ffff88021c01dc00
Apr 11 23:28:52 ROUTER kernel: [21095.454001] R10: dead000000200200 R11: dead000000100100 R12: ffff88021e212b80
Apr 11 23:28:52 ROUTER kernel: [21095.454001] R13: ffff88021da51e80 R14: ffff8802135850e8 R15: ffff88021be62000
Apr 11 23:28:52 ROUTER kernel: [21095.454001] FS:  0000000000000000(0000) GS:ffff880028200000(0063) knlGS:00000000f7e51b10
Apr 11 23:28:52 ROUTER kernel: [21095.454001] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
Apr 11 23:28:52 ROUTER kernel: [21095.454001] CR2: 0000000000000000 CR3: 000000020b248000 CR4: 00000000000006f0
Apr 11 23:28:52 ROUTER kernel: [21095.454001] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 11 23:28:52 ROUTER kernel: [21095.454001] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 11 23:28:52 ROUTER kernel: [21095.454001] Process globax (pid: 2864, threadinfo ffff8802118c0000, task ffff8802182c2c20)
Apr 11 23:28:52 ROUTER kernel: [21095.454001] Stack:
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  ffff88021d818000 ffff88021da51e80 0000000000000042 ffff88021da51e80
Apr 11 23:28:52 ROUTER kernel: [21095.454001] <0> ffff88021be62000 ffff88021be62000 ffff880028203e00 ffffffffa01c12a9
Apr 11 23:28:52 ROUTER kernel: [21095.454001] <0> 0000000000000000 ffff8802135850e8 ffff880028203e50 ffffffff811e540e
Apr 11 23:28:52 ROUTER kernel: [21095.454001] Call Trace:
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  <IRQ> 
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffffa01c12a9>] vlan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811e540e>] dev_hard_start_xmit+0x232/0x304
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811f6482>] sch_direct_xmit+0x5d/0x16b
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811f664c>] __qdisc_run+0xbc/0xdc
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811e2c89>] net_tx_action+0xc2/0x120
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81039670>] __do_softirq+0x96/0x11a
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff810037cc>] call_softirq+0x1c/0x28
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81005543>] do_softirq+0x33/0x68
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81039407>] irq_exit+0x36/0x75
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81016f63>] smp_apic_timer_interrupt+0x88/0x96
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81003293>] apic_timer_interrupt+0x13/0x20
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  <EOI>
Apr 11 23:28:52 ROUTER kernel: [21095.454001] Code: e2 48 8b 55 d0 49 c1 e4 07 66 41 8b 86 a6 00 00 00 4c 03 a2 00 03 00 00 80 e4 cf 80 cc 20 49 8b 5c 24 08 66 41 89 86 a6 00 00 00 <48> 83 3b 00 0f 84 bb 00 00 00 4c 8d ab 9c 00 00 00 4c 89 ef e8
Apr 11 23:28:52 ROUTER kernel: [21095.454001] RIP  [<ffffffff811e5877>] dev_queue_xmit+0x284/0x465
Apr 11 23:28:52 ROUTER kernel: [21095.454001]  RSP <ffff880028203db0>
Apr 11 23:28:52 ROUTER kernel: [21095.454001] CR2: 0000000000000000
Apr 11 23:28:52 ROUTER kernel: [21095.462975] ---[ end trace 2421d995c1afd7c3 ]---
Apr 11 23:28:52 ROUTER kernel: [21095.463199] Kernel panic - not syncing: Fatal exception in interrupt
Apr 11 23:28:52 ROUTER kernel: [21095.463428] Pid: 2864, comm: globax Tainted: G      D    2.6.33.2-build-0051-64 #4
Apr 11 23:28:52 ROUTER kernel: [21095.463819] Call Trace:
Apr 11 23:28:52 ROUTER kernel: [21095.464036]  <IRQ>  [<ffffffff81259743>] panic+0xa0/0x161
Apr 11 23:28:52 ROUTER kernel: [21095.464307]  [<ffffffff81003293>] ? apic_timer_interrupt+0x13/0x20
Apr 11 23:28:52 ROUTER kernel: [21095.464533]  [<ffffffff81035673>] ? kmsg_dump+0x112/0x12c
Apr 11 23:28:52 ROUTER kernel: [21095.464757]  [<ffffffff81006651>] oops_end+0xaa/0xba
Apr 11 23:28:52 ROUTER kernel: [21095.464980]  [<ffffffff8101e653>] no_context+0x1f3/0x202
Apr 11 23:28:52 ROUTER kernel: [21095.465211]  [<ffffffff810523a4>] ? tick_program_event+0x25/0x27
Apr 11 23:28:52 ROUTER kernel: [21095.465437]  [<ffffffff8101e81c>] __bad_area_nosemaphore+0x1ba/0x1e0
Apr 11 23:28:52 ROUTER kernel: [21095.465668]  [<ffffffff8113f8b3>] ? swiotlb_map_page+0x0/0xd5
Apr 11 23:28:52 ROUTER kernel: [21095.465907]  [<ffffffffa015c55a>] ? pci_map_single+0x8a/0x99 [e1000e]
Apr 11 23:28:52 ROUTER kernel: [21095.466139]  [<ffffffff8113f0c0>] ? swiotlb_dma_mapping_error+0x18/0x25
Apr 11 23:28:52 ROUTER kernel: [21095.466372]  [<ffffffffa015a2e0>] ? pci_dma_mapping_error+0x31/0x3d [e1000e]
Apr 11 23:28:52 ROUTER kernel: [21095.466605]  [<ffffffffa015cc37>] ? e1000_xmit_frame+0x6ce/0xa43 [e1000e]
Apr 11 23:28:52 ROUTER kernel: [21095.466833]  [<ffffffff8101e850>] bad_area_nosemaphore+0xe/0x10
Apr 11 23:28:52 ROUTER kernel: [21095.467064]  [<ffffffff8101eb32>] do_page_fault+0x114/0x24a
Apr 11 23:28:52 ROUTER kernel: [21095.467293]  [<ffffffff8125bc9f>] page_fault+0x1f/0x30
Apr 11 23:28:52 ROUTER kernel: [21095.467516]  [<ffffffff811e5877>] ? dev_queue_xmit+0x284/0x465
Apr 11 23:28:52 ROUTER kernel: [21095.467743]  [<ffffffffa01c12a9>] vlan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
Apr 11 23:28:52 ROUTER kernel: [21095.468139]  [<ffffffff811e540e>] dev_hard_start_xmit+0x232/0x304
Apr 11 23:28:52 ROUTER kernel: [21095.468366]  [<ffffffff811f6482>] sch_direct_xmit+0x5d/0x16b
Apr 11 23:28:52 ROUTER kernel: [21095.468591]  [<ffffffff811f664c>] __qdisc_run+0xbc/0xdc
Apr 11 23:28:52 ROUTER kernel: [21095.468814]  [<ffffffff811e2c89>] net_tx_action+0xc2/0x120
Apr 11 23:28:52 ROUTER kernel: [21095.469042]  [<ffffffff81039670>] __do_softirq+0x96/0x11a
Apr 11 23:28:52 ROUTER kernel: [21095.469267]  [<ffffffff810037cc>] call_softirq+0x1c/0x28
Apr 11 23:28:52 ROUTER kernel: [21095.469491]  [<ffffffff81005543>] do_softirq+0x33/0x68
Apr 11 23:28:52 ROUTER kernel: [21095.469714]  [<ffffffff81039407>] irq_exit+0x36/0x75
Apr 11 23:28:52 ROUTER kernel: [21095.469936]  [<ffffffff81016f63>] smp_apic_timer_interrupt+0x88/0x96
Apr 11 23:28:52 ROUTER kernel: [21095.470167]  [<ffffffff81003293>] apic_timer_interrupt+0x13/0x20

--Boundary-00=_XNjwLyIfshC+m2Z--
