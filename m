From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 5/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sat, 18 May 2013 19:24:48 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305181905490.7518@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

copyright, email address and styling update;

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 drivers/net/usb/rtl8150.c |   69 +++++++++++++++++------------------
 1 file changed, 34 insertions(+), 35 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 0e226d8..928546e 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -1,5 +1,5 @@
 /*
- *  Copyright (c) 2002 Petko Manolov (petkan@users.sourceforge.net)
+ *  Copyright (c) 2002-2013 Petko Manolov (petkan@nucleusys.com)
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -19,8 +19,8 @@
 #include "rtl8150.h"
 
 /* Version Information */
-#define DRIVER_VERSION "v0.6.2 (2004/08/27)"
-#define DRIVER_AUTHOR "Petko Manolov <petkan@users.sourceforge.net>"
+#define DRIVER_VERSION "v0.9.3 (2013/05/18)"
+#define DRIVER_AUTHOR "Petko Manolov <petkan@nucleusys.com>"
 #define DRIVER_DESC "rtl8150 based usb-ethernet driver"
 
 MODULE_DEVICE_TABLE(usb, rtl8150_table);
@@ -32,7 +32,7 @@ static const char driver_name [] = "rtl8150";
  * device related part of the code
  *
  */
-static int get_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
+static int get_registers(rtl8150_t *dev, u16 indx, u16 size, void *data)
 {
 	int res;
 
@@ -44,7 +44,7 @@ static int get_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 	return res;
 }
 
-static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
+static int set_registers(rtl8150_t *dev, u16 indx, u16 size, void *data)
 {
 	int res;
 
@@ -99,7 +99,7 @@ static int async_set_registers(rtl8150_t *dev, u16 indx, u16 size, u16 reg)
 	return res;
 }
 
-static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
+static int read_mii_word(rtl8150_t *dev, u8 phy, __u8 indx, u16 *reg)
 {
 	int i;
 	u8 data[3], tmp;
@@ -123,7 +123,7 @@ static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
 		return 1;
 }
 
-static int write_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 reg)
+static int write_mii_word(rtl8150_t *dev, u8 phy, __u8 indx, u16 reg)
 {
 	int i;
 	u8 data[3], tmp;
@@ -146,7 +146,7 @@ static int write_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 reg)
 		return 1;
 }
 
-static inline void set_ethernet_addr(rtl8150_t * dev)
+static inline void set_ethernet_addr(rtl8150_t *dev)
 {
 	u8 node_id[6];
 
@@ -189,7 +189,7 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static int rtl8150_reset(rtl8150_t * dev)
+static int rtl8150_reset(rtl8150_t *dev)
 {
 	u8 data = 0x10;
 	int i = HZ;
@@ -202,7 +202,7 @@ static int rtl8150_reset(rtl8150_t * dev)
 	return (i > 0) ? 1 : 0;
 }
 
-static int alloc_all_urbs(rtl8150_t * dev)
+static int alloc_all_urbs(rtl8150_t *dev)
 {
 	dev->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!dev->rx_urb)
@@ -221,14 +221,14 @@ static int alloc_all_urbs(rtl8150_t * dev)
 	return 1;
 }
 
-static void free_all_urbs(rtl8150_t * dev)
+static void free_all_urbs(rtl8150_t *dev)
 {
 	usb_free_urb(dev->rx_urb);
 	usb_free_urb(dev->tx_urb);
 	usb_free_urb(dev->intr_urb);
 }
 
-static void unlink_all_urbs(rtl8150_t * dev)
+static void unlink_all_urbs(rtl8150_t *dev)
 {
 	usb_kill_urb(dev->rx_urb);
 	usb_kill_urb(dev->tx_urb);
@@ -364,12 +364,12 @@ static void intr_callback(struct urb *urb)
 	if ((d[INT_MSR] & MSR_LINK) == 0) {
 		if (netif_carrier_ok(dev->netdev)) {
 			netif_carrier_off(dev->netdev);
-			netdev_dbg(dev->netdev, "%s: LINK LOST\n", __func__);
+			netdev_dbg(dev->netdev, "%s: link lost\n", __func__);
 		}
 	} else {
 		if (!netif_carrier_ok(dev->netdev)) {
 			netif_carrier_on(dev->netdev);
-			netdev_dbg(dev->netdev, "%s: LINK CAME BACK\n", __func__);
+			netdev_dbg(dev->netdev, "%s: link is back\n", __func__);
 		}
 	}
 
@@ -450,7 +450,7 @@ tlsched:
 	tasklet_schedule(&dev->tl);
 }
 
-static int enable_net_traffic(rtl8150_t * dev)
+static int enable_net_traffic(rtl8150_t *dev)
 {
 	u8 cr, tcr, rcr, msr;
 
@@ -471,7 +471,7 @@ static int enable_net_traffic(rtl8150_t * dev)
 	return 0;
 }
 
-static void disable_net_traffic(rtl8150_t * dev)
+static void disable_net_traffic(rtl8150_t *dev)
 {
 	u8 cr;
 
@@ -510,7 +510,7 @@ static void rtl8150_set_multicast(struct net_device *netdev)
 }
 
 static netdev_tx_t rtl8150_start_xmit(struct sk_buff *skb,
-					    struct net_device *netdev)
+				      struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
 	int count, res;
@@ -681,16 +681,15 @@ static int rtl8150_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 }
 
 static const struct net_device_ops rtl8150_netdev_ops = {
-	.ndo_open		= rtl8150_open,
-	.ndo_stop		= rtl8150_close,
-	.ndo_do_ioctl		= rtl8150_ioctl,
-	.ndo_start_xmit		= rtl8150_start_xmit,
-	.ndo_tx_timeout		= rtl8150_tx_timeout,
-	.ndo_set_rx_mode	= rtl8150_set_multicast,
-	.ndo_set_mac_address	= rtl8150_set_mac_address,
-
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_open = rtl8150_open,
+	.ndo_stop = rtl8150_close,
+	.ndo_do_ioctl = rtl8150_ioctl,
+	.ndo_start_xmit = rtl8150_start_xmit,
+	.ndo_tx_timeout = rtl8150_tx_timeout,
+	.ndo_set_rx_mode = rtl8150_set_multicast,
+	.ndo_set_mac_address = rtl8150_set_mac_address,
+	.ndo_change_mtu	= eth_change_mtu,
+	.ndo_validate_addr = eth_validate_addr,
 };
 
 static int rtl8150_probe(struct usb_interface *intf,
@@ -738,8 +737,8 @@ static int rtl8150_probe(struct usb_interface *intf,
 		goto out2;
 	}
 
-	dev_info(&intf->dev, "%s: rtl8150 is detected\n", netdev->name);
-
+	dev_info(&intf->dev, "%s: %s %s\n", netdev->name,
+		 DRIVER_DESC, DRIVER_VERSION);
 	return 0;
 
 out2:
@@ -771,12 +770,12 @@ static void rtl8150_disconnect(struct usb_interface *intf)
 }
 
 static struct usb_driver rtl8150_driver = {
-	.name		= driver_name,
-	.probe		= rtl8150_probe,
-	.disconnect	= rtl8150_disconnect,
-	.id_table	= rtl8150_table,
-	.suspend	= rtl8150_suspend,
-	.resume		= rtl8150_resume,
+	.name = driver_name,
+	.probe = rtl8150_probe,
+	.disconnect = rtl8150_disconnect,
+	.id_table = rtl8150_table,
+	.suspend = rtl8150_suspend,
+	.resume = rtl8150_resume,
 	.disable_hub_initiated_lpm = 1,
 };
 
