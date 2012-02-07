From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/15] tipc: Remove obsolete broadcast tag capability
Date: Mon,  6 Feb 2012 19:52:44 -0500
Message-ID: <1328575968-20643-12-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50202 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530Ab2BGAxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:16 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates support for the broadcast tag field, which is no longer
used by broadcast link NACK messages.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    1 -
 net/tipc/node.c  |    7 +------
 net/tipc/node.h  |    2 --
 3 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 1f3b160..a9b7132 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -325,7 +325,6 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 		msg_set_bcgap_to(msg, n_ptr->bclink.deferred_head
 				 ? buf_seqno(n_ptr->bclink.deferred_head) - 1
 				 : n_ptr->bclink.last_sent);
-		msg_set_bcast_tag(msg, tipc_own_tag);
 
 		spin_lock_bh(&bc_lock);
 		tipc_bearer_send(&bcbearer->bearer, buf, NULL);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6d8bdfd..7bc45e1 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -49,9 +49,8 @@ LIST_HEAD(tipc_node_list);
 static u32 tipc_num_nodes;
 
 static atomic_t tipc_num_links = ATOMIC_INIT(0);
-u32 tipc_own_tag;
 
-/**
+/*
  * tipc_node_find - locate specified node object, if it exists
  */
 
@@ -309,8 +308,6 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	if (n_ptr->bclink.supportable) {
 		tipc_bclink_add_node(n_ptr->addr);
 		n_ptr->bclink.supported = 1;
-		if (n_ptr->addr < tipc_own_addr)
-			tipc_own_tag++;
 	}
 }
 
@@ -353,8 +350,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 
 		tipc_bclink_remove_node(n_ptr->addr);
 		tipc_bclink_acknowledge(n_ptr, INVALID_LINK_SEQ);
-		if (n_ptr->addr < tipc_own_addr)
-			tipc_own_tag--;
 
 		n_ptr->bclink.supported = 0;
 	}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index c88ce64..e1b78a2 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -114,8 +114,6 @@ static inline unsigned int tipc_hashfn(u32 addr)
 	return addr & (NODE_HTABLE_SIZE - 1);
 }
 
-extern u32 tipc_own_tag;
-
 struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
 void tipc_node_delete(struct tipc_node *n_ptr);
-- 
1.7.9
