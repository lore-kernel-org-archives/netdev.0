From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: smsc: smsc911x: use phy_ethtool_{get|set}_link_ksettings
Date: Sun,  3 Jul 2016 01:14:21 +0200
Message-ID: <1467501261-8839-2-git-send-email-tremyfr@gmail.com>
References: <1467501261-8839-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, steve.glendinning@shawell.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467501261-8839-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 6fded67..ca31345 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1915,20 +1915,6 @@ static int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
-static int
-smsc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int
-smsc911x_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
 {
@@ -2112,8 +2098,6 @@ static int smsc911x_ethtool_set_eeprom(struct net_device *dev,
 }
 
 static const struct ethtool_ops smsc911x_ethtool_ops = {
-	.get_settings = smsc911x_ethtool_getsettings,
-	.set_settings = smsc911x_ethtool_setsettings,
 	.get_link = ethtool_op_get_link,
 	.get_drvinfo = smsc911x_ethtool_getdrvinfo,
 	.nway_reset = smsc911x_ethtool_nwayreset,
@@ -2125,6 +2109,8 @@ static const struct ethtool_ops smsc911x_ethtool_ops = {
 	.get_eeprom = smsc911x_ethtool_get_eeprom,
 	.set_eeprom = smsc911x_ethtool_set_eeprom,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops smsc911x_netdev_ops = {
-- 
1.7.4.4
