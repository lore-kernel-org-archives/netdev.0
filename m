From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 14/15] net: usb: ax88172x: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:43 -0800
Message-ID: <20161115180644.3941-15-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Robert Foss <robert.foss@collabora.com>,
        Colin Ian King <colin.king@canonical.com>,
        linux-usb@vger.kernel.org (open list:USB NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/usb/ax88172a.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 49a3bc107d05..6308386b09df 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -149,14 +149,6 @@ static const struct net_device_ops ax88172a_netdev_ops = {
 	.ndo_set_rx_mode        = asix_set_multicast,
 };
 
-static int ax88172a_nway_reset(struct net_device *net)
-{
-	if (!net->phydev)
-		return -ENODEV;
-
-	return phy_start_aneg(net->phydev);
-}
-
 static const struct ethtool_ops ax88172a_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= usbnet_get_link,
@@ -167,7 +159,7 @@ static const struct ethtool_ops ax88172a_ethtool_ops = {
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
 	.set_eeprom		= asix_set_eeprom,
-	.nway_reset		= ax88172a_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
-- 
2.9.3
