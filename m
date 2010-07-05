From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net: correct valid flag
Date: Mon, 5 Jul 2010 17:07:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1007051706530.15185@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:49030 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab0GEPHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 11:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Elsewhere in the "optimized" functions, the "2" constants are used.
NV_TX_VALID and NV_TX2_VALID have the same value.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 268ea4d..870c18b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2468,7 +2468,8 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
-	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
+	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID)
+	       &&
 	       (tx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
