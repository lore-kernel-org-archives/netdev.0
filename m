From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: fs-enet: use phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 16:52:37 +0200
Message-ID: <1463410357-1110-2-git-send-email-tremyfr@gmail.com>
References: <1463410357-1110-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463410357-1110-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   26 +------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index dc3700c..61fd486 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -844,28 +844,6 @@ static void fs_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs->version = 0;
 }
 
-static int fs_get_ksettings(struct net_device *dev,
-			    struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_get(phydev, cmd);
-}
-
-static int fs_set_ksettings(struct net_device *dev,
-			    const struct ethtool_link_ksettings *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_ksettings_set(phydev, cmd);
-}
-
 static int fs_nway_reset(struct net_device *dev)
 {
 	return 0;
@@ -892,8 +870,8 @@ static const struct ethtool_ops fs_ethtool_ops = {
 	.set_msglevel = fs_set_msglevel,
 	.get_regs = fs_get_regs,
 	.get_ts_info = ethtool_op_get_ts_info,
-	.get_link_ksettings = fs_get_ksettings,
-	.set_link_ksettings = fs_set_ksettings,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
