From: David Miller <davem@davemloft.net>
Subject: Re: tipc on sparc32
Date: Tue, 02 Sep 2008 23:40:20 -0700 (PDT)
Message-ID: <20080902.234020.211119869.davem@davemloft.net>
References: <20080902224059.70a182ba.akpm@linux-foundation.org>
	<20080902.231201.184658566.davem@davemloft.net>
	<20080902.232627.209816179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: akpm@linux-foundation.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20080902.232627.209816179.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 02 Sep 2008 23:26:27 -0700 (PDT)

> I can take care of TIPC.

Here is what I'll likely use, thanks Andrew.

tipc: Don't use structure names which easily globally conflict.

Andrew Morton reported a build failure on sparc32, because TIPC
uses names like "struct node" and there is a like named data
structure defined in linux/node.h

This just regexp replaces "struct node*" to "struct tipc_node*"
to avoid this and any future similar problems.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/tipc/bcast.c       |   22 ++++++++--------
 net/tipc/bcast.h       |   22 ++++++++--------
 net/tipc/bearer.c      |    2 +-
 net/tipc/bearer.h      |    2 +-
 net/tipc/cluster.c     |   16 ++++++------
 net/tipc/cluster.h     |   10 ++++----
 net/tipc/discover.c    |    2 +-
 net/tipc/link.c        |   26 ++++++++++----------
 net/tipc/link.h        |    2 +-
 net/tipc/name_table.h  |    2 +-
 net/tipc/net.c         |    2 +-
 net/tipc/net.h         |    2 +-
 net/tipc/node.c        |   60 ++++++++++++++++++++++++------------------------
 net/tipc/node.h        |   42 ++++++++++++++++----------------
 net/tipc/node_subscr.c |    4 +-
 net/tipc/node_subscr.h |   10 ++++----
 net/tipc/port.h        |    2 +-
 net/tipc/zone.c        |    4 +-
 net/tipc/zone.h        |    2 +-
 19 files changed, 117 insertions(+), 117 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b1ff16a..3ddaff4 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -96,8 +96,8 @@ struct bcbearer {
 	struct media media;
 	struct bcbearer_pair bpairs[MAX_BEARERS];
 	struct bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
-	struct node_map remains;
-	struct node_map remains_new;
+	struct tipc_node_map remains;
+	struct tipc_node_map remains_new;
 };
 
 /**
@@ -110,7 +110,7 @@ struct bcbearer {
 
 struct bclink {
 	struct link link;
-	struct node node;
+	struct tipc_node node;
 };
 
 
@@ -149,7 +149,7 @@ static void bcbuf_decr_acks(struct sk_buff *buf)
  * Called with 'node' locked, bc_lock unlocked
  */
 
