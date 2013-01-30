From: Ben Greear <greearb@candelatech.com>
Subject: Re: Lockup in barely-patched 3.7.5, maybe wifi/ath9k or i2c related
Date: Tue, 29 Jan 2013 21:59:20 -0800
Message-ID: <5108B6B8.1080603@candelatech.com>
References: <510882F3.4080000@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <510882F3.4080000@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/2013 06:18 PM, Ben Greear wrote:
> I've been seeing strange lockups since 3.7.4.  Not so easily reproducible
> most of the time.  Previous lockups looked to be rcu/rtnl based, but the one
> below has a bunch of i2c stuff in it.
>
> Patches applied are a few wifi patches from upstream and one hack to make
> ath9k able to over-ride the eeprom regdomain.
>
> I *think* the decodes are proper, I had to switch back to this patch
> set and re-compile....

I saw another lockup, in a similar spot (but no i2c stuff this time).

I had also recompiled so that it would not panic on lockup, and by the
time I noticed the problem, it seems the lockup resolved itself and
the system was stable.

So, maybe a false positive on the lockup detector, or maybe
it really was locked for a while but then recovered...

Thanks,
Ben

[  157.985459] sta3: associated
[  274.864154] [sched_delayed] sched: RT throttling activated
[  400.110028] BUG: soft lockup - CPU#1 stuck for 22s! [kworker/1:2:1140]
[  400.110028] Modules linked in: iptable_raw xt_CT nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge veth ip_gre ]
[  400.110028] irq event stamp: 9992689
[  400.110028] hardirqs last  enabled at (9992688): [<c04ea5cf>] __free_pages_ok+0x8f/0xd0
[  400.110028] hardirqs last disabled at (9992689): [<c09750d2>] apic_timer_interrupt+0x32/0x40
[  400.110028] softirqs last  enabled at (4914834): [<c044d4ab>] __do_softirq+0x10b/0x170
[  400.110028] softirqs last disabled at (4914915): [<c040ddad>] do_softirq+0x9d/0xf0
[  400.110028] Pid: 1140, comm: kworker/1:2 Tainted: G         C   3.7.5+ #39 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled.
[  400.110028] EIP: 0060:[<c04ea5d3>] EFLAGS: 00000202 CPU: 1
[  400.110028] EIP is at __free_pages_ok+0x93/0xd0
[  400.110028] EAX: 00000202 EBX: f6847900 ECX: 00000002 EDX: f5ebba74
[  400.110028] ESI: 00000003 EDI: 00000202 EBP: f5cc1c34 ESP: f5cc1c24
[  400.110028]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  400.110028] CR0: 8005003b CR2: 09f2f468 CR3: 00c83000 CR4: 000007e0
[  400.110028] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  400.110028] DR6: ffff0ff0 DR7: 00000400
[  400.110028] Process kworker/1:2 (pid: 1140, ti=f5cc0000 task=f5ebb540 task.ti=f75d2000)
[  400.110028] Stack:
[  400.110028]  00000000 f6847900 eff25480 f13cfa00 f5cc1c3c c04ea624 f5cc1c48 c04ef6f0
[  400.110028]  f6847900 f5cc1c5c c04ef7df eff25480 eff25480 f13cfa00 f5cc1c64 c04efd4c
[  400.110028]  f5cc1c6c c0854d0f f5cc1c7c c0855a3c eff25480 f09b4000 f5cc1c88 c0855a72
[  400.110028] Call Trace:
[  400.110028]  [<c04ea624>] free_compound_page+0x14/0x20
[  400.110028]  [<c04ef6f0>] __put_compound_page+0x10/0x20
[  400.110028]  [<c04ef7df>] put_compound_page+0x4f/0x190
[  400.110028]  [<c04efd4c>] put_page+0x2c/0x40
[  400.110028]  [<c0854d0f>] skb_free_head+0x2f/0x50
[  400.110028]  [<c0855a3c>] skb_release_data+0x8c/0xb0
[  400.110028]  [<c0855a72>] __kfree_skb+0x12/0x90
[  400.110028]  [<c0855887>] kfree_skb+0x17/0x40
[  400.110028]  [<c087d775>] pfifo_fast_enqueue+0x65/0x80
[  400.110028]  [<c0867080>] dev_queue_xmit+0x1e0/0x6e0
[  400.110028]  [<c0866ea0>] ? ptype_seq_start+0xa0/0xa0
[  400.110028]  [<f8acca21>] ieee80211_deliver_skb+0xb1/0x1a0 [mac80211]
[  400.110028]  [<f8ace8b8>] ieee80211_rx_handlers+0xd28/0x1940 [mac80211]
[  400.110028]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[  400.110028]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[  400.110028]  [<c09747bf>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[  400.110028]  [<f8acf7ae>] ieee80211_prepare_and_rx_handle+0x2de/0xaf0 [mac80211]
[  400.110028]  [<f8ad031b>] ieee80211_rx+0x35b/0xa80 [mac80211]
[  400.110028]  [<f8ad0071>] ? ieee80211_rx+0xb1/0xa80 [mac80211]
[  400.110028]  [<f8c08818>] ath_rx_tasklet+0xde8/0x1340 [ath9k]
[  400.110028]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  400.110028]  [<f8c0744f>] ath9k_tasklet+0xdf/0x130 [ath9k]
[  400.110028]  [<c044cf8c>] tasklet_action+0xbc/0xd0
[  400.110028]  [<c044d440>] __do_softirq+0xa0/0x170
[  400.110028]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  400.110028]  [<c044d3a0>] ? irq_enter+0x70/0x70
[  400.110028]  <IRQ>
[  400.110028]  [<c044d2fd>] ? irq_exit+0xbd/0xe0
[  400.110028]  [<c040d426>] ? do_IRQ+0x46/0xb0
[  400.110028]  [<c097a7f8>] ? common_interrupt+0x38/0x40
[  400.110028]  [<c0820352>] ? cpufreq_frequency_table_target+0xf2/0x1c0
[  400.110028]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  400.110028]  [<c0821c7f>] ? acpi_cpufreq_target+0x6f/0x3b0
[  400.110028]  [<c04a3ffc>] ? smp_call_function_single+0x9c/0x180
[  400.110028]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[  400.110028]  [<c0822b80>] ? cpufreq_get_measured_perf+0xd0/0xd0
[  400.110028]  [<c0822b6a>] ? cpufreq_get_measured_perf+0xba/0xd0
[  400.110028]  [<c0821c10>] ? do_drv_read+0x50/0x50
[  400.110028]  [<c081bbf8>] ? __cpufreq_driver_target+0x48/0xa0
[  400.110028]  [<c081be07>] ? cpufreq_cpu_put+0x17/0x20
[  400.110028]  [<c081cbad>] ? __cpufreq_driver_getavg+0x3d/0x70
[  400.110028]  [<c081edd8>] ? dbs_check_cpu+0x2d8/0x370
[  400.110028]  [<c081f4d5>] ? do_dbs_timer+0x35/0xe0
[  400.110028]  [<c081f527>] ? do_dbs_timer+0x87/0xe0
[  400.110028]  [<c045de76>] ? process_one_work+0x1a6/0x3d0
[  400.110028]  [<c045de09>] ? process_one_work+0x139/0x3d0
[  400.110028]  [<c0460e58>] ? worker_thread+0x198/0x380
[  400.110028]  [<c081f4a0>] ? store_ignore_nice_load+0x1c0/0x1c0
[  400.110028]  [<c0460dc2>] ? worker_thread+0x102/0x380
[  400.110028]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[  400.110028]  [<c046596c>] ? kthread+0xac/0xb0
[  400.110028]  [<c0460cc0>] ? manage_workers+0x2b0/0x2b0
[  400.110028]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[  400.110028]  [<c097a1b7>] ? ret_from_kernel_thread+0x1b/0x28
[  400.110028]  [<c04658c0>] ? __init_kthread_worker+0x60/0x60
[  400.110028] Code: 89 43 08 69 c2 c0 03 00 00 89 da 89 0c 24 89 f1 05 00 b9 bd c0 e8 3e f4 ff ff f7 c7 00 02 00 00 74 1e e8 71 30 fb f0
[  555.495732] SysRq : Show Locks Held
[  555.496596]
[  555.496596] Showing all locks held in the system:
[  555.521647] 1 lock held by agetty/1765:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1768:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1770:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1772:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1776:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1779:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by mingetty/1781:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by bash/1835:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by bash/1846:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647] 1 lock held by bash/1870:
[  555.521647]  #0:  (&tty->atomic_read_lock){+.+...}, at: [<c06f7762>] n_tty_read+0x462/0x700
[  555.521647]
[  555.521647] =============================================
[  555.521647]
[  592.518479] SysRq : Show backtrace of all active CPUs
[  592.519035] sending NMI to all CPUs:
[  592.519035] NMI backtrace for cpu 0
[  592.519035] Pid: 1699, comm: btserver Tainted: G         C   3.7.5+ #39 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by.
[  592.519035] EIP: 0060:[<c049aa41>] EFLAGS: 00000046 CPU: 0
[  592.519035] EIP is at trace_hardirqs_off_caller+0x61/0x90
[  592.519035] EAX: 00000000 EBX: c042e96d ECX: f1a6a380 EDX: 00000000
[  592.519035] ESI: 03000000 EDI: 00000006 EBP: f1adfe10 ESP: f1adfe08
[  592.519035]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  592.519035] CR0: 80050033 CR2: 08e5d000 CR3: 31ab5000 CR4: 000007e0
[  592.519035] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  592.519035] DR6: ffff0ff0 DR7: 00000400
[  592.519035] Process btserver (pid: 1699, ti=f1ade000 task=f1a6a380 task.ti=f1ade000)
[  592.519035] Stack:
[  592.519035]  00000046 00000002 f1adfe18 c049aa7b f1adfe3c c042e96d c0bbe5d0 00000086
[  592.519035]  f1adfe48 00000800 00000000 c0bbe5d0 00000086 f1adfe48 c042e768 00000000
[  592.519035]  f1adfe58 c042ee74 c0abc65f 0000006c f1adfe60 c06fd9c8 f1adfe84 c06fdd3d
[  592.519035] Call Trace:
[  592.519035]  [<c049aa7b>] trace_hardirqs_off+0xb/0x10
[  592.519035]  [<c042e96d>] default_send_IPI_mask_logical+0xad/0x110
[  592.519035]  [<c042e768>] default_send_IPI_all+0x68/0x70
[  592.519035]  [<c042ee74>] arch_trigger_all_cpu_backtrace+0x44/0x70
[  592.519035]  [<c06fd9c8>] sysrq_handle_showallcpus+0x8/0x10
[  592.519035]  [<c06fdd3d>] __handle_sysrq+0xed/0x140
[  592.519035]  [<c06fdfc0>] handle_sysrq+0x20/0x30
[  592.519035]  [<c071225f>] serial8250_rx_chars+0xdf/0x1f0
[  592.519035]  [<c09741d8>] ? _raw_spin_lock_irqsave+0x58/0x70
[  592.519035]  [<c0712fe1>] serial8250_handle_irq+0x81/0xa0
[  592.519035]  [<c0713017>] serial8250_default_handle_irq+0x17/0x20
[  592.519035]  [<c071169f>] serial8250_interrupt+0x4f/0xb0
[  592.519035]  [<c04c4256>] handle_irq_event_percpu+0x46/0x150
[  592.519035]  [<c04c4397>] handle_irq_event+0x37/0x60
[  592.519035]  [<c04c70d8>] handle_edge_irq+0x58/0x100
[  592.519035]  [<c040dc86>] handle_irq+0x56/0xe0
[  592.519035]  [<c040d41d>] do_IRQ+0x3d/0xb0
[  592.519035]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[  592.519035]  [<c097a7f8>] common_interrupt+0x38/0x40
[  592.519035] Code: 04 00 00 c7 81 5c 04 00 00 00 00 00 00 89 99 50 04 00 00 83 c0 01 89 81 48 04 00 00 89 81 58 04 00 00 5b 5d c3 90 8d
[  592.546178] NMI backtrace for cpu 1
[  592.546178] Pid: 0, comm: swapper/1 Tainted: G         C   3.7.5+ #39 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.
[  592.546178] EIP: 0060:[<c06ac172>] EFLAGS: 00000046 CPU: 1
[  592.546178] EIP is at intel_idle+0x92/0x110
[  592.546178] EAX: 00000030 EBX: d6bbf1a6 ECX: 00000001 EDX: 00000000
[  592.546178] ESI: 12de00c7 EDI: 00000010 EBP: f5ca3f40 ESP: f5ca3f24
[  592.546178]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  592.546178] CR0: 8005003b CR2: b77cd000 CR3: 00c83000 CR4: 000007e0
[  592.546178] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  592.546178] DR6: ffff0ff0 DR7: 00000400
[  592.546178] Process swapper/1 (pid: 0, ti=f5ca2000 task=f5c758c0 task.ti=f5ca2000)
[  592.546178] Stack:
[  592.546178]  00000030 f79d975c 00000003 00000001 000000e4 c0bb9220 00000000 f5ca3f50
[  592.546178]  c0825746 f79d975c f79d975c f5ca3f5c c082576c c0bb9220 f5ca3f6c c0825cf9
[  592.546178]  c0beab50 00000000 f5ca3f88 c041390f 23aa8b50 0000000b d08e60b8 34fee705
[  592.546178] Call Trace:
[  592.546178]  [<c0825746>] cpuidle_enter+0x16/0x30
[  592.546178]  [<c082576c>] cpuidle_enter_state+0xc/0x40
[  592.546178]  [<c0825cf9>] cpuidle_idle_call+0x79/0xb0
[  592.546178]  [<c041390f>] cpu_idle+0xaf/0xf0
[  592.546178]  [<c096c86e>] start_secondary+0x25e/0x264
[  592.546178] Code: 08 8b 52 08 83 e2 08 75 22 31 d2 89 d1 0f 01 c8 0f ae f0 89 f6 89 e0 25 00 e0 ff ff 8b 40 08 a8 08 75 08 b1 01 8b 44


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
