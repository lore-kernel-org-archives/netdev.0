From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: lockdep warning in ieee80211 rx path
Date: Wed, 8 Sep 2010 15:40:47 -0700
Message-ID: <20100908154047.d5f9d02b.akpm@linux-foundation.org>
References: <AANLkTin5KfmQLYxLWdhTcO-AM0t83dVq=LFCG0UGysaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56072 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755835Ab0IHWlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 18:41:06 -0400
In-Reply-To: <AANLkTin5KfmQLYxLWdhTcO-AM0t83dVq=LFCG0UGysaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Sep 2010 17:32:26 +0800
Ming Lei <tom.leiming@gmail.com> wrote:

> Seems the warning does not affect use of wireless,  false positive?
> 
> [  221.023115]
> [  221.023116] =======================================================
> [  221.023164] [ INFO: possible circular locking dependency detected ]
> [  221.023195] 2.6.36-rc3-next-20100903+ #65
> [  221.023215] -------------------------------------------------------

Is this a regression?  Was 2.6.35 OK?

Thanks.

> [  221.023246] X/2091 is trying to acquire lock:
> [  221.023268]  (slock-AF_INET/1){+.-...}, at: [<ffffffff81381151>]
> tcp_v4_rcv+0x290/0x6b7
> [  221.023323]
> [  221.023323] but task is already holding lock:
> [  221.023354]  (&(&sta->lock)->rlock){+.-...}, at:
> [<ffffffffa01edd37>] sta_rx_agg_reorder_timer_expired+0x61/0x9c
> [mac80211]
> [  221.023425]
> [  221.023426] which lock already depends on the new lock.
> [  221.023426]
> [  221.023469]
> [  221.023469] the existing dependency chain (in reverse order) is:
> [  221.023508]
> [  221.023509] -> #2 (&(&sta->lock)->rlock){+.-...}:
> [  221.023547]        [<ffffffff8107d7e3>] lock_acquire+0xe6/0x113
> [  221.023581]        [<ffffffff813ce6a4>] _raw_spin_lock_irqsave+0x5d/0x97
> [  221.023618]        [<ffffffff81063d0c>] __queue_work+0x10c/0x1bf
> [  221.023652]        [<ffffffff81063e08>] queue_work_on+0x1b/0x22
> [  221.023684]        [<ffffffff81063fb8>] queue_work+0x3a/0x5a
> [  221.023716]        [<ffffffffa0201d95>]
> ieee80211_queue_work+0x2e/0x35 [mac80211]
> [  221.023766]        [<ffffffffa01ed156>]
> ieee80211_start_tx_ba_cb_irqsafe+0x74/0x7d [mac80211]
> [  221.023816]        [<ffffffffa0337c2f>] ath9k_ampdu_action+0x8c/0x110 [ath9k]
> [  221.023857]        [<ffffffffa01ecd9f>] drv_ampdu_action+0x6f/0x7a [mac80211]
> [  221.023900]        [<ffffffffa01ed816>]
> ieee80211_tx_ba_session_handle_start+0xd2/0x2a1 [mac80211]
> [  221.023955]        [<ffffffffa01ecca8>]
> ieee80211_ba_session_work+0xac/0xeb [mac80211]
> [  221.024003]        [<ffffffff810646d8>] process_one_work+0x246/0x3cd
> [  221.024007]        [<ffffffff81065dbf>] worker_thread+0x13b/0x251
> [  221.024007]        [<ffffffff810699cb>] kthread+0x8e/0x96
> [  221.024007]        [<ffffffff8100ab64>] kernel_thread_helper+0x4/0x10
> [  221.024007]
> [  221.024007] -> #1 (_xmit_ETHER){+.-...}:
> [  221.024007]        [<ffffffff8107d7e3>] lock_acquire+0xe6/0x113
> [  221.024007]        [<ffffffff813ce6a4>] _raw_spin_lock_irqsave+0x5d/0x97
> [  221.024007]        [<ffffffff8111102f>] __delete_object+0x94/0xb1
> [  221.024007]        [<ffffffff811111ed>] delete_object_full+0x25/0x31
> [  221.024007]        [<ffffffff813bac9f>] kmemleak_free+0x26/0x45
> [  221.024007]        [<ffffffff81106c46>] kfree+0xb3/0x155
> [  221.024007]        [<ffffffff8133881d>] skb_release_data+0xc1/0xc6
> [  221.024007]        [<ffffffff8133857a>] __kfree_skb+0x1e/0x81
> [  221.024007]        [<ffffffff81376c4f>] tcp_ack+0x4c0/0x1945
> [  221.024007]        [<ffffffff8137889d>] tcp_rcv_state_process+0x159/0x8b4
> [  221.024007]        [<ffffffff8137ff44>] tcp_v4_do_rcv+0x2f3/0x330
> [  221.024007]        [<ffffffff813812e5>] tcp_v4_rcv+0x424/0x6b7
> [  221.024007]        [<ffffffff81364424>] ip_local_deliver+0x130/0x1c0
> [  221.024007]        [<ffffffff81364161>] ip_rcv+0x4d9/0x519
> [  221.024007]        [<ffffffff8133fdd9>] __netif_receive_skb+0x292/0x2bf
> [  221.024007]        [<ffffffff81340d9c>] netif_receive_skb+0x6c/0x73
> [  221.024007]        [<ffffffffa01fa89b>]
> ieee80211_deliver_skb+0xcb/0x100 [mac80211]
> [  221.024007]        [<ffffffffa01fba06>]
> ieee80211_rx_handlers+0xe7e/0x15f8 [mac80211]
> [  221.024007]        [<ffffffffa01fc66a>]
> ieee80211_invoke_rx_handlers+0x4ea/0x50f [mac80211]
> [  221.024007]        [<ffffffffa01fcf27>] ieee80211_rx+0x7b5/0x826 [mac80211]
> [  221.024007]        [<ffffffffa033968a>]
> ath_rx_send_to_mac80211+0x6f/0x78 [ath9k]
> [  221.024007]        [<ffffffffa033afbe>] ath_rx_tasklet+0xc6d/0xd7b [ath9k]
> [  221.024007]        [<ffffffffa033844a>] ath9k_tasklet+0xb1/0x14f [ath9k]
> [  221.024007]        [<ffffffff81053fb3>] tasklet_action+0x8c/0xf4
> [  221.024007]        [<ffffffff81054775>] __do_softirq+0x119/0x1fe
> [  221.024007]        [<ffffffff8100ac5c>] call_softirq+0x1c/0x30
> [  221.024007]        [<ffffffff8100c30b>] do_softirq+0x4b/0xa3
> [  221.024007]        [<ffffffff81054571>] irq_exit+0x4a/0x9f
> [  221.024007]        [<ffffffff813d5144>] do_IRQ+0xac/0xc3
> [  221.024007]        [<ffffffff813cf553>] ret_from_intr+0x0/0x16
> [  221.024007]        [<ffffffff81320a92>] cpuidle_idle_call+0xb2/0x130
> [  221.024007]        [<ffffffff81008c95>] cpu_idle+0x76/0xff
> [  221.024007]        [<ffffffff813b8b53>] rest_init+0xd7/0xde
> [  221.024007]        [<ffffffff81878da0>] start_kernel+0x3dd/0x3e8
> [  221.024007]        [<ffffffff818782c8>] x86_64_start_reservations+0xb3/0xb7
> [  221.024007]        [<ffffffff818783c4>] x86_64_start_kernel+0xf8/0x107
> [  221.024007]
> [  221.024007] -> #0 (slock-AF_INET/1){+.-...}:
> [  221.024007]        [<ffffffff8107d406>] __lock_acquire+0xa2c/0xd23
> [  221.024007]        [<ffffffff8107d7e3>] lock_acquire+0xe6/0x113
> [  221.024007]        [<ffffffff813ce47b>] _raw_spin_lock_nested+0x43/0x76
> [  221.024007]        [<ffffffff81381151>] tcp_v4_rcv+0x290/0x6b7
> [  221.024007]        [<ffffffff81364424>] ip_local_deliver+0x130/0x1c0
> [  221.024007]        [<ffffffff81364161>] ip_rcv+0x4d9/0x519
> [  221.024007]        [<ffffffff8133fdd9>] __netif_receive_skb+0x292/0x2bf
> [  221.024007]        [<ffffffff81340d9c>] netif_receive_skb+0x6c/0x73
> [  221.024007]        [<ffffffffa01fa89b>]
> ieee80211_deliver_skb+0xcb/0x100 [mac80211]
> [  221.024007]        [<ffffffffa01fba06>]
> ieee80211_rx_handlers+0xe7e/0x15f8 [mac80211]
> [  221.024007]        [<ffffffffa01fc762>]
> ieee80211_release_reorder_timeout+0xd3/0xe3 [mac80211]
> [  221.024007]        [<ffffffffa01edd42>]
> sta_rx_agg_reorder_timer_expired+0x6c/0x9c [mac80211]
> [  221.024007]        [<ffffffff8105b092>] run_timer_softirq+0x24c/0x34b
> [  221.024007]        [<ffffffff81054775>] __do_softirq+0x119/0x1fe
> [  221.024007]        [<ffffffff8100ac5c>] call_softirq+0x1c/0x30
> [  221.024007]        [<ffffffff8100c30b>] do_softirq+0x4b/0xa3
> [  221.024007]        [<ffffffff81054571>] irq_exit+0x4a/0x9f
> [  221.024007]        [<ffffffff813d51e0>] smp_apic_timer_interrupt+0x85/0x93
> [  221.024007]        [<ffffffff8100a713>] apic_timer_interrupt+0x13/0x20
> [  221.024007]        [<ffffffff813ce4f3>] _raw_spin_lock+0x45/0x78
> [  221.024007]        [<ffffffffa002cc49>] spin_lock+0xe/0x10 [drm]
> [  221.024007]        [<ffffffffa002ce47>] drm_gem_object_lookup+0x27/0x57 [drm]
> [  221.024007]        [<ffffffffa0085f6b>]
> i915_gem_do_execbuffer+0x575/0xe44 [i915]
> [  221.024007]        [<ffffffffa0086afd>]
> i915_gem_execbuffer+0x197/0x226 [i915]
> [  221.024007]        [<ffffffffa002b878>] drm_ioctl+0x27c/0x348 [drm]
> [  221.024007]        [<ffffffff811219c3>] do_vfs_ioctl+0x4c2/0x511
> [  221.024007]        [<ffffffff81121a59>] sys_ioctl+0x47/0x6a
> [  221.024007]        [<ffffffff81009cf2>] system_call_fastpath+0x16/0x1b
> [  221.024007]
> [  221.024007] other info that might help us debug this:
> [  221.024007]
> [  221.024007] 7 locks held by X/2091:
> [  221.024007]  #0:  (&dev->struct_mutex){+.+.+.}, at:
> [<ffffffffa00867dc>] i915_gem_do_execbuffer+0xde6/0xe44 [i915]
> [  221.024007]  #1:  (&(&file_private->table_lock)->rlock){+.+...},
> at: [<ffffffffa002cc49>] spin_lock+0xe/0x10 [drm]
> [  221.024007]  #2:  (&tid_agg_rx->reorder_timer){+.-...}, at:
> [<ffffffff8105aff8>] run_timer_softirq+0x1b2/0x34b
> [  221.024007]  #3:  (rcu_read_lock){.+.+..}, at: [<ffffffffa01edcd6>]
> sta_rx_agg_reorder_timer_expired+0x0/0x9c [mac80211]
> [  221.024007]  #4:  (&(&sta->lock)->rlock){+.-...}, at:
> [<ffffffffa01edd37>] sta_rx_agg_reorder_timer_expired+0x61/0x9c
> [mac80211]
> [  221.024007]  #5:  (rcu_read_lock){.+.+..}, at: [<ffffffff8133e884>]
> rcu_read_lock+0x0/0x3a
> [  221.024007]  #6:  (rcu_read_lock){.+.+..}, at: [<ffffffff81364362>]
> ip_local_deliver+0x6e/0x1c0
> [  221.024007]
> [  221.024007] stack backtrace:
> [  221.024007] Pid: 2091, comm: X Not tainted 2.6.36-rc3-next-20100903+ #65
> [  221.024007] Call Trace:
> [  221.024007]  <IRQ>  [<ffffffff8107b9ab>] print_circular_bug+0xa8/0xb6
> [  221.024007]  [<ffffffff8107d406>] __lock_acquire+0xa2c/0xd23
> [  221.024007]  [<ffffffff81010aa2>] ? native_sched_clock+0x2d/0x5f
> [  221.024007]  [<ffffffff81381151>] ? tcp_v4_rcv+0x290/0x6b7
> [  221.024007]  [<ffffffff8107d7e3>] lock_acquire+0xe6/0x113
> [  221.024007]  [<ffffffff81381151>] ? tcp_v4_rcv+0x290/0x6b7
> [  221.024007]  [<ffffffff813ce47b>] _raw_spin_lock_nested+0x43/0x76
> [  221.024007]  [<ffffffff81381151>] ? tcp_v4_rcv+0x290/0x6b7
> [  221.024007]  [<ffffffff81381151>] tcp_v4_rcv+0x290/0x6b7
> [  221.024007]  [<ffffffff81364362>] ? ip_local_deliver+0x6e/0x1c0
> [  221.024007]  [<ffffffff81364424>] ip_local_deliver+0x130/0x1c0
> [  221.024007]  [<ffffffff81364362>] ? ip_local_deliver+0x6e/0x1c0
> [  221.024007]  [<ffffffff81364161>] ip_rcv+0x4d9/0x519
> [  221.024007]  [<ffffffff8133fdd9>] __netif_receive_skb+0x292/0x2bf
> [  221.024007]  [<ffffffff81340d9c>] netif_receive_skb+0x6c/0x73
> [  221.024007]  [<ffffffff813ced95>] ? _raw_spin_unlock_irqrestore+0x69/0x77
> [  221.024007]  [<ffffffffa01fa4d3>] ? test_sta_flags+0x38/0x42 [mac80211]
> [  221.024007]  [<ffffffffa01fa89b>] ieee80211_deliver_skb+0xcb/0x100 [mac80211]
> [  221.024007]  [<ffffffffa01fba06>]
> ieee80211_rx_handlers+0xe7e/0x15f8 [mac80211]
> [  221.024007]  [<ffffffff813ced73>] ? _raw_spin_unlock_irqrestore+0x47/0x77
> [  221.024007]  [<ffffffff81010aa2>] ? native_sched_clock+0x2d/0x5f
> [  221.024007]  [<ffffffff810101b1>] ? sched_clock+0x9/0xd
> [  221.024007]  [<ffffffffa01fc756>] ?
> ieee80211_release_reorder_timeout+0xc7/0xe3 [mac80211]
> [  221.024007]  [<ffffffff8106f9ee>] ? sched_clock_cpu+0xc3/0xce
> [  221.024007]  [<ffffffff8106fa3a>] ? local_clock+0x41/0x5a
> [  221.024007]  [<ffffffff8107a06b>] ? lock_release_holdtime+0x141/0x146
> [  221.024007]  [<ffffffffa01fc762>]
> ieee80211_release_reorder_timeout+0xd3/0xe3 [mac80211]
> [  221.024007]  [<ffffffffa01edd37>] ?
> sta_rx_agg_reorder_timer_expired+0x61/0x9c [mac80211]
> [  221.024007]  [<ffffffff813ce51f>] ? _raw_spin_lock+0x71/0x78
> [  221.024007]  [<ffffffffa01edd42>]
> sta_rx_agg_reorder_timer_expired+0x6c/0x9c [mac80211]
> [  221.024007]  [<ffffffffa01edcd6>] ?
> sta_rx_agg_reorder_timer_expired+0x0/0x9c [mac80211]
> [  221.024007]  [<ffffffff8105b092>] run_timer_softirq+0x24c/0x34b
> [  221.024007]  [<ffffffff8105aff8>] ? run_timer_softirq+0x1b2/0x34b
> [  221.024007]  [<ffffffff8106d272>] ? __run_hrtimer+0x11c/0x14b
> [  221.024007]  [<ffffffffa01edcd6>] ?
> sta_rx_agg_reorder_timer_expired+0x0/0x9c [mac80211]
> [  221.024007]  [<ffffffff810546e3>] ? __do_softirq+0x87/0x1fe
> [  221.024007]  [<ffffffff81054775>] __do_softirq+0x119/0x1fe
> [  221.024007]  [<ffffffff81077256>] ? tick_dev_program_event+0x3c/0xfc
> [  221.024007]  [<ffffffff81077375>] ? tick_program_event+0x2a/0x2c
> [  221.024007]  [<ffffffffa002cc49>] ? spin_lock+0xe/0x10 [drm]
> [  221.024007]  [<ffffffff8100ac5c>] call_softirq+0x1c/0x30
> [  221.024007]  [<ffffffff8100c30b>] do_softirq+0x4b/0xa3
> [  221.024007]  [<ffffffff81054571>] irq_exit+0x4a/0x9f
> [  221.024007]  [<ffffffff813d51e0>] smp_apic_timer_interrupt+0x85/0x93
> [  221.024007]  [<ffffffff8100a713>] apic_timer_interrupt+0x13/0x20
> [  221.024007]  <EOI>  [<ffffffff8107d7fc>] ? lock_acquire+0xff/0x113
> [  221.024007]  [<ffffffffa002cc49>] ? spin_lock+0xe/0x10 [drm]
> [  221.024007]  [<ffffffff813ce4f3>] _raw_spin_lock+0x45/0x78
> [  221.024007]  [<ffffffffa002cc49>] ? spin_lock+0xe/0x10 [drm]
> [  221.024007]  [<ffffffff813ced1e>] ? _raw_spin_unlock+0x43/0x51
> [  221.024007]  [<ffffffffa002cc49>] spin_lock+0xe/0x10 [drm]
> [  221.024007]  [<ffffffffa002ce47>] drm_gem_object_lookup+0x27/0x57 [drm]
> [  221.024007]  [<ffffffffa0085f6b>] i915_gem_do_execbuffer+0x575/0xe44 [i915]
> [  221.024007]  [<ffffffff810e77c8>] ? might_fault+0x68/0xb8
> [  221.024007]  [<ffffffff810e7811>] ? might_fault+0xb1/0xb8
> [  221.024007]  [<ffffffff810e77c8>] ? might_fault+0x68/0xb8
> [  221.024007]  [<ffffffffa0086afd>] i915_gem_execbuffer+0x197/0x226 [i915]
> [  221.024007]  [<ffffffffa002b878>] drm_ioctl+0x27c/0x348 [drm]
> [  221.024007]  [<ffffffffa0086966>] ? i915_gem_execbuffer+0x0/0x226 [i915]
> [  221.024007]  [<ffffffff811219c3>] do_vfs_ioctl+0x4c2/0x511
> [  221.024007]  [<ffffffff81113ab3>] ? fsnotify_access+0x66/0x6e
> [  221.024007]  [<ffffffff81009d2a>] ? sysret_check+0x2e/0x69
> [  221.024007]  [<ffffffff81121a59>] sys_ioctl+0x47/0x6a
> [  221.024007]  [<ffffffff81009cf2>] system_call_fastpath+0x16/0x1b
> 

