From: Sasha Levin <levinsasha928@gmail.com>
Subject: ieee802154:  WARNING: at mm/page_alloc.c:2095
Date: Tue, 22 Nov 2011 09:53:30 +0200
Message-ID: <1321948410.3787.3.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
To: dbaryshkov@gmail.com, slapin@ossfans.org,
	davem <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I got the following warning when trying out ieee802154:

[  157.736372] WARNING: at mm/page_alloc.c:2095 __alloc_pages_nodemask+0x177/0x722()
[  157.737707] Pid: 9100, comm: trinity Not tainted 3.2.0-rc2-sasha-00280-g45a222d #22
[  157.739114] Call Trace:
[  157.739559]  [<ffffffff810fcd7f>] ? __alloc_pages_nodemask+0x177/0x722
[  157.740746]  [<ffffffff81086984>] warn_slowpath_common+0x7b/0x93
[  157.741824]  [<ffffffff81086a47>] warn_slowpath_null+0x15/0x17
[  157.743283]  [<ffffffff810fcd7f>] __alloc_pages_nodemask+0x177/0x722
[  157.744434]  [<ffffffff8112f8a3>] ? __slab_alloc.clone.46+0x42d/0x456
[  157.745598]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
[  157.747204]  [<ffffffff8112f8ab>] ? __slab_alloc.clone.46+0x435/0x456
[  157.748375]  [<ffffffff810a4875>] ? sched_clock_local+0x12/0x75
[  157.749475]  [<ffffffff81b96dd6>] ? __alloc_skb+0x42/0x14a
[  157.750682]  [<ffffffff810b2c3a>] ? lock_is_held+0x92/0x9d
[  157.751693]  [<ffffffff8112d399>] kmalloc_large_node+0x51/0x83
[  157.752757]  [<ffffffff81131ada>] __kmalloc_node_track_caller+0x29/0x127
[  157.753955]  [<ffffffff81b9449e>] ? sock_alloc_send_pskb+0xbd/0x2d7
[  157.755084]  [<ffffffff81b96e0a>] __alloc_skb+0x76/0x14a
[  157.756055]  [<ffffffff81b9449e>] sock_alloc_send_pskb+0xbd/0x2d7
[  157.757155]  [<ffffffff81b9e6ed>] ? rcu_read_unlock+0x21/0x23
[  157.758206]  [<ffffffff81b946c8>] sock_alloc_send_skb+0x10/0x12
[  157.759292]  [<ffffffff81e18f4c>] dgram_sendmsg+0xa8/0x22c
[  157.760292]  [<ffffffff81e182af>] ieee802154_sock_sendmsg+0xf/0x11
[  157.761376]  [<ffffffff81b8fc6f>] __sock_sendmsg+0x65/0x72
[  157.762388]  [<ffffffff81b908bb>] sock_sendmsg+0xa3/0xbc
[  157.763351]  [<ffffffff810a4875>] ? sched_clock_local+0x12/0x75
[  157.764420]  [<ffffffff8107ecfc>] ? get_parent_ip+0x11/0x41
[  157.765428]  [<ffffffff8107ecfc>] ? get_parent_ip+0x11/0x41
[  157.766439]  [<ffffffff810b2c3a>] ? lock_is_held+0x92/0x9d
[  157.767440]  [<ffffffff81141631>] ? fget_light+0x35/0x9e
[  157.768409]  [<ffffffff810a355f>] ? up_read+0x1e/0x35
[  157.769336]  [<ffffffff81b90479>] ? sockfd_lookup_light+0x1b/0x53
[  157.770434]  [<ffffffff81b91b1d>] sys_sendto+0x12d/0x16f
[  157.771396]  [<ffffffff810b1e8f>] ? trace_hardirqs_off_caller+0xa3/0x10b
[  157.772594]  [<ffffffff81e6fd1d>] ? retint_swapgs+0x13/0x1b
[  157.773599]  [<ffffffff810b1d97>] ? trace_hardirqs_on_caller+0x151/0x197
[  157.774826]  [<ffffffff8161620e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  157.775989]  [<ffffffff81e705d2>] system_call_fastpath+0x16/0x1b

Please let me know if theres anything I can help with debugging it.

-- 

Sasha.
