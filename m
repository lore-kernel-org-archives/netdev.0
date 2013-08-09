From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Fri, 9 Aug 2013 16:40:03 +0200
Message-ID: <CF3AE072-7B80-4C35-9236-4523EE11629F@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org> <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl> <20130809141939.GL14001@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:54995 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030305Ab3HIOkM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 10:40:12 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so2058185ead.21
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 07:40:09 -0700 (PDT)
In-Reply-To: <20130809141939.GL14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Op 9 aug. 2013, om 16:19 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> On Fri, Aug 09, 2013 at 04:12:20PM +0200, Teco Boot wrote:
>> Double checked, it works. Tested with Common Open Research Emulator (CORE, from NRL).
>> 
>> === But ===
>> 
>> I had some problems with CORE. Could be me, new kernel version, the patch, CORE using network namespaces, or combination of that. sudo hangs, reboot hangs, ip address show hangs.
>> With ps -ef, I see some suspected items:
>> root      4858  4161  0 15:57 ?        00:00:00 /sbin/ip -6 addr flush dev eth0
>> root      4859     2  0 15:57 ?        00:00:00 [kworker/0:3]
>> In the emulation I use, there was no IPv6.
>> 
>> I'll try to figure out if it is CORE & netns in combination with patch. Or just the patch. Or just the new kernel.
>> Just to speed up, any idea where to look for?
> 
> echo t > /proc/sysrq-trigger and check dmesg while the system hangs. Maybe you
> have to use a serial console and send the sysrq over keyboard/break.

System was still running.
Cleared dmesg, silence.
Then performed echo t > /proc/sysrq-trigger.
Quite large dump.
Afterwards, silence again.

Teco


