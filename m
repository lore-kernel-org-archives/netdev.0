From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/16] tipc: add tipc_ prefix to fcns targeted for un-inlining
Date: Tue, 11 May 2010 20:30:12 -0400
Message-ID: <af5e0c1dd3dd32fdab60f9da74db130c7bc2743f.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35239 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab0ELAaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:30 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UUKL000116
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:30 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

These functions have enough code in them such that they
seem like sensible targets for un-inlining.  Prior to doing
that, this adds the tipc_ prefix to the functions, so that
in the event of a panic dump or similar, the subsystem from
which the functions come from is immediately clear.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.h       |    8 ++++----
 net/tipc/bcast.c      |    2 +-
 net/tipc/bcast.h      |   12 ++++++------
 net/tipc/bearer.c     |    4 ++--
 net/tipc/cluster.c    |    2 +-
 net/tipc/discover.c   |    6 +++---
 net/tipc/link.c       |   20 ++++++++++----------
 net/tipc/msg.h        |   14 +++++++-------
 net/tipc/name_distr.c |    2 +-
 net/tipc/name_table.c |    2 +-
 net/tipc/net.c        |    4 ++--
 net/tipc/node.c       |   12 ++++++------
 net/tipc/port.c       |   22 +++++++++++-----------
 13 files changed, 55 insertions(+), 55 deletions(-)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 3ba67e6..4d4aee0 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -67,7 +67,7 @@ static inline int may_route(u32 addr)
 	return(addr ^ tipc_own_addr) >> 11;
 }
 
-static inline int in_scope(u32 domain, u32 addr)
+static inline int tipc_in_scope(u32 domain, u32 addr)
 {
 	if (!domain || (domain == addr))
 		return 1;
@@ -79,10 +79,10 @@ static inline int in_scope(u32 domain, u32 addr)
 }
 
 /**
- * addr_scope - convert message lookup domain to equivalent 2-bit scope value
+ * tipc_addr_scope - convert message lookup domain to a 2-bit scope value
  */
 
-static inline int addr_scope(u32 domain)
+static inline int tipc_addr_scope(u32 domain)
 {
 	if (likely(!domain))
 		return TIPC_ZONE_SCOPE;
@@ -110,7 +110,7 @@ static inline int addr_domain(int sc)
 	return tipc_addr(tipc_zone(tipc_own_addr), 0, 0);
 }
 
-static inline char *addr_string_fill(char *string, u32 addr)
+static inline char *tipc_addr_string_fill(char *string, u32 addr)
 {
 	snprintf(string, 16, "<%u.%u.%u>",
 		 tipc_zone(addr), tipc_cluster(addr), tipc_node(addr));
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a18f26d..a8f22e7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -275,7 +275,7 @@ static void bclink_send_nack(struct tipc_node *n_ptr)
 	buf = buf_acquire(INT_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
-		msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
+		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
 			 INT_H_SIZE, n_ptr->addr);
 		msg_set_mc_netid(msg, tipc_net_id);
 		msg_set_bcast_ack(msg, mod(n_ptr->bclink.last_in));
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 4c1771e..2b1c4a7 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -74,7 +74,7 @@ extern const char tipc_bclink_name[];
 
 
 /**
- * nmap_add - add a node to a node map
+ * tipc_nmap_add - add a node to a node map
  */
 
 static inline void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
@@ -90,7 +90,7 @@ static inline void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node)
 }
 
 /**
- * nmap_remove - remove a node from a node map
+ * tipc_nmap_remove - remove a node from a node map
  */
 
 static inline void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
@@ -106,7 +106,7 @@ static inline void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node)
 }
 
 /**
- * nmap_equal - test for equality of node maps
+ * tipc_nmap_equal - test for equality of node maps
  */
 
 static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b)
@@ -115,7 +115,7 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_m
 }
 
 /**
- * nmap_diff - find differences between node maps
+ * tipc_nmap_diff - find differences between node maps
  * @nm_a: input node map A
  * @nm_b: input node map B
  * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
@@ -143,7 +143,7 @@ static inline void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_m
 }
 
 /**
- * port_list_add - add a port to a port list, ensuring no duplicates
+ * tipc_port_list_add - add a port to a port list, ensuring no duplicates
  */
 
 static inline void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
@@ -176,7 +176,7 @@ static inline void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
 }
 
 /**
- * port_list_free - free dynamically created entries in port_list chain
+ * tipc_port_list_free - free dynamically created entries in port_list chain
  *
  * Note: First item is on stack, so it doesn't need to be released
  */
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 7809137..ccec12f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -493,7 +493,7 @@ int tipc_enable_bearer(const char *name, u32 bcast_scope, u32 priority)
 		return -EINVAL;
 	}
 	if (!tipc_addr_domain_valid(bcast_scope) ||
-	    !in_scope(bcast_scope, tipc_own_addr)) {
+	    !tipc_in_scope(bcast_scope, tipc_own_addr)) {
 		warn("Bearer <%s> rejected, illegal broadcast scope\n", name);
 		return -EINVAL;
 	}
