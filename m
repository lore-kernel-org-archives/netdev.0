From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/26] tipc: cosmetic - function names are not to be full sentences
Date: Sun, 13 Mar 2011 17:34:01 -0400
Message-ID: <1300052054-7531-14-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49901 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582Ab1CMVer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:47 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function names like "tipc_node_has_redundant_links" are unweildy
and result in long lines even for simple lines.  The "has" doesn't
contribute any value add, so dropping that is a slight step in the
right direction.   This is a cosmetic change, basic result of:

for i in `grep -l tipc_node_has_ *` ; do sed -i s/tipc_node_has_/tipc_node_/ $i ; done

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c       |    6 +++---
 net/tipc/name_distr.c |    2 +-
 net/tipc/node.c       |    6 +++---
 net/tipc/node.h       |    4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d4f2780..d8a4b90 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -548,7 +548,7 @@ void tipc_link_reset(struct link *l_ptr)
 	tipc_node_link_down(l_ptr->owner, l_ptr);
 	tipc_bearer_remove_dest(l_ptr->b_ptr, l_ptr->addr);
 
-	if (was_active_link && tipc_node_has_active_links(l_ptr->owner) &&
+	if (was_active_link && tipc_node_active_links(l_ptr->owner) &&
 	    l_ptr->owner->permit_changeover) {
 		l_ptr->reset_checkpoint = checkpoint;
 		l_ptr->exp_msg_count = START_CHANGEOVER;
@@ -1954,7 +1954,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
 	}
 
-	if (tipc_node_has_redundant_links(l_ptr->owner))
+	if (tipc_node_redundant_links(l_ptr->owner))
 		msg_set_redundant_link(msg);
 	else
 		msg_clear_redundant_link(msg);
@@ -2064,7 +2064,7 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 		l_ptr->peer_bearer_id = msg_bearer_id(msg);
 
 		/* Synchronize broadcast sequence numbers */
-		if (!tipc_node_has_redundant_links(l_ptr->owner))
+		if (!tipc_node_redundant_links(l_ptr->owner))
 			l_ptr->owner->bclink.last_in = mod(msg_last_bcast(msg));
 		break;
 	case STATE_MSG:
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 1b70d5d..c9fa6df 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -111,7 +111,7 @@ static void named_cluster_distribute(struct sk_buff *buf)
 	struct tipc_node *n_ptr;
 
 	list_for_each_entry(n_ptr, &tipc_node_list, list) {
-		if (tipc_node_has_active_links(n_ptr)) {
+		if (tipc_node_active_links(n_ptr)) {
 			buf_copy = skb_copy(buf, GFP_ATOMIC);
 			if (!buf_copy)
 				break;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 66099cb..ca09b33 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -223,19 +223,19 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr)
 		node_lost_contact(n_ptr);
 }
 
-int tipc_node_has_active_links(struct tipc_node *n_ptr)
+int tipc_node_active_links(struct tipc_node *n_ptr)
 {
 	return n_ptr->active_links[0] != NULL;
 }
 
-int tipc_node_has_redundant_links(struct tipc_node *n_ptr)
+int tipc_node_redundant_links(struct tipc_node *n_ptr)
 {
 	return n_ptr->working_links > 1;
 }
 
 int tipc_node_is_up(struct tipc_node *n_ptr)
 {
-	return tipc_node_has_active_links(n_ptr);
+	return tipc_node_active_links(n_ptr);
 }
 
 struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 02e4927..dde3165 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -115,8 +115,8 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr);
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr);
-int tipc_node_has_active_links(struct tipc_node *n_ptr);
-int tipc_node_has_redundant_links(struct tipc_node *n_ptr);
+int tipc_node_active_links(struct tipc_node *n_ptr);
+int tipc_node_redundant_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
-- 
1.7.3.3

