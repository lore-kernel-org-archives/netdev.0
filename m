From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Tue, 09 Mar 2010 10:44:34 +0300
Message-ID: <119601268120674@webmail87.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward15.mail.yandex.net ([95.108.130.119]:35114 "EHLO
	forward15.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0CIHoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 02:44:38 -0500
Received: from webmail87.yandex.ru (webmail87.yandex.ru [77.88.47.161])
	by forward15.mail.yandex.net (Yandex) with ESMTP id 9612DC0F71
	for <netdev@vger.kernel.org>; Tue,  9 Mar 2010 10:44:36 +0300 (MSK)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail87.yandex.ru (Yandex) with ESMTP id 89793234014
	for <netdev@vger.kernel.org>; Tue,  9 Mar 2010 10:44:36 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Got this kernel panic tomorrow. This PC is rather heavy loaded router with BGP full view (> 300K routes).
We're using FIB_TRIE. Last time we got similar panic about 1 month ago. Please, let me know if you
need additional information to debug (e.g. objdump). Thanks!

Mar  9 10:08:55 bras-1 kernel: BUG: unable to handle kernel NULL pointer dereference at (null)
Mar  9 10:08:55 bras-1 kernel: IP: [<c11fa012>] fib_rules_lookup+0xa2/0xd0
Mar  9 10:08:55 bras-1 kernel: *pde = 00000000
Mar  9 10:08:55 bras-1 kernel: Thread overran stack, or stack corrupted
Mar  9 10:08:55 bras-1 kernel: Oops: 0000 [#1] SMP
Mar  9 10:08:55 bras-1 kernel: Modules linked in: ipt_NETFLOW iTCO_wdt xt_tcpudp iptable_filter iptable_nat ip_tables ipt_ISG x_tables ipmi_watchdog ipmi_msghandler nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack 8021q e1000 e1000e
Mar  9 10:08:55 bras-1 kernel:
Mar  9 10:08:55 bras-1 kernel: Pid: 0, comm: swapper Not tainted (2.6.32 #3)
Mar  9 10:08:55 bras-1 kernel: EIP: 0060:[<c11fa012>] EFLAGS: 00010246 CPU: 0
Mar  9 10:08:55 bras-1 kernel: EIP is at fib_rules_lookup+0xa2/0xd0
Mar  9 10:08:55 bras-1 kernel: EAX: 00000000 EBX: 00000000 ECX: f897a000 EDX: fffffff5
Mar  9 10:08:55 bras-1 kernel: ESI: c1305ce4 EDI: f729d420 EBP: c1305cb8 ESP: c1305ca0
Mar  9 10:08:55 bras-1 kernel:  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Mar  9 10:08:55 bras-1 kernel: Process swapper (pid: 0, ti=c1304000 task=c1319ba0 task.ti=c1304000)
Mar  9 10:08:55 bras-1 kernel: Stack:
Mar  9 10:08:55 bras-1 kernel:  c1305cc4 00000000 f729d464 c1305d20 c1305d20 f5719740 c1305cd4 c1242cfd
Mar  9 10:08:55 bras-1 kernel: <0> c1305cc4 00000000 c1305d20 00000000 00000000 c1305d3c c123b985 f5719740
Mar  9 10:08:55 bras-1 kernel: <0> c1305ce4 00000008 00000003 00000000 f090195e 1816640a 00000000 00000000
Mar  9 10:08:55 bras-1 kernel: Call Trace:
Mar  9 10:08:55 bras-1 kernel:  [<c1242cfd>] ? fib_lookup+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c123b985>] ? fib_validate_source+0x295/0x2f0
Mar  9 10:08:55 bras-1 kernel:  [<c120b981>] ? ip_route_input+0x8b1/0xf30
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d2f3>] ? ip_rcv_finish+0x243/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d66e>] ? ip_rcv+0x26e/0x2b0
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c11ec354>] ? netif_receive_skb+0x314/0x4d0
Mar  9 10:08:55 bras-1 kernel:  [<c1085182>] ? __slab_free+0x112/0x2d0
Mar  9 10:08:55 bras-1 kernel:  [<c11ec572>] ? process_backlog+0x62/0xa0
Mar  9 10:08:55 bras-1 kernel:  [<c11ecbbd>] ? net_rx_action+0x7d/0x100
Mar  9 10:08:55 bras-1 kernel:  [<c1031b35>] ? __do_softirq+0x85/0x110
Mar  9 10:08:55 bras-1 kernel:  [<c1055c56>] ? handle_IRQ_event+0x36/0xd0
Mar  9 10:08:55 bras-1 kernel:  [<c1058564>] ? move_native_irq+0x14/0x50
Mar  9 10:08:55 bras-1 kernel:  [<c1031bed>] ? do_softirq+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c1031d1d>] ? irq_exit+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c1004c6f>] ? do_IRQ+0x4f/0xc0
Mar  9 10:08:55 bras-1 kernel:  [<c1031d1d>] ? irq_exit+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c10162c7>] ? smp_apic_timer_interrupt+0x57/0x90
Mar  9 10:08:55 bras-1 kernel:  [<c1003429>] ? common_interrupt+0x29/0x30
Mar  9 10:08:55 bras-1 kernel:  [<c10090e6>] ? mwait_idle+0x56/0x60
Mar  9 10:08:55 bras-1 kernel:  [<c1001e44>] ? cpu_idle+0x54/0x70
Mar  9 10:08:55 bras-1 kernel:  [<c124d2d3>] ? rest_init+0x53/0x60
Mar  9 10:08:55 bras-1 kernel:  [<c1337895>] ? start_kernel+0x2b2/0x315
Mar  9 10:08:55 bras-1 kernel:  [<c13373ae>] ? unknown_bootoption+0x0/0x1e4
Mar  9 10:08:55 bras-1 kernel:  [<c133707e>] ? i386_start_kernel+0x7e/0xa8
Mar  9 10:08:55 bras-1 kernel: Code: bf 3c 03 8d b6 00 00 00 00 74 1e 8b 45 08 89 f2 8b 4d ec 89 04 24 89 d8 ff 57 1c 83 f8 f5 89 c2 75 27 8d b4 26 00 00 00 00 8b 1b <8b> 03 0f 18 00 90 3b 5d f0 0f 85 77 ff ff ff ba fd ff ff ff 83
Mar  9 10:08:55 bras-1 kernel: EIP: [<c11fa012>] fib_rules_lookup+0xa2/0xd0 SS:ESP 0068:c1305ca0
Mar  9 10:08:55 bras-1 kernel: CR2: 0000000000000000
Mar  9 10:08:55 bras-1 kernel: ---[ end trace 51f5fed99e546606 ]---
Mar  9 10:08:55 bras-1 kernel: Kernel panic - not syncing: Fatal exception in interrupt
Mar  9 10:08:55 bras-1 kernel: Pid: 0, comm: swapper Tainted: G      D    2.6.32 #3
Mar  9 10:08:55 bras-1 kernel: Call Trace:
Mar  9 10:08:55 bras-1 kernel:  [<c1252fb3>] ? printk+0x18/0x1d
Mar  9 10:08:55 bras-1 kernel:  [<c1252ee9>] panic+0x43/0xf5
Mar  9 10:08:55 bras-1 kernel:  [<c1006739>] oops_end+0xb9/0xc0
Mar  9 10:08:55 bras-1 kernel:  [<c101bcf6>] no_context+0xb6/0x150
Mar  9 10:08:55 bras-1 kernel:  [<f8058576>] ? e1000_set_itr+0xb6/0x170 [e1000e]
Mar  9 10:08:55 bras-1 kernel:  [<c101bddf>] __bad_area_nosemaphore+0x4f/0x180
Mar  9 10:08:55 bras-1 kernel:  [<c1055c56>] ? handle_IRQ_event+0x36/0xd0
Mar  9 10:08:55 bras-1 kernel:  [<c1058564>] ? move_native_irq+0x14/0x50
Mar  9 10:08:55 bras-1 kernel:  [<c105758d>] ? handle_edge_irq+0x6d/0x140
Mar  9 10:08:55 bras-1 kernel:  [<c100569a>] ? handle_irq+0x1a/0x30
Mar  9 10:08:55 bras-1 kernel:  [<c1086195>] ? __slab_alloc+0x315/0x560
Mar  9 10:08:55 bras-1 kernel:  [<c1035fc5>] ? lock_timer_base+0x25/0x50
Mar  9 10:08:55 bras-1 kernel:  [<c101bf22>] bad_area_nosemaphore+0x12/0x20
Mar  9 10:08:55 bras-1 kernel:  [<c101c30c>] do_page_fault+0x25c/0x300
Mar  9 10:08:55 bras-1 kernel:  [<c1241cf9>] ? check_leaf+0x59/0x80
Mar  9 10:08:55 bras-1 kernel:  [<c101c0b0>] ? do_page_fault+0x0/0x300
Mar  9 10:08:55 bras-1 kernel:  [<c125570e>] error_code+0x66/0x6c
Mar  9 10:08:55 bras-1 kernel:  [<c101c0b0>] ? do_page_fault+0x0/0x300
Mar  9 10:08:55 bras-1 kernel:  [<c11fa012>] ? fib_rules_lookup+0xa2/0xd0
Mar  9 10:08:55 bras-1 kernel:  [<c1242cfd>] fib_lookup+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c123b985>] fib_validate_source+0x295/0x2f0
Mar  9 10:08:55 bras-1 kernel:  [<c120b981>] ip_route_input+0x8b1/0xf30
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d2f3>] ip_rcv_finish+0x243/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c120d66e>] ip_rcv+0x26e/0x2b0
Mar  9 10:08:55 bras-1 kernel:  [<c120d0b0>] ? ip_rcv_finish+0x0/0x350
Mar  9 10:08:55 bras-1 kernel:  [<c11ec354>] netif_receive_skb+0x314/0x4d0
Mar  9 10:08:55 bras-1 kernel:  [<c1085182>] ? __slab_free+0x112/0x2d0
Mar  9 10:08:55 bras-1 kernel:  [<c11ec572>] process_backlog+0x62/0xa0
Mar  9 10:08:55 bras-1 kernel:  [<c11ecbbd>] net_rx_action+0x7d/0x100
Mar  9 10:08:55 bras-1 kernel:  [<c1031b35>] __do_softirq+0x85/0x110
Mar  9 10:08:55 bras-1 kernel:  [<c1055c56>] ? handle_IRQ_event+0x36/0xd0
Mar  9 10:08:55 bras-1 kernel:  [<c1058564>] ? move_native_irq+0x14/0x50
Mar  9 10:08:55 bras-1 kernel:  [<c1031bed>] do_softirq+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c1031d1d>] irq_exit+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c1004c6f>] do_IRQ+0x4f/0xc0
Mar  9 10:08:55 bras-1 kernel:  [<c1031d1d>] ? irq_exit+0x2d/0x40
Mar  9 10:08:55 bras-1 kernel:  [<c10162c7>] ? smp_apic_timer_interrupt+0x57/0x90
Mar  9 10:08:55 bras-1 kernel:  [<c1003429>] common_interrupt+0x29/0x30
Mar  9 10:08:55 bras-1 kernel:  [<c10090e6>] ? mwait_idle+0x56/0x60
Mar  9 10:08:55 bras-1 kernel:  [<c1001e44>] cpu_idle+0x54/0x70
Mar  9 10:08:55 bras-1 kernel:  [<c124d2d3>] rest_init+0x53/0x60
Mar  9 10:08:55 bras-1 kernel:  [<c1337895>] start_kernel+0x2b2/0x315
Mar  9 10:08:55 bras-1 kernel:  [<c13373ae>] ? unknown_bootoption+0x0/0x1e4
Mar  9 10:08:55 bras-1 kernel:  [<c133707e>] i386_start_kernel+0x7e/0xa8


-- 
wbr, Oleg.