[ 2639.368995]  [<c11a0a50>] ? eventfd_ctx_fdget+0x60/0x60
[ 2639.368997]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369000]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369002] gdbus           S 2aa2b631     0  2562      1 0x00000000
[ 2639.369005]  e9e4db4c 00000086 00000000 2aa2b631 00000005 ecc14000 c19c9100 00000001
[ 2639.369010]  0000004c c19c9100 f739c100 f649e680 f0226300 e9e4db44 c10820cd 00000000
[ 2639.369016]  0341a04d 07000000 00000006 00004296 00000000 00004296 f3f59600 f3f59600
[ 2639.369021] Call Trace:
[ 2639.369024]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369027]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369030]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369033]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369035]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369038]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369041]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369043]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369046]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369049]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369051]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369055]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369057]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369060]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369063]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369065]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369067]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369070]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369072]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369075]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369078]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369080]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369083]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369086]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369088]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369091]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369094]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.369097]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369100]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369102]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369105]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369108]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369111]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369113]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369116]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369118]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369120] gvfs-mtp-volume S f66a1aec     0  2566      1 0x00000000
[ 2639.369127]  f66a1b4c 00000086 f73897f0 f66a1aec c106f28e e9ede000 c19c9100 bd249be9
[ 2639.369132]  0000004c c19c9100 f738e100 f697d9b0 f73897fc 00000000 f66a1b14 c12ee962
[ 2639.369138]  f66a1b70 f73897f0 f66a1b2c c106f630 f7389980 f66a1b2c 00000296 f66a1b70
[ 2639.369143] Call Trace:
[ 2639.369146]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369149]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369151]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369154]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369157]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369159]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369162]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369165]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369168]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369170]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369173]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369176]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369178]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369181]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.369184]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.369187]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.369189]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.369193]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.369196]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.369198]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.369201]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.369204]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369206]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369209]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369212]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369214]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369217]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.369220]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.369222]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.369225]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.369227]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.369230]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.369233]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369236]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.369238]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.369241]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.369244]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.369246]  [<c10a6290>] ? sys_futex+0x80/0x130
[ 2639.369249]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369252]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369254] gdbus           S 2ba62840     0  2568      1 0x00000000
[ 2639.369283]  e9d93b4c 00000086 00000000 2ba62840 00000005 ecc14000 c19c9100 00000001
[ 2639.369288]  0000004c c19c9100 f739c100 f6498cd0 f0226300 e9d93b44 c10820cd 00000000
[ 2639.369294]  0341a04d 00000253 00000006 00006032 00000000 00006032 f3f59600 f3f59600
[ 2639.369299] Call Trace:
[ 2639.369302]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369306]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369308]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369311]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369314]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369317]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369319]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369322]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369325]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369328]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369330]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369333]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369336]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369339]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369342]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369344]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369346]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369348]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369351]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369354]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369357]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369359]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369362]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369365]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369368]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369370]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369373]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.369376]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.369379]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369381]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369384]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369387]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369390]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369392]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369395]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369398]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369400]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369402] panel-4-systray S 00000012     0  2569   2414 0x00000000
[ 2639.369405]  e9e4fb4c 00200086 f3f26400 00000012 00000000 ecf76000 c19c9100 00000001
[ 2639.369411]  000000e7 c19c9100 f739c100 f6aca670 00000008 0fca7a78 f739c100 00000000
[ 2639.369416]  00000000 c16256e0 f739c100 c16256e0 e9e4fb30 c107a412 f6acd9b0 f739c100
[ 2639.369421] Call Trace:
[ 2639.369425]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.369427]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.369430]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369433]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369435]  [<c105298c>] ? irq_exit+0x5c/0xa0
[ 2639.369438]  [<c107aafe>] ? scheduler_ipi+0x4e/0xe0
[ 2639.369440]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369443]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369446]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369448]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369451]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369454]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369456]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369460]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369462]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369465]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369468]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369470]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369473]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369475]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369477]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369480]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.369483]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.369486]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369488]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369491]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369493]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.369497]  [<c151ec3b>] ? sys_recvfrom+0xcb/0x140
[ 2639.369500]  [<c1160b16>] ? do_readv_writev+0x146/0x190
[ 2639.369502]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.369505]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.369508]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369510]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369512] gvfs-afc-volume S e9e9baec     0  2571      1 0x00000000
[ 2639.369515]  e9e9bb4c 00000086 f73977f0 e9e9baec c106f28e e9dc4000 c19c9100 00000001
[ 2639.369521]  0000004c c19c9100 f739c100 f6402670 f73977fc 00000000 e9e9bb14 c12ee962
[ 2639.369526]  e9e9bb70 f73977f0 e9e9bb2c c106f630 f7397980 e9e9bb2c 00000296 e9e9bb70
[ 2639.369531] Call Trace:
[ 2639.369534]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369537]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369539]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369542]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369545]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369547]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369550]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369553]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369556]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369559]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369561]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369564]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369567]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.369583]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369585]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.369588]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.369590]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.369593]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.369595]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.369598]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369601]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369603]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.369606]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369609]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369611]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369614]  [<c107fd58>] ? effective_load.isra.30+0x68/0xa0
[ 2639.369617]  [<c10809e4>] ? select_task_rq_fair+0x674/0x6b0
[ 2639.369629]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.369632]  [<c1017458>] ? sched_clock+0x8/0x10
[ 2639.369635]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369638]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.369640]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.369643]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.369646]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.369648]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369651]  [<c1199297>] ? fsnotify+0x1e7/0x2e0
[ 2639.369654]  [<c10744c0>] ? __wake_up_locked_key+0x20/0x30
[ 2639.369657]  [<c11a0b17>] ? eventfd_write+0xc7/0x220
[ 2639.369659]  [<c1160368>] ? vfs_write+0xe8/0x160
[ 2639.369662]  [<c11a0a50>] ? eventfd_ctx_fdget+0x60/0x60
[ 2639.369664]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369667]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369669] gvfs-afc-volume S c1118a53     0  2572      1 0x00000000
[ 2639.369672]  e9ea9f00 00000086 e9ea9e90 c1118a53 e9ea9ea4 e3174000 c19c9100 00000001
[ 2639.369678]  0000002c c19c9100 f739c100 f0292670 80000000 c116d39d ecf29000 810000de
[ 2639.369683]  f7939800 f73fd000 f695cfc0 80000000 e9ea9ed8 c103ce08 e9ea9eec c161407d
[ 2639.369689] Call Trace:
[ 2639.369691]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.369694]  [<c116d39d>] ? final_putname+0x1d/0x40
[ 2639.369697]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369700]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369703]  [<c106bfdc>] ? prepare_to_wait+0x4c/0x80
[ 2639.369705]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369708]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369710]  [<c119bfb3>] inotify_read+0x213/0x280
[ 2639.369713]  [<c11601d3>] ? rw_verify_area+0x63/0x110
[ 2639.369715]  [<c106bd80>] ? finish_wait+0x70/0x70
[ 2639.369718]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369720]  [<c1160469>] vfs_read+0x89/0x160
[ 2639.369723]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369725]  [<c1160587>] sys_read+0x47/0x80
[ 2639.369728]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369730] gdbus           S ad8ab9c0     0  2574      1 0x00000000
[ 2639.369733]  e9eadb4c 00000086 00000000 ad8ab9c0 00000005 ecc14000 c19c9100 00000001
[ 2639.369738]  0000004c c19c9100 f739c100 e9eb0cd0 f3da9c00 e9eadb44 c10820cd 00000000
[ 2639.369744]  00d7e80d 00000000 00000006 000068cc 00000000 000068cc f3f5b200 f3f5b200
[ 2639.369749] Call Trace:
[ 2639.369752]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369755]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369758]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369760]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369763]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369766]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369769]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369771]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369774]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369777]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369779]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369782]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369785]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369788]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369790]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369793]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369795]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369798]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369800]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369803]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369806]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369808]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369811]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369814]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369817]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369819]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369822]  [<c1017458>] ? sched_clock+0x8/0x10
[ 2639.369824]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369827]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.369830]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369833]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369836]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369838]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369841]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369844]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369846]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369849]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369852]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369854] xfce4-indicator S e9eb9aec     0  2576   2414 0x00000000
[ 2639.369861]  e9eb9b4c 00000086 f73897f0 e9eb9aec c106f28e ecc28000 c19c9100 00000000
[ 2639.369866]  000000e7 c19c9100 f738e100 e9cb8cd0 f73897fc 00000000 e9eb9b14 c12ee962
[ 2639.369871]  e9eb9b70 f73897f0 e9eb9b2c c106f630 f7389980 e9eb9b2c 00000296 e9eb9b70
[ 2639.369877] Call Trace:
[ 2639.369880]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369883]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369885]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369888]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369890]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369893]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369896]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369899]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369902]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369904]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369907]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369909]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369912]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369915]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369918]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369921]  [<c114d4fc>] ? kfree+0xcc/0x100
[ 2639.369924]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369927]  [<c114d5f7>] ? kmem_cache_free+0xc7/0x100
[ 2639.369929]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369931]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369934]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369936]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369939]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.369941]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.369944]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369946]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369949]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369951]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.369955]  [<c151ec81>] ? sys_recvfrom+0x111/0x140
[ 2639.369958]  [<c1160b16>] ? do_readv_writev+0x146/0x190
[ 2639.369961]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.369963]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.369966]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369969]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369971] gdbus           S 0000b40e     0  2603   2414 0x00000000
[ 2639.370004]  e9fd5b4c 00200086 a88cb000 0000b40e 423a3cbf e9eb8000 c19c9100 00000000
[ 2639.370010]  00000041 c19c9100 f738e100 f6b4c010 d224c953 e9fd5b44 c108204a f738e148
[ 2639.370015]  00000000 00000036 e9fd5b44 c107f87c f68dec10 f3f5b200 00000001 e9fd5b44
[ 2639.370020] Call Trace:
[ 2639.370024]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370027]  [<c107f87c>] ? update_cfs_rq_blocked_load+0xbc/0x220
[ 2639.370030]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370033]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370036]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370038]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370041]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370043]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370046]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370049]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370052]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370054]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370057]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370060]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.370063]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.370066]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.370068]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.370071]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370073]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370075]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370078]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.370080]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.370084]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370086]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370089]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370092]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370094]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370097]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.370100]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370102]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370105]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370108]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370111]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.370114]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.370117]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370119]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370122]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370125]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370127]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370130]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370132] dconf worker    S e9fd7aec     0  2604   2414 0x00000000
[ 2639.370135]  e9fd7b4c 00200086 f73977f0 e9fd7aec c106f28e e9eb8000 c19c9100 00000001
[ 2639.370141]  00000006 c19c9100 f739c100 e9fd8000 f73977fc 00000000 e9fd7b14 c12ee962
[ 2639.370146]  e9fd7b70 f73977f0 e9fd7b2c c106f630 f7397980 e9fd7b2c 00200296 e9fd7b70
[ 2639.370152] Call Trace:
[ 2639.370155]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370157]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370160]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370163]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370165]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370168]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370171]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370174]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370176]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370179]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370182]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370184]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370187]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.370190]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370192]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370195]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.370197]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.370200]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.370202]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.370205]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.370208]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370210]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370212]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370215]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370218]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370221]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.370224]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.370226]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370229]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370231]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370234]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370237]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.370239]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370242]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370245]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370247]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370250]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370253]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370255]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.370258]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370260] panel-9-actions S e9db5aec     0  2586   2414 0x00000000
[ 2639.370262]  e9db5b4c 00200086 f73897f0 e9db5aec c106f28e ee3ec000 c19c9100 00000000
[ 2639.370268]  00000258 c19c9100 f738e100 e9f00000 f73897fc 00000000 e9db5b14 c12ee962
[ 2639.370273]  e9db5b70 f73897f0 e9db5b2c c106f630 f7389980 e9db5b2c 00200296 e9db5b70
[ 2639.370279] Call Trace:
[ 2639.370281]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370284]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370287]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370289]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370292]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370295]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370297]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370300]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370303]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370305]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.370308]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370311]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370313]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370316]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.370319]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.370321]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.370324]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370327]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370329]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.370332]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370335]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370337]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370340]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.370344]  [<c151ec3b>] ? sys_recvfrom+0xcb/0x140
[ 2639.370347]  [<c1018e96>] ? __switch_to_xtra+0x126/0x140
[ 2639.370349]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.370353]  [<c1010c58>] ? __switch_to+0x2a8/0x330
[ 2639.370355]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.370358]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.370361]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.370363]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.370366]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370369]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370371] gvfsd-trash     S e9fa1aec     0  2594      1 0x00000000
[ 2639.370374]  e9fa1b4c 00000082 f73977f0 e9fa1aec c106f28e e3232000 c19c9100 181a34d9
[ 2639.370379]  00000042 c19c9100 f739c100 e9f53340 e9fa1b04 c103ce08 e9fa1b18 c161407d
[ 2639.370385]  f73977f0 e9fa1b90 e9fa1b38 e9fa1b2c c106f705 e9fa1b2c 00000296 e9fa1b70
[ 2639.370390] Call Trace:
[ 2639.370393]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370396]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370399]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370401]  [<c106f705>] ? lock_hrtimer_base.isra.21+0x25/0x50
[ 2639.370404]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370407]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370409]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370412]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370415]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370418]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370420]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370423]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370425]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370429]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370431]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370434]  [<c106bd5d>] ? finish_wait+0x4d/0x70
[ 2639.370436]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.370440]  [<c125817e>] ? wait_answer_interruptible+0x8e/0xa0
[ 2639.370442]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370445]  [<c107f87c>] ? update_cfs_rq_blocked_load+0xbc/0x220
[ 2639.370448]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370451]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370453]  [<c1173f3b>] ? d_rehash+0x2b/0x40
[ 2639.370456]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370459]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370461]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370464]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.370467]  [<c111847c>] ? release_pages+0x17c/0x1b0
[ 2639.370470]  [<c11180d0>] ? lru_deactivate_fn+0x190/0x190
[ 2639.370473]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.370476]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.370479]  [<c114d5f7>] ? kmem_cache_free+0xc7/0x100
[ 2639.370482]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370485]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370487]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370490]  [<c106bd5d>] ? finish_wait+0x4d/0x70
[ 2639.370493]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370495]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370498]  [<c1278b90>] ? security_file_permission+0x90/0xb0
[ 2639.370501]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370504]  [<c1099fcc>] ? getnstimeofday+0x4c/0x130
[ 2639.370507]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370510]  [<c105172a>] ? sys_gettimeofday+0x2a/0x70
[ 2639.370513]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370515] gdbus           S 336b5327     0  2595      1 0x00000000
[ 2639.370524]  e9f9fb4c 00000082 00000000 336b5327 00000005 ee29c000 c19c9100 00000000
[ 2639.370529]  00000007 c19c9100 f738e100 e9f02670 f0226300 e9f9fb44 c10820cd 00000000
[ 2639.370535]  0341a04d 00000000 00000006 00004b2c 00000000 00004b2c f3f59600 f6921c00
[ 2639.370540] Call Trace:
[ 2639.370543]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370547]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.370549]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370552]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370555]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370558]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370561]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370563]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370566]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370569]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370571]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370575]  [<c1526d7c>] ? __alloc_skb+0x7c/0x250
[ 2639.370577]  [<c1520c45>] ? sock_alloc_send_pskb+0x185/0x2d0
[ 2639.370580]  [<c1520c45>] ? sock_alloc_send_pskb+0x185/0x2d0
[ 2639.370583]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370586]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370588]  [<c152511c>] ? skb_queue_tail+0x3c/0x50
[ 2639.370591]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.370594]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370597]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370599]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370602]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370604]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370607]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370610]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370613]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370615]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370618]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370621]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370624]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.370627]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.370629]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370632]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.370635]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.370637]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370640]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370643]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370645] gconfd-2        S e3005aec     0  2608      1 0x00000000
[ 2639.370648]  e3005b4c 00000086 f73977f0 e3005aec c106f28e e3005aec c19c9100 9910b026
[ 2639.370653]  0000025f c19c9100 f739c100 e9f56680 f73977f0 89979294 00000266 00000000
[ 2639.370659]  89979294 00000266 e3005b38 c19c47c0 00000001 e3005b2c 00000001 e3005b70
[ 2639.370665] Call Trace:
[ 2639.370667]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370671]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370673]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.370676]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.370678]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.370681]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370684]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370687]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370689]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.370692]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370695]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370698]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.370701]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.370704]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.370706]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.370709]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.370712]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370715]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370717]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370720]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.370723]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370727]  [<c1130b0c>] ? unmap_single_vma+0x6c/0xd0
[ 2639.370730]  [<c112f238>] ? free_pgtables+0xa8/0xf0
[ 2639.370733]  [<c112ecf7>] ? tlb_finish_mmu+0x17/0x40
[ 2639.370735]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370738]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370741]  [<c1278b90>] ? security_file_permission+0x90/0xb0
[ 2639.370743]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.370746]  [<c1170b84>] ? poll_select_set_timeout+0x64/0x80
[ 2639.370749]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370751]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370753] indicator-appli S e3025aec     0  2611      1 0x00000000
[ 2639.370803]  e3025b4c 00200082 f73977f0 e3025aec c106f28e ecc14000 c19c9100 00000000
[ 2639.370808]  000001f0 c19c9100 f738e100 e9eb3340 f73977fc 00000000 e3025b14 c12ee962
[ 2639.370814]  e3025b70 f73977f0 e3025b2c c106f630 f7397980 e3025b2c 00200296 e3025b70
[ 2639.370819] Call Trace:
[ 2639.370823]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370826]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370828]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370831]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370834]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370837]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370840]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370842]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370845]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370848]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.370850]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370853]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370856]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370859]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.370862]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.370864]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.370867]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.370869]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370872]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370874]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370877]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.370880]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370883]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370886]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370889]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370891]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.370894]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370897]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370899]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370902]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370905]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370907]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370910]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.370913]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370915]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370918]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370921]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370924]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370926]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370942]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370971] gdbus           S 41792f5c     0  2618      1 0x00000000
[ 2639.370974]  e307db4c 00200082 00000000 41792f5c 00000034 ecc14000 c19c9100 00000000
[ 2639.370980]  00000041 c19c9100 f738e100 e304b340 f3da9c00 e307db44 c10820cd 00000000
[ 2639.370985]  013a014a 00000000 00000041 000082cd 00000000 000082cd f3f5b200 f3f5b200
[ 2639.370991] Call Trace:
[ 2639.370994]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370997]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371000]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371003]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371006]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371008]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371011]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371014]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371016]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371019]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371022]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371025]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371028]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371031]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371034]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371037]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371039]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371042]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371045]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371048]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371051]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371053]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371056]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371059]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.371061]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.371065]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371067]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371070]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371073]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371076]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371078]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371081]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371084]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371086] indicator-sound S f73977fc     0  2613      1 0x00000000
[ 2639.371089]  e3029b4c 00200082 f00a7b78 f73977fc e3029af0 ecf76000 c19c9100 00000000
[ 2639.371094]  00000265 c19c9100 f738e100 e9fdb340 00000000 f7397000 e3029b0c c10319eb
[ 2639.371099]  e3029b24 c10a0805 00000000 f7397000 f73977c0 00000003 e3029b34 c10a1bd9
[ 2639.371105] Call Trace:
[ 2639.371108]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.371111]  [<c10a0805>] ? clockevents_program_event+0x95/0x140
[ 2639.371114]  [<c10a1bd9>] ? tick_program_event+0x29/0x30
[ 2639.371117]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.371120]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371122]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371125]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371128]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371130]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371133]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371136]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371139]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371141]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371144]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371147]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.371150]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.371152]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.371155]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.371158]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371160]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371162]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371165]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.371168]  [<c1052bc8>] ? raise_softirq_irqoff+0x8/0x30
[ 2639.371171]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371173]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371176]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371178]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371181]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.371184]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.371187]  [<c151ec81>] ? sys_recvfrom+0x111/0x140
[ 2639.371190]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.371193]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.371196]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.371198]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.371201]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.371204]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371206]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.371209]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371214] gdbus           S 97ac1adb     0  2622      1 0x00000000
[ 2639.371217]  e309fb4c 00200082 00000000 97ac1adb 00000006 ecc14000 c19c9100 00000000
[ 2639.371222]  00000007 c19c9100 f738e100 e304a670 f3da9c00 e309fb44 c10820cd 00000000
[ 2639.371228]  00dfea1d 000001af 00000007 0000359d 00000000 0000359d f3f5b200 f3f5b200
[ 2639.371233] Call Trace:
[ 2639.371236]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371239]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371242]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371245]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371248]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371250]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371253]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371256]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371258]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371261]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371264]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371267]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.371269]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371272]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371275]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371277]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371280]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371283]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371286]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371289]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371292]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371294]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371297]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371300]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371303]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371305]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.371308]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.371311]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371314]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371317]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371319]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371322]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371325]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371327]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371330]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371332] dconf worker    S e3023aec     0  2624      1 0x00000000
[ 2639.371358]  e3023b4c 00200082 f73897f0 e3023aec c106f28e e9d8c000 c19c9100 00000000
[ 2639.371363]  00000007 c19c9100 f738e100 e9fde680 f73897fc 00000000 e3023b14 c12ee962
[ 2639.371369]  e3023b70 f73897f0 e3023b2c c106f630 f7389980 e3023b2c 00200296 e3023b70
[ 2639.371374] Call Trace:
[ 2639.371377]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.371380]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.371383]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.371385]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.371388]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371391]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371394]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371396]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371399]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371402]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371405]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371407]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371410]  [<c1083b94>] ? task_tick_fair+0x154/0x6f0
[ 2639.371413]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.371416]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.371419]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371422]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371424]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371427]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.371429]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371432]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371434]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.371437]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.371440]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.371443]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.371445]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.371448]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371450]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371453]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.371456]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371458]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.371462]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.371464]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371467]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.371470]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.371472]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371475]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371477]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.371480]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371482] obex-data-serve S 00000016     0  2647      1 0x00000000
[ 2639.371489]  e317db4c 00000086 ffffffe9 00000016 00000007 ecc14000 c19c9100 00000000
[ 2639.371494]  000001f0 c19c9100 f738e100 e3048000 f68ddc00 0000002a 00000000 e317db50
[ 2639.371499]  00000000 f68ddc00 f3f59600 e3048000 e317db44 c1083924 00000008 28af3475
[ 2639.371505] Call Trace:
[ 2639.371508]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.371511]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371514]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371516]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371519]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371522]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371524]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371527]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.371530]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371532]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371535]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371538]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.371541]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.371544]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.371546]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371548]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371551]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371553]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.371557]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371559]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371562]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371564]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371567]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371569]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.371572]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.371574]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.371577]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.371580]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.371583]  [<c105b041>] ? update_process_times+0x61/0x70
[ 2639.371585]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.371588]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.371591]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371593]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.371596]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.371598]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371601]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371604]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371606] ntpd            D 00200292     0  2728      1 0x00000004
[ 2639.371632]  e3175e40 00200086 e3175dd4 00200292 f657bdd8 e3175df4 c19c9100 d0da4e08
[ 2639.371638]  0000005b c19c9100 f738e100 e3182670 e3116f40 e3175e34 e3116f60 e3175e18
[ 2639.371643]  e3175e0c bfd79c10 e3116f40 bfd79c80 e3175e8c c1019d90 ffff037f ffff0020
[ 2639.371648] Call Trace:
[ 2639.371652]  [<c1019d90>] ? save_fsave_header+0x30/0x90
[ 2639.371655]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371658]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.371660]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.371663]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.371667]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.371670]  [<c1533adf>] dev_ioctl+0x2af/0x4d0
[ 2639.371673]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371676]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371680]  [<c15851a0>] ? udp_poll+0x70/0x70
[ 2639.371682]  [<c151cb05>] sock_ioctl+0x85/0x270
[ 2639.371685]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.371687]  [<c151ca80>] ? sock_fasync+0x90/0x90
[ 2639.371690]  [<c116fb50>] do_vfs_ioctl+0x80/0x580
[ 2639.371693]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.371696]  [<c11797a2>] ? __fd_install+0x42/0x60
[ 2639.371698]  [<c11797e0>] ? fd_install+0x20/0x30
[ 2639.371701]  [<c151e161>] ? sys_socket+0x71/0xb0
[ 2639.371703]  [<c151f400>] ? sys_socketcall+0x70/0x2b0
[ 2639.371706]  [<c11700bb>] sys_ioctl+0x6b/0x80
[ 2639.371709]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371711] xfce4-terminal  R running      0  2736      1 0x00000000
[ 2639.371714]  ee145fa4 00200086 c13a44ef 00000000 00000000 f6946000 c19c9100 850e3308
[ 2639.371719]  00000266 c19c9100 f739c100 e3186680 b953baf1 e9f88000 c13a4380 00000001
[ 2639.371724]  ee145f8c c116030c ee145f98 a437c6b0 00000660 c13a4380 f5e9bb74 e9f88000
[ 2639.371730] Call Trace:
[ 2639.371733]  [<c13a44ef>] ? tty_write+0x16f/0x240
[ 2639.371736]  [<c13a4380>] ? tty_write_lock+0x60/0x60
[ 2639.371738]  [<c116030c>] ? vfs_write+0x8c/0x160
[ 2639.371741]  [<c13a4380>] ? tty_write_lock+0x60/0x60
[ 2639.371743]  [<c1160620>] ? sys_write+0x60/0x80
[ 2639.371746]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371748]  [<c1614346>] work_resched+0x5/0x20
[ 2639.371754] gdbus           S 80000000     0  2737      1 0x00000000
[ 2639.371757]  e9d53b4c 00200086 00000000 80000000 93259553 ee144000 c19c9100 00000000
[ 2639.371762]  000001f0 c19c9100 f738e100 e3180000 ac01498d e9d53b44 c108204a f738e148
[ 2639.371767]  00000000 00000084 e9d53b44 c107f94c f3f36810 f3f5b200 00000001 e9d53b44
[ 2639.371773] Call Trace:
[ 2639.371776]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.371779]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.371782]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371784]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371787]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371790]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371793]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371795]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371798]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371801]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371803]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371806]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371809]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371812]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371815]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371818]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371820]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371823]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371826]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371829]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371831]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371834]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371838]  [<c112f8c7>] ? do_wp_page+0x3e7/0x8e0
[ 2639.371840]  [<c11144ed>] ? free_pages_prepare+0xdd/0x140
[ 2639.371843]  [<c11146c9>] ? __free_pages+0x49/0x70
[ 2639.371845]  [<c1114756>] ? free_pages+0x26/0x30
[ 2639.371848]  [<c1041ac0>] ? pgd_free+0xf0/0x100
[ 2639.371851]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371867]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371871]  [<c1619cd6>] ? kprobe_flush_task+0x66/0xc0
[ 2639.371873]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.371876]  [<c1078f09>] ? finish_task_switch+0xa9/0xc0
[ 2639.371879]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.371881]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371884]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371887]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371890]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371917] gmain           S 00000000     0  2741      1 0x00000000
[ 2639.371921]  e31d1b4c 00200086 00000000 00000000 00000000 ee144000 c19c9100 00000001
[ 2639.371926]  00000009 c19c9100 f739c100 e32459b0 00000000 00000000 00000000 00000000
[ 2639.371932]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.371937] Call Trace:
[ 2639.371941]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371944]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371947]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371950]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371952]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371955]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371958]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371961]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371965]  [<c12e771f>] ? cpumask_next_and+0x1f/0x40
[ 2639.371968]  [<c1085f4d>] ? update_sd_lb_stats+0xcd/0x480
[ 2639.371971]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371973]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.371977]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.371979]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.371982]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.371985]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.371988]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.371991]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.371993]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.371996]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.371999]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372002]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372004]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372007]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372010]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372012]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372014] gnome-pty-helpe S 00000000     0  2739   2736 0x00000000
[ 2639.372021]  e321dd40 00000086 00000000 00000000 00000d00 ee144000 c19c9100 00000001
[ 2639.372026]  000001f0 c19c9100 f739c100 e3183340 e321dd1c 00000000 c1637fac f5eaf800
[ 2639.372032]  e321dd1c c12086d7 f797ac60 00000a86 00000180 0001ad00 00000000 e321dd60
[ 2639.372037] Call Trace:
[ 2639.372041]  [<c12086d7>] ? __ext4_journal_stop+0x57/0x80
[ 2639.372045]  [<c11eca1b>] ? ext4_da_write_end+0x9b/0x310
[ 2639.372048]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372050]  [<c161198d>] schedule_timeout+0x19d/0x240
[ 2639.372053]  [<c110d7c8>] ? generic_file_buffered_write+0x178/0x220
[ 2639.372056]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372059]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372061]  [<c106bfdc>] ? prepare_to_wait+0x4c/0x80
[ 2639.372064]  [<c15b28fc>] unix_stream_recvmsg+0x22c/0x6c0
[ 2639.372067]  [<c1161da1>] ? __sb_end_write+0x31/0x70
[ 2639.372070]  [<c106bd80>] ? finish_wait+0x70/0x70
[ 2639.372073]  [<c151cfaa>] sock_aio_read+0x10a/0x140
[ 2639.372076]  [<c11a45c1>] ? __posix_lock_file+0x2c1/0x5c0
[ 2639.372079]  [<c115fc17>] do_sync_read+0x97/0xd0
[ 2639.372082]  [<c116051d>] vfs_read+0x13d/0x160
[ 2639.372084]  [<c1160587>] sys_read+0x47/0x80
[ 2639.372087]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372089] bash            S e3161eac     0  2740   2736 0x00000000
[ 2639.372095]  e3161f18 00000082 ecc50ec0 e3161eac c12798d4 f6b58000 c19c9100 8de36aae
[ 2639.372101]  0000000a c19c9100 f738e100 e3180cd0 ecd7ed80 c1043d16 094fd8f8 80000000
[ 2639.372106]  e319c300 00000000 e30e3250 e319c300 e3161f28 c1132f15 e3161ef8 c103ce08
[ 2639.372111] Call Trace:
[ 2639.372115]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372118]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372120]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372123]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372126]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372129]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372131]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372133]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372136]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372139]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372141]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372143] sudo            S 00000000     0  2789   2740 0x00000000
[ 2639.372146]  e9f7fabc 00000086 e9f7fa78 00000000 00000000 f6b58000 c19c9100 1ae307bf
[ 2639.372152]  0000000b c19c9100 f738e100 e32419a0 f5c01380 ee2b4780 e9f7fae0 00000000
[ 2639.372157]  f5c01380 e9f7fab0 c114dc5f 00000001 00000001 c1213815 c1213815 00000038
[ 2639.372162] Call Trace:
[ 2639.372166]  [<c114dc5f>] ? __kmalloc+0x11f/0x160
[ 2639.372169]  [<c1213815>] ? ext4_ext_find_extent+0x285/0x310
[ 2639.372171]  [<c1213815>] ? ext4_ext_find_extent+0x285/0x310
[ 2639.372174]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372177]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372180]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372182]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372185]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372188]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372190]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372193]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372195]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372198]  [<c11710c9>] do_select+0x529/0x610
[ 2639.372201]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372204]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372207]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.372209]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372212]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372215]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372217]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372221]  [<c15523f8>] ? __netlink_sendskb+0x28/0x40
[ 2639.372224]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372227]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372229]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372232]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372234]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372238]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.372241]  [<c12e77b5>] ? cpumask_any_but+0x25/0x40
[ 2639.372243]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.372246]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.372249]  [<c1131b3c>] ? handle_pte_fault+0x22c/0x510
[ 2639.372251]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372254]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372257]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.372259]  [<c107c87d>] ? wake_up_new_task+0xdd/0x130
[ 2639.372262]  [<c10499d4>] ? do_fork+0xe4/0x300
[ 2639.372265]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.372267]  [<c117985b>] ? __close_fd+0x6b/0x90
[ 2639.372270]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372272] su              S e30ddeac     0  2807   2789 0x00000000
[ 2639.372299]  e30ddf18 00000082 e30bff40 e30ddeac c12798d4 f6546000 c19c9100 00000001
[ 2639.372305]  0000000b c19c9100 f739c100 e3240000 ecd7d340 c1043d16 b75e8690 00000000
[ 2639.372310]  e30b63c0 00000000 e319edd0 e30b63c0 e30ddf28 c1132f15 e30ddef8 c103ce08
[ 2639.372315] Call Trace:
[ 2639.372319]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372322]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372324]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372327]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372330]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372332]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372335]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372337]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372340]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372342]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372345]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372347] bash            R running      0  2817   2807 0x00000000
[ 2639.372350]  0000cd7c 00000092 00004c1a e30bbe28 c104bc47 e30bbdf8 c103ce08 00000092
[ 2639.372355]  c19e2078 e300be0c 00000086 c1896454 e30bbe1c 00000000 00004c1b 00004c1b
[ 2639.372361]  00000000 00000001 00000000 e30bbe70 00000046 00000009 0301c340 00004c19
[ 2639.372366] Call Trace:
[ 2639.372369]  [<c10a8130>] ? __module_text_address+0x10/0x60
[ 2639.372373]  [<c10ada0d>] ? is_module_text_address+0xd/0x20
[ 2639.372375]  [<c1068ebf>] ? __kernel_text_address+0x4f/0x70
[ 2639.372378]  [<c10140e3>] ? print_context_stack+0x63/0xd0
[ 2639.372381]  [<c1013357>] ? dump_trace+0x97/0x100
[ 2639.372384]  [<c10142bc>] show_trace_log_lvl+0x4c/0x60
[ 2639.372387]  [<c1013418>] show_stack_log_lvl+0x58/0xe0
[ 2639.372390]  [<c1014323>] show_stack+0x23/0x30
[ 2639.372393]  [<c107c3b1>] sched_show_task+0xa1/0x100
[ 2639.372395]  [<c107c46e>] show_state_filter+0x5e/0x90
[ 2639.372399]  [<c13ae85f>] sysrq_handle_showstate+0xf/0x20
[ 2639.372401]  [<c13aece9>] __handle_sysrq+0xe9/0x140
[ 2639.372404]  [<c13aed40>] ? __handle_sysrq+0x140/0x140
[ 2639.372407]  [<c13aed80>] write_sysrq_trigger+0x40/0x50
[ 2639.372410]  [<c11b1e04>] proc_reg_write+0x64/0xa0
[ 2639.372412]  [<c11b1da0>] ? proc_reg_poll+0xa0/0xa0
[ 2639.372415]  [<c116030c>] vfs_write+0x8c/0x160
[ 2639.372417]  [<c11b1da0>] ? proc_reg_poll+0xa0/0xa0
[ 2639.372420]  [<c1179be5>] ? sys_dup3+0x95/0xe0
[ 2639.372422]  [<c1160607>] sys_write+0x47/0x80
[ 2639.372425]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372427] kworker/1:1H    S e9fdd000     0  2827      2 0x00000000
[ 2639.372430]  e31ebf3c 00000046 00000000 e9fdd000 f6433cbc e32de000 c19c9100 00000001
[ 2639.372436]  0000002a c19c9100 f739c100 e9fdcce0 e31ebef8 c12c816e f680f744 f680f744
[ 2639.372441]  e9fa2d80 f7397604 e31ebf44 c10657b1 f739c100 e9fdcce0 f5d03756 f5d0be84
[ 2639.372446] Call Trace:
[ 2639.372450]  [<c12c816e>] ? __blk_run_queue+0x2e/0x40
[ 2639.372453]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.372456]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372459]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.372461]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.372464]  [<c106b694>] kthread+0x94/0xa0
[ 2639.372467]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.372470]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.372472]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.372474] bash            S ee3bfeac     0  3182   2736 0x00000000
[ 2639.372477]  ee3bff18 00000082 e31cff00 ee3bfeac c12798d4 f6b58000 c19c9100 eda7669d
[ 2639.372482]  00000019 c19c9100 f738e100 e304e680 f695d180 c1043d16 09ead8f8 80000000
[ 2639.372488]  e3010300 00000000 e3145278 e3010300 ee3bff28 c1132f15 ee3bfef8 c103ce08
[ 2639.372493] Call Trace:
[ 2639.372496]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372499]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372501]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372504]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372507]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372509]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372512]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372514]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372517]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372519]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372522]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372524] dconf-service   S 00000286     0  3256      1 0x00000000
[ 2639.372527]  e31f1b4c 00000082 f6cf11f8 00000286 00000000 e31bc000 c19c9100 00000000
[ 2639.372532]  00000018 c19c9100 f738e100 e9f06680 00000002 e31f1b10 f6fca000 ea009230
[ 2639.372538]  e31f1b58 c12377b5 00000000 e31f1b6c c1237c68 f5839f18 72cd5d66 f5eaf800
[ 2639.372543] Call Trace:
[ 2639.372547]  [<c12377b5>] ? jbd2_journal_dirty_metadata+0xb5/0x2b0
[ 2639.372550]  [<c1237c68>] ? do_get_write_access+0x2b8/0x390
[ 2639.372553]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372556]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372558]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372561]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372564]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372567]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372569]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372572]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372576]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372579]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372582]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372585]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.372587]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.372590]  [<c12361c8>] ? __jbd2_journal_temp_unlink_buffer+0x38/0xf0
[ 2639.372593]  [<c1237125>] ? __jbd2_journal_file_buffer+0xb5/0x1b0
[ 2639.372596]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372599]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372601]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372604]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372606]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.372609]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.372612]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.372615]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.372617]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.372620]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372623]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372625]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.372628]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.372631]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.372633]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.372636]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372639]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372642]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372644]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372647]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372649]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372652] gdbus           S 62d98fbb     0  3257      1 0x00000000
[ 2639.372654]  e31bdb4c 00000082 e31bdb00 62d98fbb 0000002c f3f5b200 c19c9100 7759bb4b
[ 2639.372660]  00000018 c19c9100 f738e100 f689cce0 f3da9c00 e31bdb44 c10820cd 00000000
[ 2639.372665]  00dfea1d ee093f00 00000018 00004526 00000000 00004526 f3f5b200 f3f5b200
[ 2639.372671] Call Trace:
[ 2639.372674]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372677]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372679]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372682]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372685]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372688]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372690]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372693]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372696]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372698]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372701]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372704]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.372707]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.372710]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.372713]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.372715]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.372718]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.372721]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372724]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372726]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372729]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.372732]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.372735]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.372737]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.372740]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372743]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.372746]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.372748]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.372751]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.372754]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.372757]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.372759]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372762]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372764]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372769] gmain           S 00000000     0  3258      1 0x00000000
[ 2639.372773]  e327bb4c 00000082 00000000 00000000 00000000 e9eaa000 c19c9100 00000001
[ 2639.372778]  00000018 c19c9100 f739c100 e304d9b0 00000000 00000000 00000000 00000000
[ 2639.372783]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.372788] Call Trace:
[ 2639.372792]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372795]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372798]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372800]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372803]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372806]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372809]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372811]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372814]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372817]  [<c12e77b5>] ? cpumask_any_but+0x25/0x40
[ 2639.372820]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372823]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372826]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372828]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.372831]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.372833]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372836]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372839]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372841]  [<c10846c5>] ? enqueue_entity+0x535/0xd20
[ 2639.372844]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.372847]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.372849]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.372852]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.372855]  [<c104164a>] ? pte_alloc_one+0x3a/0x50
[ 2639.372858]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372860]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372863]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372866]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372868]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372871]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372873] wish8.5         S e3177db8     0  3283   3182 0x00000000
[ 2639.372876]  e3177e18 00200086 f73977f0 e3177db8 c106f28e e3177db8 c19c9100 83924849
[ 2639.372881]  00000266 c19c9100 f739c100 e9fd8cd0 f73977f0 889fe920 00000266 00000000
[ 2639.372887]  889fe920 00000266 e3177e08 c19c47c0 00000001 359d3000 00000001 e3177e24
[ 2639.372892] Call Trace:
[ 2639.372895]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.372898]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372901]  [<c10a382f>] futex_wait_queue_me+0xcf/0xf0
[ 2639.372904]  [<c10a3f0d>] futex_wait+0x16d/0x270
[ 2639.372907]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.372909]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.372912]  [<c10a5dd2>] do_futex+0x112/0x550
[ 2639.372914]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.372917]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.372920]  [<c10a6290>] sys_futex+0x80/0x130
[ 2639.372923]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372924] wish8.5         S c12ee9f0     0  3286   3182 0x00000000
[ 2639.372927]  ecffdabc 00000086 ecffda58 c12ee9f0 f7397980 e3176000 c19c9100 00000001
[ 2639.372933]  00000266 c19c9100 f739c100 e9eb4ce0 ecffda74 c10319eb ecffda8c c10a0805
[ 2639.372938]  00000000 f7397000 f73977c0 00000003 ecffda9c c10a1bd9 00000000 00000000
[ 2639.372943] Call Trace:
[ 2639.372946]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.372949]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.372952]  [<c10a0805>] ? clockevents_program_event+0x95/0x140
[ 2639.372955]  [<c10a1bd9>] ? tick_program_event+0x29/0x30
[ 2639.372957]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.372960]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372963]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372966]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372968]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372971]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372974]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372976]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372979]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372981]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372984]  [<c11710c9>] do_select+0x529/0x610
[ 2639.372987]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372990]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372992]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372995]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372997]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372999]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.373002]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.373005]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.373007]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.373010]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.373013]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.373016]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.373018]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.373021]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.373024]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.373026]  [<c10a39f9>] ? get_futex_key+0x139/0x260
[ 2639.373029]  [<c16131c3>] ? schedule+0x23/0x60
[ 2639.373032]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373035]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373038]  [<c115fc17>] ? do_sync_read+0x97/0xd0
[ 2639.373041]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.373043]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.373046]  [<c11605a0>] ? sys_read+0x60/0x80
[ 2639.373049]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373050] vnoded          S e3233e60     0  4150      1 0x00000000
[ 2639.373053]  e3233ec0 00000086 f73977f0 e3233e60 c106f28e e3132000 c19c9100 00000001
[ 2639.373072]  0000025e c19c9100 f739c100 e3240cd0 f73977f0 7b45f363 0000026c 00000000
[ 2639.373077]  7b45f363 0000026c e3233eac c19c47c0 00000001 e3233ea0 00000001 e3233ee4
[ 2639.373083] Call Trace:
[ 2639.373086]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373089]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373092]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373095]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373097]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373100]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373103]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373106]  [<c12f31d1>] ? copy_to_user+0x41/0x60
[ 2639.373109]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373112]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373114] vnoded          S e3133e60     0  4161      1 0x00000000
[ 2639.373117]  e3133ec0 00000082 f73977f0 e3133e60 c106f28e e3133e60 c19c9100 9c252f91
[ 2639.373122]  0000025e c19c9100 f739c100 cc01e680 f73977f0 7b462637 0000026c 00000000
[ 2639.373128]  7b462637 0000026c e3133eac c19c47c0 00000001 e3133ea0 00000001 e3133ee4
[ 2639.373133] Call Trace:
[ 2639.373136]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373139]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373142]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373145]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373148]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373151]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373153]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373156]  [<c12f31d1>] ? copy_to_user+0x41/0x60
[ 2639.373159]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373162]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373164] udevd           S 00000000     0  4259    401 0x00000000
[ 2639.373171]  e33c3ec0 00000086 00000000 00000000 00000000 f3e64000 c19c9100 00000001
[ 2639.373176]  00000041 c19c9100 f739c100 e3378cd0 00000000 00000000 00000008 f6c05200
[ 2639.373182]  00000000 e33c3f4c c151eaed bfb27a7c 00000008 00000000 bfb27a7c 00000008
[ 2639.373187] Call Trace:
[ 2639.373190]  [<c151eaed>] ? sys_sendto+0xfd/0x140
[ 2639.373193]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373196]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.373198]  [<c151c02e>] ? sock_poll+0x1e/0x30
[ 2639.373201]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373204]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373207]  [<c119e1ea>] ? ep_scan_ready_list.isra.8+0x15a/0x170
[ 2639.373210]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373212]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373215]  [<c151eb6b>] ? sys_send+0x3b/0x40
[ 2639.373218]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373221]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373223] kworker/0:0     D f5c035f0     0  4487      2 0x00000000
[ 2639.373226]  f68c7ea8 00000046 f738e100 f5c035f0 00000000 00000002 c19c9100 c6835b30
[ 2639.373231]  0000005b c19c9100 f738e100 cc01b340 00000000 f68c7e64 c1613dad f68c7ebc
[ 2639.373236]  c108729f 00000002 f68c7eac c107972b cc01b340 c16256e0 00000000 c188b1e0
[ 2639.373242] Call Trace:
[ 2639.373245]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.373247]  [<c108729f>] ? idle_balance+0x29f/0x3f0
[ 2639.373250]  [<c107972b>] ? update_rq_clock+0x3b/0x70
[ 2639.373253]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.373255]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373258]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373260]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373263]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.373266]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373268]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373271]  [<c15419dd>] linkwatch_event+0xd/0x30
[ 2639.373274]  [<c1065745>] process_one_work+0x135/0x3e0
[ 2639.373277]  [<c1066c59>] worker_thread+0x119/0x3c0
[ 2639.373279]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.373282]  [<c106b694>] kthread+0x94/0xa0
[ 2639.373284]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.373287]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.373290]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.373292] sh              S e3315ec4     0  4501   1514 0x00000000
[ 2639.373319]  e3315f30 00000086 2b92d065 e3315ec4 c12798d4 cc042000 c19c9100 00000001
[ 2639.373325]  00000047 c19c9100 f739c100 e9eb0000 e336add8 e324e720 e3315f28 c1132f15
[ 2639.373330]  e3394d90 e336add8 00000029 00000008 cc0199a0 f739c100 e3315f10 c103ce08
[ 2639.373336] Call Trace:
[ 2639.373339]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373342]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373345]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373347]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373350]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373352]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373355]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373357]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373360]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373363] run-parts       S 00000000     0  4502   4501 0x00000000
[ 2639.373370]  cc043aac 00000082 00000000 00000000 00000000 e322a000 c19c9100 994887ef
[ 2639.373375]  00000047 c19c9100 f739c100 cc0199a0 00000000 00000000 00000000 00000000
[ 2639.373380]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.373386] Call Trace:
[ 2639.373389]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373392]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.373395]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373398]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373400]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.373403]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.373406]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373408]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373411]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.373414]  [<c11710c9>] do_select+0x529/0x610
[ 2639.373417]  [<c12157fe>] ? ext4_ext_map_blocks+0xae/0x1a20
[ 2639.373420]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373422]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373426]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.373428]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.373431]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373434]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373437]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373440]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.373442]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373445]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373447]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373451]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.373454]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373456]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373459]  [<c105ee33>] ? __set_current_blocked+0x43/0x60
[ 2639.373462]  [<c105ef23>] ? set_current_blocked+0x13/0x20
[ 2639.373465]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373467]  [<c104ec91>] ? wait_consider_task+0x81/0xbe0
[ 2639.373470]  [<c10192b5>] ? fpu_finit+0x55/0x70
[ 2639.373473]  [<c101a5f3>] ? __restore_xstate_sig+0x383/0x510
[ 2639.373475]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373478]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373481]  [<c106c04f>] ? remove_wait_queue+0x3f/0x50
[ 2639.373483]  [<c105c427>] ? recalc_sigpending+0x17/0x50
[ 2639.373486]  [<c105ce25>] ? __set_task_blocked+0x35/0x80
[ 2639.373488]  [<c105ee33>] ? __set_current_blocked+0x43/0x60
[ 2639.373491]  [<c105eead>] ? sigprocmask+0x5d/0xc0
[ 2639.373494]  [<c11715fb>] sys_pselect6+0xeb/0x1e0
[ 2639.373496]  [<c10508cc>] ? sys_waitpid+0x2c/0x30
[ 2639.373499]  [<c16142a7>] syscall_call+0x7/0xb
[ 2639.373501] apt             S e3363ec4     0  4509   4502 0x00000000
[ 2639.373507]  e3363f30 00000082 3af7c065 e3363ec4 c12798d4 e3363f38 c19c9100 b43b5074
[ 2639.373512]  000000c2 c19c9100 f739c100 f6898cd0 e33a3200 e323c8a0 e3363f28 c1132f15
[ 2639.373517]  e3260310 e33a3200 00000029 f738e100 c1625660 e3363f0c e3363f10 c103ce08
[ 2639.373523] Call Trace:
[ 2639.373526]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373529]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373531]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373534]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373537]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373539]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373542]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373544]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373547]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373549] ip              D 00000000     0  4858   4161 0x00000000
[ 2639.373552]  e9edfcd8 00000086 c18f8240 00000000 00000000 00000040 c19c9100 99107053
[ 2639.373557]  0000005b c19c9100 f739c100 e3184010 e9edfc90 c12eb31d 00000001 f6c6fd78
[ 2639.373563]  00000000 f6c6fe44 e9edfca8 c12eb31d e9edfcc8 c110dd7e c103ce08 f7bfb2f0
[ 2639.373568] Call Trace:
[ 2639.373571]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373574]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373576]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.373579]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373582]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373585]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373587]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373590]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373593]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373595]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.373598]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.373601]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.373604]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373607]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.373609]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373613]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.373615]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373618]  [<c11723a5>] ? d_free+0x45/0x50
[ 2639.373621]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.373624]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.373626]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.373629]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.373632]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373634] bash            S e320beac     0  5552   2736 0x00000000
[ 2639.373639]  e320bf18 00000082 e3268400 e320beac c12798d4 f5e50000 c19c9100 bbdefc14
[ 2639.373645]  000000a6 c19c9100 f738e100 e337b340 f68e6140 c1043db1 08a8b8f8 80000000
[ 2639.373650]  f68eaf00 00000000 e3235228 f68eaf00 e320bf28 c1132f15 e320bef8 c103ce08
[ 2639.373656] Call Trace:
[ 2639.373659]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373661]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.373664]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373667]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373670]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373672]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373675]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373677]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373680]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373682]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.373685]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373710] sudo            D c1114c38     0  5612   5552 0x00000000
[ 2639.373716]  e32efcf8 00000082 e32efcf4 c1114c38 00000002 00000041 c19c9100 bc0c5754
[ 2639.373722]  000000a6 c19c9100 f738e100 e337c010 00000000 00000040 00000000 00000002
[ 2639.373727]  00000020 c18f8c04 c18f85a8 00000040 000280da 00000000 00000000 00000246
[ 2639.373733] Call Trace:
[ 2639.373736]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373739]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373742]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373744]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373747]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373749]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373752]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373755]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.373758]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.373760]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.373763]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.373766]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373769]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.373771]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.373775]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.373777]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373780]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.373783]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.373786]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.373789]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373791] bash            S ecc97eac     0  5648   2736 0x00000000
[ 2639.373797]  ecc97f18 00000082 cc017fc0 ecc97eac c12798d4 f6946000 c19c9100 abae4ee1
[ 2639.373803]  000000ea c19c9100 f739c100 e337a670 f68e6680 c1043db1 08b79388 80000000
[ 2639.373808]  f68eaf60 00000000 e9d40228 f68eaf60 ecc97f28 c1132f15 ecc97ef8 c103ce08
[ 2639.373813] Call Trace:
[ 2639.373817]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373819]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.373822]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373824]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373827]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373830]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373832]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373835]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373838]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373840]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.373843]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373845] apt-get         S e3281a5c     0  5970   4509 0x00000000
[ 2639.373848]  e3281abc 00000086 f73977f0 e3281a5c c106f28e e3281a5c c19c9100 69f99bb0
[ 2639.373853]  00000266 c19c9100 f739c100 e9eb4010 f73977f0 7def4bd4 00000266 00000000
[ 2639.373859]  7def4bd4 00000266 e3281aa8 c19c47c0 00000001 e3281a9c 00000001 e3281ae0
[ 2639.373864] Call Trace:
[ 2639.373867]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373870]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373873]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373875]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373878]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373881]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373883]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.373886]  [<c11710c9>] do_select+0x529/0x610
[ 2639.373888]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.373892]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373894]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373897]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373899]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373902]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.373905]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373907]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.373910]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.373913]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.373916]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.373918]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.373921]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.373923]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.373926]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.373928]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.373931]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373934]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373937]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373939]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.373942]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.373945]  [<c105b041>] ? update_process_times+0x61/0x70
[ 2639.373947]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.373950]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.373953]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.373955]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.373958]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.373960]  [<c1170b84>] ? poll_select_set_timeout+0x64/0x80
[ 2639.373963]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.373966]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373968] http            D cc037cb0     0  5973   5970 0x00000000
[ 2639.373971]  cc037cf8 00000082 f5c04600 cc037cb0 c1157ff8 e3280000 c19c9100 00000001
[ 2639.373976]  000000c2 c19c9100 f739c100 e9eb6680 f79c33c0 f5c01480 ee31f700 cc037d20
[ 2639.373981]  00000292 8020001e 00000000 80200020 cc037cd8 c1043c04 c1526d3c 00000292
[ 2639.373987] Call Trace:
[ 2639.373990]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.373992]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.373995]  [<c1526d3c>] ? __alloc_skb+0x3c/0x250
[ 2639.373997]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374000]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374003]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374005]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374008]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374011]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374013]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374016]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374019]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374022]  [<c11727fc>] ? dget_parent+0x3c/0x60
[ 2639.374024]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374027]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374030]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374032]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.374035]  [<c1073ce6>] ? lg_local_unlock+0x16/0x20
[ 2639.374037]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374040]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374043]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374046]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374048]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374051]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374054]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374057]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374059] http            D e30afcb0     0  5974   5970 0x00000000
[ 2639.374062]  e30afcf8 00000082 f5c04600 e30afcb0 c1157ff8 ee3e4000 c19c9100 00000001
[ 2639.374067]  000000c2 c19c9100 f739c100 e3242670 00000001 fffa58f8 f7b72d80 f7b72d80
[ 2639.374072]  e30d0240 e30afcc4 c1118a53 e30afcd8 e30afcd8 c1043c04 fffa58f8 f7b72d80
[ 2639.374078] Call Trace:
[ 2639.374081]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.374084]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.374086]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.374089]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374091]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374094]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374097]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374099]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374102]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374105]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374107]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374110]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374113]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374116]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374118]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374121]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374124]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374126]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374129]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374132]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374135]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374137] http            D ee3e5cb0     0  5977   5970 0x00000000
[ 2639.374140]  ee3e5cf8 00000082 f5c04600 ee3e5cb0 c1157ff8 e3280000 c19c9100 00000001
[ 2639.374145]  000000c2 c19c9100 f739c100 e33799a0 00000001 fdfa5b50 f7bce3c0 f7bce3c0
[ 2639.374151]  e9ecf4e0 ee3e5cc4 c1118a53 ee3e5cd8 ee3e5cd8 c1043c04 fffa5b50 f7bce3c0
[ 2639.374156] Call Trace:
[ 2639.374159]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.374162]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.374164]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.374167]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374170]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374172]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374175]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374177]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374180]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374183]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374185]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374188]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374191]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374194]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374196]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374199]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374202]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374205]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374207]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374210]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374213]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374215] dhclient-script S e322beac     0  6075    960 0x00000000
[ 2639.374218]  e322bf18 00000086 fffb9168 e322beac c12798d4 e322bf20 c19c9100 c8ebfc46
[ 2639.374224]  000000cd c19c9100 f738e100 e3378000 f68e6a00 c1043db1 0a02dbc8 80000000
[ 2639.374229]  e328bf60 00000000 e32d0280 e328bf60 e322bf28 c1132f15 e322bef8 c103ce08
[ 2639.374234] Call Trace:
[ 2639.374237]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.374240]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374242]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374245]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374248]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374251]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374253]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.374256]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.374258]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.374261]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.374263]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374265] ip              D 00000000     0  6100   6075 0x00000000
[ 2639.374271]  e3047cd8 00000086 c18f8240 00000000 00000000 00000040 c19c9100 c9294d53
[ 2639.374276]  000000cd c19c9100 f738e100 e337d9b0 e3047c90 c12eb31d f7560d40 f5c19580
[ 2639.374282]  cb1eb420 e3047d08 00000282 80160010 00000000 80160016 c103ce08 f7bfb2f0
[ 2639.374287] Call Trace:
[ 2639.374290]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374293]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374296]  [<c11b1873>] ? proc_alloc_inode+0x23/0xa0
[ 2639.374299]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374301]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374304]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374307]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374309]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374312]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374315]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374317]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374321]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374323]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.374326]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374329]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374332]  [<c11723a5>] ? d_free+0x45/0x50
[ 2639.374335]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374337]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.374340]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.374343]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.374346]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374347] ip              D 00000000     0  6354   5648 0x00000004
[ 2639.374374]  cc009cd8 00000082 c18f8240 00000000 00000000 00000040 c19c9100 abeac148
[ 2639.374379]  000000ea c19c9100 f739c100 e9f54010 cc009c90 c12eb31d cc009cb0 cc009c9c
[ 2639.374385]  c103ce08 cc009cb0 c161407d cc009cb0 00000092 c18d5b80 cc009cf4 c13cd678
[ 2639.374390] Call Trace:
[ 2639.374394]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374396]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374399]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374403]  [<c13cd678>] ? account+0xf8/0x1d0
[ 2639.374406]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.374408]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374411]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374414]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374416]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374419]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374422]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374425]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374427]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374430]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374433]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374436]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374439]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374441]  [<c151e8df>] ? sys_getsockname+0xcf/0xe0
[ 2639.374444]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374446]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374449]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374452]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.374465]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.374468]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.374471]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374473] bash            S cc053eac     0  7178   2736 0x00000000
[ 2639.374476]  cc053f18 00000082 fffb9220 cc053eac c12798d4 f6b58000 c19c9100 a5710dd0
[ 2639.374481]  000001de c19c9100 f738e100 cc01cce0 f68e5880 c1043db1 088448f8 80000000
[ 2639.374487]  e9ec4ae0 00000000 ecdbe220 e9ec4ae0 cc053f28 c1132f15 cc053ef8 c103ce08
[ 2639.374492] Call Trace:
[ 2639.374495]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.374498]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374501]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374503]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374506]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374509]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374511]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.374514]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.374517]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.374519]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.374522]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374524] kworker/0:2     S f738e100     0  8231      2 0x00000000
[ 2639.374527]  f6b59f3c 00000046 f738e100 f738e100 f6b59edc e3304000 c19c9100 9b62328b
[ 2639.374532]  00000246 c19c9100 f738e100 e9f52670 00000001 f68394d0 f68380c4 f6838060
[ 2639.374537]  e3207500 f73895d8 f6b59f44 c10657b1 e325d840 f6b59f1c c1063c90 e9f52670
[ 2639.374543] Call Trace:
[ 2639.374546]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374549]  [<c1063c90>] ? need_to_create_worker+0x10/0x30
[ 2639.374552]  [<c1066aac>] ? manage_workers+0x1ac/0x240
[ 2639.374554]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374557]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374559]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374562]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374564]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374567]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374570]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374572] sudo            D c1114c38     0  8550   7178 0x00000000
[ 2639.374579]  e3353cf8 00000082 e3353cf4 c1114c38 00000002 00000041 c19c9100 a5a78096
[ 2639.374584]  000001de c19c9100 f739c100 cc01c010 00000000 00000040 00000000 00000002
[ 2639.374589]  00000020 c18f8c04 c18f85a8 00000040 000280da 00000000 00000000 00000246
[ 2639.374595] Call Trace:
[ 2639.374598]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.374601]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374603]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374606]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374609]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.374611]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374614]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374617]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374619]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374622]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374625]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374628]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374630]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374633]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.374636]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374639]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374642]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374644]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374647]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374650]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374652] bash            S 000004bf     0  8594   2736 0x00000000
[ 2639.374655]  e32bde5c 00000082 00000005 000004bf 00000008 f5e50000 c19c9100 e68baa0e
[ 2639.374661]  00000262 c19c9100 f738e100 f697e680 e32bde20 c107a412 f697e680 00000001
[ 2639.374666]  f697e680 e32bde3c c107a458 00000000 f738e100 e32bde3c 00000086 f697e680
[ 2639.374672] Call Trace:
[ 2639.374675]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.374677]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.374680]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.374683]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374685]  [<c161198d>] schedule_timeout+0x19d/0x240
[ 2639.374688]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.374690]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.374693]  [<c1066ff7>] ? flush_work+0xf7/0x120
[ 2639.374696]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374698]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374701]  [<c13a907b>] n_tty_read+0x1cb/0x740
[ 2639.374704]  [<c106c04f>] ? remove_wait_queue+0x3f/0x50
[ 2639.374707]  [<c13aac97>] ? tty_ldisc_try+0x37/0x50
[ 2639.374709]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.374712]  [<c13a8eb0>] ? is_ignored+0x40/0x40
[ 2639.374714]  [<c13a4252>] tty_read+0x72/0xd0
[ 2639.374716]  [<c13a8eb0>] ? is_ignored+0x40/0x40
[ 2639.374719]  [<c13a41e0>] ? tty_poll+0x90/0x90
[ 2639.374721]  [<c1160469>] vfs_read+0x89/0x160
[ 2639.374724]  [<c13a41e0>] ? tty_poll+0x90/0x90
[ 2639.374726]  [<c1160587>] sys_read+0x47/0x80
[ 2639.374729]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374731] kworker/0:3     S c106660c     0  8657      2 0x00000000
[ 2639.374736]  e3305f3c 00000046 e3305ed0 c106660c 000001f4 f5e50000 c19c9100 14026910
[ 2639.374742]  00000266 c19c9100 f738e100 cc018000 00000001 f68394d0 f68380c4 f6838060
[ 2639.374747]  e325ddc0 f73895d8 e3305f44 c10657b1 f738966c e3305f34 c105ac22 cc018000
[ 2639.374753] Call Trace:
[ 2639.374756]  [<c106660c>] ? queue_delayed_work+0x1c/0x20
[ 2639.374759]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374761]  [<c105ac22>] ? mod_timer+0xf2/0x1b0
[ 2639.374764]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374766]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374769]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374771]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374774]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374777]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374780]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374782] kworker/0:1     S 00000296     0  8682      2 0x00000000
[ 2639.374785]  f5e51f3c 00000046 f5e51ed8 00000296 c19e2078 ecf76000 c19c9100 00000000
[ 2639.374790]  00000266 c19c9100 f738e100 cc01a670 c18cfadc e325d840 f73895ec c18cfadc
[ 2639.374795]  e325d840 f73895ec f5e51f44 c10657b1 f738e100 cc01a670 f738964c 00000000
[ 2639.374801] Call Trace:
[ 2639.374804]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374807]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374809]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374811]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374814]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374817]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374820]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374822]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374826] Sched Debug Version: v0.10, 3.8.0-28-generic #41
[ 2639.374828] ktime                                   : 2639209.635367
[ 2639.374830] sched_clk                               : 2639374.824758
[ 2639.374831] cpu_clk                                 : 2639374.824826
[ 2639.374833] jiffies                                 : 584801
[ 2639.374834] sched_clock_stable                      : 1
[ 2639.374835] 
[ 2639.374836] sysctl_sched
[ 2639.374838]   .sysctl_sched_latency                    : 12.000000
[ 2639.374839]   .sysctl_sched_min_granularity            : 1.500000
[ 2639.374841]   .sysctl_sched_wakeup_granularity         : 2.000000
[ 2639.374842]   .sysctl_sched_child_runs_first           : 0
[ 2639.374844]   .sysctl_sched_features                   : 24187
[ 2639.374846]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[ 2639.374847] 
[ 2639.374847] cpu#0, 2652.796 MHz
[ 2639.374849]   .nr_running                    : 0
[ 2639.374855]   .load                          : 0
[ 2639.374856]   .nr_switches                   : 3620208
[ 2639.374858]   .nr_load_updates               : 110050
[ 2639.374859]   .nr_uninterruptible            : 7
[ 2639.374860]   .next_balance                  : 0.584802
[ 2639.374862]   .curr->pid                     : 0
[ 2639.374863]   .clock                         : 2639369.619218
[ 2639.374865]   .cpu_load[0]                   : 0
[ 2639.374866]   .cpu_load[1]                   : 0
[ 2639.374867]   .cpu_load[2]                   : 0
[ 2639.374869]   .cpu_load[3]                   : 0
[ 2639.374870]   .cpu_load[4]                   : 0
[ 2639.374871]   .yld_count                     : 0
[ 2639.374872]   .sched_count                   : 3620342
[ 2639.374874]   .sched_goidle                  : 1699148
[ 2639.374875]   .avg_idle                      : 1000000
[ 2639.374877]   .ttwu_count                    : 1846819
[ 2639.374878]   .ttwu_local                    : 1826806
[ 2639.374884] 
[ 2639.374884] cfs_rq[0]:/autogroup-146
[ 2639.374887]   .exec_clock                    : 34116.414703
[ 2639.374889]   .MIN_vruntime                  : 0.000001
[ 2639.374890]   .min_vruntime                  : 585890.631006
[ 2639.374892]   .max_vruntime                  : 0.000001
[ 2639.374893]   .spread                        : 0.000000
[ 2639.374894]   .spread0                       : 293622.514338
[ 2639.374896]   .nr_spread_over                : 252
[ 2639.374897]   .nr_running                    : 0
[ 2639.374898]   .load                          : 0
[ 2639.374900]   .runnable_load_avg             : 0
[ 2639.374901]   .blocked_load_avg              : 0
[ 2639.374902]   .tg_load_avg                   : 3
[ 2639.374903]   .tg_load_contrib               : 0
[ 2639.374905]   .tg_runnable_contrib           : 0
[ 2639.374906]   .tg->runnable_avg              : 4
[ 2639.374908]   .se->exec_start                : 2639341.779930
[ 2639.374909]   .se->vruntime                  : 292262.111571
[ 2639.374911]   .se->sum_exec_runtime          : 34117.917952
[ 2639.374912]   .se->statistics.wait_start     : 0.000000
[ 2639.374914]   .se->statistics.sleep_start    : 0.000000
[ 2639.374915]   .se->statistics.block_start    : 0.000000
[ 2639.374917]   .se->statistics.sleep_max      : 0.000000
[ 2639.374918]   .se->statistics.block_max      : 0.000000
[ 2639.374920]   .se->statistics.exec_max       : 490.624219
[ 2639.374921]   .se->statistics.slice_max      : 490.624219
[ 2639.374923]   .se->statistics.wait_max       : 451.293452
[ 2639.374924]   .se->statistics.wait_sum       : 7148.960837
[ 2639.374925]   .se->statistics.wait_count     : 71976
[ 2639.374927]   .se->load.weight               : 2
[ 2639.374928]   .se->avg.runnable_avg_sum      : 34
[ 2639.374929]   .se->avg.runnable_avg_period   : 46699
[ 2639.374931]   .se->avg.load_avg_contrib      : 0
[ 2639.374932]   .se->avg.decay_count           : 2517073
[ 2639.374934] 
[ 2639.374934] cfs_rq[0]:/autogroup-133
[ 2639.374936]   .exec_clock                    : 22366.359537
[ 2639.374938]   .MIN_vruntime                  : 0.000001
[ 2639.374939]   .min_vruntime                  : 22365.310961
[ 2639.374941]   .max_vruntime                  : 0.000001
[ 2639.374942]   .spread                        : 0.000000
[ 2639.374944]   .spread0                       : -269902.805707
[ 2639.374945]   .nr_spread_over                : 0
[ 2639.374946]   .nr_running                    : 0
[ 2639.374948]   .load                          : 0
[ 2639.374949]   .runnable_load_avg             : 0
[ 2639.374950]   .blocked_load_avg              : 8
[ 2639.374952]   .tg_load_avg                   : 8
[ 2639.374953]   .tg_load_contrib               : 8
[ 2639.374954]   .tg_runnable_contrib           : 9
[ 2639.374955]   .tg->runnable_avg              : 9
[ 2639.374957]   .se->exec_start                : 2639341.852056
[ 2639.374959]   .se->vruntime                  : 292268.116668
[ 2639.374960]   .se->sum_exec_runtime          : 22368.001405
[ 2639.374961]   .se->statistics.wait_start     : 0.000000
[ 2639.374963]   .se->statistics.sleep_start    : 0.000000
[ 2639.374964]   .se->statistics.block_start    : 0.000000
[ 2639.374966]   .se->statistics.sleep_max      : 0.000000
[ 2639.374967]   .se->statistics.block_max      : 0.000000
[ 2639.374969]   .se->statistics.exec_max       : 93.131673
[ 2639.374970]   .se->statistics.slice_max      : 11.031085
[ 2639.374972]   .se->statistics.wait_max       : 109.279558
[ 2639.374973]   .se->statistics.wait_sum       : 4394.571625
[ 2639.374974]   .se->statistics.wait_count     : 51681
[ 2639.374976]   .se->load.weight               : 2
[ 2639.374977]   .se->avg.runnable_avg_sum      : 419
[ 2639.374978]   .se->avg.runnable_avg_period   : 47171
[ 2639.374980]   .se->avg.load_avg_contrib      : 7
[ 2639.374981]   .se->avg.decay_count           : 2517073
[ 2639.374983] 
[ 2639.374983] cfs_rq[0]:/
[ 2639.374985]   .exec_clock                    : 125748.117098
[ 2639.374986]   .MIN_vruntime                  : 0.000001
[ 2639.374988]   .min_vruntime                  : 292268.116668
[ 2639.374989]   .max_vruntime                  : 0.000001
[ 2639.374991]   .spread                        : 0.000000
[ 2639.374992]   .spread0                       : 0.000000
[ 2639.374994]   .nr_spread_over                : 170
[ 2639.374995]   .nr_running                    : 0
[ 2639.374996]   .load                          : 0
[ 2639.374997]   .runnable_load_avg             : 0
[ 2639.374999]   .blocked_load_avg              : 0
[ 2639.375000]   .tg_load_avg                   : 3
[ 2639.375001]   .tg_load_contrib               : 0
[ 2639.375003]   .tg_runnable_contrib           : 9
[ 2639.375004]   .tg->runnable_avg              : 24
[ 2639.375006]   .avg->runnable_avg_sum         : 452
[ 2639.375007]   .avg->runnable_avg_period      : 47103
[ 2639.375015] 
[ 2639.375015] rt_rq[0]:/
[ 2639.375017]   .rt_nr_running                 : 0
[ 2639.375018]   .rt_throttled                  : 0
[ 2639.375020]   .rt_time                       : 0.000000
[ 2639.375021]   .rt_runtime                    : 950.000000
[ 2639.375023] 
[ 2639.375023] runnable tasks:
[ 2639.375023]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 2639.375023] ----------------------------------------------------------------------------------------------------------
[ 2639.375072] 
[ 2639.375072] cpu#1, 2652.796 MHz
[ 2639.375074]   .nr_running                    : 3
[ 2639.375075]   .load                          : 3072
[ 2639.375076]   .nr_switches                   : 403280
[ 2639.375078]   .nr_load_updates               : 88638
[ 2639.375079]   .nr_uninterruptible            : 5
[ 2639.375081]   .next_balance                  : 0.584785
[ 2639.375082]   .curr->pid                     : 2817
[ 2639.375084]   .clock                         : 2639342.275911
[ 2639.375085]   .cpu_load[0]                   : 0
[ 2639.375086]   .cpu_load[1]                   : 0
[ 2639.375087]   .cpu_load[2]                   : 0
[ 2639.375089]   .cpu_load[3]                   : 0
[ 2639.375090]   .cpu_load[4]                   : 0
[ 2639.375091]   .yld_count                     : 0
[ 2639.375093]   .sched_count                   : 403443
[ 2639.375094]   .sched_goidle                  : 95022
[ 2639.375095]   .avg_idle                      : 1000000
[ 2639.375097]   .ttwu_count                    : 230380
[ 2639.375098]   .ttwu_local                    : 212530
[ 2639.375100] 
[ 2639.375100] cfs_rq[1]:/autogroup-155
[ 2639.375102]   .exec_clock                    : 22740.333107
[ 2639.375103]   .MIN_vruntime                  : 0.000001
[ 2639.375105]   .min_vruntime                  : 27902.615373
[ 2639.375106]   .max_vruntime                  : 0.000001
[ 2639.375108]   .spread                        : 0.000000
[ 2639.375109]   .spread0                       : -264365.501295
[ 2639.375111]   .nr_spread_over                : 1930
[ 2639.375112]   .nr_running                    : 1
[ 2639.375113]   .load                          : 1024
[ 2639.375115]   .runnable_load_avg             : 0
[ 2639.375116]   .blocked_load_avg              : 0
[ 2639.375117]   .tg_load_avg                   : 0
[ 2639.375118]   .tg_load_contrib               : 0
[ 2639.375120]   .tg_runnable_contrib           : 0
[ 2639.375121]   .tg->runnable_avg              : 0
[ 2639.375123]   .se->exec_start                : 2639342.275911
[ 2639.375124]   .se->vruntime                  : 188900.650811
[ 2639.375126]   .se->sum_exec_runtime          : 22740.654672
[ 2639.375127]   .se->statistics.wait_start     : 0.000000
[ 2639.375129]   .se->statistics.sleep_start    : 0.000000
[ 2639.375130]   .se->statistics.block_start    : 0.000000
[ 2639.375131]   .se->statistics.sleep_max      : 0.000000
[ 2639.375133]   .se->statistics.block_max      : 0.000000
[ 2639.375134]   .se->statistics.exec_max       : 75.960967
[ 2639.375136]   .se->statistics.slice_max      : 62.362964
[ 2639.375137]   .se->statistics.wait_max       : 196.665662
[ 2639.375139]   .se->statistics.wait_sum       : 936.164293
[ 2639.375140]   .se->statistics.wait_count     : 11059
[ 2639.375141]   .se->load.weight               : 1024
[ 2639.375143]   .se->avg.runnable_avg_sum      : 0
[ 2639.375144]   .se->avg.runnable_avg_period   : 48091
[ 2639.375145]   .se->avg.load_avg_contrib      : 0
[ 2639.375147]   .se->avg.decay_count           : 0
[ 2639.375149] 
[ 2639.375149] cfs_rq[1]:/autogroup-158
[ 2639.375151]   .exec_clock                    : 3017.003805
[ 2639.375152]   .MIN_vruntime                  : 0.000001
[ 2639.375154]   .min_vruntime                  : 2888.998373
[ 2639.375155]   .max_vruntime                  : 0.000001
[ 2639.375157]   .spread                        : 0.000000
[ 2639.375158]   .spread0                       : -289379.118295
[ 2639.375160]   .nr_spread_over                : 63
[ 2639.375161]   .nr_running                    : 0
[ 2639.375162]   .load                          : 0
[ 2639.375164]   .runnable_load_avg             : 0
[ 2639.375165]   .blocked_load_avg              : 0
[ 2639.375166]   .tg_load_avg                   : 0
[ 2639.375167]   .tg_load_contrib               : 0
[ 2639.375169]   .tg_runnable_contrib           : 4
[ 2639.375170]   .tg->runnable_avg              : 4
[ 2639.375171]   .se->exec_start                : 2639317.326411
[ 2639.375173]   .se->vruntime                  : 188900.224700
[ 2639.375174]   .se->sum_exec_runtime          : 3017.344574
[ 2639.375176]   .se->statistics.wait_start     : 0.000000
[ 2639.375177]   .se->statistics.sleep_start    : 0.000000
[ 2639.375179]   .se->statistics.block_start    : 0.000000
[ 2639.375180]   .se->statistics.sleep_max      : 0.000000
[ 2639.375182]   .se->statistics.block_max      : 0.000000
[ 2639.375183]   .se->statistics.exec_max       : 30.893402
[ 2639.375185]   .se->statistics.slice_max      : 5.566855
[ 2639.375186]   .se->statistics.wait_max       : 256.613676
[ 2639.375187]   .se->statistics.wait_sum       : 699.265392
[ 2639.375189]   .se->statistics.wait_count     : 78979
[ 2639.375190]   .se->load.weight               : 2
[ 2639.375191]   .se->avg.runnable_avg_sum      : 215
[ 2639.375193]   .se->avg.runnable_avg_period   : 46105
[ 2639.375194]   .se->avg.load_avg_contrib      : 0
[ 2639.375195]   .se->avg.decay_count           : 2517050
[ 2639.375197] 
[ 2639.375197] cfs_rq[1]:/autogroup-146
[ 2639.375199]   .exec_clock                    : 26059.818672
[ 2639.375201]   .MIN_vruntime                  : 284987.250464
[ 2639.375202]   .min_vruntime                  : 284992.917778
[ 2639.375204]   .max_vruntime                  : 284987.250464
[ 2639.375205]   .spread                        : 0.000000
[ 2639.375207]   .spread0                       : -7275.198890
[ 2639.375208]   .nr_spread_over                : 222
[ 2639.375209]   .nr_running                    : 1
[ 2639.375211]   .load                          : 1024
[ 2639.375212]   .runnable_load_avg             : 0
[ 2639.375213]   .blocked_load_avg              : 3
[ 2639.375215]   .tg_load_avg                   : 3
[ 2639.375216]   .tg_load_contrib               : 3
[ 2639.375217]   .tg_runnable_contrib           : 4
[ 2639.375219]   .tg->runnable_avg              : 4
[ 2639.375220]   .se->exec_start                : 2639342.220040
[ 2639.375222]   .se->vruntime                  : 188906.609634
[ 2639.375223]   .se->sum_exec_runtime          : 26082.646772
[ 2639.375225]   .se->statistics.wait_start     : 2639342.220040
[ 2639.375226]   .se->statistics.sleep_start    : 0.000000
[ 2639.375228]   .se->statistics.block_start    : 0.000000
[ 2639.375229]   .se->statistics.sleep_max      : 0.000000
[ 2639.375230]   .se->statistics.block_max      : 0.000000
[ 2639.375232]   .se->statistics.exec_max       : 162.478909
[ 2639.375233]   .se->statistics.slice_max      : 23.454420
[ 2639.375235]   .se->statistics.wait_max       : 493.152849
[ 2639.375236]   .se->statistics.wait_sum       : 6000.435003
[ 2639.375238]   .se->statistics.wait_count     : 59962
[ 2639.375239]   .se->load.weight               : 1024
[ 2639.375240]   .se->avg.runnable_avg_sum      : 542
[ 2639.375242]   .se->avg.runnable_avg_period   : 47514
[ 2639.375243]   .se->avg.load_avg_contrib      : 3
[ 2639.375244]   .se->avg.decay_count           : 2517054
[ 2639.375246] 
[ 2639.375246] cfs_rq[1]:/
[ 2639.375247]   .exec_clock                    : 109217.037585
[ 2639.375249]   .MIN_vruntime                  : 188900.624328
[ 2639.375251]   .min_vruntime                  : 188906.609634
[ 2639.375252]   .max_vruntime                  : 188906.609634
[ 2639.375254]   .spread                        : 5.985306
[ 2639.375255]   .spread0                       : -103361.507034
[ 2639.375257]   .nr_spread_over                : 147
[ 2639.375258]   .nr_running                    : 3
[ 2639.375259]   .load                          : 3072
[ 2639.375260]   .runnable_load_avg             : 3
[ 2639.375262]   .blocked_load_avg              : 0
[ 2639.375263]   .tg_load_avg                   : 3
[ 2639.375264]   .tg_load_contrib               : 3
[ 2639.375266]   .tg_runnable_contrib           : 15
[ 2639.375267]   .tg->runnable_avg              : 24
[ 2639.375268]   .avg->runnable_avg_sum         : 740
[ 2639.375270]   .avg->runnable_avg_period      : 47613
[ 2639.375272] 
[ 2639.375272] rt_rq[1]:/
[ 2639.375273]   .rt_nr_running                 : 0
[ 2639.375275]   .rt_throttled                  : 0
[ 2639.375276]   .rt_time                       : 0.000000
[ 2639.375278]   .rt_runtime                    : 950.000000
[ 2639.375279] 
[ 2639.375279] runnable tasks:
[ 2639.375279]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 2639.375279] ----------------------------------------------------------------------------------------------------------
[ 2639.375283]      kworker/1:2    75    188900.624328      8575   120    188900.624328       438.666884   2635100.599393 /
[ 2639.375292]   xfce4-terminal  2736    284987.250464     13101   120    284987.250464      3364.964614   2595136.252768 /autogroup-146
[ 2639.375297] R           bash  2817     27900.226829       183   120     27900.226829        74.780842   2591370.038608 /autogroup-155
[ 2639.375303] 
[ 2639.368995]  [<c11a0a50>] ? eventfd_ctx_fdget+0x60/0x60
[ 2639.368997]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369000]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369002] gdbus           S 2aa2b631     0  2562      1 0x00000000
[ 2639.369005]  e9e4db4c 00000086 00000000 2aa2b631 00000005 ecc14000 c19c9100 00000001
[ 2639.369010]  0000004c c19c9100 f739c100 f649e680 f0226300 e9e4db44 c10820cd 00000000
[ 2639.369016]  0341a04d 07000000 00000006 00004296 00000000 00004296 f3f59600 f3f59600
[ 2639.369021] Call Trace:
[ 2639.369024]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369027]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369030]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369033]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369035]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369038]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369041]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369043]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369046]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369049]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369051]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369055]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369057]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369060]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369063]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369065]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369067]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369070]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369072]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369075]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369078]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369080]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369083]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369086]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369088]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369091]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369094]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.369097]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369100]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369102]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369105]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369108]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369111]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369113]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369116]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369118]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369120] gvfs-mtp-volume S f66a1aec     0  2566      1 0x00000000
[ 2639.369127]  f66a1b4c 00000086 f73897f0 f66a1aec c106f28e e9ede000 c19c9100 bd249be9
[ 2639.369132]  0000004c c19c9100 f738e100 f697d9b0 f73897fc 00000000 f66a1b14 c12ee962
[ 2639.369138]  f66a1b70 f73897f0 f66a1b2c c106f630 f7389980 f66a1b2c 00000296 f66a1b70
[ 2639.369143] Call Trace:
[ 2639.369146]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369149]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369151]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369154]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369157]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369159]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369162]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369165]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369168]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369170]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369173]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369176]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369178]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369181]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.369184]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.369187]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.369189]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.369193]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.369196]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.369198]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.369201]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.369204]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369206]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369209]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369212]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369214]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369217]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.369220]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.369222]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.369225]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.369227]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.369230]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.369233]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369236]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.369238]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.369241]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.369244]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.369246]  [<c10a6290>] ? sys_futex+0x80/0x130
[ 2639.369249]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369252]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369254] gdbus           S 2ba62840     0  2568      1 0x00000000
[ 2639.369283]  e9d93b4c 00000086 00000000 2ba62840 00000005 ecc14000 c19c9100 00000001
[ 2639.369288]  0000004c c19c9100 f739c100 f6498cd0 f0226300 e9d93b44 c10820cd 00000000
[ 2639.369294]  0341a04d 00000253 00000006 00006032 00000000 00006032 f3f59600 f3f59600
[ 2639.369299] Call Trace:
[ 2639.369302]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369306]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369308]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369311]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369314]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369317]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369319]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369322]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369325]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369328]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369330]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369333]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369336]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369339]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369342]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369344]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369346]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369348]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369351]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369354]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369357]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369359]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369362]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369365]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369368]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369370]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369373]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.369376]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.369379]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369381]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369384]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369387]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369390]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369392]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369395]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369398]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369400]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369402] panel-4-systray S 00000012     0  2569   2414 0x00000000
[ 2639.369405]  e9e4fb4c 00200086 f3f26400 00000012 00000000 ecf76000 c19c9100 00000001
[ 2639.369411]  000000e7 c19c9100 f739c100 f6aca670 00000008 0fca7a78 f739c100 00000000
[ 2639.369416]  00000000 c16256e0 f739c100 c16256e0 e9e4fb30 c107a412 f6acd9b0 f739c100
[ 2639.369421] Call Trace:
[ 2639.369425]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.369427]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.369430]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369433]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369435]  [<c105298c>] ? irq_exit+0x5c/0xa0
[ 2639.369438]  [<c107aafe>] ? scheduler_ipi+0x4e/0xe0
[ 2639.369440]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369443]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369446]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369448]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369451]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369454]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369456]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369460]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369462]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369465]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369468]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369470]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369473]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369475]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369477]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369480]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.369483]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.369486]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369488]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369491]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369493]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.369497]  [<c151ec3b>] ? sys_recvfrom+0xcb/0x140
[ 2639.369500]  [<c1160b16>] ? do_readv_writev+0x146/0x190
[ 2639.369502]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.369505]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.369508]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369510]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369512] gvfs-afc-volume S e9e9baec     0  2571      1 0x00000000
[ 2639.369515]  e9e9bb4c 00000086 f73977f0 e9e9baec c106f28e e9dc4000 c19c9100 00000001
[ 2639.369521]  0000004c c19c9100 f739c100 f6402670 f73977fc 00000000 e9e9bb14 c12ee962
[ 2639.369526]  e9e9bb70 f73977f0 e9e9bb2c c106f630 f7397980 e9e9bb2c 00000296 e9e9bb70
[ 2639.369531] Call Trace:
[ 2639.369534]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369537]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369539]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369542]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369545]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369547]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369550]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369553]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369556]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369559]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369561]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369564]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369567]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.369583]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369585]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.369588]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.369590]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.369593]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.369595]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.369598]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369601]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369603]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.369606]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369609]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369611]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.369614]  [<c107fd58>] ? effective_load.isra.30+0x68/0xa0
[ 2639.369617]  [<c10809e4>] ? select_task_rq_fair+0x674/0x6b0
[ 2639.369629]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.369632]  [<c1017458>] ? sched_clock+0x8/0x10
[ 2639.369635]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369638]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.369640]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.369643]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.369646]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.369648]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369651]  [<c1199297>] ? fsnotify+0x1e7/0x2e0
[ 2639.369654]  [<c10744c0>] ? __wake_up_locked_key+0x20/0x30
[ 2639.369657]  [<c11a0b17>] ? eventfd_write+0xc7/0x220
[ 2639.369659]  [<c1160368>] ? vfs_write+0xe8/0x160
[ 2639.369662]  [<c11a0a50>] ? eventfd_ctx_fdget+0x60/0x60
[ 2639.369664]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369667]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369669] gvfs-afc-volume S c1118a53     0  2572      1 0x00000000
[ 2639.369672]  e9ea9f00 00000086 e9ea9e90 c1118a53 e9ea9ea4 e3174000 c19c9100 00000001
[ 2639.369678]  0000002c c19c9100 f739c100 f0292670 80000000 c116d39d ecf29000 810000de
[ 2639.369683]  f7939800 f73fd000 f695cfc0 80000000 e9ea9ed8 c103ce08 e9ea9eec c161407d
[ 2639.369689] Call Trace:
[ 2639.369691]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.369694]  [<c116d39d>] ? final_putname+0x1d/0x40
[ 2639.369697]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369700]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369703]  [<c106bfdc>] ? prepare_to_wait+0x4c/0x80
[ 2639.369705]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369708]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369710]  [<c119bfb3>] inotify_read+0x213/0x280
[ 2639.369713]  [<c11601d3>] ? rw_verify_area+0x63/0x110
[ 2639.369715]  [<c106bd80>] ? finish_wait+0x70/0x70
[ 2639.369718]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369720]  [<c1160469>] vfs_read+0x89/0x160
[ 2639.369723]  [<c119bda0>] ? inotify_remove_from_idr+0x1f0/0x1f0
[ 2639.369725]  [<c1160587>] sys_read+0x47/0x80
[ 2639.369728]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369730] gdbus           S ad8ab9c0     0  2574      1 0x00000000
[ 2639.369733]  e9eadb4c 00000086 00000000 ad8ab9c0 00000005 ecc14000 c19c9100 00000001
[ 2639.369738]  0000004c c19c9100 f739c100 e9eb0cd0 f3da9c00 e9eadb44 c10820cd 00000000
[ 2639.369744]  00d7e80d 00000000 00000006 000068cc 00000000 000068cc f3f5b200 f3f5b200
[ 2639.369749] Call Trace:
[ 2639.369752]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.369755]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.369758]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369760]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369763]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369766]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369769]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369771]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369774]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369777]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369779]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369782]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369785]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.369788]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.369790]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369793]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369795]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369798]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369800]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.369803]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.369806]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369808]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369811]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369814]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369817]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.369819]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.369822]  [<c1017458>] ? sched_clock+0x8/0x10
[ 2639.369824]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.369827]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.369830]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.369833]  [<c1172308>] ? __d_free+0x38/0x60
[ 2639.369836]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.369838]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.369841]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.369844]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.369846]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.369849]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369852]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369854] xfce4-indicator S e9eb9aec     0  2576   2414 0x00000000
[ 2639.369861]  e9eb9b4c 00000086 f73897f0 e9eb9aec c106f28e ecc28000 c19c9100 00000000
[ 2639.369866]  000000e7 c19c9100 f738e100 e9cb8cd0 f73897fc 00000000 e9eb9b14 c12ee962
[ 2639.369871]  e9eb9b70 f73897f0 e9eb9b2c c106f630 f7389980 e9eb9b2c 00000296 e9eb9b70
[ 2639.369877] Call Trace:
[ 2639.369880]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.369883]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.369885]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.369888]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.369890]  [<c16131c3>] schedule+0x23/0x60
[ 2639.369893]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.369896]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.369899]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.369902]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.369904]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.369907]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.369909]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.369912]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.369915]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.369918]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.369921]  [<c114d4fc>] ? kfree+0xcc/0x100
[ 2639.369924]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.369927]  [<c114d5f7>] ? kmem_cache_free+0xc7/0x100
[ 2639.369929]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369931]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369934]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369936]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.369939]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.369941]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.369944]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369946]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369949]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.369951]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.369955]  [<c151ec81>] ? sys_recvfrom+0x111/0x140
[ 2639.369958]  [<c1160b16>] ? do_readv_writev+0x146/0x190
[ 2639.369961]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.369963]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.369966]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.369969]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.369971] gdbus           S 0000b40e     0  2603   2414 0x00000000
[ 2639.370004]  e9fd5b4c 00200086 a88cb000 0000b40e 423a3cbf e9eb8000 c19c9100 00000000
[ 2639.370010]  00000041 c19c9100 f738e100 f6b4c010 d224c953 e9fd5b44 c108204a f738e148
[ 2639.370015]  00000000 00000036 e9fd5b44 c107f87c f68dec10 f3f5b200 00000001 e9fd5b44
[ 2639.370020] Call Trace:
[ 2639.370024]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370027]  [<c107f87c>] ? update_cfs_rq_blocked_load+0xbc/0x220
[ 2639.370030]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370033]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370036]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370038]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370041]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370043]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370046]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370049]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370052]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370054]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370057]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370060]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.370063]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.370066]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.370068]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.370071]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370073]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370075]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370078]  [<c15257fc>] ? consume_skb+0x2c/0x80
[ 2639.370080]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.370084]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370086]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370089]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370092]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370094]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370097]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.370100]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370102]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370105]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370108]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370111]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.370114]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.370117]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370119]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370122]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370125]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370127]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370130]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370132] dconf worker    S e9fd7aec     0  2604   2414 0x00000000
[ 2639.370135]  e9fd7b4c 00200086 f73977f0 e9fd7aec c106f28e e9eb8000 c19c9100 00000001
[ 2639.370141]  00000006 c19c9100 f739c100 e9fd8000 f73977fc 00000000 e9fd7b14 c12ee962
[ 2639.370146]  e9fd7b70 f73977f0 e9fd7b2c c106f630 f7397980 e9fd7b2c 00200296 e9fd7b70
[ 2639.370152] Call Trace:
[ 2639.370155]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370157]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370160]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370163]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370165]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370168]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370171]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370174]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370176]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370179]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370182]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370184]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370187]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.370190]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370192]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370195]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.370197]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.370200]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.370202]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.370205]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.370208]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370210]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370212]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370215]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370218]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370221]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.370224]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.370226]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370229]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370231]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370234]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370237]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.370239]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370242]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370245]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370247]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370250]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370253]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370255]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.370258]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370260] panel-9-actions S e9db5aec     0  2586   2414 0x00000000
[ 2639.370262]  e9db5b4c 00200086 f73897f0 e9db5aec c106f28e ee3ec000 c19c9100 00000000
[ 2639.370268]  00000258 c19c9100 f738e100 e9f00000 f73897fc 00000000 e9db5b14 c12ee962
[ 2639.370273]  e9db5b70 f73897f0 e9db5b2c c106f630 f7389980 e9db5b2c 00200296 e9db5b70
[ 2639.370279] Call Trace:
[ 2639.370281]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370284]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370287]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370289]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370292]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370295]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370297]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370300]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370303]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370305]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.370308]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370311]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370313]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370316]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.370319]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.370321]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.370324]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370327]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370329]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.370332]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370335]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370337]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370340]  [<c151dfe0>] ? sock_recvmsg+0xb0/0xe0
[ 2639.370344]  [<c151ec3b>] ? sys_recvfrom+0xcb/0x140
[ 2639.370347]  [<c1018e96>] ? __switch_to_xtra+0x126/0x140
[ 2639.370349]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.370353]  [<c1010c58>] ? __switch_to+0x2a8/0x330
[ 2639.370355]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.370358]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.370361]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.370363]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.370366]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370369]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370371] gvfsd-trash     S e9fa1aec     0  2594      1 0x00000000
[ 2639.370374]  e9fa1b4c 00000082 f73977f0 e9fa1aec c106f28e e3232000 c19c9100 181a34d9
[ 2639.370379]  00000042 c19c9100 f739c100 e9f53340 e9fa1b04 c103ce08 e9fa1b18 c161407d
[ 2639.370385]  f73977f0 e9fa1b90 e9fa1b38 e9fa1b2c c106f705 e9fa1b2c 00000296 e9fa1b70
[ 2639.370390] Call Trace:
[ 2639.370393]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370396]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370399]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370401]  [<c106f705>] ? lock_hrtimer_base.isra.21+0x25/0x50
[ 2639.370404]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370407]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370409]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370412]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370415]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370418]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370420]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370423]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370425]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370429]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370431]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370434]  [<c106bd5d>] ? finish_wait+0x4d/0x70
[ 2639.370436]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.370440]  [<c125817e>] ? wait_answer_interruptible+0x8e/0xa0
[ 2639.370442]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.370445]  [<c107f87c>] ? update_cfs_rq_blocked_load+0xbc/0x220
[ 2639.370448]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370451]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.370453]  [<c1173f3b>] ? d_rehash+0x2b/0x40
[ 2639.370456]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370459]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370461]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370464]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.370467]  [<c111847c>] ? release_pages+0x17c/0x1b0
[ 2639.370470]  [<c11180d0>] ? lru_deactivate_fn+0x190/0x190
[ 2639.370473]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.370476]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.370479]  [<c114d5f7>] ? kmem_cache_free+0xc7/0x100
[ 2639.370482]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370485]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370487]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370490]  [<c106bd5d>] ? finish_wait+0x4d/0x70
[ 2639.370493]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370495]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370498]  [<c1278b90>] ? security_file_permission+0x90/0xb0
[ 2639.370501]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370504]  [<c1099fcc>] ? getnstimeofday+0x4c/0x130
[ 2639.370507]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370510]  [<c105172a>] ? sys_gettimeofday+0x2a/0x70
[ 2639.370513]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370515] gdbus           S 336b5327     0  2595      1 0x00000000
[ 2639.370524]  e9f9fb4c 00000082 00000000 336b5327 00000005 ee29c000 c19c9100 00000000
[ 2639.370529]  00000007 c19c9100 f738e100 e9f02670 f0226300 e9f9fb44 c10820cd 00000000
[ 2639.370535]  0341a04d 00000000 00000006 00004b2c 00000000 00004b2c f3f59600 f6921c00
[ 2639.370540] Call Trace:
[ 2639.370543]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370547]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.370549]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370552]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370555]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370558]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370561]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370563]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370566]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370569]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370571]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370575]  [<c1526d7c>] ? __alloc_skb+0x7c/0x250
[ 2639.370577]  [<c1520c45>] ? sock_alloc_send_pskb+0x185/0x2d0
[ 2639.370580]  [<c1520c45>] ? sock_alloc_send_pskb+0x185/0x2d0
[ 2639.370583]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370586]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370588]  [<c152511c>] ? skb_queue_tail+0x3c/0x50
[ 2639.370591]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.370594]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370597]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370599]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370602]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370604]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370607]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370610]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370613]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.370615]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370618]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370621]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370624]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.370627]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.370629]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370632]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.370635]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.370637]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370640]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370643]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370645] gconfd-2        S e3005aec     0  2608      1 0x00000000
[ 2639.370648]  e3005b4c 00000086 f73977f0 e3005aec c106f28e e3005aec c19c9100 9910b026
[ 2639.370653]  0000025f c19c9100 f739c100 e9f56680 f73977f0 89979294 00000266 00000000
[ 2639.370659]  89979294 00000266 e3005b38 c19c47c0 00000001 e3005b2c 00000001 e3005b70
[ 2639.370665] Call Trace:
[ 2639.370667]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370671]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370673]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.370676]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.370678]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.370681]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370684]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370687]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370689]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.370692]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370695]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370698]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.370701]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.370704]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.370706]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.370709]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.370712]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370715]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370717]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370720]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.370723]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370727]  [<c1130b0c>] ? unmap_single_vma+0x6c/0xd0
[ 2639.370730]  [<c112f238>] ? free_pgtables+0xa8/0xf0
[ 2639.370733]  [<c112ecf7>] ? tlb_finish_mmu+0x17/0x40
[ 2639.370735]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370738]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370741]  [<c1278b90>] ? security_file_permission+0x90/0xb0
[ 2639.370743]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.370746]  [<c1170b84>] ? poll_select_set_timeout+0x64/0x80
[ 2639.370749]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370751]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370753] indicator-appli S e3025aec     0  2611      1 0x00000000
[ 2639.370803]  e3025b4c 00200082 f73977f0 e3025aec c106f28e ecc14000 c19c9100 00000000
[ 2639.370808]  000001f0 c19c9100 f738e100 e9eb3340 f73977fc 00000000 e3025b14 c12ee962
[ 2639.370814]  e3025b70 f73977f0 e3025b2c c106f630 f7397980 e3025b2c 00200296 e3025b70
[ 2639.370819] Call Trace:
[ 2639.370823]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.370826]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.370828]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.370831]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.370834]  [<c16131c3>] schedule+0x23/0x60
[ 2639.370837]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.370840]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370842]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370845]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.370848]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.370850]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.370853]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.370856]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.370859]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.370862]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.370864]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.370867]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.370869]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370872]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370874]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.370877]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.370880]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370883]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.370886]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.370889]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370891]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.370894]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.370897]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.370899]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.370902]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.370905]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.370907]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.370910]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.370913]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.370915]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.370918]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.370921]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.370924]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.370926]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.370942]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.370971] gdbus           S 41792f5c     0  2618      1 0x00000000
[ 2639.370974]  e307db4c 00200082 00000000 41792f5c 00000034 ecc14000 c19c9100 00000000
[ 2639.370980]  00000041 c19c9100 f738e100 e304b340 f3da9c00 e307db44 c10820cd 00000000
[ 2639.370985]  013a014a 00000000 00000041 000082cd 00000000 000082cd f3f5b200 f3f5b200
[ 2639.370991] Call Trace:
[ 2639.370994]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.370997]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371000]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371003]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371006]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371008]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371011]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371014]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371016]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371019]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371022]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371025]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371028]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371031]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371034]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371037]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371039]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371042]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371045]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371048]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371051]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371053]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371056]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371059]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.371061]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.371065]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371067]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371070]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371073]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371076]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371078]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371081]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371084]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371086] indicator-sound S f73977fc     0  2613      1 0x00000000
[ 2639.371089]  e3029b4c 00200082 f00a7b78 f73977fc e3029af0 ecf76000 c19c9100 00000000
[ 2639.371094]  00000265 c19c9100 f738e100 e9fdb340 00000000 f7397000 e3029b0c c10319eb
[ 2639.371099]  e3029b24 c10a0805 00000000 f7397000 f73977c0 00000003 e3029b34 c10a1bd9
[ 2639.371105] Call Trace:
[ 2639.371108]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.371111]  [<c10a0805>] ? clockevents_program_event+0x95/0x140
[ 2639.371114]  [<c10a1bd9>] ? tick_program_event+0x29/0x30
[ 2639.371117]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.371120]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371122]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371125]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371128]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371130]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371133]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371136]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371139]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371141]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371144]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371147]  [<c15b02c5>] ? unix_write_space+0x55/0x80
[ 2639.371150]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.371152]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.371155]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.371158]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371160]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371162]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371165]  [<c15b2cc5>] ? unix_stream_recvmsg+0x5f5/0x6c0
[ 2639.371168]  [<c1052bc8>] ? raise_softirq_irqoff+0x8/0x30
[ 2639.371171]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371173]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371176]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371178]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371181]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.371184]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.371187]  [<c151ec81>] ? sys_recvfrom+0x111/0x140
[ 2639.371190]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.371193]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.371196]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.371198]  [<c151eceb>] ? sys_recv+0x3b/0x40
[ 2639.371201]  [<c151f534>] ? sys_socketcall+0x1a4/0x2b0
[ 2639.371204]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371206]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.371209]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371214] gdbus           S 97ac1adb     0  2622      1 0x00000000
[ 2639.371217]  e309fb4c 00200082 00000000 97ac1adb 00000006 ecc14000 c19c9100 00000000
[ 2639.371222]  00000007 c19c9100 f738e100 e304a670 f3da9c00 e309fb44 c10820cd 00000000
[ 2639.371228]  00dfea1d 000001af 00000007 0000359d 00000000 0000359d f3f5b200 f3f5b200
[ 2639.371233] Call Trace:
[ 2639.371236]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371239]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371242]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371245]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371248]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371250]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371253]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371256]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371258]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371261]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371264]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371267]  [<c15263e9>] ? __kmalloc_reserve+0x29/0x80
[ 2639.371269]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371272]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371275]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371277]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371280]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371283]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371286]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371289]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371292]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371294]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371297]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371300]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371303]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371305]  [<c11748b2>] ? __d_alloc+0x22/0x120
[ 2639.371308]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.371311]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371314]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371317]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371319]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371322]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371325]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371327]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371330]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371332] dconf worker    S e3023aec     0  2624      1 0x00000000
[ 2639.371358]  e3023b4c 00200082 f73897f0 e3023aec c106f28e e9d8c000 c19c9100 00000000
[ 2639.371363]  00000007 c19c9100 f738e100 e9fde680 f73897fc 00000000 e3023b14 c12ee962
[ 2639.371369]  e3023b70 f73897f0 e3023b2c c106f630 f7389980 e3023b2c 00200296 e3023b70
[ 2639.371374] Call Trace:
[ 2639.371377]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.371380]  [<c12ee962>] ? timerqueue_del+0x22/0x60
[ 2639.371383]  [<c106f630>] ? __remove_hrtimer+0x40/0xa0
[ 2639.371385]  [<c106f951>] ? hrtimer_try_to_cancel+0x41/0xd0
[ 2639.371388]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371391]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371394]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371396]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371399]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371402]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371405]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371407]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371410]  [<c1083b94>] ? task_tick_fair+0x154/0x6f0
[ 2639.371413]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.371416]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.371419]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371422]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371424]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371427]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.371429]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.371432]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371434]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.371437]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.371440]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.371443]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.371445]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.371448]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.371450]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371453]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.371456]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371458]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.371462]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.371464]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371467]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.371470]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.371472]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371475]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371477]  [<c1614e80>] ? do_debug+0x170/0x170
[ 2639.371480]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371482] obex-data-serve S 00000016     0  2647      1 0x00000000
[ 2639.371489]  e317db4c 00000086 ffffffe9 00000016 00000007 ecc14000 c19c9100 00000000
[ 2639.371494]  000001f0 c19c9100 f738e100 e3048000 f68ddc00 0000002a 00000000 e317db50
[ 2639.371499]  00000000 f68ddc00 f3f59600 e3048000 e317db44 c1083924 00000008 28af3475
[ 2639.371505] Call Trace:
[ 2639.371508]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.371511]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371514]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371516]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.371519]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371522]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371524]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371527]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.371530]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371532]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371535]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371538]  [<c15218aa>] ? sock_wfree+0x4a/0x60
[ 2639.371541]  [<c15b0891>] ? unix_destruct_scm+0x81/0x90
[ 2639.371544]  [<c1524155>] ? skb_free_head+0x45/0x50
[ 2639.371546]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371548]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371551]  [<c15254ed>] ? __kfree_skb+0x3d/0x90
[ 2639.371553]  [<c15b2b19>] ? unix_stream_recvmsg+0x449/0x6c0
[ 2639.371557]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371559]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371562]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371564]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371567]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371569]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.371572]  [<c151de60>] ? ___sys_recvmsg+0x110/0x1e0
[ 2639.371574]  [<c151df30>] ? ___sys_recvmsg+0x1e0/0x1e0
[ 2639.371577]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.371580]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.371583]  [<c105b041>] ? update_process_times+0x61/0x70
[ 2639.371585]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.371588]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.371591]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.371593]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.371596]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.371598]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.371601]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371604]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371606] ntpd            D 00200292     0  2728      1 0x00000004
[ 2639.371632]  e3175e40 00200086 e3175dd4 00200292 f657bdd8 e3175df4 c19c9100 d0da4e08
[ 2639.371638]  0000005b c19c9100 f738e100 e3182670 e3116f40 e3175e34 e3116f60 e3175e18
[ 2639.371643]  e3175e0c bfd79c10 e3116f40 bfd79c80 e3175e8c c1019d90 ffff037f ffff0020
[ 2639.371648] Call Trace:
[ 2639.371652]  [<c1019d90>] ? save_fsave_header+0x30/0x90
[ 2639.371655]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371658]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.371660]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.371663]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.371667]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.371670]  [<c1533adf>] dev_ioctl+0x2af/0x4d0
[ 2639.371673]  [<c114d913>] ? kmem_cache_alloc_trace+0x103/0x110
[ 2639.371676]  [<c12ac793>] ? apparmor_file_alloc_security+0x23/0x40
[ 2639.371680]  [<c15851a0>] ? udp_poll+0x70/0x70
[ 2639.371682]  [<c151cb05>] sock_ioctl+0x85/0x270
[ 2639.371685]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.371687]  [<c151ca80>] ? sock_fasync+0x90/0x90
[ 2639.371690]  [<c116fb50>] do_vfs_ioctl+0x80/0x580
[ 2639.371693]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.371696]  [<c11797a2>] ? __fd_install+0x42/0x60
[ 2639.371698]  [<c11797e0>] ? fd_install+0x20/0x30
[ 2639.371701]  [<c151e161>] ? sys_socket+0x71/0xb0
[ 2639.371703]  [<c151f400>] ? sys_socketcall+0x70/0x2b0
[ 2639.371706]  [<c11700bb>] sys_ioctl+0x6b/0x80
[ 2639.371709]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371711] xfce4-terminal  R running      0  2736      1 0x00000000
[ 2639.371714]  ee145fa4 00200086 c13a44ef 00000000 00000000 f6946000 c19c9100 850e3308
[ 2639.371719]  00000266 c19c9100 f739c100 e3186680 b953baf1 e9f88000 c13a4380 00000001
[ 2639.371724]  ee145f8c c116030c ee145f98 a437c6b0 00000660 c13a4380 f5e9bb74 e9f88000
[ 2639.371730] Call Trace:
[ 2639.371733]  [<c13a44ef>] ? tty_write+0x16f/0x240
[ 2639.371736]  [<c13a4380>] ? tty_write_lock+0x60/0x60
[ 2639.371738]  [<c116030c>] ? vfs_write+0x8c/0x160
[ 2639.371741]  [<c13a4380>] ? tty_write_lock+0x60/0x60
[ 2639.371743]  [<c1160620>] ? sys_write+0x60/0x80
[ 2639.371746]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371748]  [<c1614346>] work_resched+0x5/0x20
[ 2639.371754] gdbus           S 80000000     0  2737      1 0x00000000
[ 2639.371757]  e9d53b4c 00200086 00000000 80000000 93259553 ee144000 c19c9100 00000000
[ 2639.371762]  000001f0 c19c9100 f738e100 e3180000 ac01498d e9d53b44 c108204a f738e148
[ 2639.371767]  00000000 00000084 e9d53b44 c107f94c f3f36810 f3f5b200 00000001 e9d53b44
[ 2639.371773] Call Trace:
[ 2639.371776]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.371779]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.371782]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.371784]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371787]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371790]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371793]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371795]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371798]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371801]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371803]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371806]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371809]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371812]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.371815]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.371818]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.371820]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.371823]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.371826]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371829]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371831]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371834]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.371838]  [<c112f8c7>] ? do_wp_page+0x3e7/0x8e0
[ 2639.371840]  [<c11144ed>] ? free_pages_prepare+0xdd/0x140
[ 2639.371843]  [<c11146c9>] ? __free_pages+0x49/0x70
[ 2639.371845]  [<c1114756>] ? free_pages+0x26/0x30
[ 2639.371848]  [<c1041ac0>] ? pgd_free+0xf0/0x100
[ 2639.371851]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371867]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371871]  [<c1619cd6>] ? kprobe_flush_task+0x66/0xc0
[ 2639.371873]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.371876]  [<c1078f09>] ? finish_task_switch+0xa9/0xc0
[ 2639.371879]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.371881]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.371884]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.371887]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.371890]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.371917] gmain           S 00000000     0  2741      1 0x00000000
[ 2639.371921]  e31d1b4c 00200086 00000000 00000000 00000000 ee144000 c19c9100 00000001
[ 2639.371926]  00000009 c19c9100 f739c100 e32459b0 00000000 00000000 00000000 00000000
[ 2639.371932]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.371937] Call Trace:
[ 2639.371941]  [<c16131c3>] schedule+0x23/0x60
[ 2639.371944]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.371947]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.371950]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.371952]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.371955]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.371958]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.371961]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.371965]  [<c12e771f>] ? cpumask_next_and+0x1f/0x40
[ 2639.371968]  [<c1085f4d>] ? update_sd_lb_stats+0xcd/0x480
[ 2639.371971]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.371973]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.371977]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.371979]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.371982]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.371985]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.371988]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.371991]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.371993]  [<c113a68e>] ? page_add_new_anon_rmap+0x7e/0x100
[ 2639.371996]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.371999]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372002]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372004]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372007]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372010]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372012]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372014] gnome-pty-helpe S 00000000     0  2739   2736 0x00000000
[ 2639.372021]  e321dd40 00000086 00000000 00000000 00000d00 ee144000 c19c9100 00000001
[ 2639.372026]  000001f0 c19c9100 f739c100 e3183340 e321dd1c 00000000 c1637fac f5eaf800
[ 2639.372032]  e321dd1c c12086d7 f797ac60 00000a86 00000180 0001ad00 00000000 e321dd60
[ 2639.372037] Call Trace:
[ 2639.372041]  [<c12086d7>] ? __ext4_journal_stop+0x57/0x80
[ 2639.372045]  [<c11eca1b>] ? ext4_da_write_end+0x9b/0x310
[ 2639.372048]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372050]  [<c161198d>] schedule_timeout+0x19d/0x240
[ 2639.372053]  [<c110d7c8>] ? generic_file_buffered_write+0x178/0x220
[ 2639.372056]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372059]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372061]  [<c106bfdc>] ? prepare_to_wait+0x4c/0x80
[ 2639.372064]  [<c15b28fc>] unix_stream_recvmsg+0x22c/0x6c0
[ 2639.372067]  [<c1161da1>] ? __sb_end_write+0x31/0x70
[ 2639.372070]  [<c106bd80>] ? finish_wait+0x70/0x70
[ 2639.372073]  [<c151cfaa>] sock_aio_read+0x10a/0x140
[ 2639.372076]  [<c11a45c1>] ? __posix_lock_file+0x2c1/0x5c0
[ 2639.372079]  [<c115fc17>] do_sync_read+0x97/0xd0
[ 2639.372082]  [<c116051d>] vfs_read+0x13d/0x160
[ 2639.372084]  [<c1160587>] sys_read+0x47/0x80
[ 2639.372087]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372089] bash            S e3161eac     0  2740   2736 0x00000000
[ 2639.372095]  e3161f18 00000082 ecc50ec0 e3161eac c12798d4 f6b58000 c19c9100 8de36aae
[ 2639.372101]  0000000a c19c9100 f738e100 e3180cd0 ecd7ed80 c1043d16 094fd8f8 80000000
[ 2639.372106]  e319c300 00000000 e30e3250 e319c300 e3161f28 c1132f15 e3161ef8 c103ce08
[ 2639.372111] Call Trace:
[ 2639.372115]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372118]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372120]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372123]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372126]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372129]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372131]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372133]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372136]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372139]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372141]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372143] sudo            S 00000000     0  2789   2740 0x00000000
[ 2639.372146]  e9f7fabc 00000086 e9f7fa78 00000000 00000000 f6b58000 c19c9100 1ae307bf
[ 2639.372152]  0000000b c19c9100 f738e100 e32419a0 f5c01380 ee2b4780 e9f7fae0 00000000
[ 2639.372157]  f5c01380 e9f7fab0 c114dc5f 00000001 00000001 c1213815 c1213815 00000038
[ 2639.372162] Call Trace:
[ 2639.372166]  [<c114dc5f>] ? __kmalloc+0x11f/0x160
[ 2639.372169]  [<c1213815>] ? ext4_ext_find_extent+0x285/0x310
[ 2639.372171]  [<c1213815>] ? ext4_ext_find_extent+0x285/0x310
[ 2639.372174]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372177]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372180]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372182]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372185]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372188]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372190]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372193]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372195]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372198]  [<c11710c9>] do_select+0x529/0x610
[ 2639.372201]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372204]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372207]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.372209]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372212]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372215]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372217]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372221]  [<c15523f8>] ? __netlink_sendskb+0x28/0x40
[ 2639.372224]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372227]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372229]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372232]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372234]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372238]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.372241]  [<c12e77b5>] ? cpumask_any_but+0x25/0x40
[ 2639.372243]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.372246]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.372249]  [<c1131b3c>] ? handle_pte_fault+0x22c/0x510
[ 2639.372251]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372254]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372257]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.372259]  [<c107c87d>] ? wake_up_new_task+0xdd/0x130
[ 2639.372262]  [<c10499d4>] ? do_fork+0xe4/0x300
[ 2639.372265]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.372267]  [<c117985b>] ? __close_fd+0x6b/0x90
[ 2639.372270]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372272] su              S e30ddeac     0  2807   2789 0x00000000
[ 2639.372299]  e30ddf18 00000082 e30bff40 e30ddeac c12798d4 f6546000 c19c9100 00000001
[ 2639.372305]  0000000b c19c9100 f739c100 e3240000 ecd7d340 c1043d16 b75e8690 00000000
[ 2639.372310]  e30b63c0 00000000 e319edd0 e30b63c0 e30ddf28 c1132f15 e30ddef8 c103ce08
[ 2639.372315] Call Trace:
[ 2639.372319]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372322]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372324]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372327]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372330]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372332]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372335]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372337]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372340]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372342]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372345]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372347] bash            R running      0  2817   2807 0x00000000
[ 2639.372350]  0000cd7c 00000092 00004c1a e30bbe28 c104bc47 e30bbdf8 c103ce08 00000092
[ 2639.372355]  c19e2078 e300be0c 00000086 c1896454 e30bbe1c 00000000 00004c1b 00004c1b
[ 2639.372361]  00000000 00000001 00000000 e30bbe70 00000046 00000009 0301c340 00004c19
[ 2639.372366] Call Trace:
[ 2639.372369]  [<c10a8130>] ? __module_text_address+0x10/0x60
[ 2639.372373]  [<c10ada0d>] ? is_module_text_address+0xd/0x20
[ 2639.372375]  [<c1068ebf>] ? __kernel_text_address+0x4f/0x70
[ 2639.372378]  [<c10140e3>] ? print_context_stack+0x63/0xd0
[ 2639.372381]  [<c1013357>] ? dump_trace+0x97/0x100
[ 2639.372384]  [<c10142bc>] show_trace_log_lvl+0x4c/0x60
[ 2639.372387]  [<c1013418>] show_stack_log_lvl+0x58/0xe0
[ 2639.372390]  [<c1014323>] show_stack+0x23/0x30
[ 2639.372393]  [<c107c3b1>] sched_show_task+0xa1/0x100
[ 2639.372395]  [<c107c46e>] show_state_filter+0x5e/0x90
[ 2639.372399]  [<c13ae85f>] sysrq_handle_showstate+0xf/0x20
[ 2639.372401]  [<c13aece9>] __handle_sysrq+0xe9/0x140
[ 2639.372404]  [<c13aed40>] ? __handle_sysrq+0x140/0x140
[ 2639.372407]  [<c13aed80>] write_sysrq_trigger+0x40/0x50
[ 2639.372410]  [<c11b1e04>] proc_reg_write+0x64/0xa0
[ 2639.372412]  [<c11b1da0>] ? proc_reg_poll+0xa0/0xa0
[ 2639.372415]  [<c116030c>] vfs_write+0x8c/0x160
[ 2639.372417]  [<c11b1da0>] ? proc_reg_poll+0xa0/0xa0
[ 2639.372420]  [<c1179be5>] ? sys_dup3+0x95/0xe0
[ 2639.372422]  [<c1160607>] sys_write+0x47/0x80
[ 2639.372425]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372427] kworker/1:1H    S e9fdd000     0  2827      2 0x00000000
[ 2639.372430]  e31ebf3c 00000046 00000000 e9fdd000 f6433cbc e32de000 c19c9100 00000001
[ 2639.372436]  0000002a c19c9100 f739c100 e9fdcce0 e31ebef8 c12c816e f680f744 f680f744
[ 2639.372441]  e9fa2d80 f7397604 e31ebf44 c10657b1 f739c100 e9fdcce0 f5d03756 f5d0be84
[ 2639.372446] Call Trace:
[ 2639.372450]  [<c12c816e>] ? __blk_run_queue+0x2e/0x40
[ 2639.372453]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.372456]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372459]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.372461]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.372464]  [<c106b694>] kthread+0x94/0xa0
[ 2639.372467]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.372470]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.372472]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.372474] bash            S ee3bfeac     0  3182   2736 0x00000000
[ 2639.372477]  ee3bff18 00000082 e31cff00 ee3bfeac c12798d4 f6b58000 c19c9100 eda7669d
[ 2639.372482]  00000019 c19c9100 f738e100 e304e680 f695d180 c1043d16 09ead8f8 80000000
[ 2639.372488]  e3010300 00000000 e3145278 e3010300 ee3bff28 c1132f15 ee3bfef8 c103ce08
[ 2639.372493] Call Trace:
[ 2639.372496]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.372499]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.372501]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.372504]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372507]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372509]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372512]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.372514]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.372517]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.372519]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.372522]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372524] dconf-service   S 00000286     0  3256      1 0x00000000
[ 2639.372527]  e31f1b4c 00000082 f6cf11f8 00000286 00000000 e31bc000 c19c9100 00000000
[ 2639.372532]  00000018 c19c9100 f738e100 e9f06680 00000002 e31f1b10 f6fca000 ea009230
[ 2639.372538]  e31f1b58 c12377b5 00000000 e31f1b6c c1237c68 f5839f18 72cd5d66 f5eaf800
[ 2639.372543] Call Trace:
[ 2639.372547]  [<c12377b5>] ? jbd2_journal_dirty_metadata+0xb5/0x2b0
[ 2639.372550]  [<c1237c68>] ? do_get_write_access+0x2b8/0x390
[ 2639.372553]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372556]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372558]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372561]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372564]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372567]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372569]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372572]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372576]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372579]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372582]  [<c118bd7e>] ? __find_get_block+0xbe/0x1d0
[ 2639.372585]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.372587]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.372590]  [<c12361c8>] ? __jbd2_journal_temp_unlink_buffer+0x38/0xf0
[ 2639.372593]  [<c1237125>] ? __jbd2_journal_file_buffer+0xb5/0x1b0
[ 2639.372596]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372599]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372601]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372604]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372606]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.372609]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.372612]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.372615]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.372617]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.372620]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372623]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372625]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.372628]  [<c107c730>] ? default_wake_function+0x10/0x20
[ 2639.372631]  [<c1170992>] ? pollwake+0x62/0x70
[ 2639.372633]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.372636]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372639]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372642]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372644]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372647]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372649]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372652] gdbus           S 62d98fbb     0  3257      1 0x00000000
[ 2639.372654]  e31bdb4c 00000082 e31bdb00 62d98fbb 0000002c f3f5b200 c19c9100 7759bb4b
[ 2639.372660]  00000018 c19c9100 f738e100 f689cce0 f3da9c00 e31bdb44 c10820cd 00000000
[ 2639.372665]  00dfea1d ee093f00 00000018 00004526 00000000 00004526 f3f5b200 f3f5b200
[ 2639.372671] Call Trace:
[ 2639.372674]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372677]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372679]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372682]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372685]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372688]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372690]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372693]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372696]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372698]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372701]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372704]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.372707]  [<c119e2e9>] ? ep_poll_callback+0xc9/0x100
[ 2639.372710]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.372713]  [<c10755ec>] ? __wake_up_sync_key+0x4c/0x60
[ 2639.372715]  [<c15220cb>] ? sock_def_readable+0x3b/0x70
[ 2639.372718]  [<c15b0d70>] ? unix_stream_sendmsg+0x390/0x3e0
[ 2639.372721]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372724]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372726]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372729]  [<c151dce9>] ? ___sys_sendmsg+0x299/0x2b0
[ 2639.372732]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.372735]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.372737]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.372740]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.372743]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.372746]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.372748]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.372751]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.372754]  [<c151ef2f>] ? __sys_sendmsg+0x5f/0x70
[ 2639.372757]  [<c151f5f8>] ? sys_socketcall+0x268/0x2b0
[ 2639.372759]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372762]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372764]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372769] gmain           S 00000000     0  3258      1 0x00000000
[ 2639.372773]  e327bb4c 00000082 00000000 00000000 00000000 e9eaa000 c19c9100 00000001
[ 2639.372778]  00000018 c19c9100 f739c100 e304d9b0 00000000 00000000 00000000 00000000
[ 2639.372783]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.372788] Call Trace:
[ 2639.372792]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372795]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372798]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372800]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372803]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372806]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372809]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372811]  [<c1171a60>] do_sys_poll+0x320/0x450
[ 2639.372814]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372817]  [<c12e77b5>] ? cpumask_any_but+0x25/0x40
[ 2639.372820]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.372823]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372826]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372828]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.372831]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.372833]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372836]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.372839]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.372841]  [<c10846c5>] ? enqueue_entity+0x535/0xd20
[ 2639.372844]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.372847]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.372849]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.372852]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.372855]  [<c104164a>] ? pte_alloc_one+0x3a/0x50
[ 2639.372858]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.372860]  [<c11a0d1a>] ? eventfd_ctx_read+0xaa/0x190
[ 2639.372863]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.372866]  [<c11a0e00>] ? eventfd_ctx_read+0x190/0x190
[ 2639.372868]  [<c1171c3a>] sys_poll+0x5a/0xd0
[ 2639.372871]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372873] wish8.5         S e3177db8     0  3283   3182 0x00000000
[ 2639.372876]  e3177e18 00200086 f73977f0 e3177db8 c106f28e e3177db8 c19c9100 83924849
[ 2639.372881]  00000266 c19c9100 f739c100 e9fd8cd0 f73977f0 889fe920 00000266 00000000
[ 2639.372887]  889fe920 00000266 e3177e08 c19c47c0 00000001 359d3000 00000001 e3177e24
[ 2639.372892] Call Trace:
[ 2639.372895]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.372898]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372901]  [<c10a382f>] futex_wait_queue_me+0xcf/0xf0
[ 2639.372904]  [<c10a3f0d>] futex_wait+0x16d/0x270
[ 2639.372907]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.372909]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.372912]  [<c10a5dd2>] do_futex+0x112/0x550
[ 2639.372914]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.372917]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.372920]  [<c10a6290>] sys_futex+0x80/0x130
[ 2639.372923]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.372924] wish8.5         S c12ee9f0     0  3286   3182 0x00000000
[ 2639.372927]  ecffdabc 00000086 ecffda58 c12ee9f0 f7397980 e3176000 c19c9100 00000001
[ 2639.372933]  00000266 c19c9100 f739c100 e9eb4ce0 ecffda74 c10319eb ecffda8c c10a0805
[ 2639.372938]  00000000 f7397000 f73977c0 00000003 ecffda9c c10a1bd9 00000000 00000000
[ 2639.372943] Call Trace:
[ 2639.372946]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.372949]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.372952]  [<c10a0805>] ? clockevents_program_event+0x95/0x140
[ 2639.372955]  [<c10a1bd9>] ? tick_program_event+0x29/0x30
[ 2639.372957]  [<c107050d>] ? hrtimer_interrupt+0x17d/0x290
[ 2639.372960]  [<c16131c3>] schedule+0x23/0x60
[ 2639.372963]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.372966]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.372968]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.372971]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.372974]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372976]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.372979]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.372981]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.372984]  [<c11710c9>] do_select+0x529/0x610
[ 2639.372987]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372990]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372992]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.372995]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.372997]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.372999]  [<c10823a5>] ? update_cfs_shares+0xa5/0x100
[ 2639.373002]  [<c1082626>] ? dequeue_entity+0x156/0x670
[ 2639.373005]  [<c1082fee>] ? dequeue_task_fair+0x36e/0x6d0
[ 2639.373007]  [<c107e9bd>] ? sched_clock_cpu+0xfd/0x180
[ 2639.373010]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.373013]  [<c107fa05>] ? __dequeue_entity+0x25/0x40
[ 2639.373016]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.373018]  [<c1078ea1>] ? finish_task_switch+0x41/0xc0
[ 2639.373021]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.373024]  [<c1083924>] ? check_preempt_wakeup+0x144/0x260
[ 2639.373026]  [<c10a39f9>] ? get_futex_key+0x139/0x260
[ 2639.373029]  [<c16131c3>] ? schedule+0x23/0x60
[ 2639.373032]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373035]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373038]  [<c115fc17>] ? do_sync_read+0x97/0xd0
[ 2639.373041]  [<c11604c5>] ? vfs_read+0xe5/0x160
[ 2639.373043]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.373046]  [<c11605a0>] ? sys_read+0x60/0x80
[ 2639.373049]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373050] vnoded          S e3233e60     0  4150      1 0x00000000
[ 2639.373053]  e3233ec0 00000086 f73977f0 e3233e60 c106f28e e3132000 c19c9100 00000001
[ 2639.373072]  0000025e c19c9100 f739c100 e3240cd0 f73977f0 7b45f363 0000026c 00000000
[ 2639.373077]  7b45f363 0000026c e3233eac c19c47c0 00000001 e3233ea0 00000001 e3233ee4
[ 2639.373083] Call Trace:
[ 2639.373086]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373089]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373092]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373095]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373097]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373100]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373103]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373106]  [<c12f31d1>] ? copy_to_user+0x41/0x60
[ 2639.373109]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373112]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373114] vnoded          S e3133e60     0  4161      1 0x00000000
[ 2639.373117]  e3133ec0 00000082 f73977f0 e3133e60 c106f28e e3133e60 c19c9100 9c252f91
[ 2639.373122]  0000025e c19c9100 f739c100 cc01e680 f73977f0 7b462637 0000026c 00000000
[ 2639.373128]  7b462637 0000026c e3133eac c19c47c0 00000001 e3133ea0 00000001 e3133ee4
[ 2639.373133] Call Trace:
[ 2639.373136]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373139]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373142]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373145]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373148]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373151]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373153]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373156]  [<c12f31d1>] ? copy_to_user+0x41/0x60
[ 2639.373159]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373162]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373164] udevd           S 00000000     0  4259    401 0x00000000
[ 2639.373171]  e33c3ec0 00000086 00000000 00000000 00000000 f3e64000 c19c9100 00000001
[ 2639.373176]  00000041 c19c9100 f739c100 e3378cd0 00000000 00000000 00000008 f6c05200
[ 2639.373182]  00000000 e33c3f4c c151eaed bfb27a7c 00000008 00000000 bfb27a7c 00000008
[ 2639.373187] Call Trace:
[ 2639.373190]  [<c151eaed>] ? sys_sendto+0xfd/0x140
[ 2639.373193]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373196]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.373198]  [<c151c02e>] ? sock_poll+0x1e/0x30
[ 2639.373201]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373204]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373207]  [<c119e1ea>] ? ep_scan_ready_list.isra.8+0x15a/0x170
[ 2639.373210]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373212]  [<c119ef85>] sys_epoll_wait+0x2e5/0x350
[ 2639.373215]  [<c151eb6b>] ? sys_send+0x3b/0x40
[ 2639.373218]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.373221]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373223] kworker/0:0     D f5c035f0     0  4487      2 0x00000000
[ 2639.373226]  f68c7ea8 00000046 f738e100 f5c035f0 00000000 00000002 c19c9100 c6835b30
[ 2639.373231]  0000005b c19c9100 f738e100 cc01b340 00000000 f68c7e64 c1613dad f68c7ebc
[ 2639.373236]  c108729f 00000002 f68c7eac c107972b cc01b340 c16256e0 00000000 c188b1e0
[ 2639.373242] Call Trace:
[ 2639.373245]  [<c1613dad>] ? _raw_spin_lock+0xd/0x10
[ 2639.373247]  [<c108729f>] ? idle_balance+0x29f/0x3f0
[ 2639.373250]  [<c107972b>] ? update_rq_clock+0x3b/0x70
[ 2639.373253]  [<c1010a62>] ? __switch_to+0xb2/0x330
[ 2639.373255]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373258]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373260]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373263]  [<c1612b00>] ? __schedule+0x360/0x780
[ 2639.373266]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373268]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373271]  [<c15419dd>] linkwatch_event+0xd/0x30
[ 2639.373274]  [<c1065745>] process_one_work+0x135/0x3e0
[ 2639.373277]  [<c1066c59>] worker_thread+0x119/0x3c0
[ 2639.373279]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.373282]  [<c106b694>] kthread+0x94/0xa0
[ 2639.373284]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.373287]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.373290]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.373292] sh              S e3315ec4     0  4501   1514 0x00000000
[ 2639.373319]  e3315f30 00000086 2b92d065 e3315ec4 c12798d4 cc042000 c19c9100 00000001
[ 2639.373325]  00000047 c19c9100 f739c100 e9eb0000 e336add8 e324e720 e3315f28 c1132f15
[ 2639.373330]  e3394d90 e336add8 00000029 00000008 cc0199a0 f739c100 e3315f10 c103ce08
[ 2639.373336] Call Trace:
[ 2639.373339]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373342]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373345]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373347]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373350]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373352]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373355]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373357]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373360]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373363] run-parts       S 00000000     0  4502   4501 0x00000000
[ 2639.373370]  cc043aac 00000082 00000000 00000000 00000000 e322a000 c19c9100 994887ef
[ 2639.373375]  00000047 c19c9100 f739c100 cc0199a0 00000000 00000000 00000000 00000000
[ 2639.373380]  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[ 2639.373386] Call Trace:
[ 2639.373389]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373392]  [<c1612475>] schedule_hrtimeout_range_clock+0x145/0x160
[ 2639.373395]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373398]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373400]  [<c106be7e>] ? add_wait_queue+0x3e/0x50
[ 2639.373403]  [<c11708d3>] ? __pollwait+0x73/0xd0
[ 2639.373406]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373408]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373411]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.373414]  [<c11710c9>] do_select+0x529/0x610
[ 2639.373417]  [<c12157fe>] ? ext4_ext_map_blocks+0xae/0x1a20
[ 2639.373420]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373422]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373426]  [<c118c9e8>] ? __getblk+0x38/0x330
[ 2639.373428]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.373431]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373434]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373437]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373440]  [<c1043d16>] ? kmap_atomic_prot+0x46/0x100
[ 2639.373442]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373445]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373447]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373451]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.373454]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373456]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373459]  [<c105ee33>] ? __set_current_blocked+0x43/0x60
[ 2639.373462]  [<c105ef23>] ? set_current_blocked+0x13/0x20
[ 2639.373465]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373467]  [<c104ec91>] ? wait_consider_task+0x81/0xbe0
[ 2639.373470]  [<c10192b5>] ? fpu_finit+0x55/0x70
[ 2639.373473]  [<c101a5f3>] ? __restore_xstate_sig+0x383/0x510
[ 2639.373475]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373478]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373481]  [<c106c04f>] ? remove_wait_queue+0x3f/0x50
[ 2639.373483]  [<c105c427>] ? recalc_sigpending+0x17/0x50
[ 2639.373486]  [<c105ce25>] ? __set_task_blocked+0x35/0x80
[ 2639.373488]  [<c105ee33>] ? __set_current_blocked+0x43/0x60
[ 2639.373491]  [<c105eead>] ? sigprocmask+0x5d/0xc0
[ 2639.373494]  [<c11715fb>] sys_pselect6+0xeb/0x1e0
[ 2639.373496]  [<c10508cc>] ? sys_waitpid+0x2c/0x30
[ 2639.373499]  [<c16142a7>] syscall_call+0x7/0xb
[ 2639.373501] apt             S e3363ec4     0  4509   4502 0x00000000
[ 2639.373507]  e3363f30 00000082 3af7c065 e3363ec4 c12798d4 e3363f38 c19c9100 b43b5074
[ 2639.373512]  000000c2 c19c9100 f739c100 f6898cd0 e33a3200 e323c8a0 e3363f28 c1132f15
[ 2639.373517]  e3260310 e33a3200 00000029 f738e100 c1625660 e3363f0c e3363f10 c103ce08
[ 2639.373523] Call Trace:
[ 2639.373526]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373529]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373531]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373534]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373537]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373539]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373542]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373544]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373547]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373549] ip              D 00000000     0  4858   4161 0x00000000
[ 2639.373552]  e9edfcd8 00000086 c18f8240 00000000 00000000 00000040 c19c9100 99107053
[ 2639.373557]  0000005b c19c9100 f739c100 e3184010 e9edfc90 c12eb31d 00000001 f6c6fd78
[ 2639.373563]  00000000 f6c6fe44 e9edfca8 c12eb31d e9edfcc8 c110dd7e c103ce08 f7bfb2f0
[ 2639.373568] Call Trace:
[ 2639.373571]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373574]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373576]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.373579]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373582]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373585]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373587]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373590]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373593]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373595]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.373598]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.373601]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.373604]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.373607]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.373609]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373613]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.373615]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373618]  [<c11723a5>] ? d_free+0x45/0x50
[ 2639.373621]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.373624]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.373626]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.373629]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.373632]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373634] bash            S e320beac     0  5552   2736 0x00000000
[ 2639.373639]  e320bf18 00000082 e3268400 e320beac c12798d4 f5e50000 c19c9100 bbdefc14
[ 2639.373645]  000000a6 c19c9100 f738e100 e337b340 f68e6140 c1043db1 08a8b8f8 80000000
[ 2639.373650]  f68eaf00 00000000 e3235228 f68eaf00 e320bf28 c1132f15 e320bef8 c103ce08
[ 2639.373656] Call Trace:
[ 2639.373659]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373661]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.373664]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373667]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373670]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373672]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373675]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373677]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373680]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373682]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.373685]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373710] sudo            D c1114c38     0  5612   5552 0x00000000
[ 2639.373716]  e32efcf8 00000082 e32efcf4 c1114c38 00000002 00000041 c19c9100 bc0c5754
[ 2639.373722]  000000a6 c19c9100 f738e100 e337c010 00000000 00000040 00000000 00000002
[ 2639.373727]  00000020 c18f8c04 c18f85a8 00000040 000280da 00000000 00000000 00000246
[ 2639.373733] Call Trace:
[ 2639.373736]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.373739]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373742]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.373744]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.373747]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.373749]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.373752]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.373755]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.373758]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.373760]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.373763]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.373766]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.373769]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.373771]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.373775]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.373777]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373780]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.373783]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.373786]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.373789]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373791] bash            S ecc97eac     0  5648   2736 0x00000000
[ 2639.373797]  ecc97f18 00000082 cc017fc0 ecc97eac c12798d4 f6946000 c19c9100 abae4ee1
[ 2639.373803]  000000ea c19c9100 f739c100 e337a670 f68e6680 c1043db1 08b79388 80000000
[ 2639.373808]  f68eaf60 00000000 e9d40228 f68eaf60 ecc97f28 c1132f15 ecc97ef8 c103ce08
[ 2639.373813] Call Trace:
[ 2639.373817]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.373819]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.373822]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.373824]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.373827]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.373830]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373832]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.373835]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.373838]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.373840]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.373843]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373845] apt-get         S e3281a5c     0  5970   4509 0x00000000
[ 2639.373848]  e3281abc 00000086 f73977f0 e3281a5c c106f28e e3281a5c c19c9100 69f99bb0
[ 2639.373853]  00000266 c19c9100 f739c100 e9eb4010 f73977f0 7def4bd4 00000266 00000000
[ 2639.373859]  7def4bd4 00000266 e3281aa8 c19c47c0 00000001 e3281a9c 00000001 e3281ae0
[ 2639.373864] Call Trace:
[ 2639.373867]  [<c106f28e>] ? enqueue_hrtimer+0x1e/0x70
[ 2639.373870]  [<c16131c3>] schedule+0x23/0x60
[ 2639.373873]  [<c16123ec>] schedule_hrtimeout_range_clock+0xbc/0x160
[ 2639.373875]  [<c106f3b0>] ? update_rmtp+0x90/0x90
[ 2639.373878]  [<c1070286>] ? hrtimer_start_range_ns+0x26/0x30
[ 2639.373881]  [<c16124a7>] schedule_hrtimeout_range+0x17/0x20
[ 2639.373883]  [<c1170837>] poll_schedule_timeout+0x37/0x60
[ 2639.373886]  [<c11710c9>] do_select+0x529/0x610
[ 2639.373888]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.373892]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373894]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373897]  [<c1170930>] ? __pollwait+0xd0/0xd0
[ 2639.373899]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373902]  [<c107f94c>] ? update_cfs_rq_blocked_load+0x18c/0x220
[ 2639.373905]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373907]  [<c10820cd>] ? update_curr+0x13d/0x1f0
[ 2639.373910]  [<c107fa90>] ? __enqueue_entity+0x70/0x80
[ 2639.373913]  [<c108466b>] ? enqueue_entity+0x4db/0xd20
[ 2639.373916]  [<c107fb8e>] ? __update_entity_load_avg_contrib+0xae/0x110
[ 2639.373918]  [<c1079a05>] ? resched_task+0x25/0x70
[ 2639.373921]  [<c108399e>] ? check_preempt_wakeup+0x1be/0x260
[ 2639.373923]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.373926]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.373928]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.373931]  [<c108204a>] ? update_curr+0xba/0x1f0
[ 2639.373934]  [<c12f32f1>] ? _copy_from_user+0x41/0x60
[ 2639.373937]  [<c1171314>] core_sys_select+0x164/0x2b0
[ 2639.373939]  [<c108751f>] ? trigger_load_balance+0x4f/0x1c0
[ 2639.373942]  [<c107b60a>] ? scheduler_tick+0xda/0x100
[ 2639.373945]  [<c105b041>] ? update_process_times+0x61/0x70
[ 2639.373947]  [<c12ee9f0>] ? timerqueue_add+0x50/0xb0
[ 2639.373950]  [<c109a183>] ? ktime_get+0x63/0x100
[ 2639.373953]  [<c10319eb>] ? lapic_next_event+0x1b/0x20
[ 2639.373955]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.373958]  [<c109a26b>] ? ktime_get_ts+0x4b/0x150
[ 2639.373960]  [<c1170b84>] ? poll_select_set_timeout+0x64/0x80
[ 2639.373963]  [<c11714d7>] sys_select+0x77/0xb0
[ 2639.373966]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.373968] http            D cc037cb0     0  5973   5970 0x00000000
[ 2639.373971]  cc037cf8 00000082 f5c04600 cc037cb0 c1157ff8 e3280000 c19c9100 00000001
[ 2639.373976]  000000c2 c19c9100 f739c100 e9eb6680 f79c33c0 f5c01480 ee31f700 cc037d20
[ 2639.373981]  00000292 8020001e 00000000 80200020 cc037cd8 c1043c04 c1526d3c 00000292
[ 2639.373987] Call Trace:
[ 2639.373990]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.373992]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.373995]  [<c1526d3c>] ? __alloc_skb+0x3c/0x250
[ 2639.373997]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374000]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374003]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374005]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374008]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374011]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374013]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374016]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374019]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374022]  [<c11727fc>] ? dget_parent+0x3c/0x60
[ 2639.374024]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374027]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374030]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374032]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.374035]  [<c1073ce6>] ? lg_local_unlock+0x16/0x20
[ 2639.374037]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374040]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374043]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374046]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374048]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374051]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374054]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374057]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374059] http            D e30afcb0     0  5974   5970 0x00000000
[ 2639.374062]  e30afcf8 00000082 f5c04600 e30afcb0 c1157ff8 ee3e4000 c19c9100 00000001
[ 2639.374067]  000000c2 c19c9100 f739c100 e3242670 00000001 fffa58f8 f7b72d80 f7b72d80
[ 2639.374072]  e30d0240 e30afcc4 c1118a53 e30afcd8 e30afcd8 c1043c04 fffa58f8 f7b72d80
[ 2639.374078] Call Trace:
[ 2639.374081]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.374084]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.374086]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.374089]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374091]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374094]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374097]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374099]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374102]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374105]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374107]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374110]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374113]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374116]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374118]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374121]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374124]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374126]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374129]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374132]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374135]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374137] http            D ee3e5cb0     0  5977   5970 0x00000000
[ 2639.374140]  ee3e5cf8 00000082 f5c04600 ee3e5cb0 c1157ff8 e3280000 c19c9100 00000001
[ 2639.374145]  000000c2 c19c9100 f739c100 e33799a0 00000001 fdfa5b50 f7bce3c0 f7bce3c0
[ 2639.374151]  e9ecf4e0 ee3e5cc4 c1118a53 ee3e5cd8 ee3e5cd8 c1043c04 fffa5b50 f7bce3c0
[ 2639.374156] Call Trace:
[ 2639.374159]  [<c1157ff8>] ? __mem_cgroup_commit_charge+0x88/0x230
[ 2639.374162]  [<c1118a53>] ? lru_cache_add_lru+0x23/0x40
[ 2639.374164]  [<c1043c04>] ? __kunmap_atomic+0x64/0x90
[ 2639.374167]  [<c1131c60>] ? handle_pte_fault+0x350/0x510
[ 2639.374170]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374172]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374175]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374177]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374180]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374183]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374185]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374188]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374191]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374194]  [<c116910e>] ? terminate_walk+0x2e/0x40
[ 2639.374196]  [<c116b8ec>] ? do_last+0x63c/0xc20
[ 2639.374199]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374202]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374205]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374207]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374210]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374213]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374215] dhclient-script S e322beac     0  6075    960 0x00000000
[ 2639.374218]  e322bf18 00000086 fffb9168 e322beac c12798d4 e322bf20 c19c9100 c8ebfc46
[ 2639.374224]  000000cd c19c9100 f738e100 e3378000 f68e6a00 c1043db1 0a02dbc8 80000000
[ 2639.374229]  e328bf60 00000000 e32d0280 e328bf60 e322bf28 c1132f15 e322bef8 c103ce08
[ 2639.374234] Call Trace:
[ 2639.374237]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.374240]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374242]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374245]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374248]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374251]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374253]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.374256]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.374258]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.374261]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.374263]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374265] ip              D 00000000     0  6100   6075 0x00000000
[ 2639.374271]  e3047cd8 00000086 c18f8240 00000000 00000000 00000040 c19c9100 c9294d53
[ 2639.374276]  000000cd c19c9100 f738e100 e337d9b0 e3047c90 c12eb31d f7560d40 f5c19580
[ 2639.374282]  cb1eb420 e3047d08 00000282 80160010 00000000 80160016 c103ce08 f7bfb2f0
[ 2639.374287] Call Trace:
[ 2639.374290]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374293]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374296]  [<c11b1873>] ? proc_alloc_inode+0x23/0xa0
[ 2639.374299]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374301]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374304]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374307]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374309]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374312]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374315]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374317]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374321]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374323]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.374326]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374329]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374332]  [<c11723a5>] ? d_free+0x45/0x50
[ 2639.374335]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374337]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.374340]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.374343]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.374346]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374347] ip              D 00000000     0  6354   5648 0x00000004
[ 2639.374374]  cc009cd8 00000082 c18f8240 00000000 00000000 00000040 c19c9100 abeac148
[ 2639.374379]  000000ea c19c9100 f739c100 e9f54010 cc009c90 c12eb31d cc009cb0 cc009c9c
[ 2639.374385]  c103ce08 cc009cb0 c161407d cc009cb0 00000092 c18d5b80 cc009cf4 c13cd678
[ 2639.374390] Call Trace:
[ 2639.374394]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374396]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374399]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374403]  [<c13cd678>] ? account+0xf8/0x1d0
[ 2639.374406]  [<c1112544>] ? zone_watermark_ok+0x34/0x40
[ 2639.374408]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374411]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374414]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374416]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374419]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374422]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374425]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374427]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374430]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374433]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374436]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374439]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374441]  [<c151e8df>] ? sys_getsockname+0xcf/0xe0
[ 2639.374444]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374446]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374449]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374452]  [<c151eb6b>] sys_send+0x3b/0x40
[ 2639.374465]  [<c151f515>] sys_socketcall+0x185/0x2b0
[ 2639.374468]  [<c1617830>] ? __do_page_fault+0x4e0/0x4e0
[ 2639.374471]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374473] bash            S cc053eac     0  7178   2736 0x00000000
[ 2639.374476]  cc053f18 00000082 fffb9220 cc053eac c12798d4 f6b58000 c19c9100 a5710dd0
[ 2639.374481]  000001de c19c9100 f738e100 cc01cce0 f68e5880 c1043db1 088448f8 80000000
[ 2639.374487]  e9ec4ae0 00000000 ecdbe220 e9ec4ae0 cc053f28 c1132f15 cc053ef8 c103ce08
[ 2639.374492] Call Trace:
[ 2639.374495]  [<c12798d4>] ? security_task_wait+0x14/0x20
[ 2639.374498]  [<c1043db1>] ? kmap_atomic_prot+0xe1/0x100
[ 2639.374501]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374503]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374506]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374509]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374511]  [<c104f999>] do_wait+0x1a9/0x1f0
[ 2639.374514]  [<c1050829>] sys_wait4+0x69/0xe0
[ 2639.374517]  [<c104e610>] ? task_stopped_code+0x50/0x50
[ 2639.374519]  [<c10508cc>] sys_waitpid+0x2c/0x30
[ 2639.374522]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374524] kworker/0:2     S f738e100     0  8231      2 0x00000000
[ 2639.374527]  f6b59f3c 00000046 f738e100 f738e100 f6b59edc e3304000 c19c9100 9b62328b
[ 2639.374532]  00000246 c19c9100 f738e100 e9f52670 00000001 f68394d0 f68380c4 f6838060
[ 2639.374537]  e3207500 f73895d8 f6b59f44 c10657b1 e325d840 f6b59f1c c1063c90 e9f52670
[ 2639.374543] Call Trace:
[ 2639.374546]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374549]  [<c1063c90>] ? need_to_create_worker+0x10/0x30
[ 2639.374552]  [<c1066aac>] ? manage_workers+0x1ac/0x240
[ 2639.374554]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374557]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374559]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374562]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374564]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374567]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374570]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374572] sudo            D c1114c38     0  8550   7178 0x00000000
[ 2639.374579]  e3353cf8 00000082 e3353cf4 c1114c38 00000002 00000041 c19c9100 a5a78096
[ 2639.374584]  000001de c19c9100 f739c100 cc01c010 00000000 00000040 00000000 00000002
[ 2639.374589]  00000020 c18f8c04 c18f85a8 00000040 000280da 00000000 00000000 00000246
[ 2639.374595] Call Trace:
[ 2639.374598]  [<c1114c38>] ? get_page_from_freelist+0x338/0x560
[ 2639.374601]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374603]  [<c161340d>] schedule_preempt_disabled+0xd/0x10
[ 2639.374606]  [<c1612166>] __mutex_lock_slowpath+0xc6/0x120
[ 2639.374609]  [<c1114f7d>] ? __alloc_pages_nodemask+0x11d/0x7d0
[ 2639.374611]  [<c1611cf4>] mutex_lock+0x24/0x40
[ 2639.374614]  [<c153d622>] rtnl_lock+0x12/0x20
[ 2639.374617]  [<c153d640>] rtnetlink_rcv+0x10/0x30
[ 2639.374619]  [<c1554937>] netlink_unicast+0x167/0x1e0
[ 2639.374622]  [<c1554bd9>] netlink_sendmsg+0x229/0x3a0
[ 2639.374625]  [<c151da1c>] sock_sendmsg+0x9c/0xd0
[ 2639.374628]  [<c12eb31d>] ? radix_tree_lookup_slot+0xd/0x10
[ 2639.374630]  [<c110dd7e>] ? find_get_page+0x1e/0xa0
[ 2639.374633]  [<c11100bb>] ? filemap_fault+0xbb/0x400
[ 2639.374636]  [<c151eaed>] sys_sendto+0xfd/0x140
[ 2639.374639]  [<c1132f15>] ? handle_mm_fault+0x1f5/0x2c0
[ 2639.374642]  [<c1172e68>] ? __d_instantiate+0xa8/0xe0
[ 2639.374644]  [<c16175e7>] ? __do_page_fault+0x297/0x4e0
[ 2639.374647]  [<c151f561>] sys_socketcall+0x1d1/0x2b0
[ 2639.374650]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374652] bash            S 000004bf     0  8594   2736 0x00000000
[ 2639.374655]  e32bde5c 00000082 00000005 000004bf 00000008 f5e50000 c19c9100 e68baa0e
[ 2639.374661]  00000262 c19c9100 f738e100 f697e680 e32bde20 c107a412 f697e680 00000001
[ 2639.374666]  f697e680 e32bde3c c107a458 00000000 f738e100 e32bde3c 00000086 f697e680
[ 2639.374672] Call Trace:
[ 2639.374675]  [<c107a412>] ? check_preempt_curr+0x72/0x90
[ 2639.374677]  [<c107a458>] ? ttwu_do_wakeup+0x28/0x110
[ 2639.374680]  [<c107c67e>] ? try_to_wake_up+0x18e/0x230
[ 2639.374683]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374685]  [<c161198d>] schedule_timeout+0x19d/0x240
[ 2639.374688]  [<c1074445>] ? __wake_up_common+0x45/0x70
[ 2639.374690]  [<c1613dc8>] ? _raw_spin_lock_irq+0x18/0x20
[ 2639.374693]  [<c1066ff7>] ? flush_work+0xf7/0x120
[ 2639.374696]  [<c103ce08>] ? default_spin_lock_flags+0x8/0x10
[ 2639.374698]  [<c161407d>] ? _raw_spin_lock_irqsave+0x2d/0x40
[ 2639.374701]  [<c13a907b>] n_tty_read+0x1cb/0x740
[ 2639.374704]  [<c106c04f>] ? remove_wait_queue+0x3f/0x50
[ 2639.374707]  [<c13aac97>] ? tty_ldisc_try+0x37/0x50
[ 2639.374709]  [<c107c720>] ? try_to_wake_up+0x230/0x230
[ 2639.374712]  [<c13a8eb0>] ? is_ignored+0x40/0x40
[ 2639.374714]  [<c13a4252>] tty_read+0x72/0xd0
[ 2639.374716]  [<c13a8eb0>] ? is_ignored+0x40/0x40
[ 2639.374719]  [<c13a41e0>] ? tty_poll+0x90/0x90
[ 2639.374721]  [<c1160469>] vfs_read+0x89/0x160
[ 2639.374724]  [<c13a41e0>] ? tty_poll+0x90/0x90
[ 2639.374726]  [<c1160587>] sys_read+0x47/0x80
[ 2639.374729]  [<c161b24d>] sysenter_do_call+0x12/0x28
[ 2639.374731] kworker/0:3     S c106660c     0  8657      2 0x00000000
[ 2639.374736]  e3305f3c 00000046 e3305ed0 c106660c 000001f4 f5e50000 c19c9100 14026910
[ 2639.374742]  00000266 c19c9100 f738e100 cc018000 00000001 f68394d0 f68380c4 f6838060
[ 2639.374747]  e325ddc0 f73895d8 e3305f44 c10657b1 f738966c e3305f34 c105ac22 cc018000
[ 2639.374753] Call Trace:
[ 2639.374756]  [<c106660c>] ? queue_delayed_work+0x1c/0x20
[ 2639.374759]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374761]  [<c105ac22>] ? mod_timer+0xf2/0x1b0
[ 2639.374764]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374766]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374769]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374771]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374774]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374777]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374780]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374782] kworker/0:1     S 00000296     0  8682      2 0x00000000
[ 2639.374785]  f5e51f3c 00000046 f5e51ed8 00000296 c19e2078 ecf76000 c19c9100 00000000
[ 2639.374790]  00000266 c19c9100 f738e100 cc01a670 c18cfadc e325d840 f73895ec c18cfadc
[ 2639.374795]  e325d840 f73895ec f5e51f44 c10657b1 f738e100 cc01a670 f738964c 00000000
[ 2639.374801] Call Trace:
[ 2639.374804]  [<c10657b1>] ? process_one_work+0x1a1/0x3e0
[ 2639.374807]  [<c16131c3>] schedule+0x23/0x60
[ 2639.374809]  [<c1066cfd>] worker_thread+0x1bd/0x3c0
[ 2639.374811]  [<c1066b40>] ? manage_workers+0x240/0x240
[ 2639.374814]  [<c106b694>] kthread+0x94/0xa0
[ 2639.374817]  [<c1070000>] ? __hrtimer_start_range_ns+0x230/0x460
[ 2639.374820]  [<c161b1b7>] ret_from_kernel_thread+0x1b/0x28
[ 2639.374822]  [<c106b600>] ? kthread_create_on_node+0xc0/0xc0
[ 2639.374826] Sched Debug Version: v0.10, 3.8.0-28-generic #41
[ 2639.374828] ktime                                   : 2639209.635367
[ 2639.374830] sched_clk                               : 2639374.824758
[ 2639.374831] cpu_clk                                 : 2639374.824826
[ 2639.374833] jiffies                                 : 584801
[ 2639.374834] sched_clock_stable                      : 1
[ 2639.374835] 
[ 2639.374836] sysctl_sched
[ 2639.374838]   .sysctl_sched_latency                    : 12.000000
[ 2639.374839]   .sysctl_sched_min_granularity            : 1.500000
[ 2639.374841]   .sysctl_sched_wakeup_granularity         : 2.000000
[ 2639.374842]   .sysctl_sched_child_runs_first           : 0
[ 2639.374844]   .sysctl_sched_features                   : 24187
[ 2639.374846]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[ 2639.374847] 
[ 2639.374847] cpu#0, 2652.796 MHz
[ 2639.374849]   .nr_running                    : 0
[ 2639.374855]   .load                          : 0
[ 2639.374856]   .nr_switches                   : 3620208
[ 2639.374858]   .nr_load_updates               : 110050
[ 2639.374859]   .nr_uninterruptible            : 7
[ 2639.374860]   .next_balance                  : 0.584802
[ 2639.374862]   .curr->pid                     : 0
[ 2639.374863]   .clock                         : 2639369.619218
[ 2639.374865]   .cpu_load[0]                   : 0
[ 2639.374866]   .cpu_load[1]                   : 0
[ 2639.374867]   .cpu_load[2]                   : 0
[ 2639.374869]   .cpu_load[3]                   : 0
[ 2639.374870]   .cpu_load[4]                   : 0
[ 2639.374871]   .yld_count                     : 0
[ 2639.374872]   .sched_count                   : 3620342
[ 2639.374874]   .sched_goidle                  : 1699148
[ 2639.374875]   .avg_idle                      : 1000000
[ 2639.374877]   .ttwu_count                    : 1846819
[ 2639.374878]   .ttwu_local                    : 1826806
[ 2639.374884] 
[ 2639.374884] cfs_rq[0]:/autogroup-146
[ 2639.374887]   .exec_clock                    : 34116.414703
[ 2639.374889]   .MIN_vruntime                  : 0.000001
[ 2639.374890]   .min_vruntime                  : 585890.631006
[ 2639.374892]   .max_vruntime                  : 0.000001
[ 2639.374893]   .spread                        : 0.000000
[ 2639.374894]   .spread0                       : 293622.514338
[ 2639.374896]   .nr_spread_over                : 252
[ 2639.374897]   .nr_running                    : 0
[ 2639.374898]   .load                          : 0
[ 2639.374900]   .runnable_load_avg             : 0
[ 2639.374901]   .blocked_load_avg              : 0
[ 2639.374902]   .tg_load_avg                   : 3
[ 2639.374903]   .tg_load_contrib               : 0
[ 2639.374905]   .tg_runnable_contrib           : 0
[ 2639.374906]   .tg->runnable_avg              : 4
[ 2639.374908]   .se->exec_start                : 2639341.779930
[ 2639.374909]   .se->vruntime                  : 292262.111571
[ 2639.374911]   .se->sum_exec_runtime          : 34117.917952
[ 2639.374912]   .se->statistics.wait_start     : 0.000000
[ 2639.374914]   .se->statistics.sleep_start    : 0.000000
[ 2639.374915]   .se->statistics.block_start    : 0.000000
[ 2639.374917]   .se->statistics.sleep_max      : 0.000000
[ 2639.374918]   .se->statistics.block_max      : 0.000000
[ 2639.374920]   .se->statistics.exec_max       : 490.624219
[ 2639.374921]   .se->statistics.slice_max      : 490.624219
[ 2639.374923]   .se->statistics.wait_max       : 451.293452
[ 2639.374924]   .se->statistics.wait_sum       : 7148.960837
[ 2639.374925]   .se->statistics.wait_count     : 71976
[ 2639.374927]   .se->load.weight               : 2
[ 2639.374928]   .se->avg.runnable_avg_sum      : 34
[ 2639.374929]   .se->avg.runnable_avg_period   : 46699
[ 2639.374931]   .se->avg.load_avg_contrib      : 0
[ 2639.374932]   .se->avg.decay_count           : 2517073
[ 2639.374934] 
[ 2639.374934] cfs_rq[0]:/autogroup-133
[ 2639.374936]   .exec_clock                    : 22366.359537
[ 2639.374938]   .MIN_vruntime                  : 0.000001
[ 2639.374939]   .min_vruntime                  : 22365.310961
[ 2639.374941]   .max_vruntime                  : 0.000001
[ 2639.374942]   .spread                        : 0.000000
[ 2639.374944]   .spread0                       : -269902.805707
[ 2639.374945]   .nr_spread_over                : 0
[ 2639.374946]   .nr_running                    : 0
[ 2639.374948]   .load                          : 0
[ 2639.374949]   .runnable_load_avg             : 0
[ 2639.374950]   .blocked_load_avg              : 8
[ 2639.374952]   .tg_load_avg                   : 8
[ 2639.374953]   .tg_load_contrib               : 8
[ 2639.374954]   .tg_runnable_contrib           : 9
[ 2639.374955]   .tg->runnable_avg              : 9
[ 2639.374957]   .se->exec_start                : 2639341.852056
[ 2639.374959]   .se->vruntime                  : 292268.116668
[ 2639.374960]   .se->sum_exec_runtime          : 22368.001405
[ 2639.374961]   .se->statistics.wait_start     : 0.000000
[ 2639.374963]   .se->statistics.sleep_start    : 0.000000
[ 2639.374964]   .se->statistics.block_start    : 0.000000
[ 2639.374966]   .se->statistics.sleep_max      : 0.000000
[ 2639.374967]   .se->statistics.block_max      : 0.000000
[ 2639.374969]   .se->statistics.exec_max       : 93.131673
[ 2639.374970]   .se->statistics.slice_max      : 11.031085
[ 2639.374972]   .se->statistics.wait_max       : 109.279558
[ 2639.374973]   .se->statistics.wait_sum       : 4394.571625
[ 2639.374974]   .se->statistics.wait_count     : 51681
[ 2639.374976]   .se->load.weight               : 2
[ 2639.374977]   .se->avg.runnable_avg_sum      : 419
[ 2639.374978]   .se->avg.runnable_avg_period   : 47171
[ 2639.374980]   .se->avg.load_avg_contrib      : 7
[ 2639.374981]   .se->avg.decay_count           : 2517073
[ 2639.374983] 
[ 2639.374983] cfs_rq[0]:/
[ 2639.374985]   .exec_clock                    : 125748.117098
[ 2639.374986]   .MIN_vruntime                  : 0.000001
[ 2639.374988]   .min_vruntime                  : 292268.116668
[ 2639.374989]   .max_vruntime                  : 0.000001
[ 2639.374991]   .spread                        : 0.000000
[ 2639.374992]   .spread0                       : 0.000000
[ 2639.374994]   .nr_spread_over                : 170
[ 2639.374995]   .nr_running                    : 0
[ 2639.374996]   .load                          : 0
[ 2639.374997]   .runnable_load_avg             : 0
[ 2639.374999]   .blocked_load_avg              : 0
[ 2639.375000]   .tg_load_avg                   : 3
[ 2639.375001]   .tg_load_contrib               : 0
[ 2639.375003]   .tg_runnable_contrib           : 9
[ 2639.375004]   .tg->runnable_avg              : 24
[ 2639.375006]   .avg->runnable_avg_sum         : 452
[ 2639.375007]   .avg->runnable_avg_period      : 47103
[ 2639.375015] 
[ 2639.375015] rt_rq[0]:/
[ 2639.375017]   .rt_nr_running                 : 0
[ 2639.375018]   .rt_throttled                  : 0
[ 2639.375020]   .rt_time                       : 0.000000
[ 2639.375021]   .rt_runtime                    : 950.000000
[ 2639.375023] 
[ 2639.375023] runnable tasks:
[ 2639.375023]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 2639.375023] ----------------------------------------------------------------------------------------------------------
[ 2639.375072] 
[ 2639.375072] cpu#1, 2652.796 MHz
[ 2639.375074]   .nr_running                    : 3
[ 2639.375075]   .load                          : 3072
[ 2639.375076]   .nr_switches                   : 403280
[ 2639.375078]   .nr_load_updates               : 88638
[ 2639.375079]   .nr_uninterruptible            : 5
[ 2639.375081]   .next_balance                  : 0.584785
[ 2639.375082]   .curr->pid                     : 2817
[ 2639.375084]   .clock                         : 2639342.275911
[ 2639.375085]   .cpu_load[0]                   : 0
[ 2639.375086]   .cpu_load[1]                   : 0
[ 2639.375087]   .cpu_load[2]                   : 0
[ 2639.375089]   .cpu_load[3]                   : 0
[ 2639.375090]   .cpu_load[4]                   : 0
[ 2639.375091]   .yld_count                     : 0
[ 2639.375093]   .sched_count                   : 403443
[ 2639.375094]   .sched_goidle                  : 95022
[ 2639.375095]   .avg_idle                      : 1000000
[ 2639.375097]   .ttwu_count                    : 230380
[ 2639.375098]   .ttwu_local                    : 212530
[ 2639.375100] 
[ 2639.375100] cfs_rq[1]:/autogroup-155
[ 2639.375102]   .exec_clock                    : 22740.333107
[ 2639.375103]   .MIN_vruntime                  : 0.000001
[ 2639.375105]   .min_vruntime                  : 27902.615373
[ 2639.375106]   .max_vruntime                  : 0.000001
[ 2639.375108]   .spread                        : 0.000000
[ 2639.375109]   .spread0                       : -264365.501295
[ 2639.375111]   .nr_spread_over                : 1930
[ 2639.375112]   .nr_running                    : 1
[ 2639.375113]   .load                          : 1024
[ 2639.375115]   .runnable_load_avg             : 0
[ 2639.375116]   .blocked_load_avg              : 0
[ 2639.375117]   .tg_load_avg                   : 0
[ 2639.375118]   .tg_load_contrib               : 0
[ 2639.375120]   .tg_runnable_contrib           : 0
[ 2639.375121]   .tg->runnable_avg              : 0
[ 2639.375123]   .se->exec_start                : 2639342.275911
[ 2639.375124]   .se->vruntime                  : 188900.650811
[ 2639.375126]   .se->sum_exec_runtime          : 22740.654672
[ 2639.375127]   .se->statistics.wait_start     : 0.000000
[ 2639.375129]   .se->statistics.sleep_start    : 0.000000
[ 2639.375130]   .se->statistics.block_start    : 0.000000
[ 2639.375131]   .se->statistics.sleep_max      : 0.000000
[ 2639.375133]   .se->statistics.block_max      : 0.000000
[ 2639.375134]   .se->statistics.exec_max       : 75.960967
[ 2639.375136]   .se->statistics.slice_max      : 62.362964
[ 2639.375137]   .se->statistics.wait_max       : 196.665662
[ 2639.375139]   .se->statistics.wait_sum       : 936.164293
[ 2639.375140]   .se->statistics.wait_count     : 11059
[ 2639.375141]   .se->load.weight               : 1024
[ 2639.375143]   .se->avg.runnable_avg_sum      : 0
[ 2639.375144]   .se->avg.runnable_avg_period   : 48091
[ 2639.375145]   .se->avg.load_avg_contrib      : 0
[ 2639.375147]   .se->avg.decay_count           : 0
[ 2639.375149] 
[ 2639.375149] cfs_rq[1]:/autogroup-158
[ 2639.375151]   .exec_clock                    : 3017.003805
[ 2639.375152]   .MIN_vruntime                  : 0.000001
[ 2639.375154]   .min_vruntime                  : 2888.998373
[ 2639.375155]   .max_vruntime                  : 0.000001
[ 2639.375157]   .spread                        : 0.000000
[ 2639.375158]   .spread0                       : -289379.118295
[ 2639.375160]   .nr_spread_over                : 63
[ 2639.375161]   .nr_running                    : 0
[ 2639.375162]   .load                          : 0
[ 2639.375164]   .runnable_load_avg             : 0
[ 2639.375165]   .blocked_load_avg              : 0
[ 2639.375166]   .tg_load_avg                   : 0
[ 2639.375167]   .tg_load_contrib               : 0
[ 2639.375169]   .tg_runnable_contrib           : 4
[ 2639.375170]   .tg->runnable_avg              : 4
[ 2639.375171]   .se->exec_start                : 2639317.326411
[ 2639.375173]   .se->vruntime                  : 188900.224700
[ 2639.375174]   .se->sum_exec_runtime          : 3017.344574
[ 2639.375176]   .se->statistics.wait_start     : 0.000000
[ 2639.375177]   .se->statistics.sleep_start    : 0.000000
[ 2639.375179]   .se->statistics.block_start    : 0.000000
[ 2639.375180]   .se->statistics.sleep_max      : 0.000000
[ 2639.375182]   .se->statistics.block_max      : 0.000000
[ 2639.375183]   .se->statistics.exec_max       : 30.893402
[ 2639.375185]   .se->statistics.slice_max      : 5.566855
[ 2639.375186]   .se->statistics.wait_max       : 256.613676
[ 2639.375187]   .se->statistics.wait_sum       : 699.265392
[ 2639.375189]   .se->statistics.wait_count     : 78979
[ 2639.375190]   .se->load.weight               : 2
[ 2639.375191]   .se->avg.runnable_avg_sum      : 215
[ 2639.375193]   .se->avg.runnable_avg_period   : 46105
[ 2639.375194]   .se->avg.load_avg_contrib      : 0
[ 2639.375195]   .se->avg.decay_count           : 2517050
[ 2639.375197] 
[ 2639.375197] cfs_rq[1]:/autogroup-146
[ 2639.375199]   .exec_clock                    : 26059.818672
[ 2639.375201]   .MIN_vruntime                  : 284987.250464
[ 2639.375202]   .min_vruntime                  : 284992.917778
[ 2639.375204]   .max_vruntime                  : 284987.250464
[ 2639.375205]   .spread                        : 0.000000
[ 2639.375207]   .spread0                       : -7275.198890
[ 2639.375208]   .nr_spread_over                : 222
[ 2639.375209]   .nr_running                    : 1
[ 2639.375211]   .load                          : 1024
[ 2639.375212]   .runnable_load_avg             : 0
[ 2639.375213]   .blocked_load_avg              : 3
[ 2639.375215]   .tg_load_avg                   : 3
[ 2639.375216]   .tg_load_contrib               : 3
[ 2639.375217]   .tg_runnable_contrib           : 4
[ 2639.375219]   .tg->runnable_avg              : 4
[ 2639.375220]   .se->exec_start                : 2639342.220040
[ 2639.375222]   .se->vruntime                  : 188906.609634
[ 2639.375223]   .se->sum_exec_runtime          : 26082.646772
[ 2639.375225]   .se->statistics.wait_start     : 2639342.220040
[ 2639.375226]   .se->statistics.sleep_start    : 0.000000
[ 2639.375228]   .se->statistics.block_start    : 0.000000
[ 2639.375229]   .se->statistics.sleep_max      : 0.000000
[ 2639.375230]   .se->statistics.block_max      : 0.000000
[ 2639.375232]   .se->statistics.exec_max       : 162.478909
[ 2639.375233]   .se->statistics.slice_max      : 23.454420
[ 2639.375235]   .se->statistics.wait_max       : 493.152849
[ 2639.375236]   .se->statistics.wait_sum       : 6000.435003
[ 2639.375238]   .se->statistics.wait_count     : 59962
[ 2639.375239]   .se->load.weight               : 1024
[ 2639.375240]   .se->avg.runnable_avg_sum      : 542
[ 2639.375242]   .se->avg.runnable_avg_period   : 47514
[ 2639.375243]   .se->avg.load_avg_contrib      : 3
[ 2639.375244]   .se->avg.decay_count           : 2517054
[ 2639.375246] 
[ 2639.375246] cfs_rq[1]:/
[ 2639.375247]   .exec_clock                    : 109217.037585
[ 2639.375249]   .MIN_vruntime                  : 188900.624328
[ 2639.375251]   .min_vruntime                  : 188906.609634
[ 2639.375252]   .max_vruntime                  : 188906.609634
[ 2639.375254]   .spread                        : 5.985306
[ 2639.375255]   .spread0                       : -103361.507034
[ 2639.375257]   .nr_spread_over                : 147
[ 2639.375258]   .nr_running                    : 3
[ 2639.375259]   .load                          : 3072
[ 2639.375260]   .runnable_load_avg             : 3
[ 2639.375262]   .blocked_load_avg              : 0
[ 2639.375263]   .tg_load_avg                   : 3
[ 2639.375264]   .tg_load_contrib               : 3
[ 2639.375266]   .tg_runnable_contrib           : 15
[ 2639.375267]   .tg->runnable_avg              : 24
[ 2639.375268]   .avg->runnable_avg_sum         : 740
[ 2639.375270]   .avg->runnable_avg_period      : 47613
[ 2639.375272] 
[ 2639.375272] rt_rq[1]:/
[ 2639.375273]   .rt_nr_running                 : 0
[ 2639.375275]   .rt_throttled                  : 0
[ 2639.375276]   .rt_time                       : 0.000000
[ 2639.375278]   .rt_runtime                    : 950.000000
[ 2639.375279] 
[ 2639.375279] runnable tasks:
[ 2639.375279]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 2639.375279] ----------------------------------------------------------------------------------------------------------
[ 2639.375283]      kworker/1:2    75    188900.624328      8575   120    188900.624328       438.666884   2635100.599393 /
[ 2639.375292]   xfce4-terminal  2736    284987.250464     13101   120    284987.250464      3364.964614   2595136.252768 /autogroup-146
[ 2639.375297] R           bash  2817     27900.226829       183   120     27900.226829        74.780842   2591370.038608 /autogroup-155
[ 2639.375303] 
