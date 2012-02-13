From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/5] bcm63xx-enet: fix PHY name to match MDIO bus name
Date: Mon, 13 Feb 2012 12:23:21 +0100
Message-ID: <1329132204-27946-3-git-send-email-florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36775 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357Ab2BMLX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:57 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3e617506: bcm63xx_enet: use an unique MDIO bus name introduced
a regression in the PHY connection logic, since the PHY name was formatted
to expect the bus name to be "0" or "1", whereas it is now "bcm63xx-enet-0"
or "bcm63xx-enet-1".

CC: stable@vger.kernel.org
Reported-by: Joel EJC <joel_ejc@yahoofr>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 986019b..c7ca7ec 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -797,7 +797,7 @@ static int bcm_enet_open(struct net_device *dev)
 	if (priv->has_phy) {
 		/* connect to PHY */
 		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-			 priv->mac_id ? "1" : "0", priv->phy_id);
+			 priv->mii_bus->id, priv->phy_id);
 
 		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
 				     PHY_INTERFACE_MODE_MII);
-- 
1.7.5.4
