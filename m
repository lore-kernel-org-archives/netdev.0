From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: 2.6.38.2, kernel panic, probably related to framentation handling
Date: Wed, 04 May 2011 14:36:09 +0300
Message-ID: <f2c5863250c7a5fb11a189759bd736cf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:34858 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751689Ab1EDLgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 07:36:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Seems once more, during trying to bring another type of tunnel (this 
 time userspace, working over tun device) and switching routes got one 
 more kernel panic
 It is vanilla kernel, but many source routing rules, firewall, QoS and 
 etc, including this tunnel now also. Here is what i got on netconsole:
 Any other info required?

 netc [1192230.881002]
 netc [1192230.881002] Pid: 0, comm: kworker/0:1 Not tainted 
 2.6.38.2-devel2 #2
 netc
 netc Dell Inc. PowerEdge 1950
 netc /
 netc 0D8635
 netc
 netc [1192230.881002] EIP: 0060:[<c03c0847>] EFLAGS: 00010206 CPU: 3
 netc [1192230.881002] EIP is at icmp_send+0x39/0x396
 netc [1192230.881002] EAX: 121a8aca EBX: d1d28600 ECX: 00000001 EDX: 
 c63b6600
 netc [1192230.881002] ESI: d1d28600 EDI: c33438a0 EBP: f2a41840 ESP: 
 f64b5e8c
 netc [1192230.881002]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 netc [1192230.881002] Process kworker/0:1 (pid: 0, ti=f64b4000 
 task=f64a4a80 task.ti=f64b0000)
 netc [1192230.881002] Stack:
 netc [1192230.881002]  c0113ea1
 netc 00000001
 netc 0000000b
 netc 00000000
 netc efed48c7
 netc 0000114a
 netc 00000000
 netc f6b01fa8
 netc
 netc [1192230.881002]  e21be5e1
 netc c0148bf3
 netc e217d5d0
 netc 00043c53
 netc 00000001
 netc f6b02d14
 netc e21be5e1
 netc 00043c53
 netc
 netc [1192230.881002]  e21be5e1
 netc 00043c53
 netc c0148d2e
 netc 00000000
 netc 00000058
 netc 00000000
 netc c0140779
 netc ce9f5aa9
 netc
 netc [1192230.881002] Call Trace:
 netc [1192230.881002]  [<c0113ea1>] ? lapic_next_event+0x13/0x16
 netc [1192230.881002]  [<c0148bf3>] ? tick_dev_program_event+0x26/0x116
 netc [1192230.881002]  [<c0148d2e>] ? tick_program_event+0x1b/0x1f
 netc [1192230.881002]  [<c0140779>] ? hrtimer_interrupt+0x10c/0x1ca
 netc [1192230.881002]  [<c0140e49>] ? hrtimer_start+0x20/0x25
 netc [1192230.881002]  [<c012f18e>] ? irq_exit+0x36/0x59
 netc [1192230.881002]  [<c0114933>] ? 
 smp_apic_timer_interrupt+0x71/0x7d
 netc [1192230.881002]  [<c03f2752>] ? apic_timer_interrupt+0x2a/0x30
 netc [1192230.881002]  [<c039f527>] ? ip_expire+0xf2/0x11b
 netc [1192230.881002]  [<c039f435>] ? ip_expire+0x0/0x11b
 netc [1192230.881002]  [<c0133421>] ? run_timer_softirq+0x140/0x1c7
 netc [1192230.881002]  [<c012f28f>] ? __do_softirq+0x6b/0x104
 netc [1192230.881002]  [<c012f224>] ? __do_softirq+0x0/0x104
 netc [1192230.881002]  [<c012f224>] ? __do_softirq+0x0/0x104
 netc [1192230.881002]  <IRQ>
 netc
 netc [1192230.881002]  [<c012f17e>] ? irq_exit+0x26/0x59
 netc [1192230.881002]  [<c0103b3d>] ? do_IRQ+0x81/0x95
 netc [1192230.881002]  [<c0114933>] ? 
 smp_apic_timer_interrupt+0x71/0x7d
 netc [1192230.881002]  [<c0102ca9>] ? common_interrupt+0x29/0x30
 netc [1192230.881002]  [<c010807a>] ? mwait_idle+0x51/0x56
 netc [1192230.881002]  [<c0101a97>] ? cpu_idle+0x41/0x5e
 netc [1192230.881002] Code:
 netc 08
 netc 89
 netc c6
 netc 89
 netc 4c
 netc 24
 netc 04
 netc 8b
 netc 40
 netc 48
 netc 89                                                                 
                       netc c2
 netc 83
 netc e2
 netc fe
 netc 0f
 netc 84
 netc 66
 netc 03
 netc 00
 netc 00
 netc 89
 netc 94
 netc 24
 netc c0
 netc 00
 netc 00
 netc 00
 netc 8b
 netc 42
 netc 0c
 netc 8b
 netc be
 netc 94
 netc 00
 netc 00
 netc 00
 netc 3b
 netc be
 netc a4
 netc 00
 netc 00
 netc 00
 May  4 11:17:12 217.151.224.119 unparseable log message: "<8b> "
 netc 80
 netc 80
 netc 02
 netc 00
 netc 00
 netc 89
 netc 44
 netc 24
 netc 10
 netc 0f
 netc 82
 netc 40
 netc 03
 netc 00
 netc 00
 netc 8d
 netc 47
 netc 14
 netc 39
 netc 86
 netc
 netc [1192230.881002] EIP: [<c03c0847>]
 netc icmp_send+0x39/0x396
 netc SS:ESP 0068:f64b5e8c
 netc [1192230.881002] CR2: 00000000121a8d4a
 netc [1192230.910072] ---[ end trace 42aae79d7fb08725 ]---
 netc [1192230.910354] Kernel panic - not syncing: Fatal exception in 
 interrupt
 netc [1192230.911062] Rebooting in 5 seconds..

