From: poma <pomidorabelisima@gmail.com>
Subject: 3.15 & Bonding
Date: Wed, 02 Apr 2014 12:14:16 +0200
Message-ID: <533BE2F8.5040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tom Gundersen <teg@jklm.no>, Dan Williams <dcbw@redhat.com>,
	netdev@vger.kernel.org, linux-media <linux-media@vger.kernel.org>,
	Mailing-List fedora-kernel <kernel@lists.fedoraproject.org>
To: Thomas Davis <tadavis@lbl.gov>
Return-path: <linux-media-owner@vger.kernel.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Are you all all right?
New Tour de Bugs...

/sys/devices/virtual/net/bond0/bonding/mode:
active-backup 1

- systemd-networkd
dmesg:
BUG: sleeping function called from invalid context at mm/slub.c:965
in_atomic(): 1, irqs_disabled(): 0, pid: 593, name: systemd-network
2 locks held by systemd-network/593:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8169e57b>] rtnetlink_rcv+0x1b/0x40
 #1:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa0487291>]
bond_enslave+0xf31/0xf50 [bonding]
CPU: 2 PID: 593 Comm: systemd-network Not tainted
3.15.0-0.rc0.git2.1.fc21.x86_64 #1
Call Trace:
dump_stack+0x4d/0x66
__might_sleep+0x17e/0x230
kmem_cache_alloc_node+0x4a/0x390
 [<ffffffff816779dd>] __alloc_skb+0x5d/0x2d0
 [<ffffffff816a0bd8>] rtmsg_ifinfo+0x48/0x110
 [<ffffffff810fa18d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8109dd45>] ? __local_bh_enable_ip+0x75/0xe0
 [<ffffffffa0485ca7>] bond_change_active_slave+0x197/0x670 [bonding]
 [<ffffffffa0486264>] bond_select_active_slave+0xe4/0x1e0 [bonding]
 [<ffffffffa048729a>] bond_enslave+0xf3a/0xf50 [bonding]
 [<ffffffff8169fdf2>] do_setlink+0xa02/0xa70
 [<ffffffff813f4fc6>] ? nla_parse+0x96/0xe0
 [<ffffffff816a0da1>] rtnl_setlink+0xc1/0x130
 [<ffffffff810a1739>] ? ns_capable+0x39/0x70
 [<ffffffff8169e64b>] rtnetlink_rcv_msg+0xab/0x270
 [<ffffffff8169e57b>] ? rtnetlink_rcv+0x1b/0x40
 [<ffffffff8169e57b>] ? rtnetlink_rcv+0x1b/0x40
 [<ffffffff8169e5a0>] ? rtnetlink_rcv+0x40/0x40
 [<ffffffff816c3e29>] netlink_rcv_skb+0xa9/0xc0
 [<ffffffff8169e58a>] rtnetlink_rcv+0x2a/0x40
 [<ffffffff816c3420>] netlink_unicast+0x100/0x1e0
 [<ffffffff816c3847>] netlink_sendmsg+0x347/0x770
 [<ffffffff8166c78c>] sock_sendmsg+0x9c/0xe0
 [<ffffffff811de22f>] ? might_fault+0x5f/0xb0
 [<ffffffff811de278>] ? might_fault+0xa8/0xb0
 [<ffffffff811de22f>] ? might_fault+0x5f/0xb0
 [<ffffffff8166cd04>] SYSC_sendto+0x124/0x1d0
 [<ffffffff81024879>] ? sched_clock+0x9/0x10
 [<ffffffff810ddb75>] ? local_clock+0x25/0x30
 [<ffffffff8111cfc9>] ? current_kernel_time+0x69/0xd0
 [<ffffffff810fa0b5>] ? trace_hardirqs_on_caller+0x105/0x1d0
 [<ffffffff810fa18d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8166dede>] SyS_sendto+0xe/0x10
 [<ffffffff817e79a9>] system_call_fastpath+0x16/0x1b

- NetworkManager
dmesg:
BUG: sleeping function called from invalid context at mm/slub.c:965
in_atomic(): 1, irqs_disabled(): 0, pid: 73, name: kworker/u16:5
4 locks held by kworker/u16:5/73:
 #0:  ("%s"(bond_dev->name)){.+.+.+}, at: [<ffffffff810bbd14>]
process_one_work+0x1b4/0x6f0
 #1:  ((&(&bond->mii_work)->work)){+.+.+.}, at: [<ffffffff810bbd14>]
process_one_work+0x1b4/0x6f0
 #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8169d9c5>] rtnl_trylock+0x15/0x20
 #3:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa040d2bd>]
bond_mii_monitor+0x51d/0x7f0 [bonding]
CPU: 0 PID: 73 Comm: kworker/u16:5 Not tainted
3.15.0-0.rc0.git2.1.fc21.x86_64 #1
Workqueue: bond0 bond_mii_monitor [bonding]
Call Trace:
 [<ffffffff817d3c00>] dump_stack+0x4d/0x66
 [<ffffffff810d044e>] __might_sleep+0x17e/0x230
 [<ffffffff8121034a>] kmem_cache_alloc_node+0x4a/0x390
 [<ffffffff816779dd>] __alloc_skb+0x5d/0x2d0
 [<ffffffff816a0bd8>] rtmsg_ifinfo+0x48/0x110
 [<ffffffff810fa18d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8109dd45>] ? __local_bh_enable_ip+0x75/0xe0
 [<ffffffffa0409ca7>] bond_change_active_slave+0x197/0x670 [bonding]
 [<ffffffffa040a264>] bond_select_active_slave+0xe4/0x1e0 [bonding]
 [<ffffffffa040d2c6>] bond_mii_monitor+0x526/0x7f0 [bonding]
 [<ffffffffa040cdf6>] ? bond_mii_monitor+0x56/0x7f0 [bonding]
 [<ffffffff810bbd80>] process_one_work+0x220/0x6f0
 [<ffffffff810bbd14>] ? process_one_work+0x1b4/0x6f0
 [<ffffffff810bc36b>] worker_thread+0x11b/0x3a0
 [<ffffffff810bc250>] ? process_one_work+0x6f0/0x6f0
 [<ffffffff810c473f>] kthread+0xff/0x120
 [<ffffffff810c4640>] ? insert_kthread_work+0x80/0x80
 [<ffffffff817e78fc>] ret_from_fork+0x7c/0xb0
 [<ffffffff810c4640>] ? insert_kthread_work+0x80/0x80


- Ethernet Channel Bonding Driver, v3.7.1 woes
https://bugzilla.redhat.com/show_bug.cgi?id=1083455

- 3.15.0-0.rc0.git2.1.fc21.x86_64 Bonding
https://bugzilla.redhat.com/attachment.cgi?id=881690


poma
