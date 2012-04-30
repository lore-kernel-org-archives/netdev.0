From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/10] tipc: compress out gratuitous extra carriage returns
Date: Mon, 30 Apr 2012 18:37:08 -0400
Message-ID: <1335825428-16053-11-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35038 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757343Ab2D3Wh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:26 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the comment blocks are floating in limbo between two
functions, or between blocks of code.  Delete the extra line
feeds between any comment and its associated following block
of code, to be consistent with the majority of the rest of
the kernel.  Also delete trailing newlines at EOF and fix
a couple trivial typos in existing comments.

This is a 100% cosmetic change with no runtime impact.  We get
rid of over 500 lines of non-code, and being blank line deletes,
they won't even show up as noise in git blame.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Makefile      |    2 -
 net/tipc/addr.c        |    3 --
 net/tipc/addr.h        |    3 --
 net/tipc/bcast.c       |   22 ---------
 net/tipc/bcast.h       |    3 --
 net/tipc/bearer.c      |   22 +--------
 net/tipc/bearer.h      |    4 --
 net/tipc/config.c      |    7 ---
 net/tipc/core.c        |    7 ---
 net/tipc/core.h        |   14 ------
 net/tipc/discover.c    |   14 ------
 net/tipc/eth_media.c   |   19 --------
 net/tipc/handler.c     |    1 -
 net/tipc/link.c        |  120 ++----------------------------------------------
 net/tipc/link.h        |    6 ---
 net/tipc/log.c         |   14 ------
 net/tipc/log.h         |    1 -
 net/tipc/msg.c         |    3 --
 net/tipc/msg.h         |   21 ---------
 net/tipc/name_distr.c  |   11 -----
 net/tipc/name_table.c  |   50 +++-----------------
 net/tipc/name_table.h  |    3 --
 net/tipc/node.c        |   13 ------
 net/tipc/node.h        |    2 -
 net/tipc/node_subscr.c |    3 --
 net/tipc/node_subscr.h |    1 -
 net/tipc/port.c        |   33 +------------
 net/tipc/port.h        |    3 --
 net/tipc/ref.c         |   13 ------
 net/tipc/socket.c      |   83 +--------------------------------
 net/tipc/subscr.c      |   43 -----------------
 net/tipc/subscr.h      |    2 -
 32 files changed, 16 insertions(+), 530 deletions(-)

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 521d24d..6cd55d6 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -9,5 +9,3 @@ tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
 	   socket.o log.o eth_media.o
-
-# End of file
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index a6fdab3..357b74b 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -45,7 +45,6 @@
  *
  * Returns 1 if domain address is valid, otherwise 0
  */
