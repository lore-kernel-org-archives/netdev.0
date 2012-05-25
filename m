From: "kendo" <kendo999@163.com>
Subject: skb_release_data oops
Date: Fri, 25 May 2012 22:19:34 +0800
Message-ID: <4FBF9876.032A7B.32344@m12-16.163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:50243 "EHLO m12-16.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779Ab2EYOed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2012 10:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I use the Linux kernel 2.6..38.8,found a bug when free skb,This failure may occur because what was it? Can you give some suggestions, thanks!!!!

Best reguards.

---------------------------------------------------------------

May 25 19:30:54 AnShion <9> klogd: [164619.378640] BUG: unable to handle kernel paging request at 000095a3
May 25 19:30:54 AnShion <9> klogd: [164619.454609] IP: [<c01c2353>] put_page+0x3/0x40
May 25 19:30:54 AnShion <12> klogd: [164619.508726] *pde = 00000000 
May 25 19:30:54 AnShion <8> klogd: [164619.544185] Oops: 0000 [#1] SMP 
May 25 19:30:54 AnShion <8> klogd: [164619.583891] last sysfs file: /sys/devices/virtual/net/tunl_FJ/uevent
May 25 19:30:54 AnShion <12> klogd: [164619.660716] Modules linked in: dpi_engine ipmi_watchdog nf_connmark ip_set_hash_netiface ip_set_hash_net ip_set_hash_ip xt_set ip_set xt_hashrate xt_dpi xt_pcc xt_nth xt_random xt_nflog xt_replace igb e1000e [last unloaded: dpi_engine]
May 25 19:30:54 AnShion <12> klogd: [164619.912644] 
May 25 19:30:54 AnShion <12> klogd: [164619.931412] Pid: 0, comm: kworker/0:1 Not tainted 2.6.38.8 #347 To be filled by O.E.M. To be filled by O.E.M./P8B-X series
May 25 19:30:54 AnShion <12> klogd: [164620.064736] EIP: 0060:[<c01c2353>] EFLAGS: 00010202 CPU: 5
May 25 19:30:54 AnShion <12> klogd: [164620.131193] EIP is at put_page+0x3/0x40
May 25 19:30:54 AnShion <12> klogd: [164620.177950] EAX: 000095a3 EBX: 00000001 ECX: 00000000 EDX: 000095a3
May 25 19:30:54 AnShion <12> klogd: [164620.253737] ESI: dbda30c0 EDI: dbda30c0 EBP: f3cffd4c ESP: f3cffd3c
May 25 19:30:54 AnShion <12> klogd: [164620.329522]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
May 25 19:30:54 AnShion <8> klogd: [164620.394942] Process kworker/0:1 (pid: 0, ti=f3cfe000 task=f3cd4b00 task.ti=f3ce6000)
May 25 19:30:54 AnShion <8> klogd: [164620.488351] Stack:
May 25 19:30:54 AnShion <12> klogd: [164620.513337]  f3cffd4c c069dbe4 dbda30c0 00000001 f3cffd58 c069d7a2 00000000 f3cffd70
May 25 19:30:54 AnShion <12> klogd: [164620.607577]  c069d8ea c06dba0f 00000000 00000001 dbda30c0 f3cffda4 c06dba0f f30e0000
May 25 19:30:54 AnShion <12> klogd: [164620.701819]  00000000 f3cffd94 c0700ba0 80000000 00000002 c0b407a8 f34d3240 dbda30c0
May 25 19:30:54 AnShion <8> klogd: [164620.796059] Call Trace:
May 25 19:30:54 AnShion <12> klogd: [164620.826232]  [<c069dbe4>] ? skb_release_data+0x84/0xa0
May 25 19:30:54 AnShion <12> klogd: [164620.888539]  [<c069d7a2>] __kfree_skb+0x12/0x90
May 25 19:30:54 AnShion <12> klogd: [164620.943589]  [<c069d8ea>] kfree_skb+0x5a/0x70
May 25 19:30:54 AnShion <12> klogd: [164620.996568]  [<c06dba0f>] ? nf_hook_slow+0xcf/0xf0
May 25 19:30:54 AnShion <12> klogd: [164621.054730]  [<c06dba0f>] nf_hook_slow+0xcf/0xf0
May 25 19:30:54 AnShion <12> klogd: [164621.110820]  [<c0700ba0>] ? ip_local_deliver_finish+0x0/0x260
May 25 19:30:54 AnShion <12> klogd: [164621.180385]  [<c0700e52>] ip_local_deliver+0x52/0xa0
May 25 19:30:54 AnShion <12> klogd: [164621.240620]  [<c0700ba0>] ? ip_local_deliver_finish+0x0/0x260
May 25 19:30:54 AnShion <12> klogd: [164621.310186]  [<c0700701>] ip_rcv_finish+0x241/0x3c0
May 25 19:30:54 AnShion <12> klogd: [164621.369383]  [<c0700b26>] ip_rcv+0x2a6/0x320
May 25 19:30:54 AnShion <12> klogd: [164621.421324]  [<c07004c0>] ? ip_rcv_finish+0x0/0x3c0
May 25 19:30:54 AnShion <12> klogd: [164621.480523]  [<c06a9468>] __netif_receive_skb+0x258/0x520
May 25 19:30:54 AnShion <12> klogd: [164621.545942]  [<c01e8cc0>] ? add_partial+0x40/0x70
May 25 19:30:54 AnShion <12> klogd: [164621.603068]  [<c06a9863>] netif_receive_skb+0x23/0x50
May 25 19:30:54 AnShion <12> klogd: [164621.664340]  [<c06a9987>] napi_skb_finish+0x37/0x50
May 25 19:30:54 AnShion <12> klogd: [164621.723537]  [<c06a9fcb>] napi_gro_receive+0xdb/0xf0
May 25 19:30:54 AnShion <12> klogd: [164621.783774]  [<c0192a4f>] ? irq_to_desc+0xf/0x20
May 25 19:30:54 AnShion <12> klogd: [164621.839860]  [<c0105606>] ? handle_irq+0x16/0x90
May 25 19:30:54 AnShion <12> klogd: [164621.895954]  [<f81d679c>] igb_poll+0x5fc/0xef0 [igb]
May 25 19:30:54 AnShion <12> klogd: [164621.956184]  [<c0104bc5>] ? do_IRQ+0x45/0xb0
May 25 19:30:54 AnShion <12> klogd: [164622.008128]  [<c06a9dfa>] net_rx_action+0xaa/0x1a0
May 25 19:30:54 AnShion <12> klogd: [164622.066288]  [<c014bfa1>] __do_softirq+0xb1/0x190
May 25 19:30:54 AnShion <12> klogd: [164622.123411]  [<c014bef0>] ? __do_softirq+0x0/0x190
May 25 19:30:54 AnShion <8> klogd: [164622.181572]  <IRQ> 
May 25 19:30:54 AnShion <12> klogd: [164622.207700]  [<c014be6d>] ? irq_exit+0x5d/0x80
May 25 19:30:54 AnShion <12> klogd: [164622.261716]  [<c011c9a6>] ? smp_apic_timer_interrupt+0x56/0x90
May 25 19:30:54 AnShion <12> klogd: [164622.332317]  [<c0819c61>] ? apic_timer_interrupt+0x31/0x38
May 25 19:30:54 AnShion <12> klogd: [164622.398773]  [<c0124b05>] ? native_safe_halt+0x5/0x10
May 25 19:30:54 AnShion <12> klogd: [164622.460046]  [<c040e345>] ? acpi_idle_do_entry+0x33/0x54
May 25 19:30:54 AnShion <12> klogd: [164622.524426]  [<c040e3bd>] ? acpi_idle_enter_c1+0x57/0x95
May 25 19:30:54 AnShion <12> klogd: [164622.588809]  [<c0674089>] ? cpuidle_idle_call+0xd9/0x1c0
May 25 19:30:54 AnShion <12> klogd: [164622.653190]  [<c010214a>] ? cpu_idle+0x8a/0xc0
May 25 19:30:54 AnShion <12> klogd: [164622.707206]  [<c0813699>] ? start_secondary+0x1a1/0x1e8
May 25 19:30:54 AnShion <8> klogd: [164622.770550] Code: 04 f0 ff 0e 0f 94 c0 84 c0 74 d4 89 f8 e8 96 fe ff ff eb cb 0f ae e8 89 f6 8b 03 eb de 8d 74 26 00 8d bc 27 00 00 00 00 55 89 c2 <66> f7 00 00 c0 89 e5 75 1d 8b 40 04 f0 ff 4a 04 0f 94 c0 84 c0 
