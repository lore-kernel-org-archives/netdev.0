From: Ben Greear <greearb@candelatech.com>
Subject: Kernel splat with debugging on 3.3.6+ kernel.
Date: Fri, 18 May 2012 11:40:43 -0700
Message-ID: <4FB697AB.10809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51031 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965474Ab2ERSko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 14:40:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patched kernel, but nothing proprietary loaded.

We're chasing a hard-to-reproduce bug that appears to be stale
memory access related to wifi stations.

So, I enabled a bunch of debugging (memory debugging, lockdep, etc)
and this lockup occurs every time we try to load our
'400 station' test case.

I'm going to poke at this some more, try some smaller test
cases and such, but if anyone has any other suggestions I'm interested!


BUG: soft lockup - CPU#0 stuck for 22s! [iw:21673]
Modules linked in: 8021q garp stp llc macvlan pktgen fuse coretemp hwmon sunrpc ipv6 uinput arc4 ppdev snd_hda_codec_realtek ath9k snd_hda_intel mac80211 
snd_hda_codec snd_hwdep snd_seq ath9k_common microcode snd_seq_device ath9k_hw snd_pcm ath iTCO_wdt i2c_i801 serio_raw pcspkr iTCO_vendor_support cfg80211 
snd_timer snd e1000e mei(C) soundcore snd_page_alloc parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
irq event stamp: 2249893
hardirqs last  enabled at (2249892): [<ffffffff810efeaa>] __slab_alloc+0x402/0x436
hardirqs last disabled at (2249893): [<ffffffff8147d8ae>] apic_timer_interrupt+0x6e/0x80
softirqs last  enabled at (8972): [<ffffffff8103e0f2>] __do_softirq+0x13c/0x15b
softirqs last disabled at (8979): [<ffffffff8147e2ac>] call_softirq+0x1c/0x30
CPU 0
Modules linked in: 8021q garp stp llc macvlan pktgen fuse coretemp hwmon sunrpc ipv6 uinput arc4 ppdev snd_hda_codec_realtek ath9k snd_hda_intel mac80211 
snd_hda_codec snd_hwdep snd_seq ath9k_common microcode snd_seq_device ath9k_hw snd_pcm ath iTCO_wdt i2c_i801 serio_raw pcspkr iTCO_vendor_support cfg80211 
snd_timer snd e1000e mei(C) soundcore snd_page_alloc parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]

Pid: 21673, comm: iw Tainted: G         C O 3.3.6+ #1 To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M.
RIP: 0010:[<ffffffff810efeb3>]  [<ffffffff810efeb3>] __slab_alloc+0x40b/0x436
RSP: 0018:ffff88022bc03a10  EFLAGS: 00000282
RAX: ffff88021e0ec400 RBX: ffff88022bc039d0 RCX: 0000000000000003
RDX: 0000000000000003 RSI: ffffffff813aff74 RDI: 0000000000000282
RBP: ffff88022bc03ae0 R08: ffff8801fbca33d8 R09: ffff88022bc038f0
R10: 0000000000000046 R11: ffffea0007ef2820 R12: ffff88022bc03988
R13: ffffffff8147d8b3 R14: ffff88022bc03ae0 R15: ffff880223006f40
FS:  00007f498a0b1720(0000) GS:ffff88022bc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fff41409330 CR3: 000000020a006000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process iw (pid: 21673, threadinfo ffff880200e62000, task ffff88021e0ec400)
Stack:
  0000000000000003 ffff88022bc03b70 ffff88022bc03a60 0000000000000246
  ffffffff813aff74 ffff88021e0ed240 ffff88021bb10cd8 ffff88021e0ed240
  0000000200000020 0000000000000282 ffff88021bb10cd8 ffff880204232ae0
