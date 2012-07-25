From: "kendo" <kendo999@163.com>
Subject: skb_ts_get_next_block panic
Date: Wed, 25 Jul 2012 17:52:52 +0800
Message-ID: <500FC1EE.CCD72C.08694@m50-133.163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:34849 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500Ab2GYJww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 05:52:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My server every few days, or more than 10 days will restart,Probably because of the use of the Netfilter xt_string module,
But it seems not xt_string bug, but because of the bogus SKB buffer:


Jul 25 15:13:18 AnShion <9> klogd: [ 5413.055010] BUG: unable to handle kernel paging request at 2f3c0a3e
Jul 25 15:13:18 AnShion <9> klogd: [ 5413.130063] IP: [<c012c928>] kmap_atomic_prot+0x18/0xf0
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.192555] *pde = 00000000 
Jul 25 15:13:18 AnShion <8> klogd: [ 5413.227015] Oops: 0000 [#1] SMP 
Jul 25 15:13:18 AnShion <8> klogd: [ 5413.265738] last sysfs file: /sys/devices/virtual/net/bond0/bonding/slaves
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.347824] Modules linked in: igb e1000e
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.578307] 
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.596059] Pid: 0, comm: kworker/0:0 Tainted: G   M        2.6.38.8 #412 Intel Corporation S1200BTL/S1200BTL
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.715011] EIP: 0060:[<c012c928>] EFLAGS: 00010202 CPU: 1
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.780491] EIP is at kmap_atomic_prot+0x18/0xf0
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.835595] EAX: f48b2000 EBX: 00000163 ECX: 2f3c0a3e EDX: 00000163
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.910417] ESI: f1f95e40 EDI: 00000000 EBP: f48b3bc4 ESP: f48b3bb4
Jul 25 15:13:18 AnShion <12> klogd: [ 5413.985237]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Jul 25 15:13:18 AnShion <8> klogd: [ 5414.049680] Process kworker/0:0 (pid: 0, ti=f48b2000 task=f48a8000 task.ti=f489e000)
Jul 25 15:13:18 AnShion <8> klogd: [ 5414.142138] Stack:
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.166117]  00000001 f48b3c6c f1f95e40 00000000 f48b3bcc c012ca0e f48b3bf4 c069ecde
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.259457]  00000004 eb636a80 f48b3c28 000005f8 00007365 00000000 f48b3c68 f1f9584e
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.352797]  f48b3bfc c069ed1e f48b3c38 c038c2da f48b3c68 f48b3c68 f11c9d20 f11c9d30
Jul 25 15:13:18 AnShion <8> klogd: [ 5414.446140] Call Trace:
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.475306]  [<c012ca0e>] __kmap_atomic+0xe/0x10
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.530416]  [<c069ecde>] skb_seq_read+0x19e/0x1d0
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.587597]  [<c069ed1e>] skb_ts_get_next_block+0xe/0x10
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.651007]  [<c038c2da>] kmp_find+0x3a/0x150
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.703003]  [<c069c842>] skb_find_text+0x62/0x90
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.759145]  [<c06faa3b>] string_mt+0x5b/0x90
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.811140]  [<c074a6b5>] ipt_do_table+0x295/0x3b0
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.868323]  [<c074b020>] iptable_mangle_hook+0x40/0x150
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.931729]  [<c06db8e7>] nf_iterate+0x67/0x90
Jul 25 15:13:18 AnShion <12> klogd: [ 5414.984760]  [<c0702040>] ? ip_forward_finish+0x0/0x60
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.046089]  [<c06dba90>] nf_hook_slow+0xa0/0xf0
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.101195]  [<c0702040>] ? ip_forward_finish+0x0/0x60
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.162525]  [<c070227d>] ip_forward+0x1dd/0x430
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.217631]  [<c0702040>] ? ip_forward_finish+0x0/0x60
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.278962]  [<c0700941>] ip_rcv_finish+0x241/0x3c0
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.337181]  [<c0700d66>] ip_rcv+0x2a6/0x320
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.388142]  [<c0700700>] ? ip_rcv_finish+0x0/0x3c0
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.446365]  [<c06a9518>] __netif_receive_skb+0x258/0x520
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.510811]  [<c01e8d10>] ? add_partial+0x40/0x70
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.566956]  [<c06a9913>] netif_receive_skb+0x23/0x50
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.627248]  [<c06a9a37>] napi_skb_finish+0x37/0x50
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.685469]  [<c06aa07b>] napi_gro_receive+0xdb/0xf0
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.744722]  [<c069d8bf>] ? consume_skb+0x4f/0x70
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.800881]  [<f815c79c>] igb_poll+0x5fc/0xef0 [igb]
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.860137]  [<c0819538>] ? _raw_spin_lock+0x8/0x10
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.918359]  [<c01e8d10>] ? add_partial+0x40/0x70
Jul 25 15:13:18 AnShion <12> klogd: [ 5415.974502]  [<c01eb8e7>] ? __slab_free+0xc7/0xd0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.030645]  [<c01eb8e7>] ? __slab_free+0xc7/0xd0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.086787]  [<c0819538>] ? _raw_spin_lock+0x8/0x10
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.145008]  [<c0125708>] ? default_spin_lock_flags+0x8/0x10
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.212568]  [<c0819568>] ? _raw_spin_lock_irqsave+0x28/0x40
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.280124]  [<c06a9eaa>] net_rx_action+0xaa/0x1a0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.337306]  [<c014bff1>] __do_softirq+0xb1/0x190
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.393445]  [<c014bf40>] ? __do_softirq+0x0/0x190
Jul 25 15:13:18 AnShion <8> klogd: [ 5416.450626]  <IRQ> 
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.475750]  [<c014bebd>] ? irq_exit+0x5d/0x80
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.528782]  [<c0104bc5>] ? do_IRQ+0x45/0xb0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.579736]  [<c014bed5>] ? irq_exit+0x75/0x80
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.632767]  [<c011c9f6>] ? smp_apic_timer_interrupt+0x56/0x90
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.702403]  [<c01036f0>] ? common_interrupt+0x30/0x38
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.763733]  [<c040e42e>] ? acpi_idle_enter_c1+0x78/0x95
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.827142]  [<c06740d9>] ? cpuidle_idle_call+0xd9/0x1c0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.890545]  [<c010214a>] ? cpu_idle+0x8a/0xc0
Jul 25 15:13:18 AnShion <12> klogd: [ 5416.943574]  [<c0813979>] ? start_secondary+0x1a1/0x1e8
Jul 25 15:13:18 AnShion <8> klogd: [ 5417.005943] Code: 74 26 00 8b 15 8c a4 d5 c1 55 89 e5 e8 e2 f8 ff ff 5d c3 55 89 c1 89 e5 57 56 53 89 d3 83 ec 04 89 e0 25 00 e0 ff ff 83 40 14 01 <8b> 01 c1 e8 1e 69 c0 80 03 00 00 05 00 79 b3 c0 2b 80 4c 03 00
