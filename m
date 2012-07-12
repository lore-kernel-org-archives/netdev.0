From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/8] tipc: factor stats struct out of the larger link struct
Date: Thu, 12 Jul 2012 12:39:54 -0400
Message-ID: <1342111201-9426-2-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43524 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161240Ab2GLQk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:26 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is done to improve readability, and so that we can give
the struct a name that will allow us to declare a local
pointer to it in code, instead of having to always redirect
through the link struct to get to it.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.h |   62 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 30 deletions(-)

diff --git a/net/tipc/link.h b/net/tipc/link.h
index d6a60a9..8024a56 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -63,6 +63,37 @@
  */
 #define MAX_PKT_DEFAULT 1500
 
+struct tipc_stats {
+	u32 sent_info;		/* used in counting # sent packets */
+	u32 recv_info;		/* used in counting # recv'd packets */
+	u32 sent_states;
+	u32 recv_states;
+	u32 sent_probes;
+	u32 recv_probes;
+	u32 sent_nacks;
+	u32 recv_nacks;
+	u32 sent_acks;
+	u32 sent_bundled;
+	u32 sent_bundles;
+	u32 recv_bundled;
+	u32 recv_bundles;
+	u32 retransmitted;
+	u32 sent_fragmented;
+	u32 sent_fragments;
+	u32 recv_fragmented;
+	u32 recv_fragments;
+	u32 link_congs;		/* # port sends blocked by congestion */
+	u32 bearer_congs;
+	u32 deferred_recv;
+	u32 duplicates;
+	u32 max_queue_sz;	/* send queue size high water mark */
+	u32 accu_queue_sz;	/* used for send queue size profiling */
+	u32 queue_sz_counts;	/* used for send queue size profiling */
+	u32 msg_length_counts;	/* used for message length profiling */
+	u32 msg_lengths_total;	/* used for message length profiling */
+	u32 msg_length_profile[7]; /* used for msg. length profiling */
+};
+
 /**
  * struct tipc_link - TIPC link data structure
  * @addr: network address of link's peer node
@@ -175,36 +206,7 @@ struct tipc_link {
 	struct sk_buff *defragm_buf;
 
 	/* Statistics */
-	struct {
-		u32 sent_info;		/* used in counting # sent packets */
-		u32 recv_info;		/* used in counting # recv'd packets */
-		u32 sent_states;
-		u32 recv_states;
-		u32 sent_probes;
-		u32 recv_probes;
-		u32 sent_nacks;
-		u32 recv_nacks;
-		u32 sent_acks;
-		u32 sent_bundled;
-		u32 sent_bundles;
-		u32 recv_bundled;
-		u32 recv_bundles;
-		u32 retransmitted;
-		u32 sent_fragmented;
-		u32 sent_fragments;
-		u32 recv_fragmented;
-		u32 recv_fragments;
-		u32 link_congs;		/* # port sends blocked by congestion */
-		u32 bearer_congs;
-		u32 deferred_recv;
-		u32 duplicates;
-		u32 max_queue_sz;	/* send queue size high water mark */
-		u32 accu_queue_sz;	/* used for send queue size profiling */
-		u32 queue_sz_counts;	/* used for send queue size profiling */
-		u32 msg_length_counts;	/* used for message length profiling */
-		u32 msg_lengths_total;	/* used for message length profiling */
-		u32 msg_length_profile[7]; /* used for msg. length profiling */
-	} stats;
+	struct tipc_stats stats;
 };
 
 struct tipc_port;
-- 
1.7.9.7
