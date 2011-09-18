From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/28] tipc: Remove redundant search when enabling bearer
Date: Sat, 17 Sep 2011 23:32:16 -0400
Message-ID: <1316316744-29514-21-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49996 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337Ab1IRDc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:57 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes obsolete code that searches for an Ethernet bearer structure entry
to use for a newly enabled bearer, since this search is now performed
at the start of the enabling algorithm.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |   24 +++++++++---------------
 1 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 69bedd8..413b337 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -156,21 +156,15 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	if (!dev)
 		return -ENODEV;
 
-	/* Find Ethernet bearer for device (or create one) */
-
-	while ((eb_ptr != stop) && eb_ptr->dev && (eb_ptr->dev != dev))
-		eb_ptr++;
-	if (eb_ptr == stop)
-		return -EDQUOT;
-	if (!eb_ptr->dev) {
-		eb_ptr->dev = dev;
-		eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
-		eb_ptr->tipc_packet_type.dev = dev;
-		eb_ptr->tipc_packet_type.func = recv_msg;
-		eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
-		INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
-		dev_add_pack(&eb_ptr->tipc_packet_type);
-	}
+	/* Create Ethernet bearer for device */
+
+	eb_ptr->dev = dev;
+	eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
+	eb_ptr->tipc_packet_type.dev = dev;
+	eb_ptr->tipc_packet_type.func = recv_msg;
+	eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
+	INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
+	dev_add_pack(&eb_ptr->tipc_packet_type);
 
 	/* Associate TIPC bearer with Ethernet bearer */
 
-- 
1.7.4.4
