From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: r8169 not working under latest kernels
Date: Wed, 15 May 2013 23:00:24 +0300
Message-ID: <678d818cc06d1da382dc14397ad41c7e@visp.net.lb>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54209 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab3EOUA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 16:00:27 -0400
In-Reply-To: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-05-13 14:59, Denys Fedoryshchenko wrote:
> Hi
> 
> Noticed on 32-builds of my systems that r8169 is not working anymore at 
> all.
> Problem started to occur somewhere after 3.6 kernels, but it is
> difficult to try other kernels on this semi-embedded system, and i am
> not completely sure about that.
> Once i used another OS build, but 64-bit build with same latest
> kernel, and it worked.
> It spits netdev watchdog timeouts, and constantly shows interface 
> coming up.
Hi again

After Eric Dumazet fixed lockdep issue, one warning disappeared, but 
still card is not working.
It is not only for that model, i faced this problem for many realtek 
cards. Probably as i mentioned something
specific (such as ifplugd interface polling) causing that, but it is 
making almost all r8169 cards unusable for me.
Some additional dmesg info,that maybe will be helpful:

[   22.683789] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[   22.685025] r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8afe000, 
00:27:0e:27:32:41, XID 081000c0 IRQ 43
[   22.685192] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
[   22.760348] r8169 0000:03:00.0 eth0: link down
[   24.340901] r8169 0000:03:00.0 eth0: link up
[   48.720016] ------------[ cut here ]------------
[   48.720060] WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0xcd/0x121()
[   48.720101] Hardware name:
[   48.720133] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[   48.720172] Modules linked in: r8169 nf_nat_pptp nf_nat_proto_gre 
nf_conntrack_pptp nf_conntrack_proto_gre cls_flow cls_u32 em_meta 
cls_basic xt_dscp xt_hl ifb cls_fw sch_tbf sch_htb act_ipt act_mirred 
xt_nat xt_REDIRECT ipt_REJECT xt_TCPMSS ts_bm xt_string xt_connmark 
xt_DSCP xt_mark iptable_mangle iptable_nat nf_conntrack_ipv4 
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter 8021q garp 
stp mrp llc loop tulip sky2 via_velocity via_rhine sis900 ne2k_pci 8390 
skge libphy 8139cp 8139too e1000e ptp pps_core e1000 e100 usbhid [last 
unloaded: r8169]
[   48.720257] Pid: 3, comm: ksoftirqd/0 Not tainted 3.9.2-build-0065 #4
[   48.720260] Call Trace:
[   48.720267]  [<c012bee5>] warn_slowpath_common+0x77/0x8e
[   48.720273]  [<c0385261>] ? dev_watchdog+0xcd/0x121
[   48.720279]  [<c0385261>] ? dev_watchdog+0xcd/0x121
[   48.720284]  [<c012bf78>] warn_slowpath_fmt+0x2e/0x30
[   48.720289]  [<c0385261>] dev_watchdog+0xcd/0x121
[   48.720295]  [<c0136102>] call_timer_fn+0x69/0xdc
[   48.720300]  [<c0136099>] ? cascade+0x5c/0x5c
[   48.720312]  [<c03e5081>] ? _raw_spin_unlock_irq+0x22/0x26
[   48.720315]  [<c0385194>] ? netif_tx_unlock+0x41/0x41
[   48.720318]  [<c01362e6>] run_timer_softirq+0x171/0x1ab
[   48.720321]  [<c0385194>] ? netif_tx_unlock+0x41/0x41
[   48.720325]  [<c0131963>] __do_softirq+0x98/0x153
[   48.720328]  [<c0131a45>] ? run_ksoftirqd+0x27/0x38
[   48.720331]  [<c0131a39>] run_ksoftirqd+0x1b/0x38
[   48.720334]  [<c0147dc6>] smpboot_thread_fn+0x10f/0x114
[   48.720339]  [<c01421f5>] kthread+0x6b/0x70
[   48.720341]  [<c0147cb7>] ? __smpboot_create_thread+0xd3/0xd3
[   48.720345]  [<c03e5a77>] ret_from_kernel_thread+0x1b/0x28
[   48.720348]  [<c014218a>] ? __init_kthread_worker+0x47/0x47
[   48.720350] ---[ end trace 535f1a8b707a82d3 ]---
[   48.725335] r8169 0000:03:00.0 eth0: link up
[   54.725270] r8169 0000:03:00.0 eth0: link up
[   60.725270] r8169 0000:03:00.0 eth0: link up
[   66.725268] r8169 0000:03:00.0 eth0: link up
[   72.725269] r8169 0000:03:00.0 eth0: link up
[   78.725268] r8169 0000:03:00.0 eth0: link up
[   84.725270] r8169 0000:03:00.0 eth0: link up
[   90.725266] r8169 0000:03:00.0 eth0: link up
[   96.725268] r8169 0000:03:00.0 eth0: link up
[  102.725278] r8169 0000:03:00.0 eth0: link up
[  108.725271] r8169 0000:03:00.0 eth0: link up
[  114.725270] r8169 0000:03:00.0 eth0: link up
[  120.725269] r8169 0000:03:00.0 eth0: link up
[  126.725269] r8169 0000:03:00.0 eth0: link up
[  132.725272] r8169 0000:03:00.0 eth0: link up
[  138.725270] r8169 0000:03:00.0 eth0: link up
[  155.028457] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  155.028789] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[  155.029997] r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8c50000, 
00:27:0e:27:32:41, XID 081000c0 IRQ 43
[  155.030166] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
[  157.707319] r8169 0000:03:00.0 eth0: link down
[  157.707378] r8169 0000:03:00.0 eth0: link down
[  159.372510] r8169 0000:03:00.0 eth0: link up
[  166.628362] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  166.628679] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
[  166.629880] r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8c76000, 
00:27:0e:27:32:41, XID 081000c0 IRQ 43
[  166.630052] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
[  167.747589] INFO: trying to register non-static key.
[  167.747678] the code is fine but needs lockdep annotation.
[  167.747766] turning off the locking correctness validator.
[  167.748562] Pid: 2244, comm: rmmod Tainted: G        W    
3.9.2-build-0065 #4
[  167.748562] Call Trace:
[  167.748562]  [<c015f4bc>] register_lock_class+0xd6/0x284
[  167.748562]  [<c016152a>] ? __lock_acquire+0x5d6/0xd52
[  167.748562]  [<c0160ff7>] __lock_acquire+0xa3/0xd52
[  167.748562]  [<c01622f9>] ? mark_held_locks+0x48/0x7b
[  167.748562]  [<c01625a1>] ? debug_check_no_locks_freed+0x129/0x133
[  167.748562]  [<c0160dbf>] ? mark_lock+0x26/0x1bb
[  167.748562]  [<c0162068>] lock_acquire+0x71/0x85
[  167.748562]  [<c013e0bd>] ? execute_in_process_context+0x60/0x60
[  167.748562]  [<c013e0f5>] flush_work+0x38/0x1af
[  167.748562]  [<c013e0bd>] ? execute_in_process_context+0x60/0x60
[  167.748562]  [<c01622f9>] ? mark_held_locks+0x48/0x7b
[  167.748562]  [<c013e33b>] ? __cancel_work_timer+0x62/0x87
[  167.748562]  [<c016243a>] ? trace_hardirqs_on_caller+0x10e/0x13f
[  167.748562]  [<c013e346>] __cancel_work_timer+0x6d/0x87
[  167.748562]  [<c013e379>] cancel_work_sync+0xa/0xc
[  167.748562]  [<f8c68008>] rtl_remove_one+0x70/0xf9 [r8169]
[  167.748562]  [<c02c9117>] ? __pm_runtime_resume+0x48/0x50
[  167.748562]  [<c026cea9>] pci_device_remove+0x27/0x76
[  167.748562]  [<c02c1b70>] __device_release_driver+0x66/0xaa
[  167.748562]  [<c02c20a3>] driver_detach+0x62/0x83
[  167.748562]  [<c02c1919>] bus_remove_driver+0x69/0x88
[  167.748562]  [<c02c23be>] driver_unregister+0x53/0x5a
[  167.748562]  [<c016243a>] ? trace_hardirqs_on_caller+0x10e/0x13f
[  167.748562]  [<c026cf87>] pci_unregister_driver+0x10/0x5a
[  167.748562]  [<f8c6a8fb>] rtl8169_pci_driver_exit+0xd/0xf [r8169]
[  167.748562]  [<c01688cf>] sys_delete_module+0x175/0x1c1
[  167.748562]  [<c03e5367>] ? restore_all+0xf/0xf
[  167.748562]  [<c03e5334>] syscall_call+0x7/0xb



---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
