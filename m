From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/28] tipc: Cosmetic changes to broadcast bearer send routine
Date: Sat, 17 Sep 2011 23:32:03 -0400
Message-ID: <1316316744-29514-8-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49969 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab1IRDcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:45 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Updates the comments in the broadcast bearer send routine to more
accurately describe the processing done by the routine. Also replaces
the improper use of a TIPC payload message error status symbol (in a place
that has nothing to do with such errors) with its numeric equivalent.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 411c54b..7abdca0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -535,10 +535,11 @@ u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
 /**
  * tipc_bcbearer_send - send a packet through the broadcast pseudo-bearer
  *
- * Send through as many bearers as necessary to reach all nodes
- * that support TIPC multicasting.
+ * Send packet over as many bearers as necessary to reach all nodes
+ * that have joined the broadcast link.
  *
- * Returns 0 if packet sent successfully, non-zero if not
+ * Returns 0 (packet sent successfully) under all circumstances,
+ * since the broadcast link's pseudo-bearer never blocks
  */
 
 static int tipc_bcbearer_send(struct sk_buff *buf,
@@ -547,7 +548,12 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 {
 	int bp_index;
 
-	/* Prepare buffer for broadcasting (if first time trying to send it) */
+	/*
+	 * Prepare broadcast link message for reliable transmission,
+	 * if first time trying to send it;
+	 * preparation is skipped for broadcast link protocol messages
+	 * since they are sent in an unreliable manner and don't need it
+	 */
 
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		struct tipc_msg *msg;
@@ -596,18 +602,12 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		}
 
 		if (bcbearer->remains_new.count == 0)
-			return 0;
+			break;	/* all targets reached */
 
 		bcbearer->remains = bcbearer->remains_new;
 	}
 
-	/*
-	 * Unable to reach all targets (indicate success, since currently
-	 * there isn't code in place to properly block & unblock the
-	 * pseudo-bearer used by the broadcast link)
-	 */
-
-	return TIPC_OK;
+	return 0;
 }
 
 /**
-- 
1.7.4.4
