From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/2] tipc: fix potential deadlock
	when all links are reset
Date: Thu, 26 Mar 2015 18:10:23 +0800
Message-ID: <1427364624-5930-2-git-send-email-ying.xue@windriver.com>
References: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1427364624-5930-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

[   60.988363] ======================================================
[   60.988754] [ INFO: possible circular locking dependency detected ]
[   60.989152] 3.19.0+ #194 Not tainted
[   60.989377] -------------------------------------------------------
[   60.989781] swapper/3/0 is trying to acquire lock:
[   60.990079]  (&(&n_ptr->lock)->rlock){+.-...}, at: [<ffffffffa0006dca>] tipc_link_retransmit+0x1aa/0x240 [tipc]
[   60.990743]
[   60.990743] but task is already holding lock:
[   60.991106]  (&(&bclink->lock)->rlock){+.-...}, at: [<ffffffffa00004be>] tipc_bclink_lock+0x8e/0xa0 [tipc]
[   60.991738]
[   60.991738] which lock already depends on the new lock.
[   60.991738]
[   60.992174]
[   60.992174] the existing dependency chain (in reverse order) is:
[   60.992174]
-> #1 (&(&bclink->lock)->rlock){+.-...}:
[   60.992174]        [<ffffffff810a9c0c>] lock_acquire+0x9c/0x140
[   60.992174]        [<ffffffff8179c41f>] _raw_spin_lock_bh+0x3f/0x50
[   60.992174]        [<ffffffffa00004be>] tipc_bclink_lock+0x8e/0xa0 [tipc]
[   60.992174]        [<ffffffffa0000f57>] tipc_bclink_add_node+0x97/0xf0 [tipc]
[   60.992174]        [<ffffffffa0011815>] tipc_node_link_up+0xf5/0x110 [tipc]
[   60.992174]        [<ffffffffa0007783>] link_state_event+0x2b3/0x4f0 [tipc]
[   60.992174]        [<ffffffffa00193c0>] tipc_link_proto_rcv+0x24c/0x418 [tipc]
[   60.992174]        [<ffffffffa0008857>] tipc_rcv+0x827/0xac0 [tipc]
[   60.992174]        [<ffffffffa0002ca3>] tipc_l2_rcv_msg+0x73/0xd0 [tipc]
[   60.992174]        [<ffffffff81646e66>] __netif_receive_skb_core+0x746/0x980
[   60.992174]        [<ffffffff816470c1>] __netif_receive_skb+0x21/0x70
[   60.992174]        [<ffffffff81647295>] netif_receive_skb_internal+0x35/0x130
[   60.992174]        [<ffffffff81648218>] napi_gro_receive+0x158/0x1d0
[   60.992174]        [<ffffffff81559e05>] e1000_clean_rx_irq+0x155/0x490
[   60.992174]        [<ffffffff8155c1b7>] e1000_clean+0x267/0x990
[   60.992174]        [<ffffffff81647b60>] net_rx_action+0x150/0x360
[   60.992174]        [<ffffffff8105ec43>] __do_softirq+0x123/0x360
[   60.992174]        [<ffffffff8105f12e>] irq_exit+0x8e/0xb0
[   60.992174]        [<ffffffff8179f9f5>] do_IRQ+0x65/0x110
[   60.992174]        [<ffffffff8179da6f>] ret_from_intr+0x0/0x13
[   60.992174]        [<ffffffff8100de9f>] arch_cpu_idle+0xf/0x20
[   60.992174]        [<ffffffff8109dfa6>] cpu_startup_entry+0x2f6/0x3f0
[   60.992174]        [<ffffffff81033cda>] start_secondary+0x13a/0x150
[   60.992174]
-> #0 (&(&n_ptr->lock)->rlock){+.-...}:
[   60.992174]        [<ffffffff810a8f7d>] __lock_acquire+0x163d/0x1ca0
[   60.992174]        [<ffffffff810a9c0c>] lock_acquire+0x9c/0x140
[   60.992174]        [<ffffffff8179c41f>] _raw_spin_lock_bh+0x3f/0x50
[   60.992174]        [<ffffffffa0006dca>] tipc_link_retransmit+0x1aa/0x240 [tipc]
[   60.992174]        [<ffffffffa0001e11>] tipc_bclink_rcv+0x611/0x640 [tipc]
[   60.992174]        [<ffffffffa0008646>] tipc_rcv+0x616/0xac0 [tipc]
[   60.992174]        [<ffffffffa0002ca3>] tipc_l2_rcv_msg+0x73/0xd0 [tipc]
[   60.992174]        [<ffffffff81646e66>] __netif_receive_skb_core+0x746/0x980
[   60.992174]        [<ffffffff816470c1>] __netif_receive_skb+0x21/0x70
[   60.992174]        [<ffffffff81647295>] netif_receive_skb_internal+0x35/0x130
[   60.992174]        [<ffffffff81648218>] napi_gro_receive+0x158/0x1d0
[   60.992174]        [<ffffffff81559e05>] e1000_clean_rx_irq+0x155/0x490
[   60.992174]        [<ffffffff8155c1b7>] e1000_clean+0x267/0x990
[   60.992174]        [<ffffffff81647b60>] net_rx_action+0x150/0x360
[   60.992174]        [<ffffffff8105ec43>] __do_softirq+0x123/0x360
[   60.992174]        [<ffffffff8105f12e>] irq_exit+0x8e/0xb0
[   60.992174]        [<ffffffff8179f9f5>] do_IRQ+0x65/0x110
[   60.992174]        [<ffffffff8179da6f>] ret_from_intr+0x0/0x13
[   60.992174]        [<ffffffff8100de9f>] arch_cpu_idle+0xf/0x20
[   60.992174]        [<ffffffff8109dfa6>] cpu_startup_entry+0x2f6/0x3f0
[   60.992174]        [<ffffffff81033cda>] start_secondary+0x13a/0x150
[   60.992174]
[   60.992174] other info that might help us debug this:
[   60.992174]
[   60.992174]  Possible unsafe locking scenario:
[   60.992174]
[   60.992174]        CPU0                    CPU1
[   60.992174]        ----                    ----
[   60.992174]   lock(&(&bclink->lock)->rlock);
[   60.992174]                                lock(&(&n_ptr->lock)->rlock);
[   60.992174]                                lock(&(&bclink->lock)->rlock);
[   60.992174]   lock(&(&n_ptr->lock)->rlock);
[   60.992174]
[   60.992174]  *** DEADLOCK ***
[   60.992174]
[   60.992174] 3 locks held by swapper/3/0:
[   60.992174]  #0:  (rcu_read_lock){......}, at: [<ffffffff81646791>] __netif_receive_skb_core+0x71/0x980
[   60.992174]  #1:  (rcu_read_lock){......}, at: [<ffffffffa0002c35>] tipc_l2_rcv_msg+0x5/0xd0 [tipc]
[   60.992174]  #2:  (&(&bclink->lock)->rlock){+.-...}, at: [<ffffffffa00004be>] tipc_bclink_lock+0x8e/0xa0 [tipc]
[   60.992174]

