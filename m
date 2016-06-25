From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: hix5hd2: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 25 Jun 2016 16:55:13 +0200
Message-ID: <1466866513-4351-2-git-send-email-tremyfr@gmail.com>
References: <1466866513-4351-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de, felipe.balbi@linux.intel.com, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466866513-4351-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index fed1c0f..275618b 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -750,28 +750,10 @@ static const struct net_device_ops hix5hd2_netdev_ops = {
 	.ndo_set_mac_address	= hix5hd2_net_set_mac_address,
 };
 
-static int hix5hd2_get_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
-{
-	if (!net_dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(net_dev->phydev, cmd);
-}
-
-static int hix5hd2_set_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
-{
-	if (!net_dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(net_dev->phydev, cmd);
-}
-
 static struct ethtool_ops hix5hd2_ethtools_ops = {
 	.get_link		= ethtool_op_get_link,
-	.get_settings		= hix5hd2_get_settings,
-	.set_settings		= hix5hd2_set_settings,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static int hix5hd2_mdio_wait_ready(struct mii_bus *bus)
-- 
1.7.4.4
