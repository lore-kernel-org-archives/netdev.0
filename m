From: Peter Neal <doabackflip@gmail.com>
Subject: igb transmit queue timed out, rcu_sched_state detected stall
Date: Fri, 12 Aug 2011 17:42:47 +0100
Message-ID: <CALJvf+qLZyXpxfDR-3aJVn2Qf558SKPc85NpQOosafqxCUC46w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:50966 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab1HLQmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 12:42:47 -0400
Received: by iye16 with SMTP id 16so1848169iye.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 09:42:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a machine with 25 interfaces, a mixture of igb and e1000e dual
and quad port NICs. It is used to PXE install and test 24 network
appliances at the same time. During a test run, the interfaces often
go up and down, and are frequently reconfigured (ipv4 and ipv6, all
done through iproute2). I recently changed some of the scripting that
controls the network setup, and now the box has started to hang about
4 hours into the test. I set up a serial console, and the text below
was spat out when the box hung - my shell on the serial terminal
responds when I press return, but any command hangs.

The issue is reproducible on two machines, a dell R900 (below) and an
R910 in a very similar setup, both running a 64bit kernel. I initially
found the issue on a debian packaged 2.6.32-5-amd64, and upgraded to
3.0.1 - this shows the same behaviour, and provided the information
below.

Please copy me on any replies as I'm not subscribed.

Thanks,


Pete Neal


[10179.824031] ------------[ cut here ]------------
[10179.879205] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xea/0x17e()
[10179.964506] Hardware name: PowerEdge R900
[10180.012375] NETDEV WATCHDOG: eth0 (igb): transmit queue 0 timed out
[10180.087284] Modules linked in: ipmi_si ipmi_devintf ipmi_msghandler
8021q garp stp loop tpm_tis snd_pcm snd_timer snd shpchp soundcore
rng_core dcdbas snd_page_alloc i7300_idle psmouse pcspkr processor tpm
tpm_bios ioatdma evdev thermal_sys serio_raw pci_hotplug button ext3
jbd mbcache sg sr_mod cdrom sd_mod ses crc_t10dif enclosure
ata_generic usbhid hid uhci_hcd ata_piix ehci_hcd libata e1000e
usbcore bnx2 megaraid_sas scsi_mod igb dca [last unloaded:
scsi_wait_scan]
[10180.585411] Pid: 0, comm: swapper Not tainted 3.0.1 #1
[10180.646793] Call Trace:
[10180.675937]  <IRQ>  [<ffffffff810450af>] ? warn_slowpath_common+0x78/0x8c
[10180.757115]  [<ffffffff81045162>] ? warn_slowpath_fmt+0x45/0x4a
[10180.827869]  [<ffffffff81281560>] ? netif_tx_lock+0x43/0x74
[10180.894465]  [<ffffffff810625a9>] ? hrtimer_interrupt+0x114/0x1a6
[10180.967301]  [<ffffffff8128167b>] ? dev_watchdog+0xea/0x17e
[10181.033890]  [<ffffffff810662aa>] ? ktime_get+0x50/0x88
[10181.096319]  [<ffffffff81051dbb>] ? run_timer_softirq+0x1c3/0x290
[10181.169149]  [<ffffffff81281591>] ? netif_tx_lock+0x74/0x74
[10181.235734]  [<ffffffff8104a737>] ? __do_softirq+0xc4/0x1a0
[10181.302324]  [<ffffffff81090afa>] ? handle_irq_event_percpu+0x166/0x184
[10181.381402]  [<ffffffff8132af5c>] ? call_softirq+0x1c/0x30
[10181.446950]  [<ffffffff8100aa3f>] ? do_softirq+0x3f/0x79
[10181.510420]  [<ffffffff8104a507>] ? irq_exit+0x44/0xb5
[10181.571809]  [<ffffffff8100a38a>] ? do_IRQ+0x94/0xaa
[10181.631121]  [<ffffffff81323cd3>] ? common_interrupt+0x13/0x13
[10181.700827]  <EOI>  [<ffffffffa031816e>] ?
acpi_idle_enter_simple+0xc7/0xfc [processor]
[10181.796569]  [<ffffffffa031816a>] ?
acpi_idle_enter_simple+0xc3/0xfc [processor]
[10181.885006]  [<ffffffff81252d9f>] ? cpuidle_idle_call+0x123/0x1d4
[10181.957836]  [<ffffffff81008dc7>] ? cpu_idle+0xab/0xe1
[10182.019225]  [<ffffffff81692c17>] ? start_kernel+0x3b4/0x3bf
[10182.086857]  [<ffffffff816923c8>] ? x86_64_start_kernel+0x102/0x10f
[10182.161766] ---[ end trace 74b13b200a4ea2df ]---
[10182.217111] igb 0000:10:00.0: eth0: Reset adapter
[10202.300005] INFO: rcu_sched_state detected stall on CPU 10 (t=15000 jiffies)
[10202.304005] INFO: rcu_sched_state detected stall on CPU 4 (t=15000 jiffies)

