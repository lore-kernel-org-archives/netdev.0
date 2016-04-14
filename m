From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 3/3] fec: move to new ethtool api {get|set}_link_ksettings
Date: Fri, 15 Apr 2016 00:35:01 +0200
Message-ID: <1460673301-10599-4-git-send-email-tremyfr@gmail.com>
References: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, decot@googlers.com, f.fainelli@gmail.com,
	fugang.duan@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move the fec driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 08243c2..bfa10c3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2058,8 +2058,8 @@ static void fec_enet_mii_remove(struct fec_enet_private *fep)
 	}
 }
 
-static int fec_enet_get_settings(struct net_device *ndev,
-				  struct ethtool_cmd *cmd)
+static int fec_enet_get_link_ksettings(struct net_device *ndev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct phy_device *phydev = fep->phy_dev;
@@ -2067,11 +2067,11 @@ static int fec_enet_get_settings(struct net_device *ndev,
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(phydev, cmd);
+	return phy_ethtool_ksettings_get(phydev, cmd);
 }
 
-static int fec_enet_set_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
+static int fec_enet_set_link_ksettings(struct net_device *ndev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct phy_device *phydev = fep->phy_dev;
@@ -2079,7 +2079,7 @@ static int fec_enet_set_settings(struct net_device *ndev,
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(phydev, cmd);
+	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 
 static void fec_enet_get_drvinfo(struct net_device *ndev,
@@ -2562,8 +2562,6 @@ fec_enet_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 }
 
 static const struct ethtool_ops fec_enet_ethtool_ops = {
-	.get_settings		= fec_enet_get_settings,
-	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.get_regs_len		= fec_enet_get_regs_len,
 	.get_regs		= fec_enet_get_regs,
@@ -2583,6 +2581,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.set_tunable		= fec_enet_set_tunable,
 	.get_wol		= fec_enet_get_wol,
 	.set_wol		= fec_enet_set_wol,
+	.get_link_ksettings	= fec_enet_get_link_ksettings,
+	.set_link_ksettings	= fec_enet_set_link_ksettings,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
