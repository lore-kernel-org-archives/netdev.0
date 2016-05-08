From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 3/3] net: ethernet: fec: use ethtool_op_{get|set}_link_ksettings
Date: Sun,  8 May 2016 23:44:37 +0200
Message-ID: <1462743877-31738-4-git-send-email-tremyfr@gmail.com>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, davem@davemloft.net, ben@decadent.org.uk,
	kan.liang@intel.com, decot@googlers.com, aduyck@mirantis.com,
	jiri@mellanox.com, jacob.e.keller@intel.com, tom@herbertland.com,
	andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33932 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbcEHVo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 17:44:56 -0400
In-Reply-To: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions ethtool_op_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e1d24ff..f2dae6c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2055,28 +2055,6 @@ static void fec_enet_mii_remove(struct fec_enet_private *fep)
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
@@ -2575,8 +2553,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.set_tunable		= fec_enet_set_tunable,
 	.get_wol		= fec_enet_get_wol,
 	.set_wol		= fec_enet_set_wol,
-	.get_link_ksettings	= fec_enet_get_link_ksettings,
-	.set_link_ksettings	= fec_enet_set_link_ksettings,
+	.get_link_ksettings	= ethtool_op_get_link_ksettings,
+	.set_link_ksettings	= ethtool_op_set_link_ksettings,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
