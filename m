From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/8] tipc: rename struct port_list to struct tipc_port_list
Date: Thu, 29 Dec 2011 22:48:51 -0500
Message-ID: <1325216937-5856-3-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63605 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992Ab1L3DtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:11 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this rename so that it is consistent with the majority
of the other tipc structs and to assist in removing any
ambiguity with other similar names in other subsystems.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |   10 +++++-----
 net/tipc/bcast.h      |   10 +++++-----
 net/tipc/name_table.c |    2 +-
 net/tipc/name_table.h |    4 ++--
 net/tipc/port.c       |    8 ++++----
 net/tipc/port.h       |    4 ++--
 6 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b6afe73..653be79 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -893,9 +893,9 @@ static void tipc_nmap_diff(struct tipc_node_map *nm_a,
  * tipc_port_list_add - add a port to a port list, ensuring no duplicates
  */
 
-void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
+void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
 {
-	struct port_list *item = pl_ptr;
+	struct tipc_port_list *item = pl_ptr;
 	int i;
 	int item_sz = PLSIZE;
 	int cnt = pl_ptr->count;
@@ -927,10 +927,10 @@ void tipc_port_list_add(struct port_list *pl_ptr, u32 port)
  *
  */
 
-void tipc_port_list_free(struct port_list *pl_ptr)
+void tipc_port_list_free(struct tipc_port_list *pl_ptr)
 {
-	struct port_list *item;
-	struct port_list *next;
+	struct tipc_port_list *item;
+	struct tipc_port_list *next;
 
 	for (item = pl_ptr->next; item; item = next) {
 		next = item->next;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 3c37fdb..b009666 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -54,15 +54,15 @@ struct tipc_node_map {
 #define PLSIZE 32
 
 /**
- * struct port_list - set of node local destination ports
+ * struct tipc_port_list - set of node local destination ports
  * @count: # of ports in set (only valid for first entry in list)
  * @next: pointer to next entry in list
  * @ports: array of port references
  */
 
-struct port_list {
+struct tipc_port_list {
 	int count;
-	struct port_list *next;
+	struct tipc_port_list *next;
 	u32 ports[PLSIZE];
 };
 
@@ -83,8 +83,8 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_m
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
 }
 
-void tipc_port_list_add(struct port_list *pl_ptr, u32 port);
-void tipc_port_list_free(struct port_list *pl_ptr);
+void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port);
+void tipc_port_list_free(struct tipc_port_list *pl_ptr);
 
 void tipc_bclink_init(void);
 void tipc_bclink_stop(void);
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 46e6b6c..f0abae9 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -625,7 +625,7 @@ not_found:
  */
 
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
-			      struct port_list *dports)
+			      struct tipc_port_list *dports)
 {
 	struct name_seq *seq;
 	struct sub_seq *sseq;
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 62d77e5..c3b0f2c 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -40,7 +40,7 @@
 #include "node_subscr.h"
 
 struct subscription;
-struct port_list;
+struct tipc_port_list;
 
 /*
  * TIPC name types reserved for internal TIPC use (both current and planned)
@@ -90,7 +90,7 @@ extern rwlock_t tipc_nametbl_lock;
 struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space);
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
-			 struct port_list *dports);
+			 struct tipc_port_list *dports);
 int tipc_nametbl_publish_rsv(u32 ref, unsigned int scope,
 			struct tipc_name_seq const *seq);
 struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 54d812a..d91efc6 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -80,7 +80,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 	struct tipc_msg *hdr;
 	struct sk_buff *buf;
 	struct sk_buff *ibuf = NULL;
-	struct port_list dports = {0, NULL, };
+	struct tipc_port_list dports = {0, NULL, };
 	struct tipc_port *oport = tipc_port_deref(ref);
 	int ext_targets;
 	int res;
@@ -142,11 +142,11 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
  * If there is no port list, perform a lookup to create one
  */
 
-void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
+void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 {
 	struct tipc_msg *msg;
-	struct port_list dports = {0, NULL, };
-	struct port_list *item = dp;
+	struct tipc_port_list dports = {0, NULL, };
+	struct tipc_port_list *item = dp;
 	int cnt = 0;
 
 	msg = buf_msg(buf);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index b9aa341..f751807 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -151,7 +151,7 @@ struct tipc_port {
 };
 
 extern spinlock_t tipc_port_list_lock;
-struct port_list;
+struct tipc_port_list;
 
 /*
  * TIPC port manipulation routines
@@ -228,7 +228,7 @@ int tipc_port_reject_sections(struct tipc_port *p_ptr, struct tipc_msg *hdr,
 			      unsigned int total_len, int err);
 struct sk_buff *tipc_port_get_ports(void);
 void tipc_port_recv_proto_msg(struct sk_buff *buf);
-void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp);
+void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp);
 void tipc_port_reinit(void);
 
 /**
-- 
1.7.4.4
