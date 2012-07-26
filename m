From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: r8169, 3.5.0, does't work at all
Date: Thu, 26 Jul 2012 14:58:55 +0300
Message-ID: <88f2e8e7f795239ec4bc759dcda61665@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:55375 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab2GZL67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 07:58:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just pushed new kernel to test cluster and got this:

[    1.604470] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.604709] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
[    1.605211] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xf8604000, 
00:08:54:57:7a:54, XID 18000000 IRQ 43
[    1.605364] r8169 0000:02:00.0: eth0: jumbo features [frames: 4080 
bytes, tx checksumming: ko]
[    1.605549] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.605780] r8169 0000:03:00.0: irq 44 for MSI/MSI-X
[    1.606212] r8169 0000:03:00.0: eth1: RTL8168b/8111b at 0xf8606000, 
00:08:54:57:7a:33, XID 18000000 IRQ 44
[    1.606366] r8169 0000:03:00.0: eth1: jumbo features [frames: 4080 
bytes, tx checksumming: ko]
....
[   20.406090]     input device check on
[   20.406177]     Actions configured
[   21.526836] r8169 0000:02:00.0: eth0: link up
[   28.038386] ------------[ cut here ]------------
[   28.038438] WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0xd6/0x12a()
[   28.038489] Hardware name:
[   28.038534] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed 
out
[   28.038584] Modules linked in: cls_flow cls_u32 em_meta cls_basic 
xt_dscp ts_bm xt_string xt_hl ifb cls_fw sch_tbf sch_htb act_ipt 
act_mirred ipt_REDIRECT ipt_REJECT xt_TCPMSS xt_DSCP xt_mark 
iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack 
nf_defrag_ipv4 iptable_filter 8021q garp stp llc loop usb_storage mei 
lpc_ich mfd_core ahci libahci libata sr_mod cdrom tulip r8169 sky2 
via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 libphy 8139too 
e1000 e100 usbhid ohci_hcd uhci_hcd ehci_hcd usbcore usb_common [last 
unloaded: usb_storage]
[   28.038616] Pid: 4, comm: kworker/0:0 Not tainted 3.5.0-build-0063 
#4
[   28.038617] Call Trace:
[   28.038620]  [<c0127962>] warn_slowpath_common+0x77/0x8c
[   28.038623]  [<c02f507e>] ? dev_watchdog+0xd6/0x12a
[   28.038625]  [<c02f507e>] ? dev_watchdog+0xd6/0x12a
[   28.038628]  [<c01279f3>] warn_slowpath_fmt+0x2e/0x30
[   28.038630]  [<c02f507e>] dev_watchdog+0xd6/0x12a
[   28.038633]  [<c0131c45>] run_timer_softirq+0x1ab/0x254
[   28.038635]  [<c0131bc9>] ? run_timer_softirq+0x12f/0x254
[   28.038638]  [<c015d181>] ? trace_hardirqs_on_caller+0xf5/0x13f
[   28.038640]  [<c02f4fa8>] ? netif_tx_unlock+0x41/0x41
[   28.038643]  [<c012d38e>] __do_softirq+0x7b/0x118
[   28.038644]  [<c012d313>] ? local_bh_enable+0xd/0xd
[   28.038645]  <IRQ>  [<c012d5a9>] ? irq_exit+0x41/0x91
[   28.038650]  [<c0118ac0>] ? smp_apic_timer_interrupt+0x64/0x71
[   28.038652]  [<c023054c>] ? trace_hardirqs_off_thunk+0xc/0x10
[   28.038655]  [<c0353977>] ? apic_timer_interrupt+0x2f/0x34
[   28.038661]  [<f85f7e9f>] ? rtl_slow_event_work+0x14/0x1a2 [r8169]
[   28.038664]  [<c0351898>] ? mutex_lock_nested+0x20/0x22
[   28.038667]  [<f85f49d1>] ? rtl_task+0x49/0x5f [r8169]
[   28.038670]  [<c013992a>] ? process_one_work+0x1a1/0x2ab
[   28.038672]  [<c01398b9>] ? process_one_work+0x130/0x2ab
[   28.038675]  [<f85f4988>] ? rtl8169_set_features+0x39/0x39 [r8169]
[   28.038678]  [<c013a3be>] ? worker_thread+0xd1/0x14c
[   28.038680]  [<c013a2ed>] ? manage_workers.clone.20+0x14e/0x14e
[   28.038682]  [<c013d3ec>] ? kthread+0x67/0x6c
[   28.038685]  [<c0350000>] ? migration_call+0x10/0x189
[   28.038687]  [<c013d385>] ? __init_kthread_worker+0x47/0x47
[   28.038689]  [<c03542fa>] ? kernel_thread_helper+0x6/0xd
[   28.038690] ---[ end trace 9701f577e9a74181 ]---
[   28.043532] r8169 0000:02:00.0: eth0: link up
[   34.043357] r8169 0000:02:00.0: eth0: link up
[   40.043202] r8169 0000:02:00.0: eth0: link up
[   46.043052] r8169 0000:02:00.0: eth0: link up
[   52.042893] r8169 0000:02:00.0: eth0: link up
[   58.042739] r8169 0000:02:00.0: eth0: link up
[   64.042584] r8169 0000:02:00.0: eth0: link up
[   70.042430] r8169 0000:02:00.0: eth0: link up
[   76.042276] r8169 0000:02:00.0: eth0: link up
[   82.042123] r8169 0000:02:00.0: eth0: link up
[   88.041968] r8169 0000:02:00.0: eth0: link up
[   94.041813] r8169 0000:02:00.0: eth0: link up

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
