From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: usb: ax88172x: use phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 15:25:36 +0200
Message-ID: <1468589136-765-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, colin.king@canonical.com,
	f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/ax88172a.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index cf77f2d..163a2c5 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -149,24 +149,6 @@ static const struct net_device_ops ax88172a_netdev_ops = {
 	.ndo_set_rx_mode        = asix_set_multicast,
 };
 
-static int ax88172a_get_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
-{
-	if (!net->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(net->phydev, cmd);
-}
-
-static int ax88172a_set_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
-{
-	if (!net->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(net->phydev, cmd);
-}
-
 static int ax88172a_nway_reset(struct net_device *net)
 {
 	if (!net->phydev)
@@ -185,9 +167,9 @@ static const struct ethtool_ops ax88172a_ethtool_ops = {
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
 	.set_eeprom		= asix_set_eeprom,
-	.get_settings		= ax88172a_get_settings,
-	.set_settings		= ax88172a_set_settings,
 	.nway_reset		= ax88172a_nway_reset,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 static int ax88172a_reset_phy(struct usbnet *dev, int embd_phy)
-- 
1.7.4.4
