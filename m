From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: fix sparse warnings in new nl api
Date: Mon, 24 Nov 2014 11:10:29 +0100
Message-ID: <1416823829-19277-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:65404 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbaKXKNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 05:13:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

Fix sparse warnings about non-static declaration of static functions
in the new tipc netlink API.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 net/tipc/bcast.c      |  3 ++-
 net/tipc/bearer.c     |  6 ++++--
 net/tipc/link.c       | 10 ++++++----
 net/tipc/name_table.c | 13 +++++++------
 net/tipc/node.c       |  2 +-
 net/tipc/socket.c     | 16 +++++++++-------
 6 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index dcf3589..556b26a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -767,7 +767,8 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 	tipc_bclink_unlock();
 }
 
-int __tipc_nl_add_bc_link_stat(struct sk_buff *skb, struct tipc_stats *stats)
+static int __tipc_nl_add_bc_link_stat(struct sk_buff *skb,
+				      struct tipc_stats *stats)
 {
 	int i;
 	struct nlattr *nest;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 5f6f323..463db5b 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -647,7 +647,8 @@ void tipc_bearer_stop(void)
 }
 
 /* Caller should hold rtnl_lock to protect the bearer */
-int __tipc_nl_add_bearer(struct tipc_nl_msg *msg, struct tipc_bearer *bearer)
+static int __tipc_nl_add_bearer(struct tipc_nl_msg *msg,
+				struct tipc_bearer *bearer)
 {
 	void *hdr;
 	struct nlattr *attrs;
@@ -905,7 +906,8 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
-int __tipc_nl_add_media(struct tipc_nl_msg *msg, struct tipc_media *media)
+static int __tipc_nl_add_media(struct tipc_nl_msg *msg,
+			       struct tipc_media *media)
 {
 	void *hdr;
 	struct nlattr *attrs;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 629e8cf..4738cb1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2514,7 +2514,8 @@ out:
 
 	return res;
 }
-int __tipc_nl_add_stats(struct sk_buff *skb, struct tipc_stats *s)
+
+static int __tipc_nl_add_stats(struct sk_buff *skb, struct tipc_stats *s)
 {
 	int i;
 	struct nlattr *stats;
@@ -2580,7 +2581,7 @@ msg_full:
 }
 
 /* Caller should hold appropriate locks to protect the link */
-int __tipc_nl_add_link(struct tipc_nl_msg *msg, struct tipc_link *link)
+static int __tipc_nl_add_link(struct tipc_nl_msg *msg, struct tipc_link *link)
 {
 	int err;
 	void *hdr;
@@ -2649,8 +2650,9 @@ msg_full:
 }
 
 /* Caller should hold node lock  */
-int __tipc_nl_add_node_links(struct tipc_nl_msg *msg, struct tipc_node *node,
-			     u32 *prev_link)
+static int __tipc_nl_add_node_links(struct tipc_nl_msg *msg,
+				    struct tipc_node *node,
+				    u32 *prev_link)
 {
 	u32 i;
 	int err;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 30ca8e0..7cfb7a4 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1002,8 +1002,9 @@ void tipc_nametbl_stop(void)
 	write_unlock_bh(&tipc_nametbl_lock);
 }
 
-int __tipc_nl_add_nametable_publ(struct tipc_nl_msg *msg, struct name_seq *seq,
-				 struct sub_seq *sseq, u32 *last_publ)
+static int __tipc_nl_add_nametable_publ(struct tipc_nl_msg *msg,
+					struct name_seq *seq,
+					struct sub_seq *sseq, u32 *last_publ)
 {
 	void *hdr;
 	struct nlattr *attrs;
@@ -1071,8 +1072,8 @@ msg_full:
 	return -EMSGSIZE;
 }
 
-int __tipc_nl_subseq_list(struct tipc_nl_msg *msg, struct name_seq *seq,
-			  u32 *last_lower, u32 *last_publ)
+static int __tipc_nl_subseq_list(struct tipc_nl_msg *msg, struct name_seq *seq,
+				 u32 *last_lower, u32 *last_publ)
 {
 	struct sub_seq *sseq;
 	struct sub_seq *sseq_start;
@@ -1098,8 +1099,8 @@ int __tipc_nl_subseq_list(struct tipc_nl_msg *msg, struct name_seq *seq,
 	return 0;
 }
 
-int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type, u32 *last_lower,
-		       u32 *last_publ)
+static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
+			      u32 *last_lower, u32 *last_publ)
 {
 	struct hlist_head *seq_head;
 	struct name_seq *seq;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 72a75d4..82e5edd 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -609,7 +609,7 @@ void tipc_node_unlock(struct tipc_node *node)
 }
 
 /* Caller should hold node lock for the passed node */
-int __tipc_nl_add_node(struct tipc_nl_msg *msg, struct tipc_node *node)
+static int __tipc_nl_add_node(struct tipc_nl_msg *msg, struct tipc_node *node)
 {
 	void *hdr;
 	struct nlattr *attrs;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e918091..6aa8c6a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2811,7 +2811,7 @@ void tipc_socket_stop(void)
 }
 
 /* Caller should hold socket lock for the passed tipc socket. */
-int __tipc_nl_add_sk_con(struct sk_buff *skb, struct tipc_sock *tsk)
+static int __tipc_nl_add_sk_con(struct sk_buff *skb, struct tipc_sock *tsk)
 {
 	u32 peer_node;
 	u32 peer_port;
@@ -2846,8 +2846,8 @@ msg_full:
 }
 
 /* Caller should hold socket lock for the passed tipc socket. */
-int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
-		     struct tipc_sock *tsk)
+static int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
+			    struct tipc_sock *tsk)
 {
 	int err;
 	void *hdr;
@@ -2912,8 +2912,9 @@ int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 /* Caller should hold socket lock for the passed tipc socket. */
-int __tipc_nl_add_sk_publ(struct sk_buff *skb, struct netlink_callback *cb,
-			  struct publication *publ)
+static int __tipc_nl_add_sk_publ(struct sk_buff *skb,
+				 struct netlink_callback *cb,
+				 struct publication *publ)
 {
 	void *hdr;
 	struct nlattr *attrs;
@@ -2950,8 +2951,9 @@ msg_cancel:
 }
 
 /* Caller should hold socket lock for the passed tipc socket. */
-int __tipc_nl_list_sk_publ(struct sk_buff *skb, struct netlink_callback *cb,
-			   struct tipc_sock *tsk, u32 *last_publ)
+static int __tipc_nl_list_sk_publ(struct sk_buff *skb,
+				  struct netlink_callback *cb,
+				  struct tipc_sock *tsk, u32 *last_publ)
 {
 	int err;
 	struct publication *p;
-- 
2.1.1
