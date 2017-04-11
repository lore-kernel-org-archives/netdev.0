From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/10] ftgmac100: Set netdev->hw_features
Date: Tue, 11 Apr 2017 11:04:30 +1000
Message-ID: <20170411010436.23290-5-benh@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51430 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752750AbdDKBGC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:06:02 -0400
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So features can be turned on/off via ethtool

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 3c68823..257243a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1463,14 +1463,15 @@ static int ftgmac100_probe(struct platform_device *pdev)
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
