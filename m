From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 11/11] net: usb: usb: remove old api ethtool_{get|set}_settings
Date: Thu, 16 Mar 2017 23:18:57 +0100
Message-ID: <1489702737-2401-12-git-send-email-tremyfr@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, davem@davemloft.net,
        robert.foss@collabora.com, allan@asix.com.tw, grundler@google.com,
        jarod@redhat.com, peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function usbnet_{get|set}_settings is no longer used,
so we remove it.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/usbnet.c   |   35 -----------------------------------
 include/linux/usb/usbnet.h |    4 ----
 2 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 1b40b18..13d4ec5 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -947,39 +947,6 @@ int usbnet_open (struct net_device *net)
  * they'll probably want to use this base set.
  */
 
-int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
-{
-	struct usbnet *dev = netdev_priv(net);
-
-	if (!dev->mii.mdio_read)
-		return -EOPNOTSUPP;
-
-	return mii_ethtool_gset(&dev->mii, cmd);
-}
-EXPORT_SYMBOL_GPL(usbnet_get_settings);
-
-int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
-{
-	struct usbnet *dev = netdev_priv(net);
-	int retval;
-
-	if (!dev->mii.mdio_write)
-		return -EOPNOTSUPP;
-
-	retval = mii_ethtool_sset(&dev->mii, cmd);
-
-	/* link speed/duplex might have changed */
-	if (dev->driver_info->link_reset)
-		dev->driver_info->link_reset(dev);
-
-	/* hard_mtu or rx_urb_size may change in link_reset() */
-	usbnet_update_max_qlen(dev);
-
-	return retval;
-
-}
-EXPORT_SYMBOL_GPL(usbnet_set_settings);
-
 int usbnet_get_link_ksettings(struct net_device *net,
 			      struct ethtool_link_ksettings *cmd)
 {
@@ -1072,8 +1039,6 @@ void usbnet_set_msglevel (struct net_device *net, u32 level)
 
 /* drivers may override default ethtool_ops in their bind() routine */
 static const struct ethtool_ops usbnet_ethtool_ops = {
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
 	.get_link		= usbnet_get_link,
 	.nway_reset		= usbnet_nway_reset,
 	.get_drvinfo		= usbnet_get_drvinfo,
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 5bd8007..e2b5691 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -261,10 +261,6 @@ extern netdev_tx_t usbnet_start_xmit(struct sk_buff *skb,
 extern void usbnet_resume_rx(struct usbnet *);
 extern void usbnet_purge_paused_rxq(struct usbnet *);
 
-extern int usbnet_get_settings(struct net_device *net,
-			       struct ethtool_cmd *cmd);
-extern int usbnet_set_settings(struct net_device *net,
-			       struct ethtool_cmd *cmd);
 extern int usbnet_get_link_ksettings(struct net_device *net,
 				     struct ethtool_link_ksettings *cmd);
 extern int usbnet_set_link_ksettings(struct net_device *net,
-- 
1.7.4.4
