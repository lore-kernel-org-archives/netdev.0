From: Cong Wang <amwang@redhat.com>
Subject: A regression introduced by 802.1ad support patches
Date: Sun, 21 Apr 2013 15:43:04 +0800
Message-ID: <1366530184.23100.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194Ab3DUHnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 03:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Patrick,

Your recent 802.1ad patches causes the following bug. After resetting
HEAD to commit c296289 (Merge branch 'intel'), this bug is not
reproducible any more.

It is pretty easy to reproduce in my KVM guest, just boot the guest and
then shut it down, the following traces will be shown. Although it is
not 100% reproducible, it appears more than 80% times at least.

I am glad to provide any other information if you need, and of course
can test any fix if you want.

[   86.812073] kmemleak: Found object by alias at 0xffff88006ecc76f0
[   86.816019] Pid: 739, comm: kworker/u:1 Not tainted 3.9.0-rc5+ #842
[   86.816019] Call Trace:
[   86.816019]  <IRQ>  [<ffffffff81151c58>] find_and_get_object
+0x8c/0xdf
[   86.816019]  [<ffffffff8190e90d>] ? vlan_info_rcu_free+0x33/0x49
[   86.816019]  [<ffffffff81151cbe>] delete_object_full+0x13/0x2f
[   86.816019]  [<ffffffff8194bbb6>] kmemleak_free+0x26/0x45
[   86.816019]  [<ffffffff8113e8c7>] slab_free_hook+0x1e/0x7b
[   86.816019]  [<ffffffff81141c05>] kfree+0xce/0x14b
[   86.816019]  [<ffffffff8190e90d>] vlan_info_rcu_free+0x33/0x49
[   86.816019]  [<ffffffff810d0b0b>] rcu_do_batch+0x261/0x4e7
[   86.816019]  [<ffffffff810a308f>] ? mark_held_locks+0x6d/0x95
[   86.816019]  [<ffffffff8190e8da>] ? __vlan_vid_del+0xa6/0xa6
[   86.816019]  [<ffffffff810d0e99>] __rcu_process_callbacks+0x108/0x133
[   86.816019]  [<ffffffff810d0f09>] rcu_process_callbacks+0x45/0x72
[   86.816019]  [<ffffffff81058163>] __do_softirq+0x133/0x2a3
[   86.816019]  [<ffffffff8105840c>] irq_exit+0x5d/0xa4
[   86.816019]  [<ffffffff81983751>] smp_apic_timer_interrupt+0x7c/0x8a
[   86.816019]  [<ffffffff81982832>] apic_timer_interrupt+0x72/0x80
[   86.816019]  <EOI>  [<ffffffff8102f3e0>] ? __flush_tlb_all+0x15/0x22
[   86.816019]  [<ffffffff8145b427>] ? clear_page_c+0x7/0x10
[   86.816019]  [<ffffffff81105203>] ? prep_new_page+0x133/0x17f
[   86.816019]  [<ffffffff8110567e>] ? get_page_from_freelist
+0x42f/0x523
[   86.816019]  [<ffffffff811056a6>] get_page_from_freelist+0x457/0x523
[   86.816019]  [<ffffffff810a37b9>] ? lock_is_held+0x56/0x60
[   86.816019]  [<ffffffff811058d6>] __alloc_pages_nodemask+0x164/0x700
[   86.816019]  [<ffffffff81029e91>] ? kvm_clock_read+0x34/0x3b
[   86.816019]  [<ffffffff810852e9>] ? local_clock+0x14/0x4f
[   86.816019]  [<ffffffff81029e91>] ? kvm_clock_read+0x34/0x3b
[   86.816019]  [<ffffffff810852e9>] ? local_clock+0x14/0x4f
[   86.816019]  [<ffffffff810e595b>] ? time_hardirqs_off+0x15/0x2a
[   86.816019]  [<ffffffff8108530b>] ? local_clock+0x36/0x4f
[   86.816019]  [<ffffffff8108530b>] ? local_clock+0x36/0x4f
[   86.816019]  [<ffffffff81139f94>] alloc_pages_current+0xfa/0x11b
[   86.816019]  [<ffffffff811029b6>] __get_free_pages+0x16/0x44
[   86.816019]  [<ffffffff811029fa>] get_zeroed_page+0x16/0x18
[   86.816019]  [<ffffffff81121bd8>] __pud_alloc+0x20/0xa4
[   86.816019]  [<ffffffff81121c74>] pud_alloc+0x18/0x30
[   86.816019]  [<ffffffff81121df2>] handle_mm_fault+0x92/0x264
[   86.816019]  [<ffffffff81122375>] __get_user_pages+0x31d/0x4bb
[   86.816019]  [<ffffffff81154759>] ? do_sync_read+0x6d/0xaa
[   86.816019]  [<ffffffff811225ba>] get_user_pages+0x52/0x54
[   86.816019]  [<ffffffff81159614>] get_arg_page+0x5a/0xc4
[   86.816019]  [<ffffffff81084631>] ? __might_sleep+0xbe/0x19b
[   86.816019]  [<ffffffff811597b1>] copy_strings+0x133/0x210
[   86.816019]  [<ffffffff8115a443>] copy_strings_kernel+0x53/0x61
[   86.816019]  [<ffffffff8115b145>] do_execve_common+0x1c1/0x338
[   86.816019]  [<ffffffff8115b2fc>] do_execve+0x40/0x42
[   86.816019]  [<ffffffff8106844d>] ____call_usermodehelper+0x100/0x11a
[   86.816019]  [<ffffffff81068467>] ? ____call_usermodehelper
+0x11a/0x11a
[   86.816019]  [<ffffffff81068485>] call_helper+0x1e/0x20
[   86.816019]  [<ffffffff81981aec>] ret_from_fork+0x7c/0xb0
[   86.816019]  [<ffffffff81068467>] ? ____call_usermodehelper
+0x11a/0x11a
[   86.816019] kmemleak: Object 0xffff88006ecc76d0 (size 256):
[   86.816019] kmemleak:   comm "NetworkManager", pid 342, jiffies
4294896763
[   86.816019] kmemleak:   min_count = 1
[   86.816019] kmemleak:   count = 1
[   86.816019] kmemleak:   flags = 0x1
[   86.816019] kmemleak:   checksum = 0
[   86.816019] kmemleak:   backtrace:
[   86.816019]      [<ffffffff8194bae0>] kmemleak_alloc+0x26/0x43
[   86.816019]      [<ffffffff8113e771>] slab_post_alloc_hook+0x28/0x2a
[   86.816019]      [<ffffffff8114183d>] __kmalloc+0x114/0x145
[   86.816019]      [<ffffffff8190e9ea>] kzalloc.constprop.4+0xe/0x10
[   86.816019]      [<ffffffff8190f008>] vlan_vid_add+0x98/0x146
[   86.816019]      [<ffffffff8190f8d1>] vlan_device_event+0xbb/0x3c4
[   86.816019]      [<ffffffff8107896f>] notifier_call_chain+0x96/0xcd
[   86.816019]      [<ffffffff81078d35>] raw_notifier_call_chain
+0x14/0x16
[   86.816019]      [<ffffffff8176e68e>] call_netdevice_notifiers
+0x4a/0x4f
[   86.816019]      [<ffffffff81771aed>] __dev_notify_flags+0x37/0x5b
[   86.816019]      [<ffffffff81771b59>] dev_change_flags+0x48/0x53
[   86.816019]      [<ffffffff8177e743>] do_setlink+0x29e/0x5d6
[   86.816019]      [<ffffffff8177f0d1>] rtnl_newlink+0x257/0x436
[   86.816019]      [<ffffffff8177d80f>] rtnetlink_rcv_msg+0x19c/0x1ab
[   86.816019]      [<ffffffff817c5a1f>] netlink_rcv_skb+0x42/0x8d
[   86.816019]      [<ffffffff8177d655>] rtnetlink_rcv+0x26/0x2d
<..........More traces are snipped here...........>


Thanks!
