From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: packet_sendmsg_spkt sleeping from invalid context
Date: Mon, 14 Dec 2009 18:52:13 +0100
Message-ID: <20091214175211.GA5102@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932333AbZLNRwW@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I don't know if it has been reported already.
I get the following warning on boot, with latest upstream tree:

[   32.776502] sched: BUG: sleeping function called from invalid context at mm/slab.c:3032
[   32.802173] sched: in_atomic(): 1, irqs_disabled(): 0, pid: 3555, name: dhclient3
[   32.821141] 1 lock held by dhclient3/3555:
[   32.821147]  #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff815d177d>] packet_sendmsg_spkt+0x7d/0x2c0
[   32.821174] Pid: 3555, comm: dhclient3 Tainted: G        W  2.6.32-tip+ #134
[   32.821181] Call Trace:
[   32.821194]  [<ffffffff810811c3>] ? __debug_show_held_locks+0x13/0x30
[   32.821207]  [<ffffffff8103d6b8>] __might_sleep+0x118/0x140
[   32.821219]  [<ffffffff81110c23>] kmem_cache_alloc+0x173/0x190
[   32.821231]  [<ffffffff815483d9>] __alloc_skb+0x49/0x170
[   32.821241]  [<ffffffff81542238>] sock_wmalloc+0x38/0x80
[   32.821250]  [<ffffffff815d182b>] packet_sendmsg_spkt+0x12b/0x2c0
[   32.821260]  [<ffffffff815d177d>] ? packet_sendmsg_spkt+0x7d/0x2c0
[   32.821272]  [<ffffffff8153ded7>] sock_sendmsg+0x127/0x140
[   32.821285]  [<ffffffff8106f4a0>] ? autoremove_wake_function+0x0/0x40
[   32.821297]  [<ffffffff810f467b>] ? might_fault+0x7b/0xd0
[   32.821306]  [<ffffffff810f467b>] ? might_fault+0x7b/0xd0
[   32.821318]  [<ffffffff815401aa>] ? move_addr_to_kernel+0x6a/0x70
[   32.821328]  [<ffffffff8154029f>] sys_sendto+0xef/0x120
[   32.821340]  [<ffffffff81131479>] ? mntput_no_expire+0x29/0x110
[   32.821355]  [<ffffffff810027db>] system_call_fastpath+0x16/0x1b