root@worker-1b.bigrig.dom:~# [10321.876088] INFO: task kworker/3:1:62
blocked for more than 120 seconds.
[10321.956203] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10322.049830] kworker/3:1     D ffff88042ee03d50     0    62      2 0x00000000
[10322.134133]  ffff88042ee03d50 0000000000000046 0000000000000000
ffff88042ece8000
[10322.222595]  0000000000012680 ffff88042e87bfd8 ffff88042e87bfd8
0000000000012680
[10322.311059]  ffff88042ee03d50 ffff88042e87a010 ffff88042ee03d50
000000013f272680
[10322.399536] Call Trace:
[10322.428684]  [<ffffffff813229aa>] ? schedule_timeout+0x2d/0xd7
[10322.498392]  [<ffffffff81037e3b>] ? update_rq_clock+0x15/0x2f
[10322.567055]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10322.639874]  [<ffffffff8132281e>] ? wait_for_common+0xd1/0x14e
[10322.709583]  [<ffffffff810419a7>] ? try_to_wake_up+0x18d/0x18d
[10322.779288]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10322.852115]  [<ffffffff81086eb6>] ? __stop_cpus+0xc4/0xe1
[10322.916616]  [<ffffffff81086f0c>] ? try_stop_cpus+0x39/0x51
[10322.983199]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10323.056025]  [<ffffffff81095561>] ? synchronize_sched_expedited+0x99/0xc8
[10323.137181]  [<ffffffff812818a9>] ? dev_deactivate_many+0xf4/0x186
[10323.211046]  [<ffffffff81277b4d>] ? __linkwatch_run_queue+0x1a5/0x1a5
[10323.288030]  [<ffffffff81281968>] ? dev_deactivate+0x2d/0x42
[10323.355658]  [<ffffffff812777c8>] ? linkwatch_do_dev+0x9c/0xb2
[10323.425361]  [<ffffffff81277b06>] ? __linkwatch_run_queue+0x15e/0x1a5
[10323.502346]  [<ffffffff81277b6d>] ? linkwatch_event+0x20/0x26
[10323.571015]  [<ffffffff8105b7c8>] ? process_one_work+0x1cc/0x2ea
[10323.642795]  [<ffffffff8105ba13>] ? worker_thread+0x12d/0x247
[10323.711456]  [<ffffffff8105b8e6>] ? process_one_work+0x2ea/0x2ea
[10323.783243]  [<ffffffff8105b8e6>] ? process_one_work+0x2ea/0x2ea
[10323.855034]  [<ffffffff8105ec89>] ? kthread+0x7a/0x82
[10323.915382]  [<ffffffff8132ae64>] ? kernel_thread_helper+0x4/0x10
[10323.988199]  [<ffffffff8105ec0f>] ? kthread_worker_fn+0x147/0x147
[10324.061025]  [<ffffffff8132ae60>] ? gs_change+0x13/0x13
[10324.123455] INFO: task irqbalance:1793 blocked for more than 120 seconds.
[10324.204596] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10324.298223] irqbalance      D ffff88042d99a8e0     0  1793      1 0x00000000
[10324.382521]  ffff88042d99a8e0 0000000000000082 ffff880400000000
ffff88042ec6df60
[10324.470993]  0000000000012680 ffff88042a8f5fd8 ffff88042a8f5fd8
0000000000012680
[10324.559457]  ffff88042d99a8e0 ffff88042a8f4010 ffff88042a8f5cc8
000000012d91d000
[10324.647926] Call Trace:
[10324.677066]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10324.751974]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10324.815444]  [<ffffffff81269ca6>] ? dev_load+0x9/0x70
[10324.875792]  [<ffffffff8126b017>] ? dev_ioctl+0x4ad/0x62e
[10324.940302]  [<ffffffff810eb735>] ? get_partial_node+0x15/0x7b
[10325.010005]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[10325.076582]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[10325.142126]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[10325.210790]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[10325.278414]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[10325.348117]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10325.411574]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[10325.473999]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10325.547865] INFO: task snmpd:1820 blocked for more than 120 seconds.
[10325.623803] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10325.717436] snmpd           D ffff88042b412fb0     0  1820      1 0x00000000
[10325.801728]  ffff88042b412fb0 0000000000000086 ffffffff00000000
ffff88042edb0000
[10325.890194]  0000000000012680 ffff88042e961fd8 ffff88042e961fd8
0000000000012680
[10325.978657]  ffff88042b412fb0 ffff88042e960010 ffff8804127346c0
000000018113e49b
[10326.067122] Call Trace:
[10326.096260]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10326.171167]  [<ffffffff810fa4b3>] ? dget+0x12/0x1e
[10326.228388]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10326.291853]  [<ffffffff8126aba4>] ? dev_ioctl+0x3a/0x62e
[10326.355315]  [<ffffffff81103734>] ? dput+0x29/0xe9
[10326.412538]  [<ffffffff810eb735>] ? get_partial_node+0x15/0x7b
[10326.482242]  [<ffffffff810ec082>] ? kmem_cache_alloc+0x2a/0xe1
[10326.551952]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[10326.618530]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[10326.684084]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[10326.752746]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[10326.820372]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[10326.890072]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10326.953533]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[10327.015958]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10327.089837] INFO: task tcpdump:12446 blocked for more than 120 seconds.
[10327.168898] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10327.262522] tcpdump         D ffff88042e9ae630     0 12446  10117 0x00000000
[10327.346820]  ffff88042e9ae630 0000000000000086 0000003100000000
ffff88042ed44420
[10327.435286]  0000000000012680 ffff8803e6533fd8 ffff8803e6533fd8
0000000000012680
[10327.523751]  ffff88042e9ae630 ffff8803e6532010 ffff8803e6533d38
000000013fffbe00
[10327.612231] Call Trace:
[10327.641369]  [<ffffffff813229aa>] ? schedule_timeout+0x2d/0xd7
[10327.711072]  [<ffffffff810e5028>] ? alloc_pages_vma+0x101/0x11d
[10327.781816]  [<ffffffff8132281e>] ? wait_for_common+0xd1/0x14e
[10327.851522]  [<ffffffff810419a7>] ? try_to_wake_up+0x18d/0x18d
[10327.921231]  [<ffffffff8119d912>] ? hweight_long+0x5/0x6
[10327.984692]  [<ffffffff8119d94b>] ? __bitmap_weight+0x38/0x78
[10328.053357]  [<ffffffff810954c2>] ? synchronize_sched+0x4c/0x52
[10328.124101]  [<ffffffff8105c988>] ? alloc_pid+0x368/0x368
[10328.188599]  [<ffffffff813078f9>] ? packet_set_ring+0x226/0x3ac
[10328.259341]  [<ffffffff81307d3c>] ? packet_setsockopt+0x2bd/0x518
[10328.332166]  [<ffffffff813076a8>] ? packet_getsockopt+0x1c5/0x1f0
[10328.404990]  [<ffffffff81259b6c>] ? sys_setsockopt+0x7d/0x9c
[10328.472613]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10328.546481] INFO: task sshd:12447 blocked for more than 120 seconds.
[10328.622420] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10328.716055] sshd            D ffff88042e9ac420     0 12447   1828 0x00000004
[10328.800362]  ffff88042e9ac420 0000000000000086 0000093a00000000
ffff88042edb0000
[10328.888838]  0000000000012680 ffff8803f37b3fd8 ffff8803f37b3fd8
0000000000012680
[10328.977309]  ffff88042e9ac420 ffff8803f37b2010 0000000000000001
00000001f37b3b88
[10329.065787] Call Trace:
[10329.094923]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10329.169827]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10329.233289]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[10329.298836]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[10329.368538]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[10329.439282]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[10329.513145]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[10329.578695]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[10329.641113]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[10329.708736]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[10329.781560]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[10329.846073]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10329.909533]  [<ffffffff81259f56>] ? sock_map_fd+0x24/0x2d
[10329.974037]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10330.047905] INFO: task sshd:12450 blocked for more than 120 seconds.
[10330.123851] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10330.217469] sshd            D ffff88042a845890     0 12450   1828 0x00000000
[10330.301759]  ffff88042a845890 0000000000000086 000280da00000000
ffff88042edb51c0
[10330.390234]  0000000000012680 ffff8803e417ffd8 ffff8803e417ffd8
0000000000012680
[10330.478698]  ffff88042a845890 ffff8803e417e010 ffff8803e417fb88
000000018110028a
[10330.567162] Call Trace:
[10330.596301]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10330.671207]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10330.734668]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[10330.800222]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[10330.869929]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[10330.940668]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[10331.014530]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[10331.080084]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[10331.142504]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[10331.210128]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[10331.282952]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[10331.347455]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10331.410918]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10382.420003] INFO: rcu_sched_state detected stall on CPU 10 (t=60030 jiffies)
[10382.423999] INFO: rcu_sched_state detected stall on CPU 4 (t=60030 jiffies)
[10451.484093] INFO: task kworker/3:1:62 blocked for more than 120 seconds.
[10451.564192] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10451.657811] kworker/3:1     D ffff88042ee03d50     0    62      2 0x00000000
[10451.742095]  ffff88042ee03d50 0000000000000046 0000000000000000
ffff88042ece8000
[10451.830553]  0000000000012680 ffff88042e87bfd8 ffff88042e87bfd8
0000000000012680
[10451.919018]  ffff88042ee03d50 ffff88042e87a010 ffff88042ee03d50
000000013f272680
[10452.007482] Call Trace:
[10452.036621]  [<ffffffff813229aa>] ? schedule_timeout+0x2d/0xd7
[10452.106321]  [<ffffffff81037e3b>] ? update_rq_clock+0x15/0x2f
[10452.174984]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10452.247808]  [<ffffffff8132281e>] ? wait_for_common+0xd1/0x14e
[10452.317506]  [<ffffffff810419a7>] ? try_to_wake_up+0x18d/0x18d
[10452.387207]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10452.460049]  [<ffffffff81086eb6>] ? __stop_cpus+0xc4/0xe1
[10452.524548]  [<ffffffff81086f0c>] ? try_stop_cpus+0x39/0x51
[10452.591126]  [<ffffffff81094019>] ? rcu_batches_completed+0x8/0x8
[10452.663944]  [<ffffffff81095561>] ? synchronize_sched_expedited+0x99/0xc8
[10452.745082]  [<ffffffff812818a9>] ? dev_deactivate_many+0xf4/0x186
[10452.818945]  [<ffffffff81277b4d>] ? __linkwatch_run_queue+0x1a5/0x1a5
[10452.895927]  [<ffffffff81281968>] ? dev_deactivate+0x2d/0x42
[10452.963546]  [<ffffffff812777c8>] ? linkwatch_do_dev+0x9c/0xb2
[10453.033244]  [<ffffffff81277b06>] ? __linkwatch_run_queue+0x15e/0x1a5
[10453.110223]  [<ffffffff81277b6d>] ? linkwatch_event+0x20/0x26
[10453.178887]  [<ffffffff8105b7c8>] ? process_one_work+0x1cc/0x2ea
[10453.250669]  [<ffffffff8105ba13>] ? worker_thread+0x12d/0x247
[10453.319326]  [<ffffffff8105b8e6>] ? process_one_work+0x2ea/0x2ea
[10453.391105]  [<ffffffff8105b8e6>] ? process_one_work+0x2ea/0x2ea
[10453.462889]  [<ffffffff8105ec89>] ? kthread+0x7a/0x82
[10453.523231]  [<ffffffff8132ae64>] ? kernel_thread_helper+0x4/0x10
[10453.596054]  [<ffffffff8105ec0f>] ? kthread_worker_fn+0x147/0x147
[10453.668880]  [<ffffffff8132ae60>] ? gs_change+0x13/0x13
[10453.731306] INFO: task irqbalance:1793 blocked for more than 120 seconds.
[10453.812448] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10453.906070] irqbalance      D ffff88042d99a8e0     0  1793      1 0x00000000
[10453.990357]  ffff88042d99a8e0 0000000000000082 ffff880400000000
ffff88042ec6df60
[10454.078814]  0000000000012680 ffff88042a8f5fd8 ffff88042a8f5fd8
0000000000012680
[10454.167280]  ffff88042d99a8e0 ffff88042a8f4010 ffff88042a8f5cc8
000000012d91d000
[10454.255744] Call Trace:
[10454.284883]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10454.359780]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10454.423237]  [<ffffffff81269ca6>] ? dev_load+0x9/0x70
[10454.483576]  [<ffffffff8126b017>] ? dev_ioctl+0x4ad/0x62e
[10454.548088]  [<ffffffff810eb735>] ? get_partial_node+0x15/0x7b
[10454.617789]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[10454.684365]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[10454.749906]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[10454.818572]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[10454.886192]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[10454.955894]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10455.019351]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[10455.081769]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10455.155632] INFO: task ntpd:1808 blocked for more than 120 seconds.
[10455.230529] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10455.324148] ntpd            D ffff88042bf96630     0  1808      1 0x00000004
[10455.408430]  ffff88042bf96630 0000000000000082 ffff880400000000
ffff88042eceed00
[10455.496902]  0000000000012680 ffff88042a8affd8 ffff88042a8affd8
0000000000012680
[10455.585370]  ffff88042bf96630 ffff88042a8ae010 0000000700200200
000000010000ea00
[10455.673841] Call Trace:
[10455.702978]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10455.777876]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10455.841336]  [<ffffffff8126aba4>] ? dev_ioctl+0x3a/0x62e
[10455.904797]  [<ffffffff81053d92>] ? __set_task_blocked+0x5a/0x61
[10455.976575]  [<ffffffff810ec082>] ? kmem_cache_alloc+0x2a/0xe1
[10456.046279]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[10456.112861]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[10456.178400]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[10456.247062]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[10456.314679]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[10456.384377]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[10456.447833]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[10456.510251]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10456.584106] INFO: task zebra:1815 blocked for more than 120 seconds.
[10456.660054] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[10456.753680] zebra           D ffff88042bfecaf0     0  1815      1 0x00000000
[10456.837969]  ffff88042bfecaf0 0000000000000082 ffff880400000000
ffff88042edb1b40
[10456.926427]  0000000000012680 ffff88042ba69fd8 ffff88042ba69fd8
0000000000012680
[10457.014891]  ffff88042bfecaf0 ffff88042ba68010 ffff88042ba69d48
0000000181289426
[10457.103356] Call Trace:
[10457.132494]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[10457.207392]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[10457.270850]  [<ffffffff81100218>] ? __pollwait+0xd0/0xd0
[10457.334306]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[10457.399842]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[10457.469540]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[10457.540280]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[10457.614142]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[10457.679679]  [<ffffffff812580fb>] ? __sock_recvmsg_nosec+0x29/0x69
[10457.753538]  [<ffffffff81262a9c>] ? copy_from_user+0x18/0x30
[10457.821166]  [<ffffffff81262de0>] ? verify_iovec+0x46/0x98
[10457.886703]  [<ffffffff81259811>] ? __sys_sendmsg+0x1c4/0x23b
[10457.955361]  [<ffffffff810f2687>] ? do_sync_read+0xb1/0xea
[10458.020900]  [<ffffffff8103cbdb>] ? thread_group_times+0x32/0x8e
[10458.092683]  [<ffffffff81053c57>] ? __lock_task_sighand+0x4a/0x72
[10458.165506]  [<ffffffff810431f2>] ? mmput+0x9/0xde
[10458.222724]  [<ffffffff81057e16>] ? getrusage+0x34b/0x365
[10458.287227]  [<ffffffff810ec082>] ? kmem_cache_alloc+0x2a/0xe1
[10458.356924]  [<ffffffff812599e6>] ? sys_sendmsg+0x39/0x58
[10458.421420]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[10562.540002] INFO: rcu_sched_state detected stall on CPU 10 (t=105060 jiffies)
[10562.543993] INFO: rcu_sched_state detected stall on CPU 4 (t=105060 jiffies)