@@ -571,7 +571,7 @@ restart:
 	spin_lock_init(&b_ptr->publ.lock);
 	write_unlock_bh(&tipc_net_lock);
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
-	     name, addr_string_fill(addr_string, bcast_scope), priority);
+	     name, tipc_addr_string_fill(addr_string, bcast_scope), priority);
 	return 0;
 failed:
 	write_unlock_bh(&tipc_net_lock);
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index a7eac00..e68f705 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -238,7 +238,7 @@ static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest)
 	if (buf) {
 		msg = buf_msg(buf);
 		memset((char *)msg, 0, size);
-		msg_init(msg, ROUTE_DISTRIBUTOR, 0, INT_H_SIZE, dest);
+		tipc_msg_init(msg, ROUTE_DISTRIBUTOR, 0, INT_H_SIZE, dest);
 	}
 	return buf;
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ce1390a..fc1fcf5 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -120,7 +120,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 
 	if (buf) {
 		msg = buf_msg(buf);
-		msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
+		tipc_msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
 		msg_set_non_seq(msg, 1);
 		msg_set_req_links(msg, req_links);
 		msg_set_dest_domain(msg, dest_domain);
@@ -144,7 +144,7 @@ static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr,
 	char media_addr_str[64];
 	struct print_buf pb;
 
-	addr_string_fill(node_addr_str, node_addr);
+	tipc_addr_string_fill(node_addr_str, node_addr);
 	tipc_printbuf_init(&pb, media_addr_str, sizeof(media_addr_str));
 	tipc_media_addr_printf(&pb, media_addr);
 	tipc_printbuf_validate(&pb);
@@ -183,7 +183,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 			disc_dupl_alert(b_ptr, tipc_own_addr, &media_addr);
 		return;
 	}
-	if (!in_scope(dest, tipc_own_addr))
+	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
 	if (is_slave(tipc_own_addr) && is_slave(orig))
 		return;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e8320bf..a3616b9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -433,7 +433,7 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
 	msg = l_ptr->pmsg;
