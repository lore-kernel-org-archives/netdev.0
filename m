From: David Vrabel <david.vrabel@csr.com>
Subject: Inconsistent lock state in ipt_do_table
Date: Tue, 17 Aug 2010 18:45:25 +0100
Message-ID: <4C6ACAB5.2090507@csr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cluster-g.mailcontrol.com ([208.87.233.190]:57792 "EHLO
	cluster-g.mailcontrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936176Ab0HQSpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 14:45:14 -0400
Received: from rly12g.srv.mailcontrol.com (localhost.localdomain [127.0.0.1])
	by rly12g.srv.mailcontrol.com (MailControl) with ESMTP id o7HHrUii010189
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 18:53:31 +0100
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by rly12g.srv.mailcontrol.com (MailControl) id o7HHqYTi030061
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 18:52:34 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this related to or fixed by

http://marc.info/?l=linux-netdev&m=128202731626693&w=2

[   15.676004] [ INFO: inconsistent lock state ]
[   15.676004] 2.6.36-rc1+ #4
[   15.676004] ---------------------------------
[   15.689917] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   15.696562] ypwhich/1939 [HC0[0]:SC1[2]:HE1:SE0] takes:
[   15.701742]  (&(&lock->lock)->rlock){+.?...}, at: [<f805578d>]
ipt_do_table+0
xad/0x570 [ip_tables]
[   15.701742] {SOFTIRQ-ON-W} state was registered at:
[   15.701742]   [<c016b1fb>] __lock_acquire+0x6cb/0xac0
[   15.701742]   [<c016b676>] lock_acquire+0x86/0x100
[   15.701742]   [<c03f6908>] _raw_spin_lock+0x38/0x50
[   15.701742]   [<f8054285>] get_counters+0xa5/0x110 [ip_tables]
[   15.701742]   [<f8055588>] do_ipt_get_ctl+0x2d8/0x430 [ip_tables]
[   15.701742]   [<c03820d5>] nf_sockopt+0x105/0x160
[   15.701742]   [<c0382159>] nf_getsockopt+0x29/0x30
[   15.701742]   [<c038e81a>] ip_getsockopt+0x15a/0x700
[   15.701742]   [<c03ab592>] raw_getsockopt+0x32/0xc0
[   15.701742]   [<c0351117>] sock_common_getsockopt+0x27/0x40
[   15.701742]   [<c034edb5>] sys_getsockopt+0x75/0xb0
[   15.701742]   [<c035080c>] sys_socketcall+0x13c/0x2d0
[   15.701742]   [<c0102bdc>] sysenter_do_call+0x12/0x38
[   15.701742] irq event stamp: 1802
[   15.701742] hardirqs last  enabled at (1802): [<c03f74ae>]
restore_all_notrac
e+0x0/0x18
[   15.701742] hardirqs last disabled at (1801): [<c03f7638>]
reschedule_interru
pt+0x28/0x40
[   15.701742] softirqs last  enabled at (1794): [<c0362e4b>]
dev_queue_xmit+0x2
0b/0x5c0
[   15.701742] softirqs last disabled at (1795): [<c013ea27>]
do_softirq+0x67/0x
70
[   15.701742]
[   15.701742] other info that might help us debug this:
[   15.701742] 3 locks held by ypwhich/1939:
[   15.701742]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<c03af340>]
udp_sendmsg+0x2
60/0x720
[   15.701742]  #1:  (rcu_read_lock){.+.+..}, at: [<c035d624>]
__netif_receive_s
kb+0x94/0x560
[   15.701742]  #2:  (rcu_read_lock){.+.+..}, at: [<c0381010>]
nf_hook_slow+0x0/
0x110
[   15.701742]
[   15.701742] stack backtrace:
[   15.701742] Pid: 1939, comm: ypwhich Not tainted 2.6.36-rc1+ #4
[   15.701742] Call Trace:
[   15.701742]  [<c0167c46>] print_usage_bug+0x166/0x1b0
[   15.701742]  [<c0168206>] mark_lock+0x576/0x5b0
[   15.701742]  [<c01694e0>] ? check_usage_forwards+0x0/0xd0
[   15.701742]  [<c016b1b8>] __lock_acquire+0x688/0xac0
[   15.701742]  [<c016b676>] lock_acquire+0x86/0x100
[   15.701742]  [<f805578d>] ? ipt_do_table+0xad/0x570 [ip_tables]
[   15.701742]  [<c03f6908>] _raw_spin_lock+0x38/0x50
[   15.701742]  [<f805578d>] ? ipt_do_table+0xad/0x570 [ip_tables]
[   15.701742]  [<f805578d>] ipt_do_table+0xad/0x570 [ip_tables]
[   15.701742]  [<c016ae28>] ? __lock_acquire+0x2f8/0xac0
[   15.701742]  [<f8557032>] iptable_filter_hook+0x32/0x70 [iptable_filter]
[   15.701742]  [<f8557000>] ? iptable_filter_hook+0x0/0x70 [iptable_filter]
[   15.701742]  [<c0380d23>] nf_iterate+0x53/0x80
[   15.701742]  [<c0388820>] ? ip_local_deliver_finish+0x0/0x2f0
[   15.701742]  [<c03810d8>] nf_hook_slow+0xc8/0x110
[   15.701742]  [<c0388820>] ? ip_local_deliver_finish+0x0/0x2f0
[   15.701742]  [<c038828c>] ip_local_deliver+0x6c/0xa0
[   15.701742]  [<c0388820>] ? ip_local_deliver_finish+0x0/0x2f0
[   15.701742]  [<c0388422>] ip_rcv_finish+0x162/0x560
[   15.701742]  [<c0388166>] ip_rcv+0x266/0x320
[   15.701742]  [<c0168295>] ? mark_held_locks+0x55/0x70
[   15.701742]  [<c0387f00>] ? ip_rcv+0x0/0x320
[   15.701742]  [<c035d849>] __netif_receive_skb+0x2b9/0x560
[   15.701742]  [<c035d624>] ? __netif_receive_skb+0x94/0x560
[   15.701742]  [<c016007b>] ? do_adjtimex+0x69b/0x790
[   15.701742]  [<c0362000>] process_backlog+0xb0/0x190
[   15.701742]  [<c0361d16>] net_rx_action+0xf6/0x1d0
[   15.701742]  [<c013e887>] __do_softirq+0xa7/0x1e0
[   15.701742]  [<c0336fd8>] ? loopback_xmit+0x58/0x90
[   15.701742]  [<c013ea27>] do_softirq+0x67/0x70
[   15.701742]  [<c0362e4b>] ? dev_queue_xmit+0x20b/0x5c0
[   15.701742]  [<c013f7fe>] local_bh_enable+0x9e/0xc0
[   15.701742]  [<c0362e4b>] dev_queue_xmit+0x20b/0x5c0
[   15.701742]  [<c0362c40>] ? dev_queue_xmit+0x0/0x5c0
[   15.701742]  [<c036ab6f>] ? neigh_resolve_output+0x1df/0x370
[   15.701742]  [<c036aa92>] neigh_resolve_output+0x102/0x370
[   15.701742]  [<c038e45c>] ip_finish_output+0x1fc/0x460
[   15.701742]  [<c038b2f0>] ? dst_output+0x0/0x60
[   15.701742]  [<c038d03f>] ip_output+0x8f/0x120
[   15.701742]  [<c038b2f0>] ? dst_output+0x0/0x60
[   15.701742]  [<c038c866>] ip_local_out+0x26/0x70
[   15.701742]  [<c038cb06>] ip_push_pending_frames+0x256/0x3a0
[   15.701742]  [<c03ad546>] udp_push_pending_frames+0x156/0x3e0
[   15.701742]  [<c03af40e>] udp_sendmsg+0x32e/0x720
[   15.701742]  [<c03af0e0>] ? udp_sendmsg+0x0/0x720
[   15.701742]  [<c03b66f6>] inet_sendmsg+0x96/0xe0
[   15.701742]  [<c03b6660>] ? inet_sendmsg+0x0/0xe0
[   15.701742]  [<c034ea2f>] sock_sendmsg+0xef/0x110
[   15.701742]  [<c01d90c0>] ? might_fault+0x50/0xa0
[   15.701742]  [<c02a8681>] ? _copy_from_user+0x41/0x70
[   15.701742]  [<c0350527>] sys_sendto+0xa7/0xd0
[   15.701742]  [<c016b773>] ? lock_release_non_nested+0x83/0x2b0
[   15.701742]  [<c01d90c0>] ? might_fault+0x50/0xa0
[   15.701742]  [<c01d90c0>] ? might_fault+0x50/0xa0
[   15.701742]  [<c03508a5>] sys_socketcall+0x1d5/0x2d0
[   15.701742]  [<c0102bdc>] sysenter_do_call+0x12/0x38

-- 
David Vrabel, Senior Software Engineer, Drivers
CSR, Churchill House, Cambridge Business Park,  Tel: +44 (0)1223 692562
Cowley Road, Cambridge, CB4 0WZ                 http://www.csr.com/


Member of the CSR plc group of companies. CSR plc registered in England and Wales, registered number 4187346, registered office Churchill House, Cambridge Business Park, Cowley Road, Cambridge, CB4 0WZ, United Kingdom
