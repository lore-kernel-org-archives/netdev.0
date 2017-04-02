From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/13] ftgmac100: Remove "enabled" flags
Date: Sun,  2 Apr 2017 13:35:14 +1000
Message-ID: <20170402033523.9482-5-benh@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48965 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751053AbdDBDgA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 23:36:00 -0400
In-Reply-To: <20170402033523.9482-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not used in any meaningful way

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 02e0534..cc2271b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -82,7 +82,6 @@ struct ftgmac100 {
 
 	/* Misc */
 	int int_mask_all;
-	bool enabled;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
@@ -1124,8 +1123,6 @@ static int ftgmac100_open(struct net_device *netdev)
 			goto err_ncsi;
 	}
 
-	priv->enabled = true;
-
 	return 0;
 
 err_ncsi:
@@ -1144,11 +1141,7 @@ static int ftgmac100_stop(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
-	if (!priv->enabled)
-		return 0;
-
 	/* disable all interrupts */
-	priv->enabled = false;
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
 	netif_stop_queue(netdev);
-- 
2.9.3
