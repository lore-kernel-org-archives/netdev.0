From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next-2.6] fib: Some rcu warning
Date: Wed, 14 Apr 2010 21:54:04 +0200
Message-ID: <1271274844.16881.1743.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:35325 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab0DNTyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 15:54:18 -0400
Received: by bwz25 with SMTP id 25so658639bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 12:54:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[   27.756998] IPv4 FIB: Using LC-trie version 0.409
[   27.757121] 
[   27.757121] ===================================================
[   27.757228] [ INFO: suspicious rcu_dereference_check() usage. ]
[   27.757285] ---------------------------------------------------
[   27.757342] net/ipv4/fib_trie.c:212 invoked rcu_dereference_check()
without protection!
[   27.757417] 
[   27.757417] other info that might help us debug this:
[   27.757418] 
[   27.757569] 
[   27.757570] rcu_scheduler_active = 1, debug_locks = 0
[   27.757674] 2 locks held by ip/5686:
[   27.757727]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8134d247>]
rtnl_lock+0x17/0x20
[   27.757936]  #1:  ((inetaddr_chain).rwsem){.+.+.+}, at:
[<ffffffff810654a7>] __blocking_notifier_call_chain+0x47/0x90
[   27.758148] 
[   27.758149] stack backtrace:
[   27.758249] Pid: 5686, comm: ip Not tainted
2.6.34-rc3-03164-gb4bf665-dirty #10
[   27.758323] Call Trace:
[   27.758377]  [<ffffffff81071b4f>] lockdep_rcu_dereference+0xaf/0xc0
[   27.758437]  [<ffffffff813ae32c>] fib_find_node+0x19c/0x220
[   27.758495]  [<ffffffff813b0bdc>] fib_table_insert+0xac/0x760
[   27.758552]  [<ffffffff813aa121>] ? fib_get_table+0x91/0xd0
[   27.758609]  [<ffffffff813aa0b8>] ? fib_get_table+0x28/0xd0
[   27.758667]  [<ffffffff813aa561>] fib_magic+0x111/0x120
[   27.758723]  [<ffffffff813aa6a0>] fib_add_ifaddr+0x130/0x170
[   27.758780]  [<ffffffff813aad3c>] fib_inetaddr_event+0x5c/0x290
[   27.758838]  [<ffffffff810650d8>] notifier_call_chain+0x58/0x80
[   27.758896]  [<ffffffff810654bd>] __blocking_notifier_call_chain
+0x5d/0x90
[   27.758956]  [<ffffffff81065506>] blocking_notifier_call_chain
+0x16/0x20
[   27.759016]  [<ffffffff813a0c44>] __inet_insert_ifa+0xd4/0x170
[   27.759089]  [<ffffffff813a0cf2>] inet_insert_ifa+0x12/0x20
[   27.759146]  [<ffffffff813a2140>] inetdev_event+0x400/0x430
[   27.759204]  [<ffffffff81362472>] ? netlink_broadcast+0x262/0x3f0
[   27.759263]  [<ffffffff81351391>] ? fib_rules_event+0x21/0x180
[   27.759320]  [<ffffffff810650d8>] notifier_call_chain+0x58/0x80
[   27.759378]  [<ffffffff8106512e>] __raw_notifier_call_chain+0xe/0x10
[   27.759436]  [<ffffffff81065146>] raw_notifier_call_chain+0x16/0x20
[   27.761102]  [<ffffffff8133fc1b>] call_netdevice_notifiers+0x1b/0x20
[   27.761161]  [<ffffffff8133ffad>] __dev_notify_flags+0x7d/0x90
[   27.761219]  [<ffffffff81340005>] dev_change_flags+0x45/0x70
[   27.761278]  [<ffffffff813a2e79>] devinet_ioctl+0x5e9/0x770
[   27.761336]  [<ffffffff813a36b1>] inet_ioctl+0x61/0x80
[   27.761392]  [<ffffffff8132c532>] sock_do_ioctl+0x32/0x60
[   27.761449]  [<ffffffff8132d06c>] compat_sock_ioctl+0x89c/0xb60
[   27.761507]  [<ffffffff81075816>] ? __lock_acquire+0x486/0xaf0
[   27.761567]  [<ffffffff810cbfeb>] ? __do_fault+0x12b/0x480
[   27.761624]  [<ffffffff810b4a93>] ? filemap_fault+0xd3/0x3d0
[   27.761683]  [<ffffffff810f7104>] ? fget_light+0x174/0x360
[   27.761740]  [<ffffffff810cc1f9>] ? __do_fault+0x339/0x480
[   27.761798]  [<ffffffff811370e3>] compat_sys_ioctl+0xd3/0x1900
[   27.761856]  [<ffffffff810ce28a>] ? handle_mm_fault+0x19a/0x780
[   27.761915]  [<ffffffff81023832>] ? do_page_fault+0xe2/0x3b0
[   27.761972]  [<ffffffff81064703>] ? up_read+0x23/0x40
[   27.762028]  [<ffffffff810238f5>] ? do_page_fault+0x1a5/0x3b0
[   27.762087]  [<ffffffff813f36cb>] ? _raw_spin_unlock+0x2b/0x40
[   27.762145]  [<ffffffff810f3508>] ? fd_install+0xa8/0xe0
[   27.762202]  [<ffffffff8132eced>] ? sock_map_fd+0x2d/0x40
[   27.762259]  [<ffffffff813f3a69>] ? retint_swapgs+0xe/0x13
[   27.762331]  [<ffffffff8107292d>] ? trace_hardirqs_on_caller
+0x10d/0x190
[   27.762391]  [<ffffffff813f2d21>] ? trace_hardirqs_off_thunk
+0x3a/0x3c
[   27.762450]  [<ffffffff81028b64>] sysenter_dispatch+0x7/0x30
[   27.762507]  [<ffffffff813f2ce2>] ? trace_hardirqs_on_thunk+0x3a/0x3f


