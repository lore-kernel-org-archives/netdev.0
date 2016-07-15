From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: smsc9420: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 10:36:21 +0200
Message-ID: <1468571781-11136-2-git-send-email-tremyfr@gmail.com>
References: <1468571781-11136-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: steve.glendinning@shawell.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468571781-11136-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 3e5f533..b7bfed4b 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -231,26 +231,6 @@ static int smsc9420_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
-static int smsc9420_ethtool_get_settings(struct net_device *dev,
-					 struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int smsc9420_ethtool_set_settings(struct net_device *dev,
-					 struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static void smsc9420_ethtool_get_drvinfo(struct net_device *netdev,
 					 struct ethtool_drvinfo *drvinfo)
 {
@@ -434,8 +414,6 @@ static int smsc9420_ethtool_set_eeprom(struct net_device *dev,
 }
 
 static const struct ethtool_ops smsc9420_ethtool_ops = {
-	.get_settings = smsc9420_ethtool_get_settings,
-	.set_settings = smsc9420_ethtool_set_settings,
 	.get_drvinfo = smsc9420_ethtool_get_drvinfo,
 	.get_msglevel = smsc9420_ethtool_get_msglevel,
 	.set_msglevel = smsc9420_ethtool_set_msglevel,
@@ -447,6 +425,8 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.get_regs_len = smsc9420_ethtool_getregslen,
 	.get_regs = smsc9420_ethtool_getregs,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /* Sets the device MAC address to dev_addr */
-- 
1.7.4.4
