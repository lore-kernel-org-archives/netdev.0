From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: altera_tse: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 18 Jun 2016 16:37:21 +0200
Message-ID: <1466260641-22506-2-git-send-email-tremyfr@gmail.com>
References: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466260641-22506-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_ethtool.c |   24 +--------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
index c1b5608..7c36771 100644
--- a/drivers/net/ethernet/altera/altera_tse_ethtool.c
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -233,38 +233,18 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		buf[i] = csrrd32(priv->mac_dev, i * 4);
 }
 
-static int tse_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (phydev == NULL)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int tse_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (phydev == NULL)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static const struct ethtool_ops tse_ethtool_ops = {
 	.get_drvinfo = tse_get_drvinfo,
 	.get_regs_len = tse_reglen,
 	.get_regs = tse_get_regs,
 	.get_link = ethtool_op_get_link,
-	.get_settings = tse_get_settings,
-	.set_settings = tse_set_settings,
 	.get_strings = tse_gstrings,
 	.get_sset_count = tse_sset_count,
 	.get_ethtool_stats = tse_fill_stats,
 	.get_msglevel = tse_get_msglevel,
 	.set_msglevel = tse_set_msglevel,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 void altera_tse_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