-
 int tipc_addr_domain_valid(u32 addr)
 {
 	u32 n = tipc_node(addr);
@@ -66,7 +65,6 @@ int tipc_addr_domain_valid(u32 addr)
  *
  * Returns 1 if address can be used, otherwise 0
  */
-
 int tipc_addr_node_valid(u32 addr)
 {
 	return tipc_addr_domain_valid(addr) && tipc_node(addr);
@@ -86,7 +84,6 @@ int tipc_in_scope(u32 domain, u32 addr)
 /**
  * tipc_addr_scope - convert message lookup domain to a 2-bit scope value
  */
-
 int tipc_addr_scope(u32 domain)
 {
 	if (likely(!domain))
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index d706a1d..60b00ab 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -58,7 +58,6 @@ static inline int in_own_cluster_exact(u32 addr)
 /**
  * in_own_node - test for node inclusion; <0.0.0> always matches
  */
-
 static inline int in_own_node(u32 addr)
 {
 	return (addr == tipc_own_addr) || !addr;
@@ -67,7 +66,6 @@ static inline int in_own_node(u32 addr)
 /**
  * in_own_cluster - test for cluster inclusion; <0.0.0> always matches
  */
-
 static inline int in_own_cluster(u32 addr)
 {
 	return in_own_cluster_exact(addr) || !addr;
@@ -79,7 +77,6 @@ static inline int in_own_cluster(u32 addr)
  * Needed when address of a named message must be looked up a second time
  * after a network hop.
  */
-
 static inline u32 addr_domain(u32 sc)
 {
 	if (likely(sc == TIPC_NODE_SCOPE))
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e00441a2..2625f5e 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -73,7 +73,6 @@ struct tipc_bcbearer_pair {
  * large local variables within multicast routines.  Concurrent access is
  * prevented through use of the spinlock "bc_lock".
  */
-
 struct tipc_bcbearer {
 	struct tipc_bearer bearer;
 	struct tipc_media media;
@@ -92,7 +91,6 @@ struct tipc_bcbearer {
  *
  * Handles sequence numbering, fragmentation, bundling, etc.
  */
-
 struct tipc_bclink {
 	struct tipc_link link;
 	struct tipc_node node;
@@ -169,7 +167,6 @@ static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
  *
  * Called with bc_lock locked
  */
-
 struct tipc_node *tipc_bclink_retransmit_to(void)
 {
 	return bclink->retransmit_to;
@@ -182,7 +179,6 @@ struct tipc_node *tipc_bclink_retransmit_to(void)
  *
  * Called with bc_lock locked
  */
-
 static void bclink_retransmit_pkt(u32 after, u32 to)
 {
 	struct sk_buff *buf;
@@ -200,7 +196,6 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  *
  * Node is locked, bc_lock unlocked.
  */
-
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 {
 	struct sk_buff *crs;
@@ -280,7 +275,6 @@ exit:
  *
  * tipc_net_lock and node lock set
  */
-
 void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 {
 	struct sk_buff *buf;
@@ -344,7 +338,6 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
  *
  * Only tipc_net_lock set.
  */
-
 static void bclink_peek_nack(struct tipc_msg *msg)
 {
 	struct tipc_node *n_ptr = tipc_node_find(msg_destnode(msg));
@@ -365,7 +358,6 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 /*
  * tipc_bclink_send_msg - broadcast a packet to all nodes in cluster
  */
-
 int tipc_bclink_send_msg(struct sk_buff *buf)
 {
 	int res;
@@ -394,7 +386,6 @@ exit:
  *
  * Called with both sending node's lock and bc_lock taken.
  */
-
 static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 {
 	bclink_update_last_sent(node, seqno);
@@ -420,7 +411,6 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
  *
  * tipc_net_lock is read_locked, no other locks set
  */
-
 void tipc_bclink_recv_pkt(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
@@ -588,7 +578,6 @@ u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
  * Returns 0 (packet sent successfully) under all circumstances,
  * since the broadcast link's pseudo-bearer never blocks
  */
-
 static int tipc_bcbearer_send(struct sk_buff *buf,
 			      struct tipc_bearer *unused1,
 			      struct tipc_media_addr *unused2)
@@ -601,7 +590,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	 * preparation is skipped for broadcast link protocol messages
 	 * since they are sent in an unreliable manner and don't need it
 	 */
-
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		struct tipc_msg *msg;
 
@@ -618,7 +606,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	}
 
 	/* Send buffer over bearers until all targets reached */
-
 	bcbearer->remains = bclink->bcast_nodes;
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
@@ -660,7 +647,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 /**
  * tipc_bcbearer_sort - create sets of bearer pairs used by broadcast bearer
  */
-
 void tipc_bcbearer_sort(void)
 {
 	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
@@ -671,7 +657,6 @@ void tipc_bcbearer_sort(void)
 	spin_lock_bh(&bc_lock);
 
 	/* Group bearers by priority (can assume max of two per priority) */
-
 	memset(bp_temp, 0, sizeof(bcbearer->bpairs_temp));
 
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
@@ -687,7 +672,6 @@ void tipc_bcbearer_sort(void)
 	}
 
 	/* Create array of bearer pairs for broadcasting */
-
 	bp_curr = bcbearer->bpairs;
 	memset(bcbearer->bpairs, 0, sizeof(bcbearer->bpairs));
 
@@ -817,7 +801,6 @@ void tipc_bclink_stop(void)
 /**
  * tipc_nmap_add - add a node to a node map
  */
-
 void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
@@ -833,7 +816,6 @@ void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 /**
  * tipc_nmap_remove - remove a node from a node map
  */
-
 void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
 {
 	int n = tipc_node(node);
@@ -852,7 +834,6 @@ void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
  * @nm_b: input node map B
  * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
  */
-
 static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 			   struct tipc_node_map *nm_b,
 			   struct tipc_node_map *nm_diff)
@@ -878,7 +859,6 @@ static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 /**
  * tipc_port_list_add - add a port to a port list, ensuring no duplicates
  */
-
 void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
 {
 	struct tipc_port_list *item = pl_ptr;
@@ -912,7 +892,6 @@ void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
  * tipc_port_list_free - free dynamically created entries in port_list chain
  *
  */
-
 void tipc_port_list_free(struct tipc_port_list *pl_ptr)
 {
 	struct tipc_port_list *item;
@@ -923,4 +902,3 @@ void tipc_port_list_free(struct tipc_port_list *pl_ptr)
 		kfree(item);
 	}
 }
-
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 5571394..a933065 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -45,7 +45,6 @@
  * @count: # of nodes in set
  * @map: bitmap of node identifiers that are in the set
  */
-
 struct tipc_node_map {
 	u32 count;
 	u32 map[MAX_NODES / WSIZE];
@@ -59,7 +58,6 @@ struct tipc_node_map {
  * @next: pointer to next entry in list
  * @ports: array of port references
  */
-
 struct tipc_port_list {
 	int count;
 	struct tipc_port_list *next;
@@ -77,7 +75,6 @@ void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 /**
  * tipc_nmap_equal - test for equality of node maps
  */
-
 static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b)
 {
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 0bfdeba..a297e3a 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -53,7 +53,6 @@ static void bearer_disable(struct tipc_bearer *b_ptr);
  *
  * Returns 1 if media name is valid, otherwise 0.
  */
-
 static int media_name_valid(const char *name)
 {
 	u32 len;
@@ -67,7 +66,6 @@ static int media_name_valid(const char *name)
 /**
  * tipc_media_find - locates specified media object by name
  */
-
 struct tipc_media *tipc_media_find(const char *name)
 {
 	u32 i;
@@ -82,7 +80,6 @@ struct tipc_media *tipc_media_find(const char *name)
 /**
  * media_find_id - locates specified media object by type identifier
  */
-
 static struct tipc_media *media_find_id(u8 type)
 {
 	u32 i;
@@ -99,7 +96,6 @@ static struct tipc_media *media_find_id(u8 type)
  *
  * Bearers for this media type must be activated separately at a later stage.
  */
-
 int tipc_register_media(struct tipc_media *m_ptr)
 {
 	int res = -EINVAL;
@@ -134,7 +130,6 @@ exit:
 /**
  * tipc_media_addr_printf - record media address in print buffer
  */
-
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 {
 	char addr_str[MAX_ADDR_STR];
@@ -156,7 +151,6 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 /**
  * tipc_media_get_names - record names of registered media in buffer
  */
-
 struct sk_buff *tipc_media_get_names(void)
 {
 	struct sk_buff *buf;
@@ -183,7 +177,6 @@ struct sk_buff *tipc_media_get_names(void)
  *
  * Returns 1 if bearer name is valid, otherwise 0.
  */
-
 static int bearer_name_validate(const char *name,
 				struct tipc_bearer_names *name_parts)
 {
@@ -194,7 +187,6 @@ static int bearer_name_validate(const char *name,
 	u32 if_len;
 
 	/* copy bearer name & ensure length is OK */
-
 	name_copy[TIPC_MAX_BEARER_NAME - 1] = 0;
 	/* need above in case non-Posix strncpy() doesn't pad with nulls */
 	strncpy(name_copy, name, TIPC_MAX_BEARER_NAME);
@@ -202,7 +194,6 @@ static int bearer_name_validate(const char *name,
 		return 0;
 
 	/* ensure all component parts of bearer name are present */
-
 	media_name = name_copy;
 	if_name = strchr(media_name, ':');
 	if (if_name == NULL)
@@ -212,7 +203,6 @@ static int bearer_name_validate(const char *name,
 	if_len = strlen(if_name) + 1;
 
 	/* validate component parts of bearer name */
-
 	if ((media_len <= 1) || (media_len > TIPC_MAX_MEDIA_NAME) ||
 	    (if_len <= 1) || (if_len > TIPC_MAX_IF_NAME) ||
 	    (strspn(media_name, tipc_alphabet) != (media_len - 1)) ||
@@ -220,7 +210,6 @@ static int bearer_name_validate(const char *name,
 		return 0;
 
 	/* return bearer name components, if necessary */
-
 	if (name_parts) {
 		strcpy(name_parts->media_name, media_name);
 		strcpy(name_parts->if_name, if_name);
@@ -231,7 +220,6 @@ static int bearer_name_validate(const char *name,
 /**
  * tipc_bearer_find - locates bearer object with matching bearer name
  */
-
 struct tipc_bearer *tipc_bearer_find(const char *name)
 {
 	struct tipc_bearer *b_ptr;
@@ -247,7 +235,6 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 /**
  * tipc_bearer_find_interface - locates bearer object with matching interface name
  */
-
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
 {
 	struct tipc_bearer *b_ptr;
@@ -267,7 +254,6 @@ struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
 /**
  * tipc_bearer_get_names - record names of bearers in buffer
  */
-
 struct sk_buff *tipc_bearer_get_names(void)
 {
 	struct sk_buff *buf;
@@ -363,7 +349,6 @@ void tipc_continue(struct tipc_bearer *b_ptr)
  * the bearer is congested. 'tipc_net_lock' is in read_lock here
  * bearer.lock is busy
  */
-
 static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr,
 						struct tipc_link *l_ptr)
 {
@@ -377,7 +362,6 @@ static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr,
  * the bearer is congested. 'tipc_net_lock' is in read_lock here,
  * bearer.lock is free
  */
-
 void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
 {
 	spin_lock_bh(&b_ptr->lock);
@@ -410,7 +394,6 @@ int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr,
 /**
  * tipc_bearer_congested - determines if bearer is currently congested
  */
-
 int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
 {
 	if (unlikely(b_ptr->blocked))
@@ -423,7 +406,6 @@ int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
 /**
  * tipc_enable_bearer - enable bearer with the given name
  */
-
 int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 {
 	struct tipc_bearer *b_ptr;
@@ -541,7 +523,6 @@ exit:
  * tipc_block_bearer(): Block the bearer with the given name,
  *                      and reset all its links
  */
-
 int tipc_block_bearer(const char *name)
 {
 	struct tipc_bearer *b_ptr = NULL;
@@ -573,11 +554,10 @@ int tipc_block_bearer(const char *name)
 }
 
 /**
- * bearer_disable -
+ * bearer_disable
  *
  * Note: This routine assumes caller holds tipc_net_lock.
  */
-
 static void bearer_disable(struct tipc_bearer *b_ptr)
 {
 	struct tipc_link *l_ptr;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index d3eac56..e3b2be3 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -49,7 +49,6 @@
  * - media type identifier located at offset 3
  * - remaining bytes vary according to media type
  */
-
 #define TIPC_MEDIA_ADDR_SIZE	20
 #define TIPC_MEDIA_TYPE_OFFSET	3
 
@@ -64,7 +63,6 @@
  * @media_id: TIPC media type identifier
  * @broadcast: non-zero if address is a broadcast address
  */
-
 struct tipc_media_addr {
 	u8 value[TIPC_MEDIA_ADDR_SIZE];
 	u8 media_id;
@@ -89,7 +87,6 @@ struct tipc_bearer;
  * @type_id: TIPC media identifier
  * @name: media name
  */
-
 struct tipc_media {
 	int (*send_msg)(struct sk_buff *buf,
 			struct tipc_bearer *b_ptr,
@@ -216,7 +213,6 @@ void tipc_bearer_lock_push(struct tipc_bearer *b_ptr);
  * send routine always returns success -- even if the buffer was not sent --
  * and let TIPC's link code deal with the undelivered message.
  */
-
 static inline int tipc_bearer_send(struct tipc_bearer *b_ptr,
 				   struct sk_buff *buf,
 				   struct tipc_media_addr *dest)
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 843d7ae..c5712a3 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -131,7 +131,6 @@ static struct sk_buff *tipc_show_stats(void)
 	tipc_printf(&pb, "TIPC version " TIPC_MOD_VER "\n");
 
 	/* Use additional tipc_printf()'s to return more info ... */
-
 	str_len = tipc_printbuf_validate(&pb);
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
@@ -191,7 +190,6 @@ static struct sk_buff *cfg_set_own_addr(void)
 	 * configuration commands can't be received until a local configuration
 	 * command to enable the first bearer is received and processed.
 	 */
-
 	spin_unlock_bh(&config_lock);
 	tipc_core_start_net(addr);
 	spin_lock_bh(&config_lock);
@@ -283,13 +281,11 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	spin_lock_bh(&config_lock);
 
 	/* Save request and reply details in a well-known location */
-
 	req_tlv_area = request_area;
 	req_tlv_space = request_space;
 	rep_headroom = reply_headroom;
 
 	/* Check command authorization */
-
 	if (likely(in_own_node(orig_node))) {
 		/* command is permitted */
 	} else if (cmd >= 0x8000) {
@@ -310,7 +306,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	}
 
 	/* Call appropriate processing routine */
-
 	switch (cmd) {
 	case TIPC_CMD_NOOP:
 		rep_tlv_buf = tipc_cfg_reply_none();
@@ -433,7 +428,6 @@ static void cfg_named_msg_event(void *userdata,
 	struct sk_buff *rep_buf;
 
 	/* Validate configuration message header (ignore invalid message) */
-
 	req_hdr = (struct tipc_cfg_msg_hdr *)msg;
 	if ((size < sizeof(*req_hdr)) ||
 	    (size != TCM_ALIGN(ntohl(req_hdr->tcm_len))) ||
@@ -443,7 +437,6 @@ static void cfg_named_msg_event(void *userdata,
 	}
 
 	/* Generate reply for request (if can't, return request) */
-
 	rep_buf = tipc_cfg_do_cmd(orig->node,
 				  ntohs(req_hdr->tcm_type),
 				  msg + sizeof(*req_hdr),
diff --git a/net/tipc/core.c b/net/tipc/core.c
index ba08940..f7b9523 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -52,14 +52,12 @@
 #endif
 
 /* global variables used by multiple sub-systems within TIPC */
-
 int tipc_random;
 
 const char tipc_alphabet[] =
 	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
 
 /* configurable TIPC parameters */
-
 u32 tipc_own_addr;
 int tipc_max_ports;
 int tipc_max_subscriptions;
@@ -77,7 +75,6 @@ int tipc_remote_management;
  * NOTE: Headroom is reserved to allow prepending of a data link header.
  *       There may also be unrequested tailroom present at the buffer's end.
  */
-
 struct sk_buff *tipc_buf_acquire(u32 size)
 {
 	struct sk_buff *skb;
@@ -95,7 +92,6 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 /**
  * tipc_core_stop_net - shut down TIPC networking sub-systems
  */
-
 static void tipc_core_stop_net(void)
 {
 	tipc_net_stop();
@@ -105,7 +101,6 @@ static void tipc_core_stop_net(void)
 /**
  * start_net - start TIPC networking sub-systems
  */
-
 int tipc_core_start_net(unsigned long addr)
 {
 	int res;
@@ -121,7 +116,6 @@ int tipc_core_start_net(unsigned long addr)
 /**
  * tipc_core_stop - switch TIPC from SINGLE NODE to NOT RUNNING mode
  */
-
 static void tipc_core_stop(void)
 {
 	tipc_netlink_stop();
@@ -137,7 +131,6 @@ static void tipc_core_stop(void)
 /**
  * tipc_core_start - switch TIPC from NOT RUNNING to SINGLE NODE mode
  */
-
 static int tipc_core_start(void)
 {
 	int res;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 13837e0..2a9bb99 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -85,7 +85,6 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 /*
  * TIPC_OUTPUT is the destination print buffer for system messages.
  */
-
 #ifndef TIPC_OUTPUT
 #define TIPC_OUTPUT TIPC_LOG
 #endif
@@ -102,7 +101,6 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 /*
  * DBG_OUTPUT is the destination print buffer for debug messages.
  */
-
 #ifndef DBG_OUTPUT
 #define DBG_OUTPUT TIPC_LOG
 #endif
@@ -126,13 +124,11 @@ void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 /*
  * TIPC-specific error codes
  */
-
 #define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
 
 /*
  * Global configuration variables
  */
-
 extern u32 tipc_own_addr;
 extern int tipc_max_ports;
 extern int tipc_max_subscriptions;
@@ -143,7 +139,6 @@ extern int tipc_remote_management;
 /*
  * Other global variables
  */
-
 extern int tipc_random;
 extern const char tipc_alphabet[];
 
@@ -151,7 +146,6 @@ extern const char tipc_alphabet[];
 /*
  * Routines available to privileged subsystems
  */
-
 extern int tipc_core_start_net(unsigned long);
 extern int  tipc_handler_start(void);
 extern void tipc_handler_stop(void);
@@ -163,7 +157,6 @@ extern void tipc_socket_stop(void);
 /*
  * TIPC timer and signal code
  */
-
 typedef void (*Handler) (unsigned long);
 
 u32 tipc_k_signal(Handler routine, unsigned long argument);
@@ -176,7 +169,6 @@ u32 tipc_k_signal(Handler routine, unsigned long argument);
  *
  * Timer must be initialized before use (and terminated when no longer needed).
  */
-
 static inline void k_init_timer(struct timer_list *timer, Handler routine,
 				unsigned long argument)
 {
@@ -196,7 +188,6 @@ static inline void k_init_timer(struct timer_list *timer, Handler routine,
  * then an additional jiffy is added to account for the fact that
  * the starting time may be in the middle of the current jiffy.
  */
-
 static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
 {
 	mod_timer(timer, jiffies + msecs_to_jiffies(msec) + 1);
@@ -212,7 +203,6 @@ static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
  * WARNING: Must not be called when holding locks required by the timer's
  *          timeout routine, otherwise deadlock can occur on SMP systems!
  */
-
 static inline void k_cancel_timer(struct timer_list *timer)
 {
 	del_timer_sync(timer);
@@ -229,12 +219,10 @@ static inline void k_cancel_timer(struct timer_list *timer)
  * (Do not "enhance" this routine to automatically cancel an active timer,
  * otherwise deadlock can arise when a timeout routine calls k_term_timer.)
  */
-
 static inline void k_term_timer(struct timer_list *timer)
 {
 }
 
-
 /*
  * TIPC message buffer code
  *
@@ -244,7 +232,6 @@ static inline void k_term_timer(struct timer_list *timer)
  * Note: Headroom should be a multiple of 4 to ensure the TIPC header fields
  *       are word aligned for quicker access
  */
-
 #define BUF_HEADROOM LL_MAX_HEADER
 
 struct tipc_skb_cb {
@@ -253,7 +240,6 @@ struct tipc_skb_cb {
 
 #define TIPC_SKB_CB(__skb) ((struct tipc_skb_cb *)&((__skb)->cb[0]))
 
-
 static inline struct tipc_msg *buf_msg(struct sk_buff *skb)
 {
 	return (struct tipc_msg *)skb->data;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index c630a21..ae054cf 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -70,7 +70,6 @@ struct tipc_link_req {
  * @dest_domain: network domain of node(s) which should respond to message
  * @b_ptr: ptr to bearer issuing message
  */
-
 static struct sk_buff *tipc_disc_init_msg(u32 type,
 					  u32 dest_domain,
 					  struct tipc_bearer *b_ptr)
@@ -96,7 +95,6 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
  * @node_addr: duplicated node address
  * @media_addr: media address advertised by duplicated node
  */
-
 static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 			    struct tipc_media_addr *media_addr)
 {
@@ -117,7 +115,6 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
  * @buf: buffer containing message
  * @b_ptr: bearer that message arrived on
  */
-
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 {
 	struct tipc_node *n_ptr;
@@ -221,7 +218,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	 * the new media address and reset the link to ensure it starts up
 	 * cleanly.
 	 */
-
 	if (addr_mismatch) {
 		if (tipc_link_is_up(link)) {
 			disc_dupl_alert(b_ptr, orig, &media_addr);
@@ -264,7 +260,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
  * Reinitiates discovery process if discovery object has no associated nodes
  * and is either not currently searching or is searching at a slow rate
  */
-
 static void disc_update(struct tipc_link_req *req)
 {
 	if (!req->num_nodes) {
@@ -280,7 +275,6 @@ static void disc_update(struct tipc_link_req *req)
  * tipc_disc_add_dest - increment set of discovered nodes
  * @req: ptr to link request structure
  */
-
 void tipc_disc_add_dest(struct tipc_link_req *req)
 {
 	req->num_nodes++;
@@ -290,7 +284,6 @@ void tipc_disc_add_dest(struct tipc_link_req *req)
  * tipc_disc_remove_dest - decrement set of discovered nodes
  * @req: ptr to link request structure
  */
-
 void tipc_disc_remove_dest(struct tipc_link_req *req)
 {
 	req->num_nodes--;
@@ -301,7 +294,6 @@ void tipc_disc_remove_dest(struct tipc_link_req *req)
  * disc_send_msg - send link setup request message
  * @req: ptr to link request structure
  */
-
 static void disc_send_msg(struct tipc_link_req *req)
 {
 	if (!req->bearer->blocked)
@@ -314,7 +306,6 @@ static void disc_send_msg(struct tipc_link_req *req)
  *
  * Called whenever a link setup request timer associated with a bearer expires.
  */
-
 static void disc_timeout(struct tipc_link_req *req)
 {
 	int max_delay;
@@ -322,7 +313,6 @@ static void disc_timeout(struct tipc_link_req *req)
 	spin_lock_bh(&req->bearer->lock);
 
 	/* Stop searching if only desired node has been found */
-
 	if (tipc_node(req->domain) && req->num_nodes) {
 		req->timer_intv = TIPC_LINK_REQ_INACTIVE;
 		goto exit;
@@ -335,7 +325,6 @@ static void disc_timeout(struct tipc_link_req *req)
 	 * hold at fast polling rate if don't have any associated nodes,
 	 * otherwise hold at slow polling rate
 	 */
-
 	disc_send_msg(req);
 
 	req->timer_intv *= 2;
@@ -359,7 +348,6 @@ exit:
  *
  * Returns 0 if successful, otherwise -errno.
  */
-
 int tipc_disc_create(struct tipc_bearer *b_ptr,
 		     struct tipc_media_addr *dest, u32 dest_domain)
 {
@@ -391,7 +379,6 @@ int tipc_disc_create(struct tipc_bearer *b_ptr,
  * tipc_disc_delete - destroy object sending periodic link setup requests
  * @req: ptr to link request structure
  */
-
 void tipc_disc_delete(struct tipc_link_req *req)
 {
 	k_cancel_timer(&req->timer);
@@ -399,4 +386,3 @@ void tipc_disc_delete(struct tipc_link_req *req)
 	kfree_skb(req->buf);
 	kfree(req);
 }
-
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 527e3f0..90ac9bf 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -48,7 +48,6 @@
  * @tipc_packet_type: used in binding TIPC to Ethernet driver
  * @cleanup: work item used when disabling bearer
  */
-
 struct eth_bearer {
 	struct tipc_bearer *bearer;
 	struct net_device *dev;
@@ -67,7 +66,6 @@ static struct notifier_block notifier;
  * Media-dependent "value" field stores MAC address in first 6 bytes
  * and zeroes out the remaining bytes.
  */
-
 static void eth_media_addr_set(struct tipc_media_addr *a, char *mac)
 {
 	memcpy(a->value, mac, ETH_ALEN);
@@ -79,7 +77,6 @@ static void eth_media_addr_set(struct tipc_media_addr *a, char *mac)
 /**
  * send_msg - send a TIPC message out over an Ethernet interface
  */
-
 static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 		    struct tipc_media_addr *dest)
 {
@@ -115,7 +112,6 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
  * ignores packets sent using Ethernet multicast, and traffic sent to other
  * nodes (which can happen if interface is running in promiscuous mode).
  */
-
 static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 		    struct packet_type *pt, struct net_device *orig_dev)
 {
@@ -140,7 +136,6 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 /**
  * enable_bearer - attach TIPC bearer to an Ethernet interface
  */
-
 static int enable_bearer(struct tipc_bearer *tb_ptr)
 {
 	struct net_device *dev = NULL;
@@ -151,7 +146,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	int pending_dev = 0;
 
 	/* Find unused Ethernet bearer structure */
-
 	while (eb_ptr->dev) {
 		if (!eb_ptr->bearer)
 			pending_dev++;
@@ -160,7 +154,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	}
 
 	/* Find device with specified name */
-
 	read_lock(&dev_base_lock);
 	for_each_netdev(&init_net, pdev) {
 		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
@@ -174,7 +167,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 		return -ENODEV;
 
 	/* Create Ethernet bearer for device */
-
 	eb_ptr->dev = dev;
 	eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
 	eb_ptr->tipc_packet_type.dev = dev;
@@ -184,7 +176,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	dev_add_pack(&eb_ptr->tipc_packet_type);
 
 	/* Associate TIPC bearer with Ethernet bearer */
-
 	eb_ptr->bearer = tb_ptr;
 	tb_ptr->usr_handle = (void *)eb_ptr;
 	tb_ptr->mtu = dev->mtu;
@@ -198,7 +189,6 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
  *
  * This routine must be invoked from a work queue because it can sleep.
  */
-
 static void cleanup_bearer(struct work_struct *work)
 {
 	struct eth_bearer *eb_ptr =
@@ -216,7 +206,6 @@ static void cleanup_bearer(struct work_struct *work)
  * then get worker thread to complete bearer cleanup.  (Can't do cleanup
  * here because cleanup code needs to sleep and caller holds spinlocks.)
  */
-
 static void disable_bearer(struct tipc_bearer *tb_ptr)
 {
 	struct eth_bearer *eb_ptr = (struct eth_bearer *)tb_ptr->usr_handle;
@@ -232,7 +221,6 @@ static void disable_bearer(struct tipc_bearer *tb_ptr)
  * Change the state of the Ethernet bearer (if any) associated with the
  * specified device.
  */
-
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
 			     void *dv)
 {
@@ -281,7 +269,6 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 /**
  * eth_addr2str - convert Ethernet address to string
  */
-
 static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 {
 	if (str_size < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
@@ -294,7 +281,6 @@ static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 /**
  * eth_str2addr - convert string to Ethernet address
  */
-
 static int eth_str2addr(struct tipc_media_addr *a, char *str_buf)
 {
 	char mac[ETH_ALEN];
@@ -314,7 +300,6 @@ static int eth_str2addr(struct tipc_media_addr *a, char *str_buf)
 /**
  * eth_str2addr - convert Ethernet address format to message header format
  */
-
 static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 {
 	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
@@ -326,7 +311,6 @@ static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 /**
  * eth_str2addr - convert message header address format to Ethernet format
  */
-
 static int eth_msg2addr(struct tipc_media_addr *a, char *msg_area)
 {
 	if (msg_area[TIPC_MEDIA_TYPE_OFFSET] != TIPC_MEDIA_TYPE_ETH)
@@ -339,7 +323,6 @@ static int eth_msg2addr(struct tipc_media_addr *a, char *msg_area)
 /*
  * Ethernet media registration info
  */
-
 static struct tipc_media eth_media_info = {
 	.send_msg	= send_msg,
 	.enable_bearer	= enable_bearer,
@@ -363,7 +346,6 @@ static struct tipc_media eth_media_info = {
  * Register Ethernet media type with TIPC bearer code.  Also register
  * with OS for notifications about device state changes.
  */
-
 int tipc_eth_media_start(void)
 {
 	int res;
@@ -386,7 +368,6 @@ int tipc_eth_media_start(void)
 /**
  * tipc_eth_media_stop - deactivate Ethernet bearer support
  */
-
 void tipc_eth_media_stop(void)
 {
 	if (!eth_started)
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 274c98e..9c6f22f 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -129,4 +129,3 @@ void tipc_handler_stop(void)
 
 	kmem_cache_destroy(tipc_queue_item_cache);
 }
-
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 33cecd6..7a614f4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -45,13 +45,11 @@
 /*
  * Out-of-range value for link session numbers
  */
-
 #define INVALID_SESSION 0x10000
 
 /*
  * Link state events:
  */
-
 #define  STARTING_EVT    856384768	/* link processing trigger */
 #define  TRAFFIC_MSG_EVT 560815u	/* rx'd ??? */
 #define  TIMEOUT_EVT     560817u	/* link timer expired */
@@ -67,7 +65,6 @@
 /*
  * State value stored in 'exp_msg_count'
  */
-
 #define START_CHANGEOVER 100000u
 
 /**
@@ -77,7 +74,6 @@
  * @addr_peer: network address of node at far end
  * @if_peer: name of interface at far end
  */
-
 struct tipc_link_name {
 	u32 addr_local;
 	char if_local[TIPC_MAX_IF_NAME];
@@ -105,7 +101,6 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
 /*
  *  Simple link routines
  */
-
 static unsigned int align(unsigned int i)
 {
 	return (i + 3) & ~3u;
@@ -143,7 +138,6 @@ static u32 link_last_sent(struct tipc_link *l_ptr)
 /*
  *  Simple non-static link routines (i.e. referenced outside this file)
  */
-
 int tipc_link_is_up(struct tipc_link *l_ptr)
 {
 	if (!l_ptr)
@@ -164,7 +158,6 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
  *
  * Returns 1 if link name is valid, otherwise 0.
  */
-
 static int link_name_validate(const char *name,
 				struct tipc_link_name *name_parts)
 {
@@ -180,7 +173,6 @@ static int link_name_validate(const char *name,
 	u32 if_peer_len;
 
 	/* copy link name & ensure length is OK */
-
 	name_copy[TIPC_MAX_LINK_NAME - 1] = 0;
 	/* need above in case non-Posix strncpy() doesn't pad with nulls */
 	strncpy(name_copy, name, TIPC_MAX_LINK_NAME);
@@ -188,7 +180,6 @@ static int link_name_validate(const char *name,
 		return 0;
 
 	/* ensure all component parts of link name are present */
-
 	addr_local = name_copy;
 	if_local = strchr(addr_local, ':');
 	if (if_local == NULL)
@@ -206,7 +197,6 @@ static int link_name_validate(const char *name,
 	if_peer_len = strlen(if_peer) + 1;
 
 	/* validate component parts of link name */
-
 	if ((sscanf(addr_local, "%u.%u.%u%c",
 		    &z_local, &c_local, &n_local, &dummy) != 3) ||
 	    (sscanf(addr_peer, "%u.%u.%u%c",
@@ -220,7 +210,6 @@ static int link_name_validate(const char *name,
 		return 0;
 
 	/* return link name components, if necessary */
-
 	if (name_parts) {
 		name_parts->addr_local = tipc_addr(z_local, c_local, n_local);
 		strcpy(name_parts->if_local, if_local);
@@ -239,13 +228,11 @@ static int link_name_validate(const char *name,
  * another thread because tipc_link_delete() always cancels the link timer before
  * tipc_node_delete() is called.)
  */
-
 static void link_timeout(struct tipc_link *l_ptr)
 {
 	tipc_node_lock(l_ptr->owner);
 
 	/* update counters used in statistical profiling of send traffic */
-
 	l_ptr->stats.accu_queue_sz += l_ptr->out_queue_size;
 	l_ptr->stats.queue_sz_counts++;
 
@@ -278,7 +265,6 @@ static void link_timeout(struct tipc_link *l_ptr)
 	}
 
 	/* do all other link processing performed on a periodic basis */
-
 	link_check_defragm_bufs(l_ptr);
 
 	link_state_event(l_ptr, TIMEOUT_EVT);
@@ -302,7 +288,6 @@ static void link_set_timer(struct tipc_link *l_ptr, u32 time)
  *
  * Returns pointer to link.
  */
-
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr)
@@ -383,7 +368,6 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
  * This routine must not grab the node lock until after link timer cancellation
  * to avoid a potential deadlock situation.
  */
-
 void tipc_link_delete(struct tipc_link *l_ptr)
 {
 	if (!l_ptr) {
@@ -419,7 +403,6 @@ static void link_start(struct tipc_link *l_ptr)
  * Schedules port for renewed sending of messages after link congestion
  * has abated.
  */
-
 static int link_schedule_port(struct tipc_link *l_ptr, u32 origport, u32 sz)
 {
 	struct tipc_port *p_ptr;
@@ -476,7 +459,6 @@ exit:
  * link_release_outqueue - purge link's outbound message queue
  * @l_ptr: pointer to link
  */
-
 static void link_release_outqueue(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->first_out;
@@ -495,7 +477,6 @@ static void link_release_outqueue(struct tipc_link *l_ptr)
  * tipc_link_reset_fragments - purge link's inbound message fragments queue
  * @l_ptr: pointer to link
  */
-
 void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->defragm_buf;
@@ -513,7 +494,6 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
  * tipc_link_stop - purge all inbound and outbound messages associated with link
  * @l_ptr: pointer to link
  */
-
 void tipc_link_stop(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf;
@@ -569,7 +549,6 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	}
 
 	/* Clean up all queues: */
-
 	link_release_outqueue(l_ptr);
 	kfree_skb(l_ptr->proto_msg_queue);
 	l_ptr->proto_msg_queue = NULL;
@@ -611,7 +590,6 @@ static void link_activate(struct tipc_link *l_ptr)
  * @l_ptr: pointer to link
  * @event: state machine event to process
  */
-
 static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 {
 	struct tipc_link *other;
@@ -785,7 +763,6 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
  * link_bundle_buf(): Append contents of a buffer to
  * the tail of an existing one.
  */
-
 static int link_bundle_buf(struct tipc_link *l_ptr,
 			   struct sk_buff *bundler,
 			   struct sk_buff *buf)
@@ -860,7 +837,6 @@ static void link_add_chain_to_outqueue(struct tipc_link *l_ptr,
  * inside TIPC when the 'fast path' in tipc_send_buf
  * has failed, and from link_send()
  */
-
 int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
@@ -872,7 +848,6 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	u32 max_packet = l_ptr->max_pkt;
 
 	/* Match msg importance against queue limits: */
-
 	if (unlikely(queue_size >= queue_limit)) {
 		if (imp <= TIPC_CRITICAL_IMPORTANCE) {
 			link_schedule_port(l_ptr, msg_origport(msg), size);
@@ -888,12 +863,10 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	}
 
 	/* Fragmentation needed ? */
-
 	if (size > max_packet)
 		return link_send_long_buf(l_ptr, buf);
 
-	/* Packet can be queued or sent: */
-
+	/* Packet can be queued or sent. */
 	if (likely(!tipc_bearer_congested(l_ptr->b_ptr, l_ptr) &&
 		   !link_congested(l_ptr))) {
 		link_add_to_outqueue(l_ptr, buf, msg);
@@ -907,13 +880,11 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 		return dsz;
 	}
-	/* Congestion: can message be bundled ?: */
-
+	/* Congestion: can message be bundled ? */
 	if ((msg_user(msg) != CHANGEOVER_PROTOCOL) &&
 	    (msg_user(msg) != MSG_FRAGMENTER)) {
 
 		/* Try adding message to an existing bundle */
-
 		if (l_ptr->next_out &&
 		    link_bundle_buf(l_ptr, l_ptr->last_out, buf)) {
 			tipc_bearer_resolve_congestion(l_ptr->b_ptr, l_ptr);
@@ -921,7 +892,6 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 
 		/* Try creating a new bundle */
-
 		if (size <= max_packet * 2 / 3) {
 			struct sk_buff *bundler = tipc_buf_acquire(max_packet);
 			struct tipc_msg bundler_hdr;
@@ -951,7 +921,6 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
  * not been selected yet, and the the owner node is not locked
  * Called by TIPC internal users, e.g. the name distributor
  */
-
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 {
 	struct tipc_link *l_ptr;
@@ -984,7 +953,6 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
  * small enough not to require fragmentation.
  * Called without any locks held.
  */
-
 void tipc_link_send_names(struct list_head *message_list, u32 dest)
 {
 	struct tipc_node *n_ptr;
@@ -1013,7 +981,6 @@ void tipc_link_send_names(struct list_head *message_list, u32 dest)
 	read_unlock_bh(&tipc_net_lock);
 
 	/* discard the messages if they couldn't be sent */
-
 	list_for_each_safe(buf, temp_buf, ((struct sk_buff *)message_list)) {
 		list_del((struct list_head *)buf);
 		kfree_skb(buf);
@@ -1026,7 +993,6 @@ void tipc_link_send_names(struct list_head *message_list, u32 dest)
  * inclusive total message length. Very time critical.
  * Link is locked. Returns user data length.
  */
-
 static int link_send_buf_fast(struct tipc_link *l_ptr, struct sk_buff *buf,
 			      u32 *used_max_pkt)
 {
@@ -1111,7 +1077,6 @@ again:
 	 * Try building message using port's max_pkt hint.
 	 * (Must not hold any locks while building message.)
 	 */
-
 	res = tipc_msg_build(hdr, msg_sect, num_sect, total_len,
 			     sender->max_pkt, !sender->user_port, &buf);
 
@@ -1131,12 +1096,10 @@ exit:
 			}
 
 			/* Exit if build request was invalid */
-
 			if (unlikely(res < 0))
 				goto exit;
 
 			/* Exit if link (or bearer) is congested */
-
 			if (link_congested(l_ptr) ||
 			    !list_empty(&l_ptr->b_ptr->cong_links)) {
 				res = link_schedule_port(l_ptr,
@@ -1148,7 +1111,6 @@ exit:
 			 * Message size exceeds max_pkt hint; update hint,
 			 * then re-try fast path or fragment the message
 			 */
-
 			sender->max_pkt = l_ptr->max_pkt;
 			tipc_node_unlock(node);
 			read_unlock_bh(&tipc_net_lock);
@@ -1166,7 +1128,6 @@ exit:
 	read_unlock_bh(&tipc_net_lock);
 
 	/* Couldn't find a link to the destination node */
-
 	if (buf)
 		return tipc_reject_msg(buf, TIPC_ERR_NO_NODE);
 	if (res >= 0)
@@ -1220,15 +1181,13 @@ again:
 	sect_crs = NULL;
 	curr_sect = -1;
 
-	/* Prepare reusable fragment header: */
-
+	/* Prepare reusable fragment header */
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, msg_destnode(hdr));
 	msg_set_size(&fragm_hdr, max_pkt);
 	msg_set_fragm_no(&fragm_hdr, 1);
 
-	/* Prepare header of first fragment: */
-
+	/* Prepare header of first fragment */
 	buf_chain = buf = tipc_buf_acquire(max_pkt);
 	if (!buf)
 		return -ENOMEM;
@@ -1237,8 +1196,7 @@ again:
 	hsz = msg_hdr_sz(hdr);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, hdr, hsz);
 
-	/* Chop up message: */
-
+	/* Chop up message */
 	fragm_crs = INT_H_SIZE + hsz;
 	fragm_rest = fragm_sz - hsz;
 
@@ -1329,7 +1287,6 @@ reject:
 	}
 
 	/* Append chain of fragments to send queue & send them */
-
 	l_ptr->long_msg_seq_no++;
 	link_add_chain_to_outqueue(l_ptr, buf_chain, l_ptr->long_msg_seq_no);
 	l_ptr->stats.sent_fragments += fragm_no;
@@ -1350,7 +1307,6 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 
 	/* Step to position where retransmission failed, if any,    */
 	/* consider that buffers may have been released in meantime */
-
 	if (r_q_size && buf) {
 		u32 last = lesser(mod(r_q_head + r_q_size),
 				  link_last_sent(l_ptr));
@@ -1365,7 +1321,6 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	}
 
 	/* Continue retransmission now, if there is anything: */
-
 	if (r_q_size && buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
@@ -1381,7 +1336,6 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	}
 
 	/* Send deferred protocol message, if any: */
-
 	buf = l_ptr->proto_msg_queue;
 	if (buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
@@ -1398,7 +1352,6 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	}
 
 	/* Send one deferred data message, if send window not full: */
-
 	buf = l_ptr->next_out;
 	if (buf) {
 		struct tipc_msg *msg = buf_msg(buf);
@@ -1478,16 +1431,12 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 	warn("Retransmission failure on link <%s>\n", l_ptr->name);
 
 	if (l_ptr->addr) {
-
 		/* Handle failure on standard link */
-
 		link_print(l_ptr, "Resetting link\n");
 		tipc_link_reset(l_ptr);
 
 	} else {
-
 		/* Handle failure on broadcast link */
-
 		struct tipc_node *n_ptr;
 		char addr_string[16];
 
@@ -1536,7 +1485,6 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		return;
 	} else {
 		/* Detect repeated retransmit failures on uncongested bearer */
-
 		if (l_ptr->last_retransmitted == msg_seqno(msg)) {
 			if (++l_ptr->stale_count > 100) {
 				link_retransmit_failure(l_ptr, buf);
@@ -1571,7 +1519,6 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 /**
  * link_insert_deferred_queue - insert deferred messages back into receive chain
  */
-
 static struct sk_buff *link_insert_deferred_queue(struct tipc_link *l_ptr,
 						  struct sk_buff *buf)
 {
@@ -1602,7 +1549,6 @@ static struct sk_buff *link_insert_deferred_queue(struct tipc_link *l_ptr,
  * TIPC will ignore the excess, under the assumption that it is optional info
  * introduced by a later release of the protocol.
  */
-
 static int link_recv_buf_validate(struct sk_buff *buf)
 {
 	static u32 min_data_hdr_size[8] = {
@@ -1648,7 +1594,6 @@ static int link_recv_buf_validate(struct sk_buff *buf)
  * Invoked with no locks held.  Bearer pointer must point to a valid bearer
  * structure (i.e. cannot be NULL), but bearer can be inactive.
  */
-
 void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
@@ -1666,22 +1611,18 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		head = head->next;
 
 		/* Ensure bearer is still enabled */
-
 		if (unlikely(!b_ptr->active))
 			goto cont;
 
 		/* Ensure message is well-formed */
-
 		if (unlikely(!link_recv_buf_validate(buf)))
 			goto cont;
 
 		/* Ensure message data is a single contiguous unit */
-
 		if (unlikely(skb_linearize(buf)))
 			goto cont;
 
 		/* Handle arrival of a non-unicast link message */
-
 		msg = buf_msg(buf);
 
 		if (unlikely(msg_non_seq(msg))) {
@@ -1693,20 +1634,17 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Discard unicast link messages destined for another node */
-
 		if (unlikely(!msg_short(msg) &&
 			     (msg_destnode(msg) != tipc_own_addr)))
 			goto cont;
 
 		/* Locate neighboring node that sent message */
-
 		n_ptr = tipc_node_find(msg_prevnode(msg));
 		if (unlikely(!n_ptr))
 			goto cont;
 		tipc_node_lock(n_ptr);
 
 		/* Locate unicast link endpoint that should handle message */
-
 		l_ptr = n_ptr->links[b_ptr->identity];
 		if (unlikely(!l_ptr)) {
 			tipc_node_unlock(n_ptr);
@@ -1714,7 +1652,6 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Verify that communication with node is currently allowed */
-
 		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
 			msg_user(msg) == LINK_PROTOCOL &&
 			(msg_type(msg) == RESET_MSG ||
@@ -1728,12 +1665,10 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Validate message sequence number info */
-
 		seq_no = msg_seqno(msg);
 		ackd = msg_ack(msg);
 
 		/* Release acked messages */
-
 		if (n_ptr->bclink.supported)
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
@@ -1752,7 +1687,6 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Try sending any messages link endpoint has pending */
-
 		if (unlikely(l_ptr->next_out))
 			tipc_link_push_queue(l_ptr);
 		if (unlikely(!list_empty(&l_ptr->waiting_ports)))
@@ -1763,7 +1697,6 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		}
 
 		/* Now (finally!) process the incoming message */
-
 protocol_check:
 		if (likely(link_working_working(l_ptr))) {
 			if (likely(seq_no == mod(l_ptr->next_in_no))) {
@@ -1859,7 +1792,6 @@ cont:
  *
  * Returns increase in queue length (i.e. 0 or 1)
  */
-
 u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 			struct sk_buff *buf)
 {
@@ -1908,7 +1840,6 @@ u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 /*
  * link_handle_out_of_seq_msg - handle arrival of out-of-sequence packet
  */
-
 static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf)
 {
@@ -1920,14 +1851,12 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 	}
 
 	/* Record OOS packet arrival (force mismatch on next timeout) */
-
 	l_ptr->checkpoint--;
 
 	/*
 	 * Discard packet if a duplicate; otherwise add it to deferred queue
 	 * and notify peer of gap as per protocol specification
 	 */
-
 	if (less(seq_no, mod(l_ptr->next_in_no))) {
 		l_ptr->stats.duplicates++;
 		kfree_skb(buf);
@@ -1957,7 +1886,6 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	int r_flag;
 
 	/* Discard any previous message that was deferred due to congestion */
-
 	if (l_ptr->proto_msg_queue) {
 		kfree_skb(l_ptr->proto_msg_queue);
 		l_ptr->proto_msg_queue = NULL;
@@ -1967,12 +1895,10 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 		return;
 
 	/* Abort non-RESET send if communication with node is prohibited */
-
 	if ((l_ptr->owner->block_setup) && (msg_typ != RESET_MSG))
 		return;
 
 	/* Create protocol message with "out-of-sequence" sequence number */
-
 	msg_set_type(msg, msg_typ);
 	msg_set_net_plane(msg, l_ptr->b_ptr->net_plane);
 	msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
@@ -2040,14 +1966,12 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 
 	/* Defer message if bearer is already congested */
-
 	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
 		l_ptr->proto_msg_queue = buf;
 		return;
 	}
 
 	/* Defer message if attempting to send results in bearer congestion */
-
 	if (!tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
 		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
 		l_ptr->proto_msg_queue = buf;
@@ -2056,7 +1980,6 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	}
 
 	/* Discard message if it was sent successfully */
-
 	l_ptr->unacked_window = 0;
 	kfree_skb(buf);
 }
@@ -2066,7 +1989,6 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
  * Note that network plane id propagates through the network, and may
  * change at any time. The node with lowest address rules
  */
-
 static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 {
 	u32 rec_gap = 0;
@@ -2079,7 +2001,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		goto exit;
 
 	/* record unnumbered packet arrival (force mismatch on next timeout) */
-
 	l_ptr->checkpoint--;
 
 	if (l_ptr->b_ptr->net_plane != msg_net_plane(msg))
@@ -2111,7 +2032,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		/* fall thru' */
 	case ACTIVATE_MSG:
 		/* Update link settings according other endpoint's values */
-
 		strcpy((strrchr(l_ptr->name, ':') + 1), (char *)msg_data(msg));
 
 		msg_tol = msg_link_tolerance(msg);
@@ -2133,7 +2053,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		l_ptr->owner->bclink.supportable = (max_pkt_info != 0);
 
 		/* Synchronize broadcast link info, if not done previously */
-
 		if (!tipc_node_is_up(l_ptr->owner)) {
 			l_ptr->owner->bclink.last_sent =
 				l_ptr->owner->bclink.last_in =
@@ -2185,7 +2104,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 
 		/* Protocol message before retransmits, reduce loss risk */
-
 		if (l_ptr->owner->bclink.supported)
 			tipc_bclink_update_link_state(l_ptr->owner,
 						      msg_last_bcast(msg));
@@ -2243,7 +2161,6 @@ static void tipc_link_tunnel(struct tipc_link *l_ptr,
  * changeover(): Send whole message queue via the remaining link
  *               Owner node is locked.
  */
-
 void tipc_link_changeover(struct tipc_link *l_ptr)
 {
 	u32 msgcount = l_ptr->out_queue_size;
@@ -2343,8 +2260,6 @@ void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *tunnel)
 	}
 }
 
-
-
 /**
  * buf_extract - extracts embedded TIPC message from another message
  * @skb: encapsulating message buffer
@@ -2353,7 +2268,6 @@ void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *tunnel)
  * Returns a new message buffer containing an embedded message.  The
  * encapsulating message itself is left unchanged.
  */
-
 static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 {
 	struct tipc_msg *msg = (struct tipc_msg *)(skb->data + from_pos);
@@ -2370,7 +2284,6 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
  *  link_recv_changeover_msg(): Receive tunneled packet sent
  *  via other link. Node is locked. Return extracted buffer.
  */
-
 static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 				    struct sk_buff **buf)
 {
@@ -2405,7 +2318,6 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	}
 
 	/* First original message ?: */
-
 	if (tipc_link_is_up(dest_link)) {
 		info("Resetting link <%s>, changeover initiated by peer\n",
 		     dest_link->name);
@@ -2420,7 +2332,6 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	}
 
 	/* Receive original message */
-
 	if (dest_link->exp_msg_count == 0) {
 		warn("Link switchover error, "
 		     "got too many tunnelled messages\n");
@@ -2469,7 +2380,6 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
  *  Fragmentation/defragmentation:
  */
 
-
 /*
  * link_send_long_buf: Entry for buffers needing fragmentation.
  * The buffer is complete, inclusive total message length.
@@ -2496,12 +2406,10 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		destaddr = msg_destnode(inmsg);
 
 	/* Prepare reusable fragment header: */
-
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, destaddr);
 
 	/* Chop up message: */
-
 	while (rest > 0) {
 		struct sk_buff *fragm;
 
@@ -2535,7 +2443,6 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	kfree_skb(buf);
 
 	/* Append chain of fragments to send queue & send them */
-
 	l_ptr->long_msg_seq_no++;
 	link_add_chain_to_outqueue(l_ptr, buf_chain, l_ptr->long_msg_seq_no);
 	l_ptr->stats.sent_fragments += fragm_no;
@@ -2551,7 +2458,6 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
  * help storing these values in unused, available fields in the
  * pending message. This makes dynamic memory allocation unnecessary.
  */
-
 static void set_long_msg_seqno(struct sk_buff *buf, u32 seqno)
 {
 	msg_set_seqno(buf_msg(buf), seqno);
@@ -2603,7 +2509,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 	*fb = NULL;
 
 	/* Is there an incomplete message waiting for this fragment? */
-
 	while (pbuf && ((buf_seqno(pbuf) != long_msg_seq_no) ||
 			(msg_orignode(fragm) != msg_orignode(buf_msg(pbuf))))) {
 		prev = pbuf;
@@ -2629,7 +2534,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			skb_copy_to_linear_data(pbuf, imsg,
 						msg_data_sz(fragm));
 			/*  Prepare buffer for subsequent fragments. */
-
 			set_long_msg_seqno(pbuf, long_msg_seq_no);
 			set_fragm_size(pbuf, fragm_sz);
 			set_expected_frags(pbuf, exp_fragm_cnt - 1);
@@ -2650,7 +2554,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		kfree_skb(fbuf);
 
 		/* Is message complete? */
-
 		if (exp_frags == 0) {
 			if (prev)
 				prev->next = pbuf->next;
@@ -2672,7 +2575,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
  * link_check_defragm_bufs - flush stale incoming message fragments
  * @l_ptr: pointer to link
  */
-
 static void link_check_defragm_bufs(struct tipc_link *l_ptr)
 {
 	struct sk_buff *prev = NULL;
@@ -2701,8 +2603,6 @@ static void link_check_defragm_bufs(struct tipc_link *l_ptr)
 	}
 }
 
-
-
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 {
 	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
@@ -2714,7 +2614,6 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 	l_ptr->abort_limit = tolerance / (l_ptr->continuity_interval / 4);
 }
 
-
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 {
 	/* Data messages from this node, inclusive FIRST_FRAGM */
@@ -2744,7 +2643,6 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
  *
  * Returns pointer to link (or 0 if invalid link name).
  */
-
 static struct tipc_link *link_find_link(const char *name,
 					struct tipc_node **node)
 {
@@ -2778,7 +2676,6 @@ static struct tipc_link *link_find_link(const char *name,
  *
  * Returns 1 if value is within range, 0 if not.
  */
-
 static int link_value_is_valid(u16 cmd, u32 new_value)
 {
 	switch (cmd) {
@@ -2794,7 +2691,6 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
 	return 0;
 }
 
-
 /**
  * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
  * @name - ptr to link, bearer, or media name
@@ -2805,7 +2701,6 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
  *
  * Returns 0 if value updated and negative value on error.
  */
-
 static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 {
 	struct tipc_node *node;
@@ -2910,7 +2805,6 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
  * link_reset_statistics - reset link statistics
  * @l_ptr: pointer to link
  */
-
 static void link_reset_statistics(struct tipc_link *l_ptr)
 {
 	memset(&l_ptr->stats, 0, sizeof(l_ptr->stats));
@@ -2951,7 +2845,6 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 /**
  * percent - convert count to a percentage of total (rounding up or down)
  */
-
 static u32 percent(u32 count, u32 total)
 {
 	return (count * 100 + (total / 2)) / total;
@@ -2965,7 +2858,6 @@ static u32 percent(u32 count, u32 total)
  *
  * Returns length of print buffer data string (or 0 if error)
  */
-
 static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 {
 	struct print_buf pb;
@@ -3087,7 +2979,6 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
  *
  * If no active link can be found, uses default maximum packet size.
  */
-
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 {
 	struct tipc_node *n_ptr;
@@ -3171,4 +3062,3 @@ print_state:
 	tipc_printbuf_validate(buf);
 	info("%s", print_area);
 }
-
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 73c18c1..d6a60a9 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -47,13 +47,11 @@
 /*
  * Out-of-range value for link sequence numbers
  */
-
 #define INVALID_LINK_SEQ 0x10000
 
 /*
  * Link states
  */
-
 #define WORKING_WORKING 560810u
 #define WORKING_UNKNOWN 560811u
 #define RESET_UNKNOWN   560812u
@@ -63,7 +61,6 @@
  * Starting value for maximum packet size negotiation on unicast links
  * (unless bearer MTU is less)
  */
-
 #define MAX_PKT_DEFAULT 1500
 
 /**
@@ -114,7 +111,6 @@
  * @defragm_buf: list of partially reassembled inbound message fragments
  * @stats: collects statistics regarding link activity
  */
-
 struct tipc_link {
 	u32 addr;
 	char name[TIPC_MAX_LINK_NAME];
@@ -255,7 +251,6 @@ void tipc_link_retransmit(struct tipc_link *l_ptr,
 /*
  * Link sequence number manipulation routines (uses modulo 2**16 arithmetic)
  */
-
 static inline u32 buf_seqno(struct sk_buff *buf)
 {
 	return msg_seqno(buf_msg(buf));
@@ -294,7 +289,6 @@ static inline u32 lesser(u32 left, u32 right)
 /*
  * Link status checking routines
  */
-
 static inline int link_working_working(struct tipc_link *l_ptr)
 {
 	return l_ptr->state == WORKING_WORKING;
diff --git a/net/tipc/log.c b/net/tipc/log.c
index 895c6e5..026733f 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -47,7 +47,6 @@
  *
  * Additional user-defined print buffers are also permitted.
  */
-
 static struct print_buf null_buf = { NULL, 0, NULL, 0 };
 struct print_buf *const TIPC_NULL = &null_buf;
 
@@ -72,7 +71,6 @@ struct print_buf *const TIPC_LOG = &log_buf;
  * on the caller to prevent simultaneous use of the print buffer(s) being
  * manipulated.
  */
-
 static char print_string[TIPC_PB_MAX_STR];
 static DEFINE_SPINLOCK(print_lock);
 
@@ -97,7 +95,6 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
  * Note: If the character array is too small (or absent), the print buffer
  * becomes a null device that discards anything written to it.
  */
-
 void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
 {
 	pb->buf = raw;
@@ -117,7 +114,6 @@ void tipc_printbuf_init(struct print_buf *pb, char *raw, u32 size)
  * tipc_printbuf_reset - reinitialize print buffer to empty state
  * @pb: pointer to print buffer structure
  */
-
 static void tipc_printbuf_reset(struct print_buf *pb)
 {
 	if (pb->buf) {
@@ -133,7 +129,6 @@ static void tipc_printbuf_reset(struct print_buf *pb)
  *
  * Returns non-zero if print buffer is empty.
  */
-
 static int tipc_printbuf_empty(struct print_buf *pb)
 {
 	return !pb->buf || (pb->crs == pb->buf);
@@ -148,7 +143,6 @@ static int tipc_printbuf_empty(struct print_buf *pb)
  *
  * Returns length of print buffer data string (including trailing NUL)
  */
-
 int tipc_printbuf_validate(struct print_buf *pb)
 {
 	char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
@@ -182,14 +176,12 @@ int tipc_printbuf_validate(struct print_buf *pb)
  * Current contents of destination print buffer (if any) are discarded.
  * Source print buffer becomes empty if a successful move occurs.
  */
-
 static void tipc_printbuf_move(struct print_buf *pb_to,
 			       struct print_buf *pb_from)
 {
 	int len;
 
 	/* Handle the cases where contents can't be moved */
-
 	if (!pb_to->buf)
 		return;
 
@@ -206,7 +198,6 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
 	}
 
 	/* Copy data from char after cursor to end (if used) */
-
 	len = pb_from->buf + pb_from->size - pb_from->crs - 2;
 	if ((pb_from->buf[pb_from->size - 1] == 0) && (len > 0)) {
 		strcpy(pb_to->buf, pb_from->crs + 1);
@@ -215,7 +206,6 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
 		pb_to->crs = pb_to->buf;
 
 	/* Copy data from start to cursor (always) */
-
 	len = pb_from->crs - pb_from->buf;
 	strcpy(pb_to->crs, pb_from->buf);
 	pb_to->crs += len;
@@ -228,7 +218,6 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
  * @pb: pointer to print buffer
  * @fmt: formatted info to be printed
  */
-
 void tipc_printf(struct print_buf *pb, const char *fmt, ...)
 {
 	int chars_to_add;
@@ -270,7 +259,6 @@ void tipc_printf(struct print_buf *pb, const char *fmt, ...)
  * tipc_log_resize - change the size of the TIPC log buffer
  * @log_size: print buffer size to use
  */
-
 int tipc_log_resize(int log_size)
 {
 	int res = 0;
@@ -295,7 +283,6 @@ int tipc_log_resize(int log_size)
 /**
  * tipc_log_resize_cmd - reconfigure size of TIPC log buffer
  */
-
 struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 value;
@@ -316,7 +303,6 @@ struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
 /**
  * tipc_log_dump - capture TIPC log buffer contents in configuration message
  */
-
 struct sk_buff *tipc_log_dump(void)
 {
 	struct sk_buff *reply;
diff --git a/net/tipc/log.h b/net/tipc/log.h
index 2248d96..d1f5eb9 100644
--- a/net/tipc/log.h
+++ b/net/tipc/log.h
@@ -44,7 +44,6 @@
  * @crs: pointer to first unused space in character array (i.e. final NUL)
  * @echo: echo output to system console if non-zero
  */
-
 struct print_buf {
 	char *buf;
 	u32 size;
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index e3afe16..deea0d2 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -72,7 +72,6 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
  *
  * Returns message data size or errno
  */
-
 int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   u32 num_sect, unsigned int total_len,
 			    int max_size, int usrmem, struct sk_buff **buf)
@@ -112,7 +111,6 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 }
 
 #ifdef CONFIG_TIPC_DEBUG
-
 void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 {
 	u32 usr = msg_user(msg);
@@ -352,5 +350,4 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 	if ((usr == MSG_FRAGMENTER) && (msg_type(msg) == FIRST_FRAGMENT))
 		tipc_msg_dbg(buf, msg_get_wrapped(msg), "      /");
 }
-
 #endif
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index eba524e3..ba2a72b 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -44,7 +44,6 @@
  *
  * Note: Some items are also used with TIPC internal message headers
  */
-
 #define TIPC_VERSION              2
 
 /*
@@ -58,7 +57,6 @@
 /*
  * Payload message types
  */
-
 #define TIPC_CONN_MSG		0
 #define TIPC_MCAST_MSG		1
 #define TIPC_NAMED_MSG		2
@@ -67,7 +65,6 @@
 /*
  * Message header sizes
  */
-
 #define SHORT_H_SIZE              24	/* In-cluster basic payload message */
 #define BASIC_H_SIZE              32	/* Basic payload message */
 #define NAMED_H_SIZE              40	/* Named payload message */
@@ -121,7 +118,6 @@ static inline void msg_swap_words(struct tipc_msg *msg, u32 a, u32 b)
 /*
  * Word 0
  */
-
 static inline u32 msg_version(struct tipc_msg *m)
 {
 	return msg_bits(m, 0, 29, 7);
@@ -216,7 +212,6 @@ static inline void msg_set_size(struct tipc_msg *m, u32 sz)
 /*
  * Word 1
  */
-
 static inline u32 msg_type(struct tipc_msg *m)
 {
 	return msg_bits(m, 1, 29, 0x7);
@@ -291,7 +286,6 @@ static inline void msg_set_bcast_ack(struct tipc_msg *m, u32 n)
 /*
  * Word 2
  */
-
 static inline u32 msg_ack(struct tipc_msg *m)
 {
 	return msg_bits(m, 2, 16, 0xffff);
@@ -315,8 +309,6 @@ static inline void msg_set_seqno(struct tipc_msg *m, u32 n)
 /*
  * Words 3-10
  */
-
-
 static inline u32 msg_prevnode(struct tipc_msg *m)
 {
 	return msg_word(m, 3);
@@ -434,7 +426,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 	return (struct tipc_msg *)msg_data(m);
 }
 
-
 /*
  * Constants and routines used to read and write TIPC internal message headers
  */
@@ -442,7 +433,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  * Internal message users
  */
-
 #define  BCAST_PROTOCOL       5
 #define  MSG_BUNDLER          6
 #define  LINK_PROTOCOL        7
@@ -456,7 +446,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  *  Connection management protocol message types
  */
-
 #define CONN_PROBE        0
 #define CONN_PROBE_REPLY  1
 #define CONN_ACK          2
@@ -464,14 +453,12 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  * Name distributor message types
  */
-
 #define PUBLICATION       0
 #define WITHDRAWAL        1
 
 /*
  * Segmentation message types
  */
-
 #define FIRST_FRAGMENT		0
 #define FRAGMENT		1
 #define LAST_FRAGMENT		2
@@ -479,7 +466,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  * Link management protocol message types
  */
-
 #define STATE_MSG		0
 #define RESET_MSG		1
 #define ACTIVATE_MSG		2
@@ -493,7 +479,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  * Config protocol message types
  */
-
 #define DSC_REQ_MSG		0
 #define DSC_RESP_MSG		1
 
@@ -501,7 +486,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 /*
  * Word 1
  */
-
 static inline u32 msg_seq_gap(struct tipc_msg *m)
 {
 	return msg_bits(m, 1, 16, 0x1fff);
@@ -526,7 +510,6 @@ static inline void msg_set_node_sig(struct tipc_msg *m, u32 n)
 /*
  * Word 2
  */
-
 static inline u32 msg_dest_domain(struct tipc_msg *m)
 {
 	return msg_word(m, 2);
@@ -561,7 +544,6 @@ static inline void msg_set_bcgap_to(struct tipc_msg *m, u32 n)
 /*
  * Word 4
  */
-
 static inline u32 msg_last_bcast(struct tipc_msg *m)
 {
 	return msg_bits(m, 4, 16, 0xffff);
@@ -628,7 +610,6 @@ static inline void msg_set_link_selector(struct tipc_msg *m, u32 n)
 /*
  * Word 5
  */
-
 static inline u32 msg_session(struct tipc_msg *m)
 {
 	return msg_bits(m, 5, 16, 0xffff);
@@ -697,7 +678,6 @@ static inline char *msg_media_addr(struct tipc_msg *m)
 /*
  * Word 9
  */
-
 static inline u32 msg_msgcnt(struct tipc_msg *m)
 {
 	return msg_bits(m, 9, 16, 0xffff);
@@ -744,5 +724,4 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   u32 num_sect, unsigned int total_len,
 			    int max_size, int usrmem, struct sk_buff **buf);
-
 #endif
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 211c172..158318e 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -58,7 +58,6 @@
  * Note: There is no field that identifies the publishing node because it is
  * the same for all items contained within a publication message.
  */
-
 struct distr_item {
 	__be32 type;
 	__be32 lower;
@@ -103,7 +102,6 @@ static struct publ_list *publ_lists[] = {
 /**
  * publ_to_item - add publication info to a publication message
  */
-
 static void publ_to_item(struct distr_item *i, struct publication *p)
 {
 	i->type = htonl(p->type);
@@ -116,7 +114,6 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 /**
  * named_prepare_buf - allocate & initialize a publication message
  */
-
 static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 {
 	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size);
@@ -151,7 +148,6 @@ static void named_cluster_distribute(struct sk_buff *buf)
 /**
  * tipc_named_publish - tell other nodes about a new publication by this node
  */
-
 void tipc_named_publish(struct publication *publ)
 {
 	struct sk_buff *buf;
@@ -177,7 +173,6 @@ void tipc_named_publish(struct publication *publ)
 /**
  * tipc_named_withdraw - tell other nodes about a withdrawn publication by this node
  */
-
 void tipc_named_withdraw(struct publication *publ)
 {
 	struct sk_buff *buf;
@@ -236,7 +231,6 @@ static void named_distribute(struct list_head *message_list, u32 node,
 /**
  * tipc_named_node_up - tell specified node about all publications by this node
  */
-
 void tipc_named_node_up(unsigned long nodearg)
 {
 	struct tipc_node *n_ptr;
@@ -246,7 +240,6 @@ void tipc_named_node_up(unsigned long nodearg)
 	u32 max_item_buf = 0;
 
 	/* compute maximum amount of publication data to send per message */
-
 	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(node);
 	if (n_ptr) {
@@ -262,7 +255,6 @@ void tipc_named_node_up(unsigned long nodearg)
 		return;
 
 	/* create list of publication messages, then send them as a unit */
-
 	INIT_LIST_HEAD(&message_list);
 
 	read_lock_bh(&tipc_nametbl_lock);
@@ -279,7 +271,6 @@ void tipc_named_node_up(unsigned long nodearg)
  * Invoked for each publication issued by a newly failed node.
  * Removes publication structure from name table & deletes it.
  */
-
 static void named_purge_publ(struct publication *publ)
 {
 	struct publication *p;
@@ -303,7 +294,6 @@ static void named_purge_publ(struct publication *publ)
 /**
  * tipc_named_recv - process name table update message sent by another node
  */
-
 void tipc_named_recv(struct sk_buff *buf)
 {
 	struct publication *publ;
@@ -361,7 +351,6 @@ void tipc_named_recv(struct sk_buff *buf)
  * All name table entries published by this node are updated to reflect
  * the node's new network address.
  */
-
 void tipc_named_reinit(void)
 {
 	struct publication *publ;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 4de58de..010f24a 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -56,7 +56,6 @@ static int tipc_nametbl_size = 1024;		/* must be a power of 2 */
  *       publications of the associated name sequence belong to it.
  *       (The cluster and node lists may be empty.)
  */
-
 struct name_info {
 	struct list_head node_list;
 	struct list_head cluster_list;
@@ -72,7 +71,6 @@ struct name_info {
  * @upper: name sequence upper bound
  * @info: pointer to name sequence publication info
  */
-
 struct sub_seq {
 	u32 lower;
 	u32 upper;
@@ -90,7 +88,6 @@ struct sub_seq {
  * @subscriptions: list of subscriptions for this 'type'
  * @lock: spinlock controlling access to publication lists of all sub-sequences
  */
-
 struct name_seq {
 	u32 type;
 	struct sub_seq *sseqs;
@@ -107,7 +104,6 @@ struct name_seq {
  *         accessed via hashing on 'type'; name sequence lists are *not* sorted
  * @local_publ_count: number of publications issued by this node
  */
-
 struct name_table {
 	struct hlist_head *types;
 	u32 local_publ_count;
@@ -124,7 +120,6 @@ static int hash(int x)
 /**
  * publ_create - create a publication structure
  */
-
 static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 				       u32 scope, u32 node, u32 port_ref,
 				       u32 key)
@@ -151,7 +146,6 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 /**
  * tipc_subseq_alloc - allocate a specified number of sub-sequence structures
  */
-
 static struct sub_seq *tipc_subseq_alloc(u32 cnt)
 {
 	struct sub_seq *sseq = kcalloc(cnt, sizeof(struct sub_seq), GFP_ATOMIC);
@@ -163,7 +157,6 @@ static struct sub_seq *tipc_subseq_alloc(u32 cnt)
  *
  * Allocates a single sub-sequence structure and sets it to all 0's.
  */
-
 static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_head)
 {
 	struct name_seq *nseq = kzalloc(sizeof(*nseq), GFP_ATOMIC);
@@ -203,7 +196,6 @@ static void nameseq_delete_empty(struct name_seq *seq)
  *
  * Very time-critical, so binary searches through sub-sequence array.
  */
-
 static struct sub_seq *nameseq_find_subseq(struct name_seq *nseq,
 					   u32 instance)
 {
@@ -233,7 +225,6 @@ static struct sub_seq *nameseq_find_subseq(struct name_seq *nseq,
  *
  * Note: Similar to binary search code for locating a sub-sequence.
  */
-
 static u32 nameseq_locate_subseq(struct name_seq *nseq, u32 instance)
 {
 	struct sub_seq *sseqs = nseq->sseqs;
@@ -254,9 +245,8 @@ static u32 nameseq_locate_subseq(struct name_seq *nseq, u32 instance)
 }
 
 /**
- * tipc_nameseq_insert_publ -
+ * tipc_nameseq_insert_publ
  */
-
 static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 						    u32 type, u32 lower, u32 upper,
 						    u32 scope, u32 node, u32 port, u32 key)
@@ -272,7 +262,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	if (sseq) {
 
 		/* Lower end overlaps existing entry => need an exact match */
-
 		if ((sseq->lower != lower) || (sseq->upper != upper)) {
 			warn("Cannot publish {%u,%u,%u}, overlap error\n",
 			     type, lower, upper);
@@ -292,11 +281,9 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		struct sub_seq *freesseq;
 
 		/* Find where lower end should be inserted */
-
 		inspos = nameseq_locate_subseq(nseq, lower);
 
 		/* Fail if upper end overlaps into an existing entry */
-
 		if ((inspos < nseq->first_free) &&
 		    (upper >= nseq->sseqs[inspos].lower)) {
 			warn("Cannot publish {%u,%u,%u}, overlap error\n",
@@ -305,7 +292,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		}
 
 		/* Ensure there is space for new sub-sequence */
-
 		if (nseq->first_free == nseq->alloc) {
 			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
 
@@ -333,7 +319,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		INIT_LIST_HEAD(&info->zone_list);
 
 		/* Insert new sub-sequence */
-
 		sseq = &nseq->sseqs[inspos];
 		freesseq = &nseq->sseqs[nseq->first_free];
 		memmove(sseq + 1, sseq, (freesseq - sseq) * sizeof(*sseq));
@@ -345,8 +330,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		created_subseq = 1;
 	}
 
-	/* Insert a publication: */
-
+	/* Insert a publication */
 	publ = publ_create(type, lower, upper, scope, node, port, key);
 	if (!publ)
 		return NULL;
@@ -364,9 +348,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		info->node_list_size++;
 	}
 
-	/*
-	 * Any subscriptions waiting for notification?
-	 */
+	/* Any subscriptions waiting for notification?  */
 	list_for_each_entry_safe(s, st, &nseq->subscriptions, nameseq_list) {
 		tipc_subscr_report_overlap(s,
 					   publ->lower,
@@ -380,7 +362,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 }
 
 /**
- * tipc_nameseq_remove_publ -
+ * tipc_nameseq_remove_publ
  *
  * NOTE: There may be cases where TIPC is asked to remove a publication
  * that is not in the name table.  For example, if another node issues a
@@ -390,7 +372,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
  * A failed withdraw request simply returns a failure indication and lets the
  * caller issue any error or warning messages associated with such a problem.
  */
-
 static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 inst,
 						    u32 node, u32 ref, u32 key)
 {
@@ -407,7 +388,6 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	info = sseq->info;
 
 	/* Locate publication, if it exists */
-
 	list_for_each_entry(publ, &info->zone_list, zone_list) {
 		if ((publ->key == key) && (publ->ref == ref) &&
 		    (!publ->node || (publ->node == node)))
@@ -417,26 +397,22 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 
 found:
 	/* Remove publication from zone scope list */
-
 	list_del(&publ->zone_list);
 	info->zone_list_size--;
 
 	/* Remove publication from cluster scope list, if present */
-
 	if (in_own_cluster(node)) {
 		list_del(&publ->cluster_list);
 		info->cluster_list_size--;
 	}
 
 	/* Remove publication from node scope list, if present */
-
 	if (in_own_node(node)) {
 		list_del(&publ->node_list);
 		info->node_list_size--;
 	}
 
 	/* Contract subseq list if no more publications for that subseq */
-
 	if (list_empty(&info->zone_list)) {
 		kfree(info);
 		free = &nseq->sseqs[nseq->first_free--];
@@ -445,7 +421,6 @@ found:
 	}
 
 	/* Notify any waiting subscriptions */
-
 	list_for_each_entry_safe(s, st, &nseq->subscriptions, nameseq_list) {
 		tipc_subscr_report_overlap(s,
 					   publ->lower,
@@ -464,7 +439,6 @@ found:
  * the prescribed number of events if there is any sub-
  * sequence overlapping with the requested sequence
  */
-
 static void tipc_nameseq_subscribe(struct name_seq *nseq,
 					struct tipc_subscription *s)
 {
@@ -559,7 +533,6 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
  * - if name translation is attempted and fails, sets 'destnode' to 0
  *   and returns 0
  */
-
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 {
 	struct sub_seq *sseq;
@@ -582,7 +555,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	spin_lock_bh(&seq->lock);
 	info = sseq->info;
 
-	/* Closest-First Algorithm: */
+	/* Closest-First Algorithm */
 	if (likely(!*destnode)) {
 		if (!list_empty(&info->node_list)) {
 			publ = list_first_entry(&info->node_list,
@@ -605,7 +578,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 		}
 	}
 
-	/* Round-Robin Algorithm: */
+	/* Round-Robin Algorithm */
 	else if (*destnode == tipc_own_addr) {
 		if (list_empty(&info->node_list))
 			goto no_match;
@@ -646,7 +619,6 @@ not_found:
  *
  * Returns non-zero if any off-node ports overlap
  */
-
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 			      struct tipc_port_list *dports)
 {
@@ -690,7 +662,6 @@ exit:
 /*
  * tipc_nametbl_publish - add name publication to network name tables
  */
-
 struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 				    u32 scope, u32 port_ref, u32 key)
 {
@@ -716,7 +687,6 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 /**
  * tipc_nametbl_withdraw - withdraw name publication from network name tables
  */
-
 int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 {
 	struct publication *publ;
@@ -741,7 +711,6 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 /**
  * tipc_nametbl_subscribe - add a subscription object to the name table
  */
-
 void tipc_nametbl_subscribe(struct tipc_subscription *s)
 {
 	u32 type = s->seq.type;
@@ -765,7 +734,6 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 /**
  * tipc_nametbl_unsubscribe - remove a subscription object from name table
  */
-
 void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 {
 	struct name_seq *seq;
@@ -785,7 +753,6 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 /**
  * subseq_list: print specified sub-sequence contents into the given buffer
  */
-
 static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			u32 index)
 {
@@ -822,7 +789,6 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 /**
  * nameseq_list: print specified name sequence contents into the given buffer
  */
-
 static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 			 u32 type, u32 lowbound, u32 upbound, u32 index)
 {
@@ -853,7 +819,6 @@ static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 /**
  * nametbl_header - print name table header into the given buffer
  */
-
 static void nametbl_header(struct print_buf *buf, u32 depth)
 {
 	const char *header[] = {
@@ -875,7 +840,6 @@ static void nametbl_header(struct print_buf *buf, u32 depth)
 /**
  * nametbl_list - print specified name table contents into the given buffer
  */
-
 static void nametbl_list(struct print_buf *buf, u32 depth_info,
 			 u32 type, u32 lowbound, u32 upbound)
 {
@@ -974,7 +938,6 @@ void tipc_nametbl_stop(void)
 		return;
 
 	/* Verify name table is empty, then release it */
-
 	write_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < tipc_nametbl_size; i++) {
 		if (!hlist_empty(&table.types[i]))
@@ -984,4 +947,3 @@ void tipc_nametbl_stop(void)
 	table.types = NULL;
 	write_unlock_bh(&tipc_nametbl_lock);
 }
-
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 207d59e..71cb4dc 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -45,10 +45,8 @@ struct tipc_port_list;
 /*
  * TIPC name types reserved for internal TIPC use (both current and planned)
  */
-
 #define TIPC_ZM_SRV 3		/* zone master service name type */
 
-
 /**
  * struct publication - info about a published (name or) name sequence
  * @type: name sequence type
@@ -67,7 +65,6 @@ struct tipc_port_list;
  *
  * Note that the node list, cluster list, and zone list are circular lists.
  */
-
 struct publication {
 	u32 type;
 	u32 lower;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 76565c9..d4fd341 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -66,7 +66,6 @@ static unsigned int tipc_hashfn(u32 addr)
 /*
  * tipc_node_find - locate specified node object, if it exists
  */
-
 struct tipc_node *tipc_node_find(u32 addr)
 {
 	struct tipc_node *node;
@@ -91,7 +90,6 @@ struct tipc_node *tipc_node_find(u32 addr)
  * time.  (It would be preferable to switch to holding net_lock in write mode,
  * but this is a non-trivial change.)
  */
-
 struct tipc_node *tipc_node_create(u32 addr)
 {
 	struct tipc_node *n_ptr, *temp_node;
@@ -142,13 +140,11 @@ void tipc_node_delete(struct tipc_node *n_ptr)
 	tipc_num_nodes--;
 }
 
-
 /**
  * tipc_node_link_up - handle addition of link
  *
  * Link becomes active (alone or shared) or standby, depending on its priority.
  */
-
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active = &n_ptr->active_links[0];
@@ -181,7 +177,6 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 /**
  * node_select_active_links - select active link
  */
-
 static void node_select_active_links(struct tipc_node *n_ptr)
 {
 	struct tipc_link **active = &n_ptr->active_links[0];
@@ -209,7 +204,6 @@ static void node_select_active_links(struct tipc_node *n_ptr)
 /**
  * tipc_node_link_down - handle loss of link
  */
-
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active;
@@ -300,7 +294,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	     tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
-
 	if (n_ptr->bclink.supported) {
 		while (n_ptr->bclink.deferred_head) {
 			struct sk_buff *buf = n_ptr->bclink.deferred_head;
@@ -334,7 +327,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	tipc_nodesub_notify(n_ptr);
 
 	/* Prevent re-contact with node until cleanup is done */
-
 	n_ptr->block_setup = WAIT_PEER_DOWN | WAIT_NAMES_GONE;
 	tipc_k_signal((Handler)node_name_purge_complete, n_ptr->addr);
 }
@@ -362,7 +354,6 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	}
 
 	/* For now, get space for all other nodes */
-
 	payload_size = TLV_SPACE(sizeof(node_info)) * tipc_num_nodes;
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
@@ -376,7 +367,6 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	}
 
 	/* Add TLVs for all nodes in scope */
-
 	list_for_each_entry(n_ptr, &tipc_node_list, list) {
 		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
@@ -412,7 +402,6 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	read_lock_bh(&tipc_net_lock);
 
 	/* Get space for all unicast links + broadcast link */
-
 	payload_size = TLV_SPACE(sizeof(link_info)) *
 		(atomic_read(&tipc_num_links) + 1);
 	if (payload_size > 32768u) {
@@ -427,14 +416,12 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	}
 
 	/* Add TLV for broadcast link */
-
 	link_info.dest = htonl(tipc_cluster_mask(tipc_own_addr));
 	link_info.up = htonl(1);
 	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
 
 	/* Add TLVs for any other links in scope */
-
 	list_for_each_entry(n_ptr, &tipc_node_list, list) {
 		u32 i;
 
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 72561c9..cfcaf4d 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -48,7 +48,6 @@
 #define INVALID_NODE_SIG 0x10000
 
 /* Flags used to block (re)establishment of contact with a neighboring node */
-
 #define WAIT_PEER_DOWN	0x0001	/* wait to see that peer's links are down */
 #define WAIT_NAMES_GONE	0x0002	/* wait for peer's publications to be purged */
 #define WAIT_NODE_DOWN	0x0004	/* wait until peer node is declared down */
@@ -79,7 +78,6 @@
  *    @deferred_tail: newest OOS b'cast message received from node
  *    @defragm: list of partially reassembled b'cast message fragments from node
  */
-
 struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 327ffbb..7a27344 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -41,7 +41,6 @@
 /**
  * tipc_nodesub_subscribe - create "node down" subscription for specified node
  */
-
 void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 		       void *usr_handle, net_ev_handler handle_down)
 {
@@ -66,7 +65,6 @@ void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 /**
  * tipc_nodesub_unsubscribe - cancel "node down" subscription (if any)
  */
-
 void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
 {
 	if (!node_sub->node)
@@ -82,7 +80,6 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
  *
  * Note: node is locked by caller
  */
-
 void tipc_nodesub_notify(struct tipc_node *node)
 {
 	struct tipc_node_subscr *ns;
diff --git a/net/tipc/node_subscr.h b/net/tipc/node_subscr.h
index 4bc2ca0..c95d207 100644
--- a/net/tipc/node_subscr.h
+++ b/net/tipc/node_subscr.h
@@ -48,7 +48,6 @@ typedef void (*net_ev_handler) (void *usr_handle);
  * @usr_handle: argument to pass to routine when node fails
  * @nodesub_list: adjacent entries in list of subscriptions for the node
  */
-
 struct tipc_node_subscr {
 	struct tipc_node *node;
 	net_ev_handler handle_node_down;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index e684170..2ad37a4 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -75,7 +75,6 @@ static u32 port_peerport(struct tipc_port *p_ptr)
  * Handles cases where the node's network address has changed from
  * the default of <0.0.0> to its configured setting.
  */
-
 int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
 {
 	u32 peernode;
@@ -94,7 +93,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
 /**
  * tipc_multicast - send a multicast message to local and remote destinations
  */
-
 int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 		   u32 num_sect, struct iovec const *msg_sect,
 		   unsigned int total_len)
@@ -111,7 +109,6 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 		return -EINVAL;
 
 	/* Create multicast message */
-
 	hdr = &oport->phdr;
 	msg_set_type(hdr, TIPC_MCAST_MSG);
 	msg_set_lookup_scope(hdr, TIPC_CLUSTER_SCOPE);
@@ -127,12 +124,10 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 		return res;
 
 	/* Figure out where to send multicast message */
-
 	ext_targets = tipc_nametbl_mc_translate(seq->type, seq->lower, seq->upper,
 						TIPC_NODE_SCOPE, &dports);
 
 	/* Send message to destinations (duplicate it only if necessary) */
-
 	if (ext_targets) {
 		if (dports.count != 0) {
 			ibuf = skb_copy(buf, GFP_ATOMIC);
@@ -163,7 +158,6 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
  *
  * If there is no port list, perform a lookup to create one
  */
-
 void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 {
 	struct tipc_msg *msg;
@@ -174,7 +168,6 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 	msg = buf_msg(buf);
 
 	/* Create destination port list, if one wasn't supplied */
-
 	if (dp == NULL) {
 		tipc_nametbl_mc_translate(msg_nametype(msg),
 				     msg_namelower(msg),
@@ -185,7 +178,6 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 	}
 
 	/* Deliver a copy of message to each destination port */
-
 	if (dp->count != 0) {
 		msg_set_destnode(msg, tipc_own_addr);
 		if (dp->count == 1) {
@@ -218,7 +210,6 @@ exit:
  *
  * Returns pointer to (locked) TIPC port, or NULL if unable to create it
  */
-
 struct tipc_port *tipc_createport_raw(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
@@ -257,7 +248,6 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	 * to ensure a change to node's own network address doesn't result
 	 * in template containing out-dated network address information
 	 */
-
 	spin_lock_bh(&tipc_port_list_lock);
 	msg = &p_ptr->phdr;
 	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, NAMED_H_SIZE, 0);
@@ -390,7 +380,6 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	u32 rmsg_sz;
 
 	/* discard rejected message if it shouldn't be returned to sender */
-
 	if (WARN(!msg_isdata(msg),
 		 "attempt to reject message with user=%u", msg_user(msg))) {
 		dump_stack();
@@ -403,7 +392,6 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	 * construct returned message by copying rejected message header and
 	 * data (or subset), then updating header fields that need adjusting
 	 */
-
 	hdr_sz = msg_hdr_sz(msg);
 	rmsg_sz = hdr_sz + min_t(u32, data_sz, MAX_REJECT_SIZE);
 
@@ -442,7 +430,6 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	}
 
 	/* send returned message & dispose of rejected message */
-
 	src_node = msg_prevnode(msg);
 	if (in_own_node(src_node))
 		tipc_port_recv_msg(rbuf);
@@ -552,7 +539,6 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	int wakeable;
 
 	/* Validate connection */
-
 	p_ptr = tipc_port_lock(destport);
 	if (!p_ptr || !p_ptr->connected || !tipc_port_peer_msg(p_ptr, msg)) {
 		r_buf = tipc_buf_acquire(BASIC_H_SIZE);
@@ -570,7 +556,6 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	}
 
 	/* Process protocol message sent by peer */
-
 	switch (msg_type(msg)) {
 	case CONN_ACK:
 		wakeable = tipc_port_congested(p_ptr) && p_ptr->congested &&
@@ -682,7 +667,6 @@ void tipc_port_reinit(void)
  *  port_dispatcher_sigh(): Signal handler for messages destinated
  *                          to the tipc_port interface.
  */
-
 static void port_dispatcher_sigh(void *dummy)
 {
 	struct sk_buff *buf;
@@ -843,7 +827,6 @@ reject:
  *  port_dispatcher(): Dispatcher for messages destinated
  *  to the tipc_port interface. Called with port locked.
  */
-
 static u32 port_dispatcher(struct tipc_port *dummy, struct sk_buff *buf)
 {
 	buf->next = NULL;
@@ -860,10 +843,8 @@ static u32 port_dispatcher(struct tipc_port *dummy, struct sk_buff *buf)
 }
 
 /*
- * Wake up port after congestion: Called with port locked,
- *
+ * Wake up port after congestion: Called with port locked
  */
-
 static void port_wakeup_sh(unsigned long ref)
 {
 	struct tipc_port *p_ptr;
@@ -909,7 +890,6 @@ void tipc_acknowledge(u32 ref, u32 ack)
 /*
  * tipc_createport(): user level call.
  */
-
 int tipc_createport(void *usr_handle,
 		    unsigned int importance,
 		    tipc_msg_err_event error_cb,
@@ -918,7 +898,7 @@ int tipc_createport(void *usr_handle,
 		    tipc_msg_event msg_cb,
 		    tipc_named_msg_event named_msg_cb,
 		    tipc_conn_msg_event conn_msg_cb,
-		    tipc_continue_event continue_event_cb,/* May be zero */
+		    tipc_continue_event continue_event_cb, /* May be zero */
 		    u32 *portref)
 {
 	struct user_port *up_ptr;
@@ -1091,7 +1071,6 @@ exit:
  *
  * Port must be locked.
  */
-
 int tipc_disconnect_port(struct tipc_port *tp_ptr)
 {
 	int res;
@@ -1112,7 +1091,6 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr)
  * tipc_disconnect(): Disconnect port form peer.
  *                    This is a node local operation.
  */
-
 int tipc_disconnect(u32 ref)
 {
 	struct tipc_port *p_ptr;
@@ -1147,7 +1125,6 @@ int tipc_shutdown(u32 ref)
 /**
  * tipc_port_recv_msg - receive message from lower layer and deliver to port user
  */
-
 int tipc_port_recv_msg(struct sk_buff *buf)
 {
 	struct tipc_port *p_ptr;
@@ -1180,7 +1157,6 @@ int tipc_port_recv_msg(struct sk_buff *buf)
  *  tipc_port_recv_sections(): Concatenate and deliver sectioned
  *                        message for this node.
  */
-
 static int tipc_port_recv_sections(struct tipc_port *sender, unsigned int num_sect,
 				   struct iovec const *msg_sect,
 				   unsigned int total_len)
@@ -1198,7 +1174,6 @@ static int tipc_port_recv_sections(struct tipc_port *sender, unsigned int num_se
 /**
  * tipc_send - send message sections on connection
  */
-
 int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect,
 	      unsigned int total_len)
 {
@@ -1237,7 +1212,6 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect,
 /**
  * tipc_send2name - send message sections to port name
  */
-
 int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 		   unsigned int num_sect, struct iovec const *msg_sect,
 		   unsigned int total_len)
@@ -1291,7 +1265,6 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 /**
  * tipc_send2port - send message sections to port identity
  */
-
 int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 		   unsigned int num_sect, struct iovec const *msg_sect,
 		   unsigned int total_len)
@@ -1334,7 +1307,6 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 /**
  * tipc_send_buf2port - send message buffer to port identity
  */
-
 int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 	       struct sk_buff *buf, unsigned int dsz)
 {
@@ -1371,4 +1343,3 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 		return dsz;
 	return -ELINKCONG;
 }
-
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 301e1bd..98cbec9 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -81,7 +81,6 @@ typedef void (*tipc_continue_event) (void *usr_handle, u32 portref);
  * @ref: object reference to associated TIPC port
  * <various callback routines>
  */
-
 struct user_port {
 	void *usr_handle;
 	u32 ref;
@@ -236,7 +235,6 @@ void tipc_port_reinit(void);
 /**
  * tipc_port_lock - lock port instance referred to and return its pointer
  */
-
 static inline struct tipc_port *tipc_port_lock(u32 ref)
 {
 	return (struct tipc_port *)tipc_ref_lock(ref);
@@ -247,7 +245,6 @@ static inline struct tipc_port *tipc_port_lock(u32 ref)
  *
  * Can use pointer instead of tipc_ref_unlock() since port is already locked.
  */
-
 static inline void tipc_port_unlock(struct tipc_port *p_ptr)
 {
 	spin_unlock_bh(p_ptr->lock);
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 9e37b78..5cada0e 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -43,7 +43,6 @@
  * @lock: spinlock controlling access to object
  * @ref: reference value for object (combines instance & array index info)
  */
-
 struct reference {
 	void *object;
 	spinlock_t lock;
@@ -60,7 +59,6 @@ struct reference {
  * @index_mask: bitmask for array index portion of reference values
  * @start_mask: initial value for instance value portion of reference values
  */
-
 struct ref_table {
 	struct reference *entries;
 	u32 capacity;
@@ -96,7 +94,6 @@ static DEFINE_RWLOCK(ref_table_lock);
 /**
  * tipc_ref_table_init - create reference table for objects
  */
-
 int tipc_ref_table_init(u32 requested_size, u32 start)
 {
 	struct reference *table;
@@ -109,7 +106,6 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 		/* do nothing */ ;
 
 	/* allocate table & mark all entries as uninitialized */
-
 	table = vzalloc(actual_size * sizeof(struct reference));
 	if (table == NULL)
 		return -ENOMEM;
@@ -128,7 +124,6 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 /**
  * tipc_ref_table_stop - destroy reference table for objects
  */
-
 void tipc_ref_table_stop(void)
 {
 	if (!tipc_ref_table.entries)
@@ -149,7 +144,6 @@ void tipc_ref_table_stop(void)
  * register a partially initialized object, without running the risk that
  * the object will be accessed before initialization is complete.
  */
-
 u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 {
 	u32 index;
@@ -168,7 +162,6 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	}
 
 	/* take a free entry, if available; otherwise initialize a new entry */
-
 	write_lock_bh(&ref_table_lock);
 	if (tipc_ref_table.first_free) {
 		index = tipc_ref_table.first_free;
@@ -211,7 +204,6 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
  * Disallow future references to an object and free up the entry for re-use.
  * Note: The entry's spin_lock may still be busy after discard
  */
-
 void tipc_ref_discard(u32 ref)
 {
 	struct reference *entry;
@@ -242,12 +234,10 @@ void tipc_ref_discard(u32 ref)
 	 * mark entry as unused; increment instance part of entry's reference
 	 * to invalidate any subsequent references
 	 */
-
 	entry->object = NULL;
 	entry->ref = (ref & ~index_mask) + (index_mask + 1);
 
 	/* append entry to free entry list */
-
 	if (tipc_ref_table.first_free == 0)
 		tipc_ref_table.first_free = index;
 	else
@@ -261,7 +251,6 @@ exit:
 /**
  * tipc_ref_lock - lock referenced object and return pointer to it
  */
-
 void *tipc_ref_lock(u32 ref)
 {
 	if (likely(tipc_ref_table.entries)) {
@@ -283,7 +272,6 @@ void *tipc_ref_lock(u32 ref)
 /**
  * tipc_ref_deref - return pointer referenced object (without locking it)
  */
-
 void *tipc_ref_deref(u32 ref)
 {
 	if (likely(tipc_ref_table.entries)) {
@@ -296,4 +284,3 @@ void *tipc_ref_deref(u32 ref)
 	}
 	return NULL;
 }
-
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3c00b40..5577a44 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -123,7 +123,6 @@ static atomic_t tipc_queue_size = ATOMIC_INIT(0);
  *
  * Caller must hold socket lock
  */
-
 static void advance_rx_queue(struct sock *sk)
 {
 	kfree_skb(__skb_dequeue(&sk->sk_receive_queue));
@@ -135,7 +134,6 @@ static void advance_rx_queue(struct sock *sk)
  *
  * Caller must hold socket lock
  */
-
 static void discard_rx_queue(struct sock *sk)
 {
 	struct sk_buff *buf;
@@ -151,7 +149,6 @@ static void discard_rx_queue(struct sock *sk)
  *
  * Caller must hold socket lock
  */
-
 static void reject_rx_queue(struct sock *sk)
 {
 	struct sk_buff *buf;
@@ -174,7 +171,6 @@ static void reject_rx_queue(struct sock *sk)
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int tipc_create(struct net *net, struct socket *sock, int protocol,
 		       int kern)
 {
@@ -184,7 +180,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	struct tipc_port *tp_ptr;
 
 	/* Validate arguments */
-
 	if (unlikely(protocol != 0))
 		return -EPROTONOSUPPORT;
 
@@ -207,13 +202,11 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	}
 
 	/* Allocate socket's protocol area */
-
 	sk = sk_alloc(net, AF_TIPC, GFP_KERNEL, &tipc_proto);
 	if (sk == NULL)
 		return -ENOMEM;
 
 	/* Allocate TIPC port for socket to use */
-
 	tp_ptr = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
 				     TIPC_LOW_IMPORTANCE);
 	if (unlikely(!tp_ptr)) {
@@ -222,7 +215,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	}
 
 	/* Finish initializing socket data structures */
-
 	sock->ops = ops;
 	sock->state = state;
 
@@ -258,7 +250,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -270,7 +261,6 @@ static int release(struct socket *sock)
 	 * Exit if socket isn't fully initialized (occurs when a failed accept()
 	 * releases a pre-allocated child socket that was never used)
 	 */
-
 	if (sk == NULL)
 		return 0;
 
@@ -281,7 +271,6 @@ static int release(struct socket *sock)
 	 * Reject all unreceived messages, except on an active connection
 	 * (which disconnects locally & sends a 'FIN+' to peer)
 	 */
-
 	while (sock->state != SS_DISCONNECTING) {
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf == NULL)
@@ -303,15 +292,12 @@ static int release(struct socket *sock)
 	 * Delete TIPC port; this ensures no more messages are queued
 	 * (also disconnects an active connection & sends a 'FIN-' to peer)
 	 */
-
 	res = tipc_deleteport(tport->ref);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
-
 	discard_rx_queue(sk);
 
 	/* Reject any messages that accumulated in backlog queue */
-
 	sock->state = SS_DISCONNECTING;
 	release_sock(sk);
 
@@ -336,7 +322,6 @@ static int release(struct socket *sock)
  * NOTE: This routine doesn't need to take the socket lock since it doesn't
  *       access any non-constant socket information.
  */
-
 static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
@@ -376,7 +361,6 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
  *       accesses socket information that is unchanging (or which changes in
  *       a completely predictable manner).
  */
-
 static int get_name(struct socket *sock, struct sockaddr *uaddr,
 		    int *uaddr_len, int peer)
 {
@@ -444,7 +428,6 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
  * imply that the operation will succeed, merely that it should be performed
  * and will not block.
  */
-
 static unsigned int poll(struct file *file, struct socket *sock,
 			 poll_table *wait)
 {
@@ -482,7 +465,6 @@ static unsigned int poll(struct file *file, struct socket *sock,
  *
  * Returns 0 if permission is granted, otherwise errno
  */
-
 static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 {
 	struct tipc_cfg_msg_hdr hdr;
@@ -518,7 +500,6 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
  *
  * Returns the number of bytes sent on success, or errno otherwise
  */
-
 static int send_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t total_len)
 {
@@ -562,7 +543,6 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		/* Abort any pending connection attempts (very unlikely) */
-
 		reject_rx_queue(sk);
 	}
 
@@ -631,7 +611,6 @@ exit:
  *
  * Returns the number of bytes sent on success, or errno otherwise
  */
-
 static int send_packet(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
@@ -642,7 +621,6 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	int res;
 
 	/* Handle implied connection establishment */
-
 	if (unlikely(dest))
 		return send_msg(iocb, sock, m, total_len);
 
@@ -695,7 +673,6 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
  * Returns the number of bytes sent on success (or partial success),
  * or errno if no data sent
  */
-
 static int send_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
@@ -715,7 +692,6 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	lock_sock(sk);
 
 	/* Handle special cases where there is no connection */
-
 	if (unlikely(sock->state != SS_CONNECTED)) {
 		if (sock->state == SS_UNCONNECTED) {
 			res = send_packet(NULL, sock, m, total_len);
@@ -747,7 +723,6 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	 * (i.e. one large iovec entry), but could be improved to pass sets
 	 * of small iovec entries into send_packet().
 	 */
-
 	curr_iov = m->msg_iov;
 	curr_iovlen = m->msg_iovlen;
 	my_msg.msg_iov = &my_iov;
@@ -796,7 +771,6 @@ exit:
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int auto_connect(struct socket *sock, struct tipc_msg *msg)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
@@ -821,7 +795,6 @@ static int auto_connect(struct socket *sock, struct tipc_msg *msg)
  *
  * Note: Address is not captured if not requested by receiver.
  */
-
 static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)m->msg_name;
@@ -847,7 +820,6 @@ static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
  *
  * Returns 0 if successful, otherwise errno
  */
-
 static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 				struct tipc_port *tport)
 {
@@ -861,7 +833,6 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 		return 0;
 
 	/* Optionally capture errored message object(s) */
-
 	err = msg ? msg_errcode(msg) : 0;
 	if (unlikely(err)) {
 		anc_data[0] = err;
@@ -878,7 +849,6 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 	}
 
 	/* Optionally capture message destination object */
-
 	dest_type = msg ? msg_type(msg) : TIPC_DIRECT_MSG;
 	switch (dest_type) {
 	case TIPC_NAMED_MSG:
@@ -923,7 +893,6 @@ static int anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
  *
  * Returns size of returned message data, errno otherwise
  */
-
 static int recv_msg(struct kiocb *iocb, struct socket *sock,
 		    struct msghdr *m, size_t buf_len, int flags)
 {
@@ -937,7 +906,6 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 	int res;
 
 	/* Catch invalid receive requests */
-
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
@@ -952,7 +920,6 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
-
 	while (skb_queue_empty(&sk->sk_receive_queue)) {
 		if (sock->state == SS_DISCONNECTING) {
 			res = -ENOTCONN;
@@ -970,14 +937,12 @@ restart:
 	}
 
 	/* Look at first message in receive queue */
-
 	buf = skb_peek(&sk->sk_receive_queue);
 	msg = buf_msg(buf);
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
 
 	/* Complete connection setup for an implied connect */
-
 	if (unlikely(sock->state == SS_CONNECTING)) {
 		res = auto_connect(sock, msg);
 		if (res)
@@ -985,24 +950,20 @@ restart:
 	}
 
 	/* Discard an empty non-errored message & try again */
-
 	if ((!sz) && (!err)) {
 		advance_rx_queue(sk);
 		goto restart;
 	}
 
 	/* Capture sender's address (optional) */
-
 	set_orig_addr(m, msg);
 
 	/* Capture ancillary data (optional) */
-
 	res = anc_data_recv(m, msg, tport);
 	if (res)
 		goto exit;
 
 	/* Capture message data (if valid) & compute return value (always) */
-
 	if (!err) {
 		if (unlikely(buf_len < sz)) {
 			sz = buf_len;
@@ -1022,7 +983,6 @@ restart:
 	}
 
 	/* Consume received message (optional) */
-
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state != SS_READY) &&
 		    (++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
@@ -1046,7 +1006,6 @@ exit:
  *
  * Returns size of returned message data, errno otherwise
  */
-
 static int recv_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t buf_len, int flags)
 {
@@ -1062,7 +1021,6 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	int res = 0;
 
 	/* Catch invalid receive attempts */
-
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
@@ -1076,10 +1034,9 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, buf_len);
 	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
-restart:
 
+restart:
 	/* Look for a message in receive queue; wait if necessary */
-
 	while (skb_queue_empty(&sk->sk_receive_queue)) {
 		if (sock->state == SS_DISCONNECTING) {
 			res = -ENOTCONN;
@@ -1097,21 +1054,18 @@ restart:
 	}
 
 	/* Look at first message in receive queue */
-
 	buf = skb_peek(&sk->sk_receive_queue);
 	msg = buf_msg(buf);
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
 
 	/* Discard an empty non-errored message & try again */
-
 	if ((!sz) && (!err)) {
 		advance_rx_queue(sk);
 		goto restart;
 	}
 
 	/* Optionally capture sender's address & ancillary data of first msg */
-
 	if (sz_copied == 0) {
 		set_orig_addr(m, msg);
 		res = anc_data_recv(m, msg, tport);
@@ -1120,7 +1074,6 @@ restart:
 	}
 
 	/* Capture message data (if valid) & compute return value (always) */
-
 	if (!err) {
 		u32 offset = (u32)(unsigned long)(TIPC_SKB_CB(buf)->handle);
 
@@ -1152,7 +1105,6 @@ restart:
 	}
 
 	/* Consume received message (optional) */
-
 	if (likely(!(flags & MSG_PEEK))) {
 		if (unlikely(++tport->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
 			tipc_acknowledge(tport->ref, tport->conn_unacked);
@@ -1160,7 +1112,6 @@ restart:
 	}
 
 	/* Loop around if more data is required */
-
 	if ((sz_copied < buf_len) &&	/* didn't get all requested data */
 	    (!skb_queue_empty(&sk->sk_receive_queue) ||
 	    (sz_copied < target)) &&	/* and more is ready or required */
@@ -1181,7 +1132,6 @@ exit:
  *
  * Returns 1 if queue is unable to accept message, 0 otherwise
  */
-
 static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
 {
 	u32 threshold;
@@ -1214,7 +1164,6 @@ static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
  *
  * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
  */
-
 static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	struct socket *sock = sk->sk_socket;
@@ -1222,7 +1171,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	u32 recv_q_len;
 
 	/* Reject message if it is wrong sort of message for socket */
-
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
 		return TIPC_ERR_NO_PORT;
 
@@ -1251,7 +1199,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	}
 
 	/* Reject message if there isn't room to queue it */
-
 	recv_q_len = (u32)atomic_read(&tipc_queue_size);
 	if (unlikely(recv_q_len >= OVERLOAD_LIMIT_BASE)) {
 		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
@@ -1264,13 +1211,11 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	}
 
 	/* Enqueue message (finally!) */
-
 	TIPC_SKB_CB(buf)->handle = 0;
 	atomic_inc(&tipc_queue_size);
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
 
 	/* Initiate connection termination for an incoming 'FIN' */
-
 	if (unlikely(msg_errcode(msg) && (sock->state == SS_CONNECTED))) {
 		sock->state = SS_DISCONNECTING;
 		tipc_disconnect_port(tipc_sk_port(sk));
@@ -1290,7 +1235,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
  *
  * Returns 0
  */
-
 static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	u32 res;
@@ -1310,7 +1254,6 @@ static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
  *
  * Returns TIPC error status code (TIPC_OK if message is not to be rejected)
  */
-
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 {
 	struct sock *sk = (struct sock *)tport->usr_handle;
@@ -1322,7 +1265,6 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 	 * This code is based on sk_receive_skb(), but must be distinct from it
 	 * since a TIPC-specific filter/reject mechanism is utilized
 	 */
-
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
@@ -1343,7 +1285,6 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
  *
  * Called with port lock already taken.
  */
-
 static void wakeupdispatch(struct tipc_port *tport)
 {
 	struct sock *sk = (struct sock *)tport->usr_handle;
@@ -1361,7 +1302,6 @@ static void wakeupdispatch(struct tipc_port *tport)
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		   int flags)
 {
@@ -1376,21 +1316,18 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	lock_sock(sk);
 
 	/* For now, TIPC does not allow use of connect() with DGRAM/RDM types */
-
 	if (sock->state == SS_READY) {
 		res = -EOPNOTSUPP;
 		goto exit;
 	}
 
 	/* For now, TIPC does not support the non-blocking form of connect() */
-
 	if (flags & O_NONBLOCK) {
 		res = -EOPNOTSUPP;
 		goto exit;
 	}
 
 	/* Issue Posix-compliant error code if socket is in the wrong state */
-
 	if (sock->state == SS_LISTENING) {
 		res = -EOPNOTSUPP;
 		goto exit;
@@ -1410,18 +1347,15 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	 * Note: send_msg() validates the rest of the address fields,
 	 *       so there's no need to do it here
 	 */
-
 	if (dst->addrtype == TIPC_ADDR_MCAST) {
 		res = -EINVAL;
 		goto exit;
 	}
 
 	/* Reject any messages already in receive queue (very unlikely) */
-
 	reject_rx_queue(sk);
 
 	/* Send a 'SYN-' to destination */
-
 	m.msg_name = dest;
 	m.msg_namelen = destlen;
 	res = send_msg(NULL, sock, &m, 0);
@@ -1429,7 +1363,6 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 
 	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
-
 	timeout = tipc_sk(sk)->conn_timeout;
 	release_sock(sk);
 	res = wait_event_interruptible_timeout(*sk_sleep(sk),
@@ -1474,7 +1407,6 @@ exit:
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int listen(struct socket *sock, int len)
 {
 	struct sock *sk = sock->sk;
@@ -1501,7 +1433,6 @@ static int listen(struct socket *sock, int len)
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int accept(struct socket *sock, struct socket *new_sock, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -1544,11 +1475,9 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		 * Reject any stray messages received by new socket
 		 * before the socket lock was taken (very, very unlikely)
 		 */
-
 		reject_rx_queue(new_sk);
 
 		/* Connect new socket to it's peer */
-
 		new_tsock->peer_name.ref = msg_origport(msg);
 		new_tsock->peer_name.node = msg_orignode(msg);
 		tipc_connect2port(new_ref, &new_tsock->peer_name);
@@ -1564,7 +1493,6 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		 * Respond to 'SYN-' by discarding it & returning 'ACK'-.
 		 * Respond to 'SYN+' by queuing it on new socket.
 		 */
-
 		if (!msg_data_sz(msg)) {
 			struct msghdr m = {NULL,};
 
@@ -1590,7 +1518,6 @@ exit:
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
@@ -1607,8 +1534,8 @@ static int shutdown(struct socket *sock, int how)
 	case SS_CONNECTING:
 	case SS_CONNECTED:
 
-		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
 restart:
+		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf) {
 			atomic_dec(&tipc_queue_size);
@@ -1629,7 +1556,6 @@ restart:
 	case SS_DISCONNECTING:
 
 		/* Discard any unreceived messages; wake up sleeping tasks */
-
 		discard_rx_queue(sk);
 		if (waitqueue_active(sk_sleep(sk)))
 			wake_up_interruptible(sk_sleep(sk));
@@ -1657,7 +1583,6 @@ restart:
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int setsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, unsigned int ol)
 {
@@ -1717,7 +1642,6 @@ static int setsockopt(struct socket *sock,
  *
  * Returns 0 on success, errno otherwise
  */
-
 static int getsockopt(struct socket *sock,
 		      int lvl, int opt, char __user *ov, int __user *ol)
 {
@@ -1778,7 +1702,6 @@ static int getsockopt(struct socket *sock,
 /**
  * Protocol switches for the various types of TIPC sockets
  */
-
 static const struct proto_ops msg_ops = {
 	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
@@ -1884,7 +1807,6 @@ int tipc_socket_init(void)
 /**
  * tipc_socket_stop - stop TIPC socket interface
  */
-
 void tipc_socket_stop(void)
 {
 	if (!sockets_enabled)
@@ -1894,4 +1816,3 @@ void tipc_socket_stop(void)
 	sock_unregister(tipc_family_ops.family);
 	proto_unregister(&tipc_proto);
 }
-
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index af93ea9..f976e9c 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -46,7 +46,6 @@
  * @subscriber_list: adjacent subscribers in top. server's list of subscribers
  * @subscription_list: list of subscription objects for this subscriber
  */
-
 struct tipc_subscriber {
 	u32 port_ref;
 	spinlock_t *lock;
@@ -61,7 +60,6 @@ struct tipc_subscriber {
  * @subscriber_list: list of ports subscribing to service
  * @lock: spinlock govering access to subscriber list
  */
-
 struct top_srv {
 	u32 setup_port;
 	atomic_t subscription_count;
@@ -78,7 +76,6 @@ static struct top_srv topsrv;
  *
  * Returns converted value
  */
-
 static u32 htohl(u32 in, int swap)
 {
 	return swap ? swab32(in) : in;
@@ -90,7 +87,6 @@ static u32 htohl(u32 in, int swap)
  * Note: Must not hold subscriber's server port lock, since tipc_send() will
  *       try to take the lock if the message is rejected and returned!
  */
-
 static void subscr_send_event(struct tipc_subscription *sub,
 			      u32 found_lower,
 			      u32 found_upper,
@@ -116,7 +112,6 @@ static void subscr_send_event(struct tipc_subscription *sub,
  *
  * Returns 1 if there is overlap, otherwise 0.
  */
-
 int tipc_subscr_overlap(struct tipc_subscription *sub,
 			u32 found_lower,
 			u32 found_upper)
@@ -136,7 +131,6 @@ int tipc_subscr_overlap(struct tipc_subscription *sub,
  *
  * Protected by nameseq.lock in name_table.c
  */
-
 void tipc_subscr_report_overlap(struct tipc_subscription *sub,
 				u32 found_lower,
 				u32 found_upper,
@@ -156,43 +150,35 @@ void tipc_subscr_report_overlap(struct tipc_subscription *sub,
 /**
  * subscr_timeout - subscription timeout has occurred
  */
-
 static void subscr_timeout(struct tipc_subscription *sub)
 {
 	struct tipc_port *server_port;
 
 	/* Validate server port reference (in case subscriber is terminating) */
-
 	server_port = tipc_port_lock(sub->server_ref);
 	if (server_port == NULL)
 		return;
 
 	/* Validate timeout (in case subscription is being cancelled) */
-
 	if (sub->timeout == TIPC_WAIT_FOREVER) {
 		tipc_port_unlock(server_port);
 		return;
 	}
 
 	/* Unlink subscription from name table */
-
 	tipc_nametbl_unsubscribe(sub);
 
 	/* Unlink subscription from subscriber */
-
 	list_del(&sub->subscription_list);
 
 	/* Release subscriber's server port */
-
 	tipc_port_unlock(server_port);
 
 	/* Notify subscriber of timeout */
-
 	subscr_send_event(sub, sub->evt.s.seq.lower, sub->evt.s.seq.upper,
 			  TIPC_SUBSCR_TIMEOUT, 0, 0);
 
 	/* Now destroy subscription */
-
 	k_term_timer(&sub->timer);
 	kfree(sub);
 	atomic_dec(&topsrv.subscription_count);
@@ -203,7 +189,6 @@ static void subscr_timeout(struct tipc_subscription *sub)
  *
  * Called with subscriber port locked.
  */
-
 static void subscr_del(struct tipc_subscription *sub)
 {
 	tipc_nametbl_unsubscribe(sub);
@@ -222,7 +207,6 @@ static void subscr_del(struct tipc_subscription *sub)
  * a new object reference in the interim that uses this lock; this routine will
  * simply wait for it to be released, then claim it.)
  */
-
 static void subscr_terminate(struct tipc_subscriber *subscriber)
 {
 	u32 port_ref;
@@ -230,18 +214,15 @@ static void subscr_terminate(struct tipc_subscriber *subscriber)
 	struct tipc_subscription *sub_temp;
 
 	/* Invalidate subscriber reference */
-
 	port_ref = subscriber->port_ref;
 	subscriber->port_ref = 0;
 	spin_unlock_bh(subscriber->lock);
 
 	/* Sever connection to subscriber */
-
 	tipc_shutdown(port_ref);
 	tipc_deleteport(port_ref);
 
 	/* Destroy any existing subscriptions for subscriber */
-
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
 		if (sub->timeout != TIPC_WAIT_FOREVER) {
@@ -252,17 +233,14 @@ static void subscr_terminate(struct tipc_subscriber *subscriber)
 	}
 
 	/* Remove subscriber from topology server's subscriber list */
-
 	spin_lock_bh(&topsrv.lock);
 	list_del(&subscriber->subscriber_list);
 	spin_unlock_bh(&topsrv.lock);
 
 	/* Reclaim subscriber lock */
-
 	spin_lock_bh(subscriber->lock);
 
 	/* Now destroy subscriber */
-
 	kfree(subscriber);
 }
 
@@ -275,7 +253,6 @@ static void subscr_terminate(struct tipc_subscriber *subscriber)
  *
  * Note that fields of 's' use subscriber's endianness!
  */
-
 static void subscr_cancel(struct tipc_subscr *s,
 			  struct tipc_subscriber *subscriber)
 {
@@ -284,7 +261,6 @@ static void subscr_cancel(struct tipc_subscr *s,
 	int found = 0;
 
 	/* Find first matching subscription, exit if not found */
-
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
 		if (!memcmp(s, &sub->evt.s, sizeof(struct tipc_subscr))) {
@@ -296,7 +272,6 @@ static void subscr_cancel(struct tipc_subscr *s,
 		return;
 
 	/* Cancel subscription timer (if used), then delete subscription */
-
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
 		sub->timeout = TIPC_WAIT_FOREVER;
 		spin_unlock_bh(subscriber->lock);
@@ -312,7 +287,6 @@ static void subscr_cancel(struct tipc_subscr *s,
  *
  * Called with subscriber port locked.
  */
-
 static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 					     struct tipc_subscriber *subscriber)
 {
@@ -320,11 +294,9 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	int swap;
 
 	/* Determine subscriber's endianness */
-
 	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
 
 	/* Detect & process a subscription cancellation request */
-
 	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
 		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
 		subscr_cancel(s, subscriber);
@@ -332,7 +304,6 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	}
 
 	/* Refuse subscription if global limit exceeded */
-
 	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
 		warn("Subscription rejected, subscription limit reached (%u)\n",
 		     tipc_max_subscriptions);
@@ -341,7 +312,6 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	}
 
 	/* Allocate subscription object */
-
 	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
 		warn("Subscription rejected, no memory\n");
@@ -350,7 +320,6 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	}
 
 	/* Initialize subscription object */
-
 	sub->seq.type = htohl(s->seq.type, swap);
 	sub->seq.lower = htohl(s->seq.lower, swap);
 	sub->seq.upper = htohl(s->seq.upper, swap);
@@ -384,7 +353,6 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
  *
  * Called with subscriber's server port unlocked.
  */
-
 static void subscr_conn_shutdown_event(void *usr_handle,
 				       u32 port_ref,
 				       struct sk_buff **buf,
@@ -408,7 +376,6 @@ static void subscr_conn_shutdown_event(void *usr_handle,
  *
  * Called with subscriber's server port unlocked.
  */
-
 static void subscr_conn_msg_event(void *usr_handle,
 				  u32 port_ref,
 				  struct sk_buff **buf,
@@ -423,7 +390,6 @@ static void subscr_conn_msg_event(void *usr_handle,
 	 * Lock subscriber's server port (& make a local copy of lock pointer,
 	 * in case subscriber is deleted while processing subscription request)
 	 */
-
 	if (tipc_port_lock(port_ref) == NULL)
 		return;
 
@@ -451,7 +417,6 @@ static void subscr_conn_msg_event(void *usr_handle,
 			 *    timeout code cannot delete the subscription,
 			 * so the subscription object is still protected.
 			 */
-
 			tipc_nametbl_subscribe(sub);
 		}
 	}
@@ -460,7 +425,6 @@ static void subscr_conn_msg_event(void *usr_handle,
 /**
  * subscr_named_msg_event - handle request to establish a new subscriber
  */
-
 static void subscr_named_msg_event(void *usr_handle,
 				   u32 port_ref,
 				   struct sk_buff **buf,
@@ -474,7 +438,6 @@ static void subscr_named_msg_event(void *usr_handle,
 	u32 server_port_ref;
 
 	/* Create subscriber object */
-
 	subscriber = kzalloc(sizeof(struct tipc_subscriber), GFP_ATOMIC);
 	if (subscriber == NULL) {
 		warn("Subscriber rejected, no memory\n");
@@ -484,7 +447,6 @@ static void subscr_named_msg_event(void *usr_handle,
 	INIT_LIST_HEAD(&subscriber->subscriber_list);
 
 	/* Create server port & establish connection to subscriber */
-
 	tipc_createport(subscriber,
 			importance,
 			NULL,
@@ -503,26 +465,21 @@ static void subscr_named_msg_event(void *usr_handle,
 	tipc_connect2port(subscriber->port_ref, orig);
 
 	/* Lock server port (& save lock address for future use) */
-
 	subscriber->lock = tipc_port_lock(subscriber->port_ref)->lock;
 
 	/* Add subscriber to topology server's subscriber list */
-
 	spin_lock_bh(&topsrv.lock);
 	list_add(&subscriber->subscriber_list, &topsrv.subscriber_list);
 	spin_unlock_bh(&topsrv.lock);
 
 	/* Unlock server port */
-
 	server_port_ref = subscriber->port_ref;
 	spin_unlock_bh(subscriber->lock);
 
 	/* Send an ACK- to complete connection handshaking */
-
 	tipc_send(server_port_ref, 0, NULL, 0);
 
 	/* Handle optional subscription request */
-
 	if (size != 0) {
 		subscr_conn_msg_event(subscriber, server_port_ref,
 				      buf, data, size);
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index ef6529c..218d2e0 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -51,7 +51,6 @@ struct tipc_subscription;
  * @swap: indicates if subscriber uses opposite endianness in its messages
  * @evt: template for events generated by subscription
  */
-
 struct tipc_subscription {
 	struct tipc_name_seq seq;
 	u32 timeout;
@@ -80,5 +79,4 @@ int tipc_subscr_start(void);
 
 void tipc_subscr_stop(void);
 
-
 #endif
-- 
1.7.9.6
