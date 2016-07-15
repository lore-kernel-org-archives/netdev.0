From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 2/2] net: ethernet: ethoc: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 09:59:12 +0200
Message-ID: <1468569552-24824-2-git-send-email-tremyfr@gmail.com>
References: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, tklauser@distanz.ch,
	colin.king@canonical.com, f.fainelli@gmail.com, jcmvbkbc@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- no change for this path from v1

 drivers/net/ethernet/ethoc.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 317168a..37a39b4 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -894,26 +894,6 @@ out:
 	return NETDEV_TX_OK;
 }
 
-static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static int ethoc_get_regs_len(struct net_device *netdev)
 {
 	return ETH_END;
@@ -978,14 +958,14 @@ static int ethoc_set_ringparam(struct net_device *dev,
 }
 
 const struct ethtool_ops ethoc_ethtool_ops = {
-	.get_settings = ethoc_get_settings,
-	.set_settings = ethoc_set_settings,
 	.get_regs_len = ethoc_get_regs_len,
 	.get_regs = ethoc_get_regs,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = ethoc_get_ringparam,
 	.set_ringparam = ethoc_set_ringparam,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops ethoc_netdev_ops = {
-- 
1.7.4.4
