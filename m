From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: init ingress queue
Date: Sat,  4 Dec 2010 13:45:58 +0800
Message-ID: <1291441558-3196-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45925 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab0LDFwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 00:52:10 -0500
Received: by gyb11 with SMTP id 11so5179153gyb.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 21:52:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev field of ingress queue is forgot to initialized, then NULL
pointer dereference happens in qdisc_alloc().

[  303.019348] BUG: unable to handle kernel NULL pointer dereference at 0000000000000398
[  303.020068] IP: [<ffffffff81472aab>] qdisc_alloc+0x9b/0xc0
[  303.020068] PGD 3d637067 PUD 3d03f067 PMD 0 
[  303.020068] Oops: 0000 [#1] SMP 
[  303.020068] last sysfs file: /sys/kernel/uevent_seqnum
[  303.020068] CPU 0 
[  303.020068] Modules linked in: sch_ingress ipv6
[  303.020068] 
[  303.020068] Pid: 3138, comm: tc Not tainted 2.6.37-rc1+ #90 /VirtualBox
[  303.020068] RIP: 0010:[<ffffffff81472aab>]  [<ffffffff81472aab>] qdisc_alloc+0x9b/0xc0
[  303.020068] RSP: 0018:ffff88003daf1938  EFLAGS: 00010246
[  303.020068] RAX: ffff88003db01400 RBX: ffffffffa00612a0 RCX: 0000000000000000
[  303.020068] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88003db01600
[  303.020068] RBP: ffff88003daf1948 R08: 0000000000000000 R09: ffff88003db01400
[  303.020068] R10: ffff88003fbe9fe8 R11: dead000000200200 R12: ffff88003d37c600
[  303.020068] R13: 00000000fffffff1 R14: ffffffffa00612a0 R15: 00000000fffffff1
[  303.020068] FS:  00007f1b3575a700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[  303.020068] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  303.020068] CR2: 0000000000000398 CR3: 000000003d2a9000 CR4: 00000000000006f0
[  303.020068] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  303.020068] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  303.020068] Process tc (pid: 3138, threadinfo ffff88003daf0000, task ffff88003d407500)
[  303.020068] Stack:
[  303.020068]  ffff88003e231000 ffff88003d6e1024 ffff88003daf19b8 ffffffff81474d68
[  303.020068]  0000000000000001 0000000000000000 ffff88003d37c600 ffff88003daf1a08
[  303.020068]  0073736572676e69 0000000000000000 ffff88003daf19b8 ffff88003d6e1010
[  303.020068] Call Trace:
[  303.020068]  [<ffffffff81474d68>] qdisc_create+0x78/0x350
[  303.020068]  [<ffffffff81476849>] tc_modify_qdisc+0x339/0x590
[  303.020068]  [<ffffffff8146622f>] rtnetlink_rcv_msg+0x16f/0x280
[  303.020068]  [<ffffffff814660c0>] ? rtnetlink_rcv_msg+0x0/0x280
[  303.020068]  [<ffffffff8147d6d9>] netlink_rcv_skb+0xa9/0xd0
[  303.020068]  [<ffffffff814660b0>] rtnetlink_rcv+0x20/0x30
[  303.020068]  [<ffffffff8147ce85>] netlink_unicast+0x2c5/0x2e0
[  303.020068]  [<ffffffff8147e195>] netlink_sendmsg+0x245/0x360
[  303.020068]  [<ffffffff81444874>] sock_sendmsg+0xe4/0x110
[  303.020068]  [<ffffffff810c5e19>] ? find_get_page+0x19/0x90
[  303.020068]  [<ffffffff810c716a>] ? filemap_fault+0xca/0x4b0
[  303.020068]  [<ffffffff810c6cd5>] ? unlock_page+0x25/0x30
[  303.020068]  [<ffffffff81444b6d>] ? move_addr_to_kernel+0x5d/0x60
[  303.020068]  [<ffffffff814500bd>] ? verify_iovec+0x7d/0xf0
[  303.020068]  [<ffffffff814465b5>] sys_sendmsg+0x1e5/0x330
[  303.020068]  [<ffffffff8147b5c8>] ? netlink_table_ungrab+0x28/0x30
[  303.020068]  [<ffffffff81516fac>] ? do_page_fault+0x1dc/0x4c0
[  303.020068]  [<ffffffff81444abb>] ? move_addr_to_user+0x9b/0xb0
[  303.020068]  [<ffffffff8112463b>] ? alloc_fd+0x4b/0x140
[  303.020068]  [<ffffffff81446394>] ? sys_recvmsg+0x44/0x80
[  303.020068]  [<ffffffff81002eab>] system_call_fastpath+0x16/0x1b
[  303.020068] Code: 8d 90 88 00 00 00 48 89 90 88 00 00 00 48 89 90 90 00 00 00 48 8b 53 28 48 89 10 48 8b 53 30 4c 89 60 68 48 89 50 08 49 8b 14 24 <48> 8b 92 98 03 00 00 65 ff 02 c7 40 40 01 00 00 00 5b 41 5c c9 
[  303.020068] RIP  [<ffffffff81472aab>] qdisc_alloc+0x9b/0xc0
[  303.020068]  RSP <ffff88003daf1938>
[  303.020068] CR2: 0000000000000398
[  303.135737] ---[ end trace 5b6e09a3328c82e4 ]---

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index cd24374..8083c68 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5577,6 +5577,8 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 	queue = kzalloc(sizeof(*queue), GFP_KERNEL);
 	if (!queue)
 		return NULL;
+	netdev_queue_numa_node_write(queue, -1);
+	queue->dev = dev;
 	netdev_init_one_queue(dev, queue, NULL);
 	queue->qdisc = &noop_qdisc;
 	queue->qdisc_sleeping = &noop_qdisc;
