From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: gianfar: use phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 01:30:09 +0200
Message-ID: <1463355009-19803-2-git-send-email-tremyfr@gmail.com>
References: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: claudiu.manoil@freescale.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33328 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbcEOXaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:30:23 -0400
In-Reply-To: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   27 +--------------------
 1 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 94a8dc5..56588f2 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -184,29 +184,6 @@ static void gfar_gdrvinfo(struct net_device *dev,
 	strlcpy(drvinfo->bus_info, "N/A", sizeof(drvinfo->bus_info));
 }
 
-
-static int gfar_set_ksettings(struct net_device *dev,
-			      const struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_set(phydev, cmd);
-}
-
-static int gfar_get_ksettings(struct net_device *dev,
-			      struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_get(phydev, cmd);
-}
-
 /* Return the length of the register structure */
 static int gfar_reglen(struct net_device *dev)
 {
@@ -1580,6 +1557,6 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_rxnfc = gfar_set_nfc,
 	.get_rxnfc = gfar_get_nfc,
 	.get_ts_info = gfar_get_ts_info,
-	.get_link_ksettings = gfar_get_ksettings,
-	.set_link_ksettings = gfar_set_ksettings,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
-- 
1.7.4.4