Call Trace:
  <IRQ>
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff8147796c>] ? _raw_spin_unlock+0x4e/0x52
  [<ffffffffa02b30e7>] ? ieee80211_rx_handlers+0x17d2/0x1855 [mac80211]
  [<ffffffff810f1b07>] __kmalloc_node_track_caller+0x95/0xf7
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff813af2f5>] __alloc_skb+0x71/0x138
  [<ffffffff813aff74>] skb_copy+0x3b/0x9f
  [<ffffffffa02b34e3>] ieee80211_prepare_and_rx_handle+0x379/0x921 [mac80211]
  [<ffffffffa02b43a8>] ieee80211_rx+0x864/0x95c [mac80211]
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffffa0208c40>] ath_rx_tasklet+0x1765/0x18a3 [ath9k]
  [<ffffffff814779b2>] ? _raw_spin_unlock_irqrestore+0x42/0x79
  [<ffffffffa0204d82>] ath9k_tasklet+0x10d/0x182 [ath9k]
  [<ffffffff8103da1f>] tasklet_action+0x91/0xf1
  [<ffffffff8103e054>] __do_softirq+0x9e/0x15b
  [<ffffffff8147e2ac>] call_softirq+0x1c/0x30
  [<ffffffff8100bd6e>] do_softirq+0x46/0x9e
  [<ffffffff8103ddc2>] irq_exit+0x4e/0xcc
  [<ffffffff8100b662>] do_IRQ+0x97/0xae
  [<ffffffff81477ef3>] common_interrupt+0x73/0x73
  <EOI>
  [<ffffffff8106e19e>] ? sysctl_check_table+0x201/0x303
  [<ffffffff8106e178>] ? sysctl_check_table+0x1db/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffff810efeaa>] ? __slab_alloc+0x402/0x436
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8103f38c>] ? sysctl_set_parent+0x24/0x33
  [<ffffffff810405e9>] __register_sysctl_paths+0xce/0x25c
  [<ffffffffa02fae2a>] ? ndisc_net_init+0x7d/0x7d [ipv6]
  [<ffffffff81458524>] register_net_sysctl_table+0x43/0x47
  [<ffffffff813c08e6>] neigh_sysctl_register+0x1fc/0x235
  [<ffffffffa02edc82>] addrconf_sysctl_register+0x29/0x46 [ipv6]
  [<ffffffffa02eea1d>] ipv6_add_dev+0x308/0x368 [ipv6]
  [<ffffffffa02f027f>] addrconf_notify+0x58/0x8a5 [ipv6]
  [<ffffffff814759b4>] ? mutex_unlock+0x9/0xb
  [<ffffffffa012120d>] ? cfg80211_netdev_notifier_call+0x1c2/0x561 [cfg80211]
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8147ad48>] notifier_call_chain+0x54/0x81
  [<ffffffff81057372>] raw_notifier_call_chain+0xf/0x11
  [<ffffffff813b9877>] call_netdevice_notifiers+0x45/0x4a
  [<ffffffff813bb0e9>] register_netdevice+0x258/0x307
  [<ffffffffa02a9e16>] ieee80211_if_add+0x55a/0x5e6 [mac80211]
  [<ffffffff81475975>] ? __mutex_unlock_slowpath+0x11f/0x155
  [<ffffffff810788c1>] ? trace_hardirqs_on_caller+0x123/0x15a
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffffa02afd93>] ieee80211_add_iface+0x2d/0x57 [mac80211]
  [<ffffffffa01228cd>] ? cfg80211_get_dev_from_info+0x44/0x4b [cfg80211]
  [<ffffffffa012b0c9>] nl80211_new_interface+0xf2/0x186 [cfg80211]
  [<ffffffff813da541>] genl_rcv_msg+0x1f4/0x239
  [<ffffffff813da34d>] ? genl_rcv+0x28/0x28
  [<ffffffff813d921d>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff813da346>] genl_rcv+0x21/0x28
  [<ffffffff813d8ff8>] netlink_unicast+0xe9/0x152
  [<ffffffff813d9777>] netlink_sendmsg+0x1f8/0x216
  [<ffffffff813a979f>] ? rcu_read_unlock+0x4b/0x4d
  [<ffffffff813a5d3d>] __sock_sendmsg_nosec+0x5f/0x6a
  [<ffffffff813a5d85>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813a662f>] sock_sendmsg+0xa3/0xbc
  [<ffffffff810cdab1>] ? might_fault+0x4e/0x9e
  [<ffffffff810cdafa>] ? might_fault+0x97/0x9e
  [<ffffffff813b02fa>] ? copy_from_user+0x2a/0x2c
  [<ffffffff813b06cc>] ? verify_iovec+0x4f/0xa3
  [<ffffffff813a6e38>] __sys_sendmsg+0x20f/0x29c
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8110360a>] ? fcheck_files+0xac/0xea
  [<ffffffff8110375e>] ? fget_light+0x35/0xac
  [<ffffffff813a702e>] sys_sendmsg+0x3d/0x5b
  [<ffffffff8147cd79>] system_call_fastpath+0x16/0x1b
