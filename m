From: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>
Subject: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 15:51:57 +0200
Message-ID: <577FAFFD.2020306@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:64977 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911AbcGHNwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 09:52:02 -0400
Received: from t44.localdomain ([78.54.169.77]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0MBIAz-1bBIug11wT-00AEmI for
 <netdev@vger.kernel.org>; Fri, 08 Jul 2016 15:51:59 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. A DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv6 at that system.

The IPv6 monitoring from my ISP told my that the to be monitored services (80, 443, 52222) weren't reachable any longer at ipv6 (at ipv4 there was no issue). Restarting the NIC brought back green lights for the services at the ipv6 ports too.

The log gave just :

Jul  7 15:36:28 ms-magpie kernel: ------------[ cut here ]------------
Jul  7 15:36:28 ms-magpie kernel: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:306 dev_watchdog+0x243/0x260
Jul  7 15:36:28 ms-magpie kernel: NETDEV WATCHDOG: enp3s0 (r8169): transmit queue 0 timed out
Jul  7 15:36:28 ms-magpie kernel: Modules linked in: af_packet nf_log_ipv6 xt_limit nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_log_ipv4 nf_log_common xt_LOG xt_multiport nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter ip_tables i2c_i801 i2c_core tpm_tis tpm thermal processor atkbd button x86_pkg_temp_thermal
Jul  7 15:36:28 ms-magpie kernel: CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6.3-hardened #1
Jul  7 15:36:28 ms-magpie kernel: Hardware name: System manufacturer System Product Name/P8H77-M PRO, BIOS 9002 05/30/2014
Jul  7 15:36:28 ms-magpie kernel:  0000000000000000 ffff88041fa03db8 ffffffffbb3d655b 0000000000000007
Jul  7 15:36:28 ms-magpie kernel:  ffff88041fa03e08 0000000000000000 ffff88041fa03df8 ffffffffbb07f7dd
Jul  7 15:36:28 ms-magpie kernel:  000001321fa11640 0000000000000000 ffff88040d354080 0000000000000000
Jul  7 15:36:28 ms-magpie kernel: Call Trace:
Jul  7 15:36:28 ms-magpie kernel:  <IRQ>  [<ffffffffbb3d655b>] dump_stack+0x4e/0x83
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb07f7dd>] __warn+0xcd/0x100
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb07f85a>] warn_slowpath_fmt+0x4a/0x70
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb59d633>] dev_watchdog+0x243/0x260
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb59d3f0>] ? dev_deactivate_queue+0x80/0x80
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb0db7b3>] call_timer_fn.isra.24+0x33/0xa0
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb59d3f0>] ? dev_deactivate_queue+0x80/0x80
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb0dba52>] run_timer_softirq+0x232/0x3c0
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb0eb188>] ? clockevents_program_event+0x98/0x160
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb08444d>] __do_softirq+0xfd/0x210
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb0846d0>] irq_exit+0x80/0xa0
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb03e9a4>] smp_apic_timer_interrupt+0x54/0x80
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb67805b>] apic_timer_interrupt+0x8b/0x90
Jul  7 15:36:28 ms-magpie kernel:  <EOI>  [<ffffffffbb53fa75>] ? cpuidle_enter_state+0x185/0x240
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb53fb82>] cpuidle_enter+0x12/0x30
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb0c0530>] cpu_startup_entry+0x1d0/0x220
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe13120>] ? early_idt_handler_array+0x120/0x120
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbb6701f5>] rest_init+0x6d/0x88
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe14c6c>] start_kernel+0x64c/0x692
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe13120>] ? early_idt_handler_array+0x120/0x120
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe7c7ff>] ? memblock_reserve+0x76/0x9c
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe136d7>] x86_64_start_reservations+0x53/0x75
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe136d7>] ? x86_64_start_reservations+0x53/0x75
Jul  7 15:36:28 ms-magpie kernel:  [<ffffffffbbe1382d>] x86_64_start_kernel+0x134/0x16f
Jul  7 15:36:28 ms-magpie kernel: ---[ end trace b779686b40691d67 ]---
Jul  7 15:36:28 ms-magpie kernel: r8169 0000:03:00.0 enp3s0: link up 

I did not try to restart just the firewall or so.
WHat let me wonder were why just the IPv6 had a problem, whereas ipV4 worked smoothly.

-- 
Toralf
PGP: C4EACDDE 0076E94E, OTR: 420E74C8 30246EE7
