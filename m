From: Dave Jones <davej@redhat.com>
Subject: velocity driver unmaps incorrect size.
Date: Sun, 21 Jun 2009 13:37:45 -0400
Message-ID: <20090621173745.GC26093@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48782 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702AbZFURhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 13:37:43 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n5LHblD6021818
	for <netdev@vger.kernel.org>; Sun, 21 Jun 2009 13:37:47 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n5LHbkOp026031
	for <netdev@vger.kernel.org>; Sun, 21 Jun 2009 13:37:46 -0400
Received: from gelk.kernelslacker.org (vpn-10-36.bos.redhat.com [10.16.10.36])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n5LHbkLa026486
	for <netdev@vger.kernel.org>; Sun, 21 Jun 2009 13:37:46 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n5LHbjUm026598
	for <netdev@vger.kernel.org>; Sun, 21 Jun 2009 13:37:45 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n5LHbjYs026597
	for netdev@vger.kernel.org; Sun, 21 Jun 2009 13:37:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seen during boot when the interface comes up..

	Dave

------------[ cut here ]------------
WARNING: at lib/dma-debug.c:505 check_unmap+0x1f8/0x4d4()
Hardware name:  
via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x000000001a456242] [map size=90 bytes] [unmap size=1 bytes]
Modules linked in: nf_conntrack_netbios_ns ip6t_REJECT ip6table_filter ip6_tables ipv6 cpufreq_ondemand acpi_cpufreq serio_raw pcspkr i2c_viapro 3c59x mii i2c_core usb_storage firewire_ohci via_velocity firewire_core crc_ccitt crc_itu_t ata_generic pata_acpi pata_via ext2 [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper Tainted: G        W  2.6.30-6.fc12.i686.PAE #1
Call Trace:
 [<c04434a2>] warn_slowpath_common+0x75/0x9d
 [<c05e1029>] ? check_unmap+0x1f8/0x4d4
 [<c0443533>] warn_slowpath_fmt+0x34/0x48
 [<c05e1029>] check_unmap+0x1f8/0x4d4
 [<c05e15a8>] debug_dma_unmap_page+0x71/0x8a
 [<dcf88829>] pci_unmap_single+0x74/0x90 [via_velocity]
 [<dcf88922>] velocity_tx_srv+0xdd/0x1a0 [via_velocity]
 [<dcf89e76>] velocity_intr+0x52f/0x5a1 [via_velocity]
 [<dd0c60d6>] ? ip6_output_finish+0x0/0x104 [ipv6]
 [<dd0c6172>] ? ip6_output_finish+0x9c/0x104 [ipv6]
 [<c0494938>] ? handle_fasteoi_irq+0x27/0xcf
 [<c046c8fb>] ? print_lock_contention_bug+0x1f/0xd1
 [<c0494938>] ? handle_fasteoi_irq+0x27/0xcf
 [<c0494938>] ? handle_fasteoi_irq+0x27/0xcf
 [<c0492c06>] handle_IRQ_event+0x56/0x112
 [<c0492c06>] ? handle_IRQ_event+0x56/0x112
 [<c0494997>] handle_fasteoi_irq+0x86/0xcf
 [<c040c350>] handle_irq+0x50/0x6c
 [<c040bc4f>] do_IRQ+0x52/0xa4
 [<c040a715>] common_interrupt+0x35/0x3c
 [<c0757f3f>] ? netif_receive_skb+0x1b9/0x3ca
 [<c07581de>] process_backlog+0x8e/0xcf
 [<c0756262>] net_rx_action+0xa7/0x1b9
 [<c0449064>] __do_softirq+0xaa/0x173
 [<c0449176>] do_softirq+0x49/0x7f
 [<c04492ca>] irq_exit+0x48/0x87
 [<c040bc7c>] do_IRQ+0x7f/0xa4
 [<c040a715>] common_interrupt+0x35/0x3c
 [<c046b2ff>] ? trace_hardirqs_on+0x19/0x2c
 [<c06437a7>] ? acpi_idle_enter_simple+0x11d/0x161
 [<c07316ff>] cpuidle_idle_call+0x73/0xbc
 [<c0409091>] cpu_idle+0xac/0xcb
 [<c07e024a>] rest_init+0x66/0x79
 [<c0a38acd>] start_kernel+0x36b/0x383
 [<c0a38090>] i386_start_kernel+0x7f/0x98
---[ end trace 6db0eec1553c1cdc ]---
Mapped at:
 [<c05e196f>] debug_dma_map_page+0x85/0x168
 [<dcf891fb>] pci_map_single+0x8e/0xab [via_velocity]
 [<dcf8979a>] velocity_xmit+0xae/0x1c2 [via_velocity]
 [<c0758d2d>] dev_hard_start_xmit+0x233/0x2a5
 [<c076a13e>] __qdisc_run+0xd0/0x1c5


