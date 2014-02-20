From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next 1/3] net: bcmgenet: drop checks on priv->phydev
Date: Thu, 20 Feb 2014 12:53:49 -0800
Message-ID: <1392929631-7685-2-git-send-email-f.fainelli@gmail.com>
References: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:33703 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbaBTUyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 15:54:20 -0500
In-Reply-To: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop all the checks on priv->phydev since we will refuse probing the
driver if we cannot attach to a PHY device. Drop all checks on
priv->phydev. This also fixes some smatch issues reported by Dan
Carpenter where smatch would complain that a pointer is not always
checked correctly.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0ebc297..8af5f07 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -732,8 +732,7 @@ static void bcmgenet_power_down(struct bcmgenet_priv *priv,
 
 	switch (mode) {
 	case GENET_POWER_CABLE_SENSE:
-		if (priv->phydev)
-			phy_detach(priv->phydev);
+		phy_detach(priv->phydev);
 		break;
 
 	case GENET_POWER_PASSIVE:
@@ -1811,8 +1810,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 	/* Link UP/DOWN event */
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
 		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
-		if (priv->phydev)
-			phy_mac_interrupt(priv->phydev,
+		phy_mac_interrupt(priv->phydev,
 				(priv->irq0_stat & UMAC_IRQ_LINK_UP));
 		priv->irq0_stat &= ~(UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN);
 	}
@@ -1931,8 +1929,7 @@ static int bcmgenet_wol_resume(struct bcmgenet_priv *priv)
 	if (ret)
 		return ret;
 
-	if (priv->phydev)
-		phy_init_hw(priv->phydev);
+	phy_init_hw(priv->phydev);
 	/* Speed settings must be restored */
 	bcmgenet_mii_config(priv->dev);
 
@@ -2058,8 +2055,7 @@ static int bcmgenet_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	phy_start(priv->phydev);
 
 	return 0;
 
@@ -2134,8 +2130,7 @@ static int bcmgenet_close(struct net_device *dev)
 
 	netif_dbg(priv, ifdown, dev, "bcmgenet_close\n");
 
-	if (priv->phydev)
-		phy_stop(priv->phydev);
+	phy_stop(priv->phydev);
 
 	/* Disable MAC receive */
 	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-- 
1.8.3.2
