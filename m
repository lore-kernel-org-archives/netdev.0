From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 02/10] tipc: adjust order of variables in tipc_node structure
Date: Mon, 5 May 2014 08:56:10 +0800
Message-ID: <1399251378-23842-3-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59952 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaEEA4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:37 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move more frequently used variables up to the head of tipc_node
structure, hopefully improving a bit performance.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.h |   63 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 29 deletions(-)

diff --git a/net/tipc/node.h b/net/tipc/node.h
index 411b191..bb7f708 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -53,56 +53,61 @@
 #define WAIT_NODE_DOWN	0x0004	/* wait until peer node is declared down */
 
 /**
+ * struct tipc_node_bclink - TIPC node bclink structure
+ * @acked: sequence # of last outbound b'cast message acknowledged by node
+ * @last_in: sequence # of last in-sequence b'cast message received from node
+ * @last_sent: sequence # of last b'cast message sent by node
+ * @oos_state: state tracker for handling OOS b'cast messages
+ * @deferred_size: number of OOS b'cast messages in deferred queue
+ * @deferred_head: oldest OOS b'cast message received from node
+ * @deferred_tail: newest OOS b'cast message received from node
+ * @reasm_head: broadcast reassembly queue head from node
+ * @reasm_tail: last broadcast fragment received from node
+ * @recv_permitted: true if node is allowed to receive b'cast messages
+ */
+struct tipc_node_bclink {
+	u32 acked;
+	u32 last_in;
+	u32 last_sent;
+	u32 oos_state;
+	u32 deferred_size;
+	struct sk_buff *deferred_head;
+	struct sk_buff *deferred_tail;
+	struct sk_buff *reasm_head;
+	struct sk_buff *reasm_tail;
+	bool recv_permitted;
+};
+
+/**
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
  * @lock: spinlock governing access to structure
  * @hash: links to adjacent nodes in unsorted hash chain
- * @list: links to adjacent nodes in sorted list of cluster's nodes
- * @nsub: list of "node down" subscriptions monitoring node
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
- * @working_links: number of working links to node (both active and standby)
  * @block_setup: bit mask of conditions preventing link establishment to node
+ * @bclink: broadcast-related info
+ * @list: links to adjacent nodes in sorted list of cluster's nodes
+ * @working_links: number of working links to node (both active and standby)
  * @link_cnt: number of links to node
  * @signature: node instance identifier
- * @bclink: broadcast-related info
+ * @nsub: list of "node down" subscriptions monitoring node
  * @rcu: rcu struct for tipc_node
- *    @acked: sequence # of last outbound b'cast message acknowledged by node
- *    @last_in: sequence # of last in-sequence b'cast message received from node
- *    @last_sent: sequence # of last b'cast message sent by node
- *    @oos_state: state tracker for handling OOS b'cast messages
- *    @deferred_size: number of OOS b'cast messages in deferred queue
- *    @deferred_head: oldest OOS b'cast message received from node
- *    @deferred_tail: newest OOS b'cast message received from node
- *    @reasm_head: broadcast reassembly queue head from node
- *    @reasm_tail: last broadcast fragment received from node
- *    @recv_permitted: true if node is allowed to receive b'cast messages
  */
 struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
 	struct hlist_node hash;
-	struct list_head list;
-	struct list_head nsub;
 	struct tipc_link *active_links[2];
 	struct tipc_link *links[MAX_BEARERS];
+	int block_setup;
+	struct tipc_node_bclink bclink;
+	struct list_head list;
 	int link_cnt;
 	int working_links;
-	int block_setup;
 	u32 signature;
+	struct list_head nsub;
 	struct rcu_head rcu;
-	struct {
-		u32 acked;
-		u32 last_in;
-		u32 last_sent;
-		u32 oos_state;
-		u32 deferred_size;
-		struct sk_buff *deferred_head;
-		struct sk_buff *deferred_tail;
-		struct sk_buff *reasm_head;
-		struct sk_buff *reasm_tail;
-		bool recv_permitted;
-	} bclink;
 };
 
 extern struct list_head tipc_node_list;
-- 
1.7.9.5