Code: ff ff 00 02 00 00 75 15 48 8b bd 78 ff ff ff 57 9d 66 66 90 66 90 e8 c9 65 f8 ff eb 13 e8 4e 8a f8 ff 48 8b bd 78 ff ff ff 57 9d <66> 66 90 66 90 48 81 c4 
a8 00 00 00 4c 89 f0 5b 41 5c 41 5d 41
Call Trace:
  <IRQ>  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff8147796c>] ? _raw_spin_unlock+0x4e/0x52
  [<ffffffffa02b30e7>] ? ieee80211_rx_handlers+0x17d2/0x1855 [mac80211]
  [<ffffffff810f1b07>] __kmalloc_node_track_caller+0x95/0xf7
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff813af2f5>] __alloc_skb+0x71/0x138
  [<ffffffff813aff74>] skb_copy+0x3b/0x9f
  [<ffffffffa02b34e3>] ieee80211_prepare_and_rx_handle+0x379/0x921 [mac80211]
  [<ffffffffa02b43a8>] ieee80211_rx+0x864/0x95c [mac80211]
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffffa0208c40>] ath_rx_tasklet+0x1765/0x18a3 [ath9k]
  [<ffffffff814779b2>] ? _raw_spin_unlock_irqrestore+0x42/0x79
  [<ffffffffa0204d82>] ath9k_tasklet+0x10d/0x182 [ath9k]
  [<ffffffff8103da1f>] tasklet_action+0x91/0xf1
  [<ffffffff8103e054>] __do_softirq+0x9e/0x15b
  [<ffffffff8147e2ac>] call_softirq+0x1c/0x30
  [<ffffffff8100bd6e>] do_softirq+0x46/0x9e
  [<ffffffff8103ddc2>] irq_exit+0x4e/0xcc
  [<ffffffff8100b662>] do_IRQ+0x97/0xae
  [<ffffffff81477ef3>] common_interrupt+0x73/0x73
  <EOI>  [<ffffffff8106e19e>] ? sysctl_check_table+0x201/0x303
  [<ffffffff8106e178>] ? sysctl_check_table+0x1db/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffff810efeaa>] ? __slab_alloc+0x402/0x436
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8103f38c>] ? sysctl_set_parent+0x24/0x33
  [<ffffffff810405e9>] __register_sysctl_paths+0xce/0x25c
  [<ffffffffa02fae2a>] ? ndisc_net_init+0x7d/0x7d [ipv6]
  [<ffffffff81458524>] register_net_sysctl_table+0x43/0x47
  [<ffffffff813c08e6>] neigh_sysctl_register+0x1fc/0x235
  [<ffffffffa02edc82>] addrconf_sysctl_register+0x29/0x46 [ipv6]
  [<ffffffffa02eea1d>] ipv6_add_dev+0x308/0x368 [ipv6]
  [<ffffffffa02f027f>] addrconf_notify+0x58/0x8a5 [ipv6]
  [<ffffffff814759b4>] ? mutex_unlock+0x9/0xb
  [<ffffffffa012120d>] ? cfg80211_netdev_notifier_call+0x1c2/0x561 [cfg80211]
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8147ad48>] notifier_call_chain+0x54/0x81
  [<ffffffff81057372>] raw_notifier_call_chain+0xf/0x11
  [<ffffffff813b9877>] call_netdevice_notifiers+0x45/0x4a
  [<ffffffff813bb0e9>] register_netdevice+0x258/0x307
  [<ffffffffa02a9e16>] ieee80211_if_add+0x55a/0x5e6 [mac80211]
  [<ffffffff81475975>] ? __mutex_unlock_slowpath+0x11f/0x155
  [<ffffffff810788c1>] ? trace_hardirqs_on_caller+0x123/0x15a
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffffa02afd93>] ieee80211_add_iface+0x2d/0x57 [mac80211]
  [<ffffffffa01228cd>] ? cfg80211_get_dev_from_info+0x44/0x4b [cfg80211]
  [<ffffffffa012b0c9>] nl80211_new_interface+0xf2/0x186 [cfg80211]
  [<ffffffff813da541>] genl_rcv_msg+0x1f4/0x239
  [<ffffffff813da34d>] ? genl_rcv+0x28/0x28
  [<ffffffff813d921d>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff813da346>] genl_rcv+0x21/0x28
  [<ffffffff813d8ff8>] netlink_unicast+0xe9/0x152
  [<ffffffff813d9777>] netlink_sendmsg+0x1f8/0x216
  [<ffffffff813a979f>] ? rcu_read_unlock+0x4b/0x4d
  [<ffffffff813a5d3d>] __sock_sendmsg_nosec+0x5f/0x6a
  [<ffffffff813a5d85>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813a662f>] sock_sendmsg+0xa3/0xbc
  [<ffffffff810cdab1>] ? might_fault+0x4e/0x9e
  [<ffffffff810cdafa>] ? might_fault+0x97/0x9e
  [<ffffffff813b02fa>] ? copy_from_user+0x2a/0x2c
  [<ffffffff813b06cc>] ? verify_iovec+0x4f/0xa3
  [<ffffffff813a6e38>] __sys_sendmsg+0x20f/0x29c
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8110360a>] ? fcheck_files+0xac/0xea
  [<ffffffff8110375e>] ? fget_light+0x35/0xac
  [<ffffffff813a702e>] sys_sendmsg+0x3d/0x5b
  [<ffffffff8147cd79>] system_call_fastpath+0x16/0x1b
