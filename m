From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 25/26] tipc: Eliminate obsolete routine for handling routed messages
Date: Sun, 13 Mar 2011 17:34:13 -0400
Message-ID: <1300052054-7531-26-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50010 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266Ab1CMVfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:35:04 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates a routine that is used in handling messages arriving from
another cluster or zone. Such messages can no longer be received by TIPC
now that multi-cluster and multi-zone network support has been eliminated.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    3 ---
 net/tipc/msg.c  |    6 ------
 net/tipc/msg.h  |    7 -------
 3 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a572f0a..43639ff 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2423,9 +2423,6 @@ static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 	else
 		destaddr = msg_destnode(inmsg);
 
-	if (msg_routed(inmsg))
-		msg_set_prevnode(inmsg, tipc_own_addr);
-
 	/* Prepare reusable fragment header: */
 
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 0562b38..6d92d17 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -192,8 +192,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 		default:
 			tipc_printf(buf, "UNKNOWN TYPE %u", msg_type(msg));
 		}
-		if (msg_routed(msg) && !msg_non_seq(msg))
-			tipc_printf(buf, "ROUT:");
 		if (msg_reroute_cnt(msg))
 			tipc_printf(buf, "REROUTED(%u):",
 				    msg_reroute_cnt(msg));
@@ -210,8 +208,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 		default:
 			tipc_printf(buf, "UNKNOWN:%x", msg_type(msg));
 		}
-		if (msg_routed(msg))
-			tipc_printf(buf, "ROUT:");
 		if (msg_reroute_cnt(msg))
 			tipc_printf(buf, "REROUTED(%u):",
 				    msg_reroute_cnt(msg));
@@ -232,8 +228,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 		default:
 			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
-		if (msg_routed(msg))
-			tipc_printf(buf, "ROUT:");
 		if (msg_reroute_cnt(msg))
 			tipc_printf(buf, "REROUTED(%u):", msg_reroute_cnt(msg));
 		break;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7b4f4d7..de02339 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -421,13 +421,6 @@ static inline int msg_is_dest(struct tipc_msg *m, u32 d)
 	return msg_short(m) || (msg_destnode(m) == d);
 }
 
-static inline u32 msg_routed(struct tipc_msg *m)
-{
-	if (likely(msg_short(m)))
-		return 0;
-	return (msg_destnode(m) ^ msg_orignode(m)) >> 11;
-}
-
 static inline u32 msg_nametype(struct tipc_msg *m)
 {
 	return msg_word(m, 8);
-- 
1.7.3.3

