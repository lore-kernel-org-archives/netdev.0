From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 04/10] ftgmac100: Set netdev->hw_features
Date: Wed, 12 Apr 2017 13:27:04 +1000
Message-ID: <20170412032710.17546-5-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41850 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751992AbdDLD1e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:34 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So features can be turned on/off via ethtool

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bd25b6b..cef5909 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1472,14 +1472,15 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	}
 
 	/* Base feature set */
-	netdev->features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
+	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
 		NETIF_F_GRO | NETIF_F_SG;
 
 	/* AST2400  doesn't have working HW checksum generation */
 	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac")))
-		netdev->features &= ~NETIF_F_HW_CSUM;
+		netdev->hw_features &= ~NETIF_F_HW_CSUM;
 	if (np && of_get_property(np, "no-hw-checksum", NULL))
-		netdev->features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM);
+		netdev->hw_features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM);
+	netdev->features |= netdev->hw_features;
 
 	/* register network device */
 	err = register_netdev(netdev);
-- 
2.9.3
