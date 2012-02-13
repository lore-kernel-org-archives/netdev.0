From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/5] cpmac: fix PHY name to match MDIO bus name
Date: Mon, 13 Feb 2012 12:23:20 +0100
Message-ID: <1329132204-27946-2-git-send-email-florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36768 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab2BMLX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:57 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d1733f07: cpmac: use an unique MDIO bus name changed the MDIO bus
name from "1" to "cpmac-1", this breaks the PHY connection logic because
the PHY name still uses the old bus names "0" and "1", fix that to
always use the mdio bus id instead.

CC: stable@vger.kernel.org
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/ti/cpmac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 97e1df3..860c252 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1122,7 +1122,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	pdata = pdev->dev.platform_data;
 
 	if (external_switch || dumb_switch) {
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
+		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	} else {
 		for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
@@ -1138,7 +1138,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	if (phy_id == PHY_MAX_ADDR) {
 		dev_err(&pdev->dev, "no PHY present, falling back "
 					"to switch on MDIO bus 0\n");
-		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
+		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	}
 
-- 
1.7.5.4