-	msg_init(msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE, l_ptr->addr);
+	tipc_msg_init(msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
 	msg_set_session(msg, (tipc_random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
@@ -1025,7 +1025,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 	u32 size = msg_size(msg);
 	u32 dsz = msg_data_sz(msg);
 	u32 queue_size = l_ptr->out_queue_size;
-	u32 imp = msg_tot_importance(msg);
+	u32 imp = tipc_msg_tot_importance(msg);
 	u32 queue_limit = l_ptr->queue_limit[imp];
 	u32 max_packet = l_ptr->max_pkt;
 
@@ -1090,7 +1090,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 			struct tipc_msg bundler_hdr;
 
 			if (bundler) {
-				msg_init(&bundler_hdr, MSG_BUNDLER, OPEN_MSG,
+				tipc_msg_init(&bundler_hdr, MSG_BUNDLER, OPEN_MSG,
 					 INT_H_SIZE, l_ptr->addr);
 				skb_copy_to_linear_data(bundler, &bundler_hdr,
 							INT_H_SIZE);
@@ -1243,7 +1243,7 @@ again:
 	 * (Must not hold any locks while building message.)
 	 */
 
-	res = msg_build(hdr, msg_sect, num_sect, sender->publ.max_pkt,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, sender->publ.max_pkt,
 			!sender->user_port, &buf);
 
 	read_lock_bh(&tipc_net_lock);
@@ -1354,7 +1354,7 @@ again:
 	/* Prepare reusable fragment header: */
 
 	msg_dbg(hdr, ">FRAGMENTING>");
-	msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
+	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, msg_destnode(hdr));
 	msg_set_link_selector(&fragm_hdr, sender->publ.ref);
 	msg_set_size(&fragm_hdr, max_pkt);
@@ -1613,7 +1613,7 @@ static void link_reset_all(unsigned long addr)
 	tipc_node_lock(n_ptr);
 
 	warn("Resetting all links to %s\n",
-	     addr_string_fill(addr_string, n_ptr->addr));
+	     tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (n_ptr->links[i]) {
@@ -1655,7 +1655,7 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 		n_ptr = l_ptr->owner->next;
 		tipc_node_lock(n_ptr);
 
-		addr_string_fill(addr_string, n_ptr->addr);
+		tipc_addr_string_fill(addr_string, n_ptr->addr);
 		tipc_printf(TIPC_OUTPUT, "Multicast link info for %s\n", addr_string);
 		tipc_printf(TIPC_OUTPUT, "Supported: %d,  ", n_ptr->bclink.supported);
 		tipc_printf(TIPC_OUTPUT, "Acked: %u\n", n_ptr->bclink.acked);
@@ -2398,7 +2398,7 @@ void tipc_link_changeover(struct link *l_ptr)
 		return;
 	}
 
-	msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
+	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
 		 ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
@@ -2453,7 +2453,7 @@ void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
 	struct sk_buff *iter;
 	struct tipc_msg tunnel_hdr;
 
-	msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
+	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
 		 DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_msgcnt(&tunnel_hdr, l_ptr->out_queue_size);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
@@ -2659,7 +2659,7 @@ int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 
 	/* Prepare reusable fragment header: */
 
-	msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
+	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, destaddr);
 	msg_set_link_selector(&fragm_hdr, msg_link_selector(inmsg));
 	msg_set_long_msgno(&fragm_hdr, mod(l_ptr->long_msg_seq_no++));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7ee6ae2..fbcd46f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -708,7 +708,7 @@ static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
 #define DSC_REQ_MSG          0
 #define DSC_RESP_MSG         1
 
-static inline u32 msg_tot_importance(struct tipc_msg *m)
+static inline u32 tipc_msg_tot_importance(struct tipc_msg *m)
 {
 	if (likely(msg_isdata(m))) {
 		if (likely(msg_orignode(m) == tipc_own_addr))
@@ -722,7 +722,7 @@ static inline u32 msg_tot_importance(struct tipc_msg *m)
 }
 
 
-static inline void msg_init(struct tipc_msg *m, u32 user, u32 type,
+static inline void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 			    u32 hsize, u32 destnode)
 {
 	memset(m, 0, hsize);
@@ -739,10 +739,10 @@ static inline void msg_init(struct tipc_msg *m, u32 user, u32 type,
 }
 
 /**
- * msg_calc_data_size - determine total data size for message
+ * tipc_msg_calc_data_size - determine total data size for message
  */
 
-static inline int msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
+static inline int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
 {
 	int dsz = 0;
 	int i;
@@ -753,20 +753,20 @@ static inline int msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
 }
 
 /**
- * msg_build - create message using specified header and data
+ * tipc_msg_build - create message using specified header and data
  *
  * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
  *
  * Returns message data size or errno
  */
 
-static inline int msg_build(struct tipc_msg *hdr,
+static inline int tipc_msg_build(struct tipc_msg *hdr,
 			    struct iovec const *msg_sect, u32 num_sect,
 			    int max_size, int usrmem, struct sk_buff** buf)
 {
 	int dsz, sz, hsz, pos, res, cnt;
 
-	dsz = msg_calc_data_size(msg_sect, num_sect);
+	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
 	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
 		*buf = NULL;
 		return -EINVAL;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 10a6989..6ac3c54 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -103,7 +103,7 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 
 	if (buf != NULL) {
 		msg = buf_msg(buf);
-		msg_init(msg, NAME_DISTRIBUTOR, type, LONG_H_SIZE, dest);
+		tipc_msg_init(msg, NAME_DISTRIBUTOR, type, LONG_H_SIZE, dest);
 		msg_set_size(msg, LONG_H_SIZE + size);
 	}
 	return buf;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index acab41a..8ba7962 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -627,7 +627,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	struct name_seq *seq;
 	u32 ref;
 
-	if (!in_scope(*destnode, tipc_own_addr))
+	if (!tipc_in_scope(*destnode, tipc_own_addr))
 		return 0;
 
 	read_lock_bh(&tipc_nametbl_lock);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index d7cd1e0..f61b769 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -219,7 +219,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 
 	/* Handle message for this node */
 	dnode = msg_short(msg) ? tipc_own_addr : msg_destnode(msg);
-	if (in_scope(dnode, tipc_own_addr)) {
+	if (tipc_in_scope(dnode, tipc_own_addr)) {
 		if (msg_isdata(msg)) {
 			if (msg_mcast(msg))
 				tipc_port_recv_mcast(buf, NULL);
@@ -277,7 +277,7 @@ int tipc_net_start(u32 addr)
 
 	info("Started in network mode\n");
 	info("Own node address %s, network identity %u\n",
-	     addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
+	     tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
 	return 0;
 }
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 17cc394..b634942 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -268,7 +268,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 
 		if (n_ptr->link_cnt >= 2) {
 			err("Attempt to create third link to %s\n",
-			    addr_string_fill(addr_string, n_ptr->addr));
+			    tipc_addr_string_fill(addr_string, n_ptr->addr));
 			return NULL;
 		}
 
@@ -280,7 +280,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 		}
 		err("Attempt to establish second link on <%s> to %s\n",
 		    l_ptr->b_ptr->publ.name,
-		    addr_string_fill(addr_string, l_ptr->addr));
+		    tipc_addr_string_fill(addr_string, l_ptr->addr));
 	}
 	return NULL;
 }
@@ -439,7 +439,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		return;
 
 	info("Lost contact with %s\n",
-	     addr_string_fill(addr_string, n_ptr->addr));
+	     tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Abort link changeover */
 	for (i = 0; i < MAX_BEARERS; i++) {
@@ -602,7 +602,7 @@ u32 tipc_available_nodes(const u32 domain)
 
 	read_lock_bh(&tipc_net_lock);
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		if (tipc_node_is_up(n_ptr))
 			cnt++;
@@ -651,7 +651,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	/* Add TLVs for all nodes in scope */
 
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
 		node_info.up = htonl(tipc_node_is_up(n_ptr));
@@ -711,7 +711,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
 		u32 i;
 
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 7641db6..0737680 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -116,7 +116,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq, u32 domain,
 	msg_set_namelower(hdr, seq->lower);
 	msg_set_nameupper(hdr, seq->upper);
 	msg_set_hdr_sz(hdr, MCAST_H_SIZE);
-	res = msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
 			!oport->user_port, &buf);
 	if (unlikely(!buf))
 		return res;
@@ -241,7 +241,7 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
 	msg = &p_ptr->publ.phdr;
-	msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
+	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_origport(msg, ref);
 	p_ptr->last_in_seqno = 41;
 	p_ptr->sent = 1;
@@ -395,7 +395,7 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 	buf = buf_acquire(LONG_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
-		msg_init(msg, usr, type, LONG_H_SIZE, destnode);
+		tipc_msg_init(msg, usr, type, LONG_H_SIZE, destnode);
 		msg_set_errcode(msg, err);
 		msg_set_destport(msg, destport);
 		msg_set_origport(msg, origport);
@@ -439,7 +439,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		return data_sz;
 	}
 	rmsg = buf_msg(rbuf);
-	msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
+	tipc_msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
 	msg_set_errcode(rmsg, err);
 	msg_set_destport(rmsg, msg_origport(msg));
 	msg_set_origport(rmsg, msg_destport(msg));
@@ -480,7 +480,7 @@ int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 	struct sk_buff *buf;
 	int res;
 
-	res = msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
 			!p_ptr->user_port, &buf);
 	if (!buf)
 		return res;
@@ -1343,7 +1343,7 @@ int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
 	struct sk_buff *buf;
 	int res;
 
-	res = msg_build(&sender->publ.phdr, msg_sect, num_sect,
+	res = tipc_msg_build(&sender->publ.phdr, msg_sect, num_sect,
 			MAX_MSG_SIZE, !sender->user_port, &buf);
 	if (likely(buf))
 		tipc_port_recv_msg(buf);
@@ -1383,7 +1383,7 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 	if (port_unreliable(p_ptr)) {
 		p_ptr->publ.congested = 0;
 		/* Just calculate msg length and return */
-		return msg_calc_data_size(msg_sect, num_sect);
+		return tipc_msg_calc_data_size(msg_sect, num_sect);
 	}
 	return -ELINKCONG;
 }
@@ -1466,7 +1466,7 @@ int tipc_forward2name(u32 ref,
 	msg_set_hdr_sz(msg, LONG_H_SIZE);
 	msg_set_nametype(msg, name->type);
 	msg_set_nameinst(msg, name->instance);
-	msg_set_lookup_scope(msg, addr_scope(domain));
+	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
 	if (importance <= TIPC_CRITICAL_IMPORTANCE)
 		msg_set_importance(msg,importance);
 	destport = tipc_nametbl_translate(name->type, name->instance, &destnode);
@@ -1483,7 +1483,7 @@ int tipc_forward2name(u32 ref,
 			return res;
 		if (port_unreliable(p_ptr)) {
 			/* Just calculate msg length and return */
-			return msg_calc_data_size(msg_sect, num_sect);
+			return tipc_msg_calc_data_size(msg_sect, num_sect);
 		}
 		return -ELINKCONG;
 	}
@@ -1539,7 +1539,7 @@ int tipc_forward_buf2name(u32 ref,
 	msg_set_origport(msg, orig->ref);
 	msg_set_nametype(msg, name->type);
 	msg_set_nameinst(msg, name->instance);
-	msg_set_lookup_scope(msg, addr_scope(domain));
+	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
 	msg_set_hdr_sz(msg, LONG_H_SIZE);
 	msg_set_size(msg, LONG_H_SIZE + dsz);
 	destport = tipc_nametbl_translate(name->type, name->instance, &destnode);
@@ -1619,7 +1619,7 @@ int tipc_forward2port(u32 ref,
 		return res;
 	if (port_unreliable(p_ptr)) {
 		/* Just calculate msg length and return */
-		return msg_calc_data_size(msg_sect, num_sect);
+		return tipc_msg_calc_data_size(msg_sect, num_sect);
 	}
 	return -ELINKCONG;
 }
-- 
1.7.1.rc2

