From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/5] ixp4xx-eth: fix PHY name to match MDIO bus name
Date: Mon, 13 Feb 2012 12:23:24 +0100
Message-ID: <1329132204-27946-6-git-send-email-florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36788 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754903Ab2BMLX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:59 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0869b3a4: ixp4xx-eth: use an unique MDIO bus name changed
the MDIO bus name from "0" to "ixp4xx-eth-0", as a result the PHY
name is not longer appropriate and will not match the MDIO bus name
so PHY connection will not succeed, fix that.

CC: stable@vger.kernel.org
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 72a854f..41a8b5a 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1416,7 +1416,8 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	__raw_writel(DEFAULT_CORE_CNTRL, &port->regs->core_control);
 	udelay(50);
 
-	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
+	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
+		mdio_bus->id, plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(port->phydev)) {
-- 
1.7.5.4
