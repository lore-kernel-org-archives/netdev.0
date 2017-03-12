From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: usb: asix88179_178a: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 18:02:36 +0100
Message-ID: <1489338156-18632-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com, chris.roth@usask.ca,
        allan@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/ax88179_178a.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index a3a7db0..4a0ae7c 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -620,16 +620,18 @@ static int ax88179_get_eeprom_len(struct net_device *net)
 	return 0;
 }
 
-static int ax88179_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
+static int ax88179_get_link_ksettings(struct net_device *net,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-	return mii_ethtool_gset(&dev->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&dev->mii, cmd);
 }
 
-static int ax88179_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
+static int ax88179_set_link_ksettings(struct net_device *net,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-	return mii_ethtool_sset(&dev->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&dev->mii, cmd);
 }
 
 static int
@@ -826,11 +828,11 @@ static int ax88179_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 	.set_wol		= ax88179_set_wol,
 	.get_eeprom_len		= ax88179_get_eeprom_len,
 	.get_eeprom		= ax88179_get_eeprom,
-	.get_settings		= ax88179_get_settings,
-	.set_settings		= ax88179_set_settings,
 	.get_eee		= ax88179_get_eee,
 	.set_eee		= ax88179_set_eee,
 	.nway_reset		= usbnet_nway_reset,
+	.get_link_ksettings	= ax88179_get_link_ksettings,
+	.set_link_ksettings	= ax88179_set_link_ksettings,
 };
 
 static void ax88179_set_multicast(struct net_device *net)
-- 
1.7.4.4
