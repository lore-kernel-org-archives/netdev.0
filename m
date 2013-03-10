From: Jonas Gorski <jogo@openwrt.org>
Subject: [PATCH 2/3] bcm63xx_enet: use managed memory allocations
Date: Sun, 10 Mar 2013 14:57:48 +0100
Message-ID: <1362923869-21346-2-git-send-email-jogo@openwrt.org>
References: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <florian@openwrt.org>,
	Kevin Cernekee <cernekee@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:50580 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab3CJN6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 09:58:01 -0400
In-Reply-To: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Gorski <jogo@openwrt.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 0a43188..8397d1c 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1742,7 +1742,8 @@ static int bcm_enet_probe(struct platform_device *pdev)
 		 * if a slave is not present on hw */
 		bus->phy_mask = ~(1 << priv->phy_id);
 
-		bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+		bus->irq = devm_kzalloc(&pdev->dev, sizeof(int) * PHY_MAX_ADDR,
+					GFP_KERNEL);
 		if (!bus->irq) {
 			ret = -ENOMEM;
 			goto out_free_mdio;
@@ -1803,10 +1804,8 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	return 0;
 
 out_unregister_mdio:
-	if (priv->mii_bus) {
+	if (priv->mii_bus)
 		mdiobus_unregister(priv->mii_bus);
-		kfree(priv->mii_bus->irq);
-	}
 
 out_free_mdio:
 	if (priv->mii_bus)
@@ -1847,7 +1846,6 @@ static int bcm_enet_remove(struct platform_device *pdev)
 
 	if (priv->has_phy) {
 		mdiobus_unregister(priv->mii_bus);
-		kfree(priv->mii_bus->irq);
 		mdiobus_free(priv->mii_bus);
 	} else {
 		struct bcm63xx_enet_platform_data *pd;
-- 
1.7.10.4
