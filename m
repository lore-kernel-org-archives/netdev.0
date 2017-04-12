From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 06/10] ftgmac100: Rename ftgmac100_setup_mac to ftgmac100_initial_mac
Date: Wed, 12 Apr 2017 13:27:06 +1000
Message-ID: <20170412032710.17546-7-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36102 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752076AbdDLDoI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:44:08 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To remove more confusion. This function is about obtaining the
initial MAC address at driver probe time.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 4bcd22b..35c54e8 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -182,7 +182,7 @@ static void ftgmac100_write_mac_addr(struct ftgmac100 *priv, const u8 *mac)
 	iowrite32(laddr, priv->base + FTGMAC100_OFFSET_MAC_LADR);
 }
 
-static void ftgmac100_setup_mac(struct ftgmac100 *priv)
+static void ftgmac100_initial_mac(struct ftgmac100 *priv)
 {
 	u8 mac[ETH_ALEN];
 	unsigned int m;
@@ -1440,7 +1440,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	netdev->irq = irq;
 
 	/* MAC address from chip or random one */
-	ftgmac100_setup_mac(priv);
+	ftgmac100_initial_mac(priv);
 
 	np = pdev->dev.of_node;
 	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac") ||
-- 
2.9.3