The correct the sequence of grabbing n_ptr->lock and bclink->lock
should be that the former is first held and the latter is then taken,
which exactly happened on CPU1. But especially when the retransmission
of broadcast link is failed, bclink->lock is first held in
tipc_bclink_rcv(), and n_ptr->lock is taken in link_retransmit_failure()
called by tipc_link_retransmit() subsequently, which is demonstrated on
CPU0. As a result, deadlock occurs.

If the order of holding the two locks happening on CPU0 is reversed, the
deadlock risk will be relieved. Therefore, the node lock taken in
link_retransmit_failure() originally is moved to tipc_bclink_rcv()
so that it's obtained before bclink lock. But the precondition of
the adjustment of node lock is that responding to bclink reset event
must be moved from tipc_bclink_unlock() to tipc_node_unlock().

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c |   23 +----------------------
 net/tipc/bcast.h |    4 ----
 net/tipc/link.c  |    5 +----
 net/tipc/node.c  |    5 ++++-
 net/tipc/node.h  |    3 ++-
 5 files changed, 8 insertions(+), 32 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7935553..4289dd6 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -62,21 +62,8 @@ static void tipc_bclink_lock(struct net *net)
 static void tipc_bclink_unlock(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct tipc_node *node = NULL;
 
-	if (likely(!tn->bclink->flags)) {
-		spin_unlock_bh(&tn->bclink->lock);
-		return;
-	}
-
-	if (tn->bclink->flags & TIPC_BCLINK_RESET) {
-		tn->bclink->flags &= ~TIPC_BCLINK_RESET;
-		node = tipc_bclink_retransmit_to(net);
-	}
 	spin_unlock_bh(&tn->bclink->lock);
-
-	if (node)
-		tipc_link_reset_all(node);
 }
 
 void tipc_bclink_input(struct net *net)
@@ -91,13 +78,6 @@ uint  tipc_bclink_get_mtu(void)
 	return MAX_PKT_DEFAULT_MCAST;
 }
 
