From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 24/26] tipc: Eliminate remaining support for routing table messages
Date: Sun, 13 Mar 2011 17:34:12 -0400
Message-ID: <1300052054-7531-25-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49998 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262Ab1CMVfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:35:03 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of all remaining code relating to ROUTE_DISTRIBUTOR messages.
These messages were only used in multi-cluster and multi-zone networks,
which TIPC no longer supports. (For safety, TIPC now treats such messages
the same way that it handles other unrecognized messages.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    8 ++++----
 net/tipc/msg.c  |   27 ---------------------------
 net/tipc/msg.h  |   15 ---------------
 3 files changed, 4 insertions(+), 46 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b73adeb..a572f0a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1746,10 +1746,6 @@ deliver:
 						tipc_node_unlock(n_ptr);
 						tipc_link_recv_bundle(buf);
 						continue;
-					case ROUTE_DISTRIBUTOR:
-						tipc_node_unlock(n_ptr);
-						buf_discard(buf);
-						continue;
 					case NAME_DISTRIBUTOR:
 						tipc_node_unlock(n_ptr);
 						tipc_named_recv(buf);
@@ -1776,6 +1772,10 @@ deliver:
 							goto protocol_check;
 						}
 						break;
+					default:
+						buf_discard(buf);
+						buf = NULL;
+						break;
 					}
 				}
 				tipc_node_unlock(n_ptr);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index b694c9a..0562b38 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -274,33 +274,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
 		break;
-	case ROUTE_DISTRIBUTOR:
-		tipc_printf(buf, "ROUTING_MNG:");
-		switch (msg_type(msg)) {
-		case EXT_ROUTING_TABLE:
-			tipc_printf(buf, "EXT_TBL:");
-			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
-			break;
-		case LOCAL_ROUTING_TABLE:
-			tipc_printf(buf, "LOCAL_TBL:");
-			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
-			break;
-		case SLAVE_ROUTING_TABLE:
-			tipc_printf(buf, "DP_TBL:");
-			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
-			break;
-		case ROUTE_ADDITION:
-			tipc_printf(buf, "ADD:");
-			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
-			break;
-		case ROUTE_REMOVAL:
-			tipc_printf(buf, "REMOVE:");
-			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
-			break;
-		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
-		}
-		break;
 	case LINK_CONFIG:
 		tipc_printf(buf, "CFG:");
 		switch (msg_type(msg)) {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5006366..7b4f4d7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -769,21 +769,6 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 }
 
 /*
- * Routing table message data
- */
-
-
-static inline u32 msg_remote_node(struct tipc_msg *m)
-{
-	return msg_word(m, msg_hdr_sz(m)/4);
-}
-
-static inline void msg_set_remote_node(struct tipc_msg *m, u32 a)
-{
-	msg_set_word(m, msg_hdr_sz(m)/4, a);
-}
-
-/*
  * Segmentation message types
  */
 
-- 
1.7.3.3

