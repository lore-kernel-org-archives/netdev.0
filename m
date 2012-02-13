From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/5] octeon: fix PHY name to match MDIO bus name
Date: Mon, 13 Feb 2012 12:23:23 +0100
Message-ID: <1329132204-27946-5-git-send-email-florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36785 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763Ab2BMLX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:58 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit "d6c25be: mdio-octeon: use an unique MDIO bus name" changed the
octeon MDIO bus name from "0" to "mdio-octeon-0", change the PHY
formatting logic to account for that name change, so that PHY connection
on this bus succeeds.

CC: stable@vger.kernel.org
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 212f43b..cd827ff 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -670,7 +670,7 @@ static void octeon_mgmt_adjust_link(struct net_device *netdev)
 static int octeon_mgmt_init_phy(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
-	char phy_id[20];
+	char phy_id[MII_BUS_ID_SIZE + 3];
 
 	if (octeon_is_simulation()) {
 		/* No PHYs in the simulator. */
@@ -678,7 +678,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
 		return 0;
 	}
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "0", p->port);
+	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "mdio-octeon-0", p->port);
 
 	p->phydev = phy_connect(netdev, phy_id, octeon_mgmt_adjust_link, 0,
 				PHY_INTERFACE_MODE_MII);
-- 
1.7.5.4