-static void bclink_set_gap(struct node *n_ptr)
+static void bclink_set_gap(struct tipc_node *n_ptr)
 {
 	struct sk_buff *buf = n_ptr->bclink.deferred_head;
 
@@ -202,7 +202,7 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  * Node is locked, bc_lock unlocked.
  */
 
-void tipc_bclink_acknowledge(struct node *n_ptr, u32 acked)
+void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 {
 	struct sk_buff *crs;
 	struct sk_buff *next;
@@ -250,7 +250,7 @@ void tipc_bclink_acknowledge(struct node *n_ptr, u32 acked)
  * tipc_net_lock and node lock set
  */
 
-static void bclink_send_ack(struct node *n_ptr)
+static void bclink_send_ack(struct tipc_node *n_ptr)
 {
 	struct link *l_ptr = n_ptr->active_links[n_ptr->addr & 1];
 
@@ -264,7 +264,7 @@ static void bclink_send_ack(struct node *n_ptr)
  * tipc_net_lock and node lock set
  */
 
-static void bclink_send_nack(struct node *n_ptr)
+static void bclink_send_nack(struct tipc_node *n_ptr)
 {
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -308,7 +308,7 @@ static void bclink_send_nack(struct node *n_ptr)
  * tipc_net_lock and node lock set
  */
 
-void tipc_bclink_check_gap(struct node *n_ptr, u32 last_sent)
+void tipc_bclink_check_gap(struct tipc_node *n_ptr, u32 last_sent)
 {
 	if (!n_ptr->bclink.supported ||
 	    less_eq(last_sent, mod(n_ptr->bclink.last_in)))
@@ -328,7 +328,7 @@ void tipc_bclink_check_gap(struct node *n_ptr, u32 last_sent)
 
 static void tipc_bclink_peek_nack(u32 dest, u32 sender_tag, u32 gap_after, u32 gap_to)
 {
-	struct node *n_ptr = tipc_node_find(dest);
+	struct tipc_node *n_ptr = tipc_node_find(dest);
 	u32 my_after, my_to;
 
 	if (unlikely(!n_ptr || !tipc_node_is_up(n_ptr)))
@@ -418,7 +418,7 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	static int rx_count = 0;
 #endif
 	struct tipc_msg *msg = buf_msg(buf);
-	struct node* node = tipc_node_find(msg_prevnode(msg));
+	struct tipc_node* node = tipc_node_find(msg_prevnode(msg));
 	u32 next_in;
 	u32 seqno;
 	struct sk_buff *deferred;
@@ -538,7 +538,7 @@ u32 tipc_bclink_get_last_sent(void)
 	return last_sent;
 }
 
-u32 tipc_bclink_acks_missing(struct node *n_ptr)
+u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
 {
 	return (n_ptr->bclink.supported &&
 		(tipc_bclink_get_last_sent() != n_ptr->bclink.acked));
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index a2416fa..5aa024b 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -41,12 +41,12 @@
 #define WSIZE 32
 
 /**
- * struct node_map - set of node identifiers
+ * struct tipc_node_map - set of node identifiers
  * @count: # of nodes in set
  * @map: bitmap of node identifiers that are in the set
  */
 
-struct node_map {
+struct tipc_node_map {
 	u32 count;
 	u32 map[MAX_NODES / WSIZE];
 };
@@ -68,7 +68,7 @@ struct port_list {
 };
 
 
-struct node;
+struct tipc_node;
 
 extern char tipc_bclink_name[];
 
@@ -77,7 +77,7 @@ extern char tipc_bclink_name[];
  * nmap_add - add a node to a node map
  */
 
-static inline void tipc_nmap_add(struct node_map *nm_ptr, u32 node)
+static inline void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
 	int w = n / WSIZE;
@@ -93,7 +93,7 @@ static inline void tipc_nmap_add(struct node_map *nm_ptr, u32 node)
  * nmap_remove - remove a node from a node map
  */
 
-static inline void tipc_nmap_remove(struct node_map *nm_ptr, u32 node)
+static inline void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
 	int w = n / WSIZE;
@@ -109,7 +109,7 @@ static inline void tipc_nmap_remove(struct node_map *nm_ptr, u32 node)
  * nmap_equal - test for equality of node maps
  */
 
-static inline int tipc_nmap_equal(struct node_map *nm_a, struct node_map *nm_b)
+static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b)
 {
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
 }
@@ -121,8 +121,8 @@ static inline int tipc_nmap_equal(struct node_map *nm_a, struct node_map *nm_b)
  * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
  */
 
-static inline void tipc_nmap_diff(struct node_map *nm_a, struct node_map *nm_b,
-				  struct node_map *nm_diff)
+static inline void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
+				  struct tipc_node_map *nm_diff)
 {
 	int stop = sizeof(nm_a->map) / sizeof(u32);
 	int w;
@@ -195,12 +195,12 @@ static inline void tipc_port_list_free(struct port_list *pl_ptr)
 
 int  tipc_bclink_init(void);
 void tipc_bclink_stop(void);
-void tipc_bclink_acknowledge(struct node *n_ptr, u32 acked);
+void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
 int  tipc_bclink_send_msg(struct sk_buff *buf);
 void tipc_bclink_recv_pkt(struct sk_buff *buf);
 u32  tipc_bclink_get_last_sent(void);
-u32  tipc_bclink_acks_missing(struct node *n_ptr);
-void tipc_bclink_check_gap(struct node *n_ptr, u32 seqno);
+u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
+void tipc_bclink_check_gap(struct tipc_node *n_ptr, u32 seqno);
 int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 6a9aba3..a7a3677 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -599,7 +599,7 @@ int tipc_block_bearer(const char *name)
 	spin_lock_bh(&b_ptr->publ.lock);
 	b_ptr->publ.blocked = 1;
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
-		struct node *n_ptr = l_ptr->owner;
+		struct tipc_node *n_ptr = l_ptr->owner;
 
 		spin_lock_bh(&n_ptr->lock);
 		tipc_link_reset(l_ptr);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 6a36b66..ca57348 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -104,7 +104,7 @@ struct bearer {
 	u32 continue_count;
 	int active;
 	char net_plane;
-	struct node_map nodes;
+	struct tipc_node_map nodes;
 };
 
 struct bearer_name {
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 46ee6c5..689fdef 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -48,8 +48,8 @@ static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 				u32 lower, u32 upper);
 static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest);
 
-struct node **tipc_local_nodes = NULL;
-struct node_map tipc_cltr_bcast_nodes = {0,{0,}};
+struct tipc_node **tipc_local_nodes = NULL;
+struct tipc_node_map tipc_cltr_bcast_nodes = {0,{0,}};
 u32 tipc_highest_allowed_slave = 0;
 
 struct cluster *tipc_cltr_create(u32 addr)
@@ -115,7 +115,7 @@ void tipc_cltr_delete(struct cluster *c_ptr)
 
 u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr)
 {
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 n_num = tipc_node(addr) + 1;
 
 	if (!c_ptr)
@@ -133,7 +133,7 @@ u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr)
 	return 0;
 }
 
-void tipc_cltr_attach_node(struct cluster *c_ptr, struct node *n_ptr)
+void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr)
 {
 	u32 n_num = tipc_node(n_ptr->addr);
 	u32 max_n_num = tipc_max_nodes;
@@ -196,7 +196,7 @@ u32 tipc_cltr_select_router(struct cluster *c_ptr, u32 ref)
  * Uses deterministic and fair algorithm.
  */
 
-struct node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector)
+struct tipc_node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector)
 {
 	u32 n_num;
 	u32 mask = tipc_max_nodes;
@@ -379,7 +379,7 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	struct cluster *c_ptr;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	unchar *node_table;
 	u32 table_size;
 	u32 router;
@@ -499,7 +499,7 @@ static void tipc_cltr_multicast(struct cluster *c_ptr, struct sk_buff *buf,
 			 u32 lower, u32 upper)
 {
 	struct sk_buff *buf_copy;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 n_num;
 	u32 tstop;
 
@@ -534,7 +534,7 @@ void tipc_cltr_broadcast(struct sk_buff *buf)
 {
 	struct sk_buff *buf_copy;
 	struct cluster *c_ptr;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 n_num;
 	u32 tstart;
 	u32 tstop;
diff --git a/net/tipc/cluster.h b/net/tipc/cluster.h
index 62df074..333efb0 100644
--- a/net/tipc/cluster.h
+++ b/net/tipc/cluster.h
@@ -54,24 +54,24 @@
 struct cluster {
 	u32 addr;
 	struct _zone *owner;
-	struct node **nodes;
+	struct tipc_node **nodes;
 	u32 highest_node;
 	u32 highest_slave;
 };
 
 
-extern struct node **tipc_local_nodes;
+extern struct tipc_node **tipc_local_nodes;
 extern u32 tipc_highest_allowed_slave;
-extern struct node_map tipc_cltr_bcast_nodes;
+extern struct tipc_node_map tipc_cltr_bcast_nodes;
 
 void tipc_cltr_remove_as_router(struct cluster *c_ptr, u32 router);
 void tipc_cltr_send_ext_routes(struct cluster *c_ptr, u32 dest);
-struct node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector);
+struct tipc_node *tipc_cltr_select_node(struct cluster *c_ptr, u32 selector);
 u32 tipc_cltr_select_router(struct cluster *c_ptr, u32 ref);
 void tipc_cltr_recv_routing_table(struct sk_buff *buf);
 struct cluster *tipc_cltr_create(u32 addr);
 void tipc_cltr_delete(struct cluster *c_ptr);
-void tipc_cltr_attach_node(struct cluster *c_ptr, struct node *n_ptr);
+void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr);
 void tipc_cltr_send_slave_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_broadcast(struct sk_buff *buf);
 int tipc_cltr_init(void);
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 1657f0e..74b7d1e 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -193,7 +193,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 		/* Always accept link here */
 		struct sk_buff *rbuf;
 		struct tipc_media_addr *addr;
-		struct node *n_ptr = tipc_node_find(orig);
+		struct tipc_node *n_ptr = tipc_node_find(orig);
 		int link_fully_up;
 
 		dbg(" in own cluster\n");
diff --git a/net/tipc/link.c b/net/tipc/link.c
index d60113b..dd4c18b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1155,7 +1155,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 {
 	struct link *l_ptr;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	int res = -ELINKCONG;
 
 	read_lock_bh(&tipc_net_lock);
@@ -1226,7 +1226,7 @@ static int link_send_buf_fast(struct link *l_ptr, struct sk_buff *buf,
 int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 {
 	struct link *l_ptr;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	int res;
 	u32 selector = msg_origport(buf_msg(buf)) & 1;
 	u32 dummy;
@@ -1270,7 +1270,7 @@ int tipc_link_send_sections_fast(struct port *sender,
 	struct tipc_msg *hdr = &sender->publ.phdr;
 	struct link *l_ptr;
 	struct sk_buff *buf;
-	struct node *node;
+	struct tipc_node *node;
 	int res;
 	u32 selector = msg_origport(hdr) & 1;
 
@@ -1364,7 +1364,7 @@ static int link_send_sections_long(struct port *sender,
 				   u32 destaddr)
 {
 	struct link *l_ptr;
-	struct node *node;
+	struct tipc_node *node;
 	struct tipc_msg *hdr = &sender->publ.phdr;
 	u32 dsz = msg_data_sz(hdr);
 	u32 max_pkt,fragm_sz,rest;
@@ -1636,7 +1636,7 @@ void tipc_link_push_queue(struct link *l_ptr)
 
 static void link_reset_all(unsigned long addr)
 {
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	char addr_string[16];
 	u32 i;
 
@@ -1682,7 +1682,7 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 
 		/* Handle failure on broadcast link */
 
-		struct node *n_ptr;
+		struct tipc_node *n_ptr;
 		char addr_string[16];
 
 		tipc_printf(TIPC_OUTPUT, "Msg seq number: %u,  ", msg_seqno(msg));
@@ -1843,7 +1843,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 	read_lock_bh(&tipc_net_lock);
 	while (head) {
 		struct bearer *b_ptr = (struct bearer *)tb_ptr;
-		struct node *n_ptr;
+		struct tipc_node *n_ptr;
 		struct link *l_ptr;
 		struct sk_buff *crs;
 		struct sk_buff *buf = head;
@@ -2935,7 +2935,7 @@ void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
  * Returns pointer to link (or 0 if invalid link name).
  */
 
-static struct link *link_find_link(const char *name, struct node **node)
+static struct link *link_find_link(const char *name, struct tipc_node **node)
 {
 	struct link_name link_name_parts;
 	struct bearer *b_ptr;
@@ -2965,7 +2965,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 	struct tipc_link_config *args;
 	u32 new_value;
 	struct link *l_ptr;
-	struct node *node;
+	struct tipc_node *node;
 	int res;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_CONFIG))
@@ -3043,7 +3043,7 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 {
 	char *link_name;
 	struct link *l_ptr;
-	struct node *node;
+	struct tipc_node *node;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -3091,7 +3091,7 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 {
 	struct print_buf pb;
 	struct link *l_ptr;
-	struct node *node;
+	struct tipc_node *node;
 	char *status;
 	u32 profile_total = 0;
 
@@ -3207,7 +3207,7 @@ int link_control(const char *name, u32 op, u32 val)
 	int res = -EINVAL;
 	struct link *l_ptr;
 	u32 bearer_id;
-	struct node * node;
+	struct tipc_node * node;
 	u32 a;
 
 	a = link_name2addr(name, &bearer_id);
@@ -3249,7 +3249,7 @@ int link_control(const char *name, u32 op, u32 val)
 
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 {
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	struct link *l_ptr;
 	u32 res = MAX_PKT_DEFAULT;
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 52f3e7c..6a51e38 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -116,7 +116,7 @@ struct link {
 	char name[TIPC_MAX_LINK_NAME];
 	struct tipc_media_addr media_addr;
 	struct timer_list timer;
-	struct node *owner;
+	struct tipc_node *owner;
 	struct list_head link_list;
 
 	/* Management and link supervision data */
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index b9e7cd3..139882d 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -76,7 +76,7 @@ struct publication {
 	u32 node;
 	u32 ref;
 	u32 key;
-	struct node_subscr subscr;
+	struct tipc_node_subscr subscr;
 	struct list_head local_list;
 	struct list_head pport_list;
 	struct publication *node_list_next;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index ec7b04f..7906608 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -118,7 +118,7 @@
 DEFINE_RWLOCK(tipc_net_lock);
 struct network tipc_net = { NULL };
 
-struct node *tipc_net_select_remote_node(u32 addr, u32 ref)
+struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref)
 {
 	return tipc_zone_select_remote_node(tipc_net.zones[tipc_zone(addr)], addr, ref);
 }
diff --git a/net/tipc/net.h b/net/tipc/net.h
index d154ac2..de2b9ad 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -55,7 +55,7 @@ extern rwlock_t tipc_net_lock;
 void tipc_net_remove_as_router(u32 router);
 void tipc_net_send_external_routes(u32 dest);
 void tipc_net_route_msg(struct sk_buff *buf);
-struct node *tipc_net_select_remote_node(u32 addr, u32 ref);
+struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref);
 u32 tipc_net_select_router(u32 addr, u32 ref);
 
 int tipc_net_start(u32 addr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index ee952ad..20d98c5 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -46,11 +46,11 @@
 #include "bearer.h"
 #include "name_distr.h"
 
-void node_print(struct print_buf *buf, struct node *n_ptr, char *str);
-static void node_lost_contact(struct node *n_ptr);
-static void node_established_contact(struct node *n_ptr);
+void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str);
+static void node_lost_contact(struct tipc_node *n_ptr);
+static void node_established_contact(struct tipc_node *n_ptr);
 
-struct node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
+struct tipc_node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
 
 static DEFINE_SPINLOCK(node_create_lock);
 
@@ -66,11 +66,11 @@ u32 tipc_own_tag = 0;
  * but this is a non-trivial change.)
  */
 
-struct node *tipc_node_create(u32 addr)
+struct tipc_node *tipc_node_create(u32 addr)
 {
 	struct cluster *c_ptr;
-	struct node *n_ptr;
-	struct node **curr_node;
+	struct tipc_node *n_ptr;
+	struct tipc_node **curr_node;
 
 	spin_lock_bh(&node_create_lock);
 
@@ -120,7 +120,7 @@ struct node *tipc_node_create(u32 addr)
 	return n_ptr;
 }
 
-void tipc_node_delete(struct node *n_ptr)
+void tipc_node_delete(struct tipc_node *n_ptr)
 {
 	if (!n_ptr)
 		return;
@@ -146,7 +146,7 @@ void tipc_node_delete(struct node *n_ptr)
  * Link becomes active (alone or shared) or standby, depending on its priority.
  */
 
-void tipc_node_link_up(struct node *n_ptr, struct link *l_ptr)
+void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	struct link **active = &n_ptr->active_links[0];
 
@@ -180,7 +180,7 @@ void tipc_node_link_up(struct node *n_ptr, struct link *l_ptr)
  * node_select_active_links - select active link
  */
 
-static void node_select_active_links(struct node *n_ptr)
+static void node_select_active_links(struct tipc_node *n_ptr)
 {
 	struct link **active = &n_ptr->active_links[0];
 	u32 i;
@@ -208,7 +208,7 @@ static void node_select_active_links(struct node *n_ptr)
  * tipc_node_link_down - handle loss of link
  */
 
-void tipc_node_link_down(struct node *n_ptr, struct link *l_ptr)
+void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	struct link **active;
 
@@ -235,30 +235,30 @@ void tipc_node_link_down(struct node *n_ptr, struct link *l_ptr)
 		node_lost_contact(n_ptr);
 }
 
-int tipc_node_has_active_links(struct node *n_ptr)
+int tipc_node_has_active_links(struct tipc_node *n_ptr)
 {
 	return (n_ptr &&
 		((n_ptr->active_links[0]) || (n_ptr->active_links[1])));
 }
 
-int tipc_node_has_redundant_links(struct node *n_ptr)
+int tipc_node_has_redundant_links(struct tipc_node *n_ptr)
 {
 	return (n_ptr->working_links > 1);
 }
 
-static int tipc_node_has_active_routes(struct node *n_ptr)
+static int tipc_node_has_active_routes(struct tipc_node *n_ptr)
 {
 	return (n_ptr && (n_ptr->last_router >= 0));
 }
 
-int tipc_node_is_up(struct node *n_ptr)
+int tipc_node_is_up(struct tipc_node *n_ptr)
 {
 	return (tipc_node_has_active_links(n_ptr) || tipc_node_has_active_routes(n_ptr));
 }
 
-struct node *tipc_node_attach_link(struct link *l_ptr)
+struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 {
-	struct node *n_ptr = tipc_node_find(l_ptr->addr);
+	struct tipc_node *n_ptr = tipc_node_find(l_ptr->addr);
 
 	if (!n_ptr)
 		n_ptr = tipc_node_create(l_ptr->addr);
@@ -285,7 +285,7 @@ struct node *tipc_node_attach_link(struct link *l_ptr)
 	return NULL;
 }
 
-void tipc_node_detach_link(struct node *n_ptr, struct link *l_ptr)
+void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
 	tipc_net.zones[tipc_zone(l_ptr->addr)]->links--;
@@ -338,7 +338,7 @@ void tipc_node_detach_link(struct node *n_ptr, struct link *l_ptr)
  *
  */
 
-static void node_established_contact(struct node *n_ptr)
+static void node_established_contact(struct tipc_node *n_ptr)
 {
 	struct cluster *c_ptr;
 
@@ -384,10 +384,10 @@ static void node_established_contact(struct node *n_ptr)
 				  tipc_highest_allowed_slave);
 }
 
-static void node_lost_contact(struct node *n_ptr)
+static void node_lost_contact(struct tipc_node *n_ptr)
 {
 	struct cluster *c_ptr;
-	struct node_subscr *ns, *tns;
+	struct tipc_node_subscr *ns, *tns;
 	char addr_string[16];
 	u32 i;
 
@@ -466,9 +466,9 @@ static void node_lost_contact(struct node *n_ptr)
  * Called by when cluster local lookup has failed.
  */
 
-struct node *tipc_node_select_next_hop(u32 addr, u32 selector)
+struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector)
 {
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 router_addr;
 
 	if (!tipc_addr_domain_valid(addr))
@@ -513,7 +513,7 @@ struct node *tipc_node_select_next_hop(u32 addr, u32 selector)
  * Uses a deterministic and fair algorithm for selecting router node.
  */
 
-u32 tipc_node_select_router(struct node *n_ptr, u32 ref)
+u32 tipc_node_select_router(struct tipc_node *n_ptr, u32 ref)
 {
 	u32 ulim;
 	u32 mask;
@@ -551,7 +551,7 @@ u32 tipc_node_select_router(struct node *n_ptr, u32 ref)
 	return tipc_addr(own_zone(), own_cluster(), r);
 }
 
-void tipc_node_add_router(struct node *n_ptr, u32 router)
+void tipc_node_add_router(struct tipc_node *n_ptr, u32 router)
 {
 	u32 r_num = tipc_node(router);
 
@@ -562,7 +562,7 @@ void tipc_node_add_router(struct node *n_ptr, u32 router)
 	       !n_ptr->routers[n_ptr->last_router]);
 }
 
-void tipc_node_remove_router(struct node *n_ptr, u32 router)
+void tipc_node_remove_router(struct tipc_node *n_ptr, u32 router)
 {
 	u32 r_num = tipc_node(router);
 
@@ -580,7 +580,7 @@ void tipc_node_remove_router(struct node *n_ptr, u32 router)
 }
 
 #if 0
-void node_print(struct print_buf *buf, struct node *n_ptr, char *str)
+void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str)
 {
 	u32 i;
 
@@ -597,7 +597,7 @@ void node_print(struct print_buf *buf, struct node *n_ptr, char *str)
 
 u32 tipc_available_nodes(const u32 domain)
 {
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 cnt = 0;
 
 	read_lock_bh(&tipc_net_lock);
@@ -615,7 +615,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 domain;
 	struct sk_buff *buf;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	struct tipc_node_info node_info;
 	u32 payload_size;
 
@@ -667,7 +667,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 domain;
 	struct sk_buff *buf;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	struct tipc_link_info link_info;
 	u32 payload_size;
 
diff --git a/net/tipc/node.h b/net/tipc/node.h
index cd18826..6f990da 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -43,7 +43,7 @@
 #include "bearer.h"
 
 /**
- * struct node - TIPC node structure
+ * struct tipc_node - TIPC node structure
  * @addr: network address of node
  * @lock: spinlock governing access to structure
  * @owner: pointer to cluster that node belongs to
@@ -68,11 +68,11 @@
  *    @defragm: list of partially reassembled b'cast message fragments from node
  */
 
-struct node {
+struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
 	struct cluster *owner;
-	struct node *next;
+	struct tipc_node *next;
 	struct list_head nsub;
 	struct link *active_links[2];
 	struct link *links[MAX_BEARERS];
@@ -94,26 +94,26 @@ struct node {
 	} bclink;
 };
 
-extern struct node *tipc_nodes;
+extern struct tipc_node *tipc_nodes;
 extern u32 tipc_own_tag;
 
-struct node *tipc_node_create(u32 addr);
-void tipc_node_delete(struct node *n_ptr);
-struct node *tipc_node_attach_link(struct link *l_ptr);
-void tipc_node_detach_link(struct node *n_ptr, struct link *l_ptr);
-void tipc_node_link_down(struct node *n_ptr, struct link *l_ptr);
-void tipc_node_link_up(struct node *n_ptr, struct link *l_ptr);
-int tipc_node_has_active_links(struct node *n_ptr);
-int tipc_node_has_redundant_links(struct node *n_ptr);
-u32 tipc_node_select_router(struct node *n_ptr, u32 ref);
-struct node *tipc_node_select_next_hop(u32 addr, u32 selector);
-int tipc_node_is_up(struct node *n_ptr);
-void tipc_node_add_router(struct node *n_ptr, u32 router);
-void tipc_node_remove_router(struct node *n_ptr, u32 router);
+struct tipc_node *tipc_node_create(u32 addr);
+void tipc_node_delete(struct tipc_node *n_ptr);
+struct tipc_node *tipc_node_attach_link(struct link *l_ptr);
+void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr);
+void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr);
+void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr);
+int tipc_node_has_active_links(struct tipc_node *n_ptr);
+int tipc_node_has_redundant_links(struct tipc_node *n_ptr);
+u32 tipc_node_select_router(struct tipc_node *n_ptr, u32 ref);
+struct tipc_node *tipc_node_select_next_hop(u32 addr, u32 selector);
+int tipc_node_is_up(struct tipc_node *n_ptr);
+void tipc_node_add_router(struct tipc_node *n_ptr, u32 router);
+void tipc_node_remove_router(struct tipc_node *n_ptr, u32 router);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
 
-static inline struct node *tipc_node_find(u32 addr)
+static inline struct tipc_node *tipc_node_find(u32 addr)
 {
 	if (likely(in_own_cluster(addr)))
 		return tipc_local_nodes[tipc_node(addr)];
@@ -126,19 +126,19 @@ static inline struct node *tipc_node_find(u32 addr)
 	return NULL;
 }
 
-static inline struct node *tipc_node_select(u32 addr, u32 selector)
+static inline struct tipc_node *tipc_node_select(u32 addr, u32 selector)
 {
 	if (likely(in_own_cluster(addr)))
 		return tipc_local_nodes[tipc_node(addr)];
 	return tipc_node_select_next_hop(addr, selector);
 }
 
-static inline void tipc_node_lock(struct node *n_ptr)
+static inline void tipc_node_lock(struct tipc_node *n_ptr)
 {
 	spin_lock_bh(&n_ptr->lock);
 }
 
-static inline void tipc_node_unlock(struct node *n_ptr)
+static inline void tipc_node_unlock(struct tipc_node *n_ptr)
 {
 	spin_unlock_bh(&n_ptr->lock);
 }
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 8ecbd0f..19194d4 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -44,7 +44,7 @@
  * tipc_nodesub_subscribe - create "node down" subscription for specified node
  */
 
-void tipc_nodesub_subscribe(struct node_subscr *node_sub, u32 addr,
+void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 		       void *usr_handle, net_ev_handler handle_down)
 {
 	if (addr == tipc_own_addr) {
@@ -69,7 +69,7 @@ void tipc_nodesub_subscribe(struct node_subscr *node_sub, u32 addr,
  * tipc_nodesub_unsubscribe - cancel "node down" subscription (if any)
  */
 
-void tipc_nodesub_unsubscribe(struct node_subscr *node_sub)
+void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
 {
 	if (!node_sub->node)
 		return;
diff --git a/net/tipc/node_subscr.h b/net/tipc/node_subscr.h
index 5f3f585..006ed73 100644
--- a/net/tipc/node_subscr.h
+++ b/net/tipc/node_subscr.h
@@ -42,22 +42,22 @@
 typedef void (*net_ev_handler) (void *usr_handle);
 
 /**
- * struct node_subscr - "node down" subscription entry
+ * struct tipc_node_subscr - "node down" subscription entry
  * @node: ptr to node structure of interest (or NULL, if none)
  * @handle_node_down: routine to invoke when node fails
  * @usr_handle: argument to pass to routine when node fails
  * @nodesub_list: adjacent entries in list of subscriptions for the node
  */
 
-struct node_subscr {
-	struct node *node;
+struct tipc_node_subscr {
+	struct tipc_node *node;
 	net_ev_handler handle_node_down;
 	void *usr_handle;
 	struct list_head nodesub_list;
 };
 
-void tipc_nodesub_subscribe(struct node_subscr *node_sub, u32 addr,
+void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 			    void *usr_handle, net_ev_handler handle_down);
-void tipc_nodesub_unsubscribe(struct node_subscr *node_sub);
+void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub);
 
 #endif
diff --git a/net/tipc/port.h b/net/tipc/port.h
index e5f8c16..ff31ee4 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -105,7 +105,7 @@ struct port {
 	u32 probing_interval;
 	u32 last_in_seqno;
 	struct timer_list timer;
-	struct node_subscr subscription;
+	struct tipc_node_subscr subscription;
 };
 
 extern spinlock_t tipc_port_list_lock;
diff --git a/net/tipc/zone.c b/net/tipc/zone.c
index 3506f85..2c01ba2 100644
--- a/net/tipc/zone.c
+++ b/net/tipc/zone.c
@@ -111,10 +111,10 @@ void tipc_zone_send_external_routes(struct _zone *z_ptr, u32 dest)
 	}
 }
 
-struct node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref)
+struct tipc_node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref)
 {
 	struct cluster *c_ptr;
-	struct node *n_ptr;
+	struct tipc_node *n_ptr;
 	u32 c_num;
 
 	if (!z_ptr)
diff --git a/net/tipc/zone.h b/net/tipc/zone.h
index 6e7a08d..7bdc340 100644
--- a/net/tipc/zone.h
+++ b/net/tipc/zone.h
@@ -54,7 +54,7 @@ struct _zone {
 	u32 links;
 };
 
-struct node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref);
+struct tipc_node *tipc_zone_select_remote_node(struct _zone *z_ptr, u32 addr, u32 ref);
 u32 tipc_zone_select_router(struct _zone *z_ptr, u32 addr, u32 ref);
 void tipc_zone_remove_as_router(struct _zone *z_ptr, u32 router);
 void tipc_zone_send_external_routes(struct _zone *z_ptr, u32 dest);
-- 
1.5.6.5.GIT


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
