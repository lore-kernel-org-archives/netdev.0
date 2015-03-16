From: Andrew Vagin <avagin@parallels.com>
Subject: RE: [PATCH net-next 0/6] tcp_metrics: Network namespace bloat
 reduction v3
Date: Mon, 16 Mar 2015 14:35:44 +0300
Message-ID: <20150316113542.GA27127@paralelels.com>
Reply-To: <87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:58924 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbbCPLfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 07:35:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

We use deref_locked_genl(), but &genl_mutex isn't hold on this path.

[   13.215863] ===============================
[   13.216562] [ INFO: suspicious RCU usage. ]
[   13.217433] 4.0.0-rc3-next-20150316 #186 Not tainted
[   13.218550] -------------------------------
[   13.219496] net/ipv4/tcp_metrics.c:1060 suspicious rcu_dereference_protected() usage!
[   13.221213] other info that might help us debug this:
[   13.223050] rcu_scheduler_active = 1, debug_locks = 0
[   13.224491] 4 locks held by kworker/u8:2/62:
[   13.225461]  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff8109d9be>] process_one_work+0x15e/0x520
[   13.227600]  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff8109d9be>] process_one_work+0x15e/0x520
[   13.229979]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff8162cddc>] cleanup_net+0x8c/0x240
[   13.231858]  #3:  (tcp_metrics_lock){+.....}, at: [<ffffffff816ac14c>] tcp_metrics_flush_all+0x4c/0x170
[   13.234059] stack backtrace:
[   13.234975] CPU: 2 PID: 62 Comm: kworker/u8:2 Not tainted 4.0.0-rc3-next-20150316 #186
[   13.236689] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.237972] Workqueue: netns cleanup_net
[   13.238943]  0000000000000000 0000000002af7693 ffff880036d73c58 ffffffff8176a03d
[   13.240746]  0000000000000000 ffff88011a4d8000 ffff880036d73c88 ffffffff810d2867
[   13.242434]  ffff88011aa28000 ffff88011aa28000 ffff8800db620000 ffff8800db640000
[   13.244104] Call Trace:
[   13.244613]  [<ffffffff8176a03d>] dump_stack+0x45/0x57
[   13.245693]  [<ffffffff810d2867>] lockdep_rcu_suspicious+0xe7/0x120
[   13.247021]  [<ffffffff816ac264>] tcp_metrics_flush_all+0x164/0x170
[   13.248346]  [<ffffffff816ac27e>] tcp_net_metrics_exit+0xe/0x10
[   13.249619]  [<ffffffff8162bc49>] ops_exit_list.isra.4+0x39/0x60
[   13.250842]  [<ffffffff8162ceb0>] cleanup_net+0x160/0x240
[   13.251960]  [<ffffffff8109da2c>] process_one_work+0x1cc/0x520
[   13.253142]  [<ffffffff8109d9be>] ? process_one_work+0x15e/0x520
[   13.254411]  [<ffffffff8109e0db>] worker_thread+0x4b/0x470
[   13.255591]  [<ffffffff8109e090>] ? rescuer_thread+0x310/0x310
[   13.256753]  [<ffffffff8109e090>] ? rescuer_thread+0x310/0x310
[   13.257922]  [<ffffffff810a3a43>] kthread+0xf3/0x110
[   13.258948]  [<ffffffff810a3950>] ? kthread_create_on_node+0x240/0x240
[   13.260240]  [<ffffffff81774023>] ret_from_fork+0x53/0xb0
[   13.261272]  [<ffffffff810a3950>] ? kthread_create_on_node+0x240/0x240