-void tipc_bclink_set_flags(struct net *net, unsigned int flags)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-
-	tn->bclink->flags |= flags;
-}
-
 static u32 bcbuf_acks(struct sk_buff *buf)
 {
 	return (u32)(unsigned long)TIPC_SKB_CB(buf)->handle;
@@ -156,7 +136,6 @@ static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
 						seqno : node->bclink.last_sent;
 }
 
-
 /**
  * tipc_bclink_retransmit_to - get most recent node to request retransmission
  *
@@ -476,13 +455,13 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 			goto unlock;
 		if (msg_destnode(msg) == tn->own_addr) {
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
-			tipc_node_unlock(node);
 			tipc_bclink_lock(net);
 			bcl->stats.recv_nacks++;
 			tn->bclink->retransmit_to = node;
 			bclink_retransmit_pkt(tn, msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
 			tipc_bclink_unlock(net);
+			tipc_node_unlock(node);
 		} else {
 			tipc_node_unlock(node);
 			bclink_peek_nack(net, msg);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 43f397f..4bdc122 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -55,7 +55,6 @@ struct tipc_bcbearer_pair {
 	struct tipc_bearer *secondary;
 };
 
-#define TIPC_BCLINK_RESET	1
 #define	BCBEARER		MAX_BEARERS
 
 /**
@@ -86,7 +85,6 @@ struct tipc_bcbearer {
  * @lock: spinlock governing access to structure
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
- * @flags: represent bclink states
  * @bcast_nodes: map of broadcast-capable nodes
  * @retransmit_to: node that most recently requested a retransmit
  *
@@ -96,7 +94,6 @@ struct tipc_bclink {
 	spinlock_t lock;
 	struct tipc_link link;
 	struct tipc_node node;
-	unsigned int flags;
 	struct sk_buff_head arrvq;
 	struct sk_buff_head inputq;
 	struct tipc_node_map bcast_nodes;
@@ -117,7 +114,6 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a,
 
 int tipc_bclink_init(struct net *net);
 void tipc_bclink_stop(struct net *net);
-void tipc_bclink_set_flags(struct net *tn, unsigned int flags);
 void tipc_bclink_add_node(struct net *net, u32 addr);
 void tipc_bclink_remove_node(struct net *net, u32 addr);
 struct tipc_node *tipc_bclink_retransmit_to(struct net *tn);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1287161..f5e086c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -980,7 +980,6 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 			(unsigned long) TIPC_SKB_CB(buf)->handle);
 
 		n_ptr = tipc_bclink_retransmit_to(net);
-		tipc_node_lock(n_ptr);
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
 		pr_info("Broadcast link info for %s\n", addr_string);
@@ -992,9 +991,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 			n_ptr->bclink.oos_state,
 			n_ptr->bclink.last_sent);
 
-		tipc_node_unlock(n_ptr);
-
-		tipc_bclink_set_flags(net, TIPC_BCLINK_RESET);
+		n_ptr->action_flags |= TIPC_BCAST_RESET;
 		l_ptr->stale_count = 0;
 	}
 }
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 26d1de1..5cc43d3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -459,7 +459,7 @@ void tipc_node_unlock(struct tipc_node *node)
 				TIPC_NOTIFY_NODE_DOWN | TIPC_NOTIFY_NODE_UP |
 				TIPC_NOTIFY_LINK_DOWN | TIPC_NOTIFY_LINK_UP |
 				TIPC_WAKEUP_BCAST_USERS | TIPC_BCAST_MSG_EVT |
-				TIPC_NAMED_MSG_EVT);
+				TIPC_NAMED_MSG_EVT | TIPC_BCAST_RESET);
 
 	spin_unlock_bh(&node->lock);
 
@@ -488,6 +488,9 @@ void tipc_node_unlock(struct tipc_node *node)
 
 	if (flags & TIPC_BCAST_MSG_EVT)
 		tipc_bclink_input(net);
+
+	if (flags & TIPC_BCAST_RESET)
+		tipc_link_reset_all(node);
 }
 
 /* Caller should hold node lock for the passed node */
diff --git a/net/tipc/node.h b/net/tipc/node.h
index e89ac04..9629ecd 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -64,7 +64,8 @@ enum {
 	TIPC_NOTIFY_LINK_UP		= (1 << 6),
 	TIPC_NOTIFY_LINK_DOWN		= (1 << 7),
 	TIPC_NAMED_MSG_EVT		= (1 << 8),
-	TIPC_BCAST_MSG_EVT		= (1 << 9)
+	TIPC_BCAST_MSG_EVT		= (1 << 9),
+	TIPC_BCAST_RESET		= (1 << 10)
 };
 
 /**
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