Kernel panic - not syncing: softlockup: hung tasks
Pid: 21673, comm: iw Tainted: G         C O 3.3.6+ #1
Call Trace:
  <IRQ>  [<ffffffff81474e27>] panic+0xb8/0x1d6
  [<ffffffff8109b3ad>] watchdog_timer_fn+0x147/0x16b
  [<ffffffff8109b266>] ? __touch_watchdog+0x1f/0x1f
  [<ffffffff81055938>] __run_hrtimer+0x66/0xc1
  [<ffffffff81055cb7>] hrtimer_interrupt+0xe5/0x1c0
  [<ffffffff8102324e>] smp_apic_timer_interrupt+0x80/0x93
  [<ffffffff8147d8b3>] apic_timer_interrupt+0x73/0x80
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff810efeb3>] ? __slab_alloc+0x40b/0x436
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff8147796c>] ? _raw_spin_unlock+0x4e/0x52
  [<ffffffffa02b30e7>] ? ieee80211_rx_handlers+0x17d2/0x1855 [mac80211]
  [<ffffffff810f1b07>] __kmalloc_node_track_caller+0x95/0xf7
  [<ffffffff813aff74>] ? skb_copy+0x3b/0x9f
  [<ffffffff813af2f5>] __alloc_skb+0x71/0x138
  [<ffffffff813aff74>] skb_copy+0x3b/0x9f
  [<ffffffffa02b34e3>] ieee80211_prepare_and_rx_handle+0x379/0x921 [mac80211]
  [<ffffffffa02b43a8>] ieee80211_rx+0x864/0x95c [mac80211]
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffffa0208c40>] ath_rx_tasklet+0x1765/0x18a3 [ath9k]
  [<ffffffff814779b2>] ? _raw_spin_unlock_irqrestore+0x42/0x79
  [<ffffffffa0204d82>] ath9k_tasklet+0x10d/0x182 [ath9k]
  [<ffffffff8103da1f>] tasklet_action+0x91/0xf1
  [<ffffffff8103e054>] __do_softirq+0x9e/0x15b
  [<ffffffff8147e2ac>] call_softirq+0x1c/0x30
  [<ffffffff8100bd6e>] do_softirq+0x46/0x9e
  [<ffffffff8103ddc2>] irq_exit+0x4e/0xcc
  [<ffffffff8100b662>] do_IRQ+0x97/0xae
  [<ffffffff81477ef3>] common_interrupt+0x73/0x73
  <EOI>  [<ffffffff8106e19e>] ? sysctl_check_table+0x201/0x303
  [<ffffffff8106e178>] ? sysctl_check_table+0x1db/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff810785ef>] ? mark_held_locks+0x73/0x97
  [<ffffffff810efeaa>] ? __slab_alloc+0x402/0x436
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8106e21c>] sysctl_check_table+0x27f/0x303
  [<ffffffff8103f38c>] ? sysctl_set_parent+0x24/0x33
  [<ffffffff810405e9>] __register_sysctl_paths+0xce/0x25c
  [<ffffffffa02fae2a>] ? ndisc_net_init+0x7d/0x7d [ipv6]
  [<ffffffff81458524>] register_net_sysctl_table+0x43/0x47
  [<ffffffff813c08e6>] neigh_sysctl_register+0x1fc/0x235
  [<ffffffffa02edc82>] addrconf_sysctl_register+0x29/0x46 [ipv6]
  [<ffffffffa02eea1d>] ipv6_add_dev+0x308/0x368 [ipv6]
  [<ffffffffa02f027f>] addrconf_notify+0x58/0x8a5 [ipv6]
  [<ffffffff814759b4>] ? mutex_unlock+0x9/0xb
  [<ffffffffa012120d>] ? cfg80211_netdev_notifier_call+0x1c2/0x561 [cfg80211]
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8147ad48>] notifier_call_chain+0x54/0x81
  [<ffffffff81057372>] raw_notifier_call_chain+0xf/0x11
  [<ffffffff813b9877>] call_netdevice_notifiers+0x45/0x4a
  [<ffffffff813bb0e9>] register_netdevice+0x258/0x307
  [<ffffffffa02a9e16>] ieee80211_if_add+0x55a/0x5e6 [mac80211]
  [<ffffffff81475975>] ? __mutex_unlock_slowpath+0x11f/0x155
  [<ffffffff810788c1>] ? trace_hardirqs_on_caller+0x123/0x15a
  [<ffffffff81078905>] ? trace_hardirqs_on+0xd/0xf
  [<ffffffffa02afd93>] ieee80211_add_iface+0x2d/0x57 [mac80211]
  [<ffffffffa01228cd>] ? cfg80211_get_dev_from_info+0x44/0x4b [cfg80211]
  [<ffffffffa012b0c9>] nl80211_new_interface+0xf2/0x186 [cfg80211]
  [<ffffffff813da541>] genl_rcv_msg+0x1f4/0x239
  [<ffffffff813da34d>] ? genl_rcv+0x28/0x28
  [<ffffffff813d921d>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff813da346>] genl_rcv+0x21/0x28
  [<ffffffff813d8ff8>] netlink_unicast+0xe9/0x152
  [<ffffffff813d9777>] netlink_sendmsg+0x1f8/0x216
  [<ffffffff813a979f>] ? rcu_read_unlock+0x4b/0x4d
  [<ffffffff813a5d3d>] __sock_sendmsg_nosec+0x5f/0x6a
  [<ffffffff813a5d85>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813a662f>] sock_sendmsg+0xa3/0xbc
  [<ffffffff810cdab1>] ? might_fault+0x4e/0x9e
  [<ffffffff810cdafa>] ? might_fault+0x97/0x9e
  [<ffffffff813b02fa>] ? copy_from_user+0x2a/0x2c
  [<ffffffff813b06cc>] ? verify_iovec+0x4f/0xa3
  [<ffffffff813a6e38>] __sys_sendmsg+0x20f/0x29c
  [<ffffffff8105c5e0>] ? get_parent_ip+0x11/0x42
  [<ffffffff8110360a>] ? fcheck_files+0xac/0xea
  [<ffffffff8110375e>] ? fget_light+0x35/0xac
  [<ffffffff813a702e>] sys_sendmsg+0x3d/0x5b
  [<ffffffff8147cd79>] system_call_fastpath+0x16/0x1b
panic occurred, switching back to text console
Rebooting in 10 seconds..[greearb@fs3 linux-3.3.dev.y]$

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
