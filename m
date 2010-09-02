From: Dave Jones <davej@redhat.com>
Subject: cgroups/netlink related rcu_dereference_check() without protection
 (2.6.35.4)
Date: Wed, 1 Sep 2010 21:43:37 -0400
Message-ID: <20100902014337.GC30324@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566Ab0IBBnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 21:43:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see this during boot on one of my boxes..

	Dave

INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/linux/cgroup.h:542 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
1 lock held by swapper/1:
 #0:  (net_mutex){+.+.+.}, at: [<c074b595>] register_pernet_subsys+0x17/0x34

stack backtrace:
Pid: 1, comm: swapper Not tainted 2.6.35.4-15.fc14.i686.PAE #1
Call Trace:
 [<c07e2197>] ? printk+0x25/0x2e
 [<c0467969>] lockdep_rcu_dereference+0x7d/0x86
 [<c07440ea>] sock_update_classid+0x6c/0x8e
 [<c074416b>] sk_alloc+0x5f/0x6a
 [<c07674a9>] __netlink_create+0x2a/0x90
 [<c0768d54>] netlink_kernel_create+0x5f/0x14f
 [<c075805c>] rtnetlink_net_init+0x23/0x3b
 [<c0759412>] ? rtnetlink_rcv+0x0/0x27
 [<c074b388>] ops_init+0xda/0xe9
 [<c074b4c8>] register_pernet_operations+0x84/0xee
 [<c074b5a1>] register_pernet_subsys+0x23/0x34
 [<c0ab7e94>] rtnetlink_init+0x42/0xe0
 [<c0ab84fa>] netlink_proto_init+0xee/0x103
 [<c0ab840c>] ? netlink_proto_init+0x0/0x103
 [<c0403182>] do_one_initcall+0x62/0x170
 [<c0a809d3>] kernel_init+0x1b9/0x23a
 [<c0a8081a>] ? kernel_init+0x0/0x23a
 [<c0408fc2>] kernel_thread_helper+0x6/0x10

