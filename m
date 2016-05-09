From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v3 3/3] net: ethernet: fec: use phy_ethtool_{get|set}_link_ksettings
Date: Tue, 10 May 2016 00:19:43 +0200
Message-ID: <1462832383-25541-4-git-send-email-tremyfr@gmail.com>
References: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, f.fainelli@gmail.com, davem@davemloft.net,
	decot@googlers.com, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34835 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbcEIWUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 18:20:13 -0400
In-Reply-To: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9d6e35c..ca2cccc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2061,28 +2061,6 @@ static void fec_enet_mii_remove(struct fec_enet_private *fep)
 	}
 }
 
-static int fec_enet_get_link_ksettings(struct net_device *ndev,
-				       struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = ndev->phydev;
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
-	struct phy_device *phydev = ndev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_set(phydev, cmd);
-}
-
 static void fec_enet_get_drvinfo(struct net_device *ndev,
 				 struct ethtool_drvinfo *info)
 {
@@ -2581,8 +2559,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.set_tunable		= fec_enet_set_tunable,
 	.get_wol		= fec_enet_get_wol,
 	.set_wol		= fec_enet_set_wol,
-	.get_link_ksettings	= fec_enet_get_link_ksettings,
-	.set_link_ksettings	= fec_enet_set_link_ksettings,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
