From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 3/4] net: ethernet: fs-enet: move to new ethtool api {get|set}_link_ksettings
Date: Sun,  1 May 2016 17:08:10 +0200
Message-ID: <1462115291-11372-3-git-send-email-tremyfr@gmail.com>
References: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Philippe Reynes <tremyfr@gmail.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	claudiu.manoil@freescale.com, leoli@freescale.com,
	treding@nvidia.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move the fs-enet driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 48a9c17..da90b5a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -847,24 +847,28 @@ static void fs_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs->version = 0;
 }
 
-static int fs_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int fs_get_ksettings(struct net_device *dev,
+			    struct ethtool_link_ksettings *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+	struct phy_device *phydev = fep->phydev;
 
 	if (!fep->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(fep->phydev, cmd);
+	return phy_ethtool_ksettings_get(phydev, cmd);
 }
 
-static int fs_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int fs_set_ksettings(struct net_device *dev,
+			    const struct ethtool_link_ksettings *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+	struct phy_device *phydev = fep->phydev;
 
 	if (!fep->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(fep->phydev, cmd);
+	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 
 static int fs_nway_reset(struct net_device *dev)
@@ -887,14 +891,14 @@ static void fs_set_msglevel(struct net_device *dev, u32 value)
 static const struct ethtool_ops fs_ethtool_ops = {
 	.get_drvinfo = fs_get_drvinfo,
 	.get_regs_len = fs_get_regs_len,
-	.get_settings = fs_get_settings,
-	.set_settings = fs_set_settings,
 	.nway_reset = fs_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = fs_get_msglevel,
 	.set_msglevel = fs_set_msglevel,
 	.get_regs = fs_get_regs,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = fs_get_ksettings,
+	.set_link_ksettings = fs_set_ksettings,
 };
 
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
