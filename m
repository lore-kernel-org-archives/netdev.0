From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: fec: use ethtool_phy_{get|set}_link_ksettings
Date: Sat,  7 May 2016 01:18:49 +0200
Message-ID: <1462576729-5932-2-git-send-email-tremyfr@gmail.com>
References: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, fugang.duan@nxp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36078 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758602AbcEFXTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 19:19:04 -0400
In-Reply-To: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the generic ethtool_phy_{get|set}_link_ksettings to
generate the callback for {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   25 ++-----------------------
 1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bfa10c3..00339d0 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2058,29 +2058,8 @@ static void fec_enet_mii_remove(struct fec_enet_private *fep)
 	}
 }
 
-static int fec_enet_get_link_ksettings(struct net_device *ndev,
-				       struct ethtool_link_ksettings *cmd)
-{
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phydev = fep->phy_dev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_get(phydev, cmd);
-}
-
-static int fec_enet_set_link_ksettings(struct net_device *ndev,
-				       const struct ethtool_link_ksettings *cmd)
-{
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phydev = fep->phy_dev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_set(phydev, cmd);
-}
+ethtool_phy_get_link_ksettings(fec_enet, fec_enet_private, phy_dev);
+ethtool_phy_set_link_ksettings(fec_enet, fec_enet_private, phy_dev);
 
 static void fec_enet_get_drvinfo(struct net_device *ndev,
 				 struct ethtool_drvinfo *info)
-- 
1.7.4.4
