From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH 1/4] asix: Fix checkpatch warnings
Date: Fri, 6 Jul 2012 13:33:05 +0200
Message-ID: <1341574388-7464-2-git-send-email-christian.riesch@omicron.at>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:54477 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030243Ab2GFLq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:46:57 -0400
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/asix.c |  242 +++++++++++++++++++++++++-----------------------
 1 files changed, 126 insertions(+), 116 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 3ae80ec..9210f40 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -20,8 +20,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
+/* #define	DEBUG	*/		/* error path messages, extra info */
+/* #define	VERBOSE	*/		/* more; success messages */
 
 #include <linux/module.h>
 #include <linux/kmod.h>
@@ -81,7 +81,7 @@
 #define AX88172_MEDIUM_TX		0x04
 #define AX88172_MEDIUM_FC		0x10
 #define AX88172_MEDIUM_DEFAULT \
-		( AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC )
+		(AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC)
 
 #define AX_MCAST_FILTER_SIZE		8
 #define AX_MAX_MCAST			64
@@ -253,8 +253,8 @@ static void asix_async_cmd_callback(struct urb *urb)
 	int status = urb->status;
 
 	if (status < 0)
-		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
-			status);
+		pr_debug("asix_async_cmd_callback() failed with %d",
+			 status);
 
 	kfree(req);
 	usb_free_urb(urb);
@@ -262,7 +262,7 @@ static void asix_async_cmd_callback(struct urb *urb)
 
 static void
 asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-				    u16 size, void *data)
+		     u16 size, void *data)
 {
 	struct usb_ctrlrequest *req;
 	int status;
@@ -399,9 +399,10 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 	if (netif_carrier_ok(dev->net) != link) {
 		if (link) {
 			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
-		} else
+			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+		} else {
 			netif_carrier_off(dev->net);
+		}
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
@@ -432,7 +433,8 @@ static inline int asix_get_phy_addr(struct usbnet *dev)
 	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
 
 	if (ret < 0) {
-		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
+		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
+			   ret);
 		goto out;
 	}
 	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
@@ -447,9 +449,10 @@ static int asix_sw_reset(struct usbnet *dev, u8 flags)
 {
 	int ret;
 
-        ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
+	ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
 	if (ret < 0)
-		netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
+		netdev_err(dev->net, "Failed to send software reset: %02x\n",
+			   ret);
 
 	return ret;
 }
@@ -460,7 +463,8 @@ static u16 asix_read_rx_ctl(struct usbnet *dev)
 	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
 
 	if (ret < 0) {
-		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n", ret);
+		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n",
+			   ret);
 		goto out;
 	}
 	ret = le16_to_cpu(v);
@@ -500,7 +504,8 @@ static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
 {
 	int ret;
 
-	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
+	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n",
+		   mode);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
 	if (ret < 0)
 		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
@@ -559,7 +564,7 @@ static void asix_set_multicast(struct net_device *net)
 		}
 
 		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
-				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+				     AX_MCAST_FILTER_SIZE, data->multi_filter);
 
 		rx_ctl |= AX_RX_CTL_AM;
 	}
@@ -575,7 +580,7 @@ static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, &res);
+		      (__u16)loc, 2, &res);
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
@@ -609,7 +614,8 @@ static u32 asix_get_phyid(struct usbnet *dev)
 
 	/* Poll for the rare case the FW or phy isn't ready yet.  */
 	for (i = 0; i < 100; i++) {
-		phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
+		phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id,
+					 MII_PHYSID1);
 		if (phy_reg != 0 && phy_reg != 0xFFFF)
 			break;
 		mdelay(1);
@@ -660,7 +666,7 @@ asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 		opt |= AX_MONITOR_MAGIC;
 
 	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			      opt, 0, 0, NULL) < 0)
+			   opt, 0, 0, NULL) < 0)
 		return -EINVAL;
 
 	return 0;
@@ -690,24 +696,24 @@ static int asix_get_eeprom(struct net_device *net,
 	eeprom->magic = AX_EEPROM_MAGIC;
 
 	/* ax8817x returns 2 bytes from eeprom on read */
-	for (i=0; i < eeprom->len / 2; i++) {
+	for (i = 0; i < eeprom->len / 2; i++) {
 		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
-			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
+				  eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
 			return -EINVAL;
 	}
 	return 0;
 }
 
-static void asix_get_drvinfo (struct net_device *net,
-				 struct ethtool_drvinfo *info)
+static void asix_get_drvinfo(struct net_device *net,
+			     struct ethtool_drvinfo *info)
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct asix_data *data = (struct asix_data *)&dev->data;
 
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
-	strncpy (info->driver, DRIVER_NAME, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
+	strncpy(info->driver, DRIVER_NAME, sizeof info->driver);
+	strncpy(info->version, DRIVER_VERSION, sizeof info->version);
 	info->eedump_len = data->eeprom_len;
 }
 
@@ -718,7 +724,7 @@ static u32 asix_get_link(struct net_device *net)
 	return mii_link_ok(&dev->mii);
 }
 
-static int asix_ioctl (struct net_device *net, struct ifreq *rq, int cmd)
+static int asix_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 
@@ -744,7 +750,7 @@ static int asix_set_mac_address(struct net_device *net, void *p)
 	 * is tricky to free later */
 	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
 	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
-							data->mac_addr);
+			     data->mac_addr);
 
 	return 0;
 }
@@ -797,7 +803,7 @@ static void ax88172_set_multicast(struct net_device *net)
 		}
 
 		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
-				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+				     AX_MCAST_FILTER_SIZE, data->multi_filter);
 
 		rx_ctl |= 0x10;
 	}
@@ -831,7 +837,7 @@ static const struct net_device_ops ax88172_netdev_ops = {
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
 	.ndo_set_rx_mode	= ax88172_set_multicast,
@@ -847,7 +853,7 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	data->eeprom_len = AX88172_EEPROM_LEN;
 
-	usbnet_get_endpoints(dev,intf);
+	usbnet_get_endpoints(dev, intf);
 
 	/* Toggle the GPIOs in a manufacturer/model specific way */
 	for (i = 2; i >= 0; i--) {
@@ -883,7 +889,7 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
-		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	mii_nway_restart(&dev->mii);
 
 	return 0;
@@ -1040,7 +1046,7 @@ static const struct net_device_ops ax88772_netdev_ops = {
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= asix_set_mac_address,
+	.ndo_set_mac_address	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
 	.ndo_set_rx_mode        = asix_set_multicast,
@@ -1055,7 +1061,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	data->eeprom_len = AX88772_EEPROM_LEN;
 
-	usbnet_get_endpoints(dev,intf);
+	usbnet_get_endpoints(dev, intf);
 
 	/* Get the MAC address */
 	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
@@ -1143,16 +1149,18 @@ static int marvell_phy_init(struct usbnet *dev)
 	if (data->ledmode) {
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
 			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n", reg);
+		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n",
+			   reg);
 
 		reg &= 0xf8ff;
 		reg |= (1 + 0x0100);
 		asix_mdio_write(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL, reg);
+				MII_MARVELL_LED_CTRL, reg);
 
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n", reg);
+				     MII_MARVELL_LED_CTRL);
+		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n",
+			   reg);
 		reg &= 0xfc0f;
 	}
 
@@ -1165,16 +1173,16 @@ static int rtl8211cl_phy_init(struct usbnet *dev)
 
 	netdev_dbg(dev->net, "rtl8211cl_phy_init()\n");
 
-	asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0x0005);
-	asix_mdio_write (dev->net, dev->mii.phy_id, 0x0c, 0);
-	asix_mdio_write (dev->net, dev->mii.phy_id, 0x01,
-		asix_mdio_read (dev->net, dev->mii.phy_id, 0x01) | 0x0080);
-	asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0);
+	asix_mdio_write(dev->net, dev->mii.phy_id, 0x1f, 0x0005);
+	asix_mdio_write(dev->net, dev->mii.phy_id, 0x0c, 0);
+	asix_mdio_write(dev->net, dev->mii.phy_id, 0x01,
+		asix_mdio_read(dev->net, dev->mii.phy_id, 0x01) | 0x0080);
+	asix_mdio_write(dev->net, dev->mii.phy_id, 0x1f, 0);
 
 	if (data->ledmode == 12) {
-		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0x0002);
-		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1a, 0x00cb);
-		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0);
+		asix_mdio_write(dev->net, dev->mii.phy_id, 0x1f, 0x0002);
+		asix_mdio_write(dev->net, dev->mii.phy_id, 0x1a, 0x00cb);
+		asix_mdio_write(dev->net, dev->mii.phy_id, 0x1f, 0);
 	}
 
 	return 0;
@@ -1190,14 +1198,14 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 	reg &= 0xfc0f;
 
 	switch (speed) {
-		case SPEED_1000:
-			reg |= 0x03e0;
-			break;
-		case SPEED_100:
-			reg |= 0x03b0;
-			break;
-		default:
-			reg |= 0x02f0;
+	case SPEED_1000:
+		reg |= 0x03e0;
+		break;
+	case SPEED_100:
+		reg |= 0x03b0;
+		break;
+	default:
+		reg |= 0x02f0;
 	}
 
 	netdev_dbg(dev->net, "marvell_led_status() writing 0x%04x\n", reg);
@@ -1265,8 +1273,9 @@ static int ax88178_reset(struct usbnet *dev)
 	if (data->phymode == PHY_MODE_MARVELL) {
 		marvell_phy_init(dev);
 		msleep(60);
-	} else if (data->phymode == PHY_MODE_RTL8211CL)
+	} else if (data->phymode == PHY_MODE_RTL8211CL) {
 		rtl8211cl_phy_init(dev);
+	}
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
 			BMCR_RESET | BMCR_ANENABLE);
@@ -1394,11 +1403,11 @@ static const struct net_device_ops ax88178_netdev_ops = {
 	.ndo_stop		= usbnet_stop,
 	.ndo_start_xmit		= usbnet_start_xmit,
 	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_set_mac_address 	= asix_set_mac_address,
+	.ndo_set_mac_address	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= asix_set_multicast,
-	.ndo_do_ioctl 		= asix_ioctl,
-	.ndo_change_mtu 	= ax88178_change_mtu,
+	.ndo_do_ioctl		= asix_ioctl,
+	.ndo_change_mtu		= ax88178_change_mtu,
 };
 
 static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
@@ -1409,7 +1418,7 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	data->eeprom_len = AX88772_EEPROM_LEN;
 
-	usbnet_get_endpoints(dev,intf);
+	usbnet_get_endpoints(dev, intf);
 
 	/* Get the MAC address */
 	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
@@ -1494,7 +1503,8 @@ static const struct driver_info ax88772_info = {
 	.status = asix_status,
 	.link_reset = ax88772_link_reset,
 	.reset = ax88772_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_MULTI_PACKET,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
 };
@@ -1510,133 +1520,133 @@ static const struct driver_info ax88178_info = {
 	.tx_fixup = asix_tx_fixup,
 };
 
-static const struct usb_device_id	products [] = {
+static const struct usb_device_id	products[] = {
 {
-	// Linksys USB200M
-	USB_DEVICE (0x077b, 0x2226),
+	/* Linksys USB200M */
+	USB_DEVICE(0x077b, 0x2226),
 	.driver_info =	(unsigned long) &ax8817x_info,
 }, {
-	// Netgear FA120
-	USB_DEVICE (0x0846, 0x1040),
+	/* Netgear FA120 */
+	USB_DEVICE(0x0846, 0x1040),
 	.driver_info =  (unsigned long) &netgear_fa120_info,
 }, {
-	// DLink DUB-E100
-	USB_DEVICE (0x2001, 0x1a00),
+	/* DLink DUB-E100 */
+	USB_DEVICE(0x2001, 0x1a00),
 	.driver_info =  (unsigned long) &dlink_dub_e100_info,
 }, {
-	// Intellinet, ST Lab USB Ethernet
-	USB_DEVICE (0x0b95, 0x1720),
+	/* Intellinet, ST Lab USB Ethernet */
+	USB_DEVICE(0x0b95, 0x1720),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Hawking UF200, TrendNet TU2-ET100
-	USB_DEVICE (0x07b8, 0x420a),
+	/* Hawking UF200, TrendNet TU2-ET100 */
+	USB_DEVICE(0x07b8, 0x420a),
 	.driver_info =  (unsigned long) &hawking_uf200_info,
 }, {
-	// Billionton Systems, USB2AR
-	USB_DEVICE (0x08dd, 0x90ff),
+	/* Billionton Systems, USB2AR */
+	USB_DEVICE(0x08dd, 0x90ff),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// ATEN UC210T
-	USB_DEVICE (0x0557, 0x2009),
+	/* ATEN UC210T */
+	USB_DEVICE(0x0557, 0x2009),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-KTX
-	USB_DEVICE (0x0411, 0x003d),
+	/* Buffalo LUA-U2-KTX */
+	USB_DEVICE(0x0411, 0x003d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-GT 10/100/1000
-	USB_DEVICE (0x0411, 0x006e),
+	/* Buffalo LUA-U2-GT 10/100/1000 */
+	USB_DEVICE(0x0411, 0x006e),
 	.driver_info =  (unsigned long) &ax88178_info,
 }, {
-	// Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter"
-	USB_DEVICE (0x6189, 0x182d),
+	/* Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter" */
+	USB_DEVICE(0x6189, 0x182d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Sitecom LN-031 "USB 2.0 10/100/1000 Ethernet adapter"
-	USB_DEVICE (0x0df6, 0x0056),
+	/* Sitecom LN-031 "USB 2.0 10/100/1000 Ethernet adapter" */
+	USB_DEVICE(0x0df6, 0x0056),
 	.driver_info =  (unsigned long) &ax88178_info,
 }, {
-	// corega FEther USB2-TX
-	USB_DEVICE (0x07aa, 0x0017),
+	/* corega FEther USB2-TX */
+	USB_DEVICE(0x07aa, 0x0017),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Surecom EP-1427X-2
-	USB_DEVICE (0x1189, 0x0893),
+	/* Surecom EP-1427X-2 */
+	USB_DEVICE(0x1189, 0x0893),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// goodway corp usb gwusb2e
-	USB_DEVICE (0x1631, 0x6200),
+	/* goodway corp usb gwusb2e */
+	USB_DEVICE(0x1631, 0x6200),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// JVC MP-PRX1 Port Replicator
-	USB_DEVICE (0x04f1, 0x3008),
+	/* JVC MP-PRX1 Port Replicator */
+	USB_DEVICE(0x04f1, 0x3008),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// ASIX AX88772B 10/100
-	USB_DEVICE (0x0b95, 0x772b),
+	/* ASIX AX88772B 10/100 */
+	USB_DEVICE(0x0b95, 0x772b),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// ASIX AX88772 10/100
-	USB_DEVICE (0x0b95, 0x7720),
+	/* ASIX AX88772 10/100 */
+	USB_DEVICE(0x0b95, 0x7720),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// ASIX AX88178 10/100/1000
-	USB_DEVICE (0x0b95, 0x1780),
+	/* ASIX AX88178 10/100/1000 */
+	USB_DEVICE(0x0b95, 0x1780),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// Logitec LAN-GTJ/U2A
-	USB_DEVICE (0x0789, 0x0160),
+	/* Logitec LAN-GTJ/U2A */
+	USB_DEVICE(0x0789, 0x0160),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// Linksys USB200M Rev 2
-	USB_DEVICE (0x13b1, 0x0018),
+	/* Linksys USB200M Rev 2 */
+	USB_DEVICE(0x13b1, 0x0018),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// 0Q0 cable ethernet
-	USB_DEVICE (0x1557, 0x7720),
+	/* 0Q0 cable ethernet */
+	USB_DEVICE(0x1557, 0x7720),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// DLink DUB-E100 H/W Ver B1
-	USB_DEVICE (0x07d1, 0x3c05),
+	/* DLink DUB-E100 H/W Ver B1 */
+	USB_DEVICE(0x07d1, 0x3c05),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// DLink DUB-E100 H/W Ver B1 Alternate
-	USB_DEVICE (0x2001, 0x3c05),
+	/* DLink DUB-E100 H/W Ver B1 Alternate */
+	USB_DEVICE(0x2001, 0x3c05),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// Linksys USB1000
-	USB_DEVICE (0x1737, 0x0039),
+	/* Linksys USB1000 */
+	USB_DEVICE(0x1737, 0x0039),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// IO-DATA ETG-US2
-	USB_DEVICE (0x04bb, 0x0930),
+	/* IO-DATA ETG-US2 */
+	USB_DEVICE(0x04bb, 0x0930),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// Belkin F5D5055
+	/* Belkin F5D5055 */
 	USB_DEVICE(0x050d, 0x5055),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// Apple USB Ethernet Adapter
+	/* Apple USB Ethernet Adapter */
 	USB_DEVICE(0x05ac, 0x1402),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// Cables-to-Go USB Ethernet Adapter
+	/* Cables-to-Go USB Ethernet Adapter */
 	USB_DEVICE(0x0b95, 0x772a),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// ABOCOM for pci
+	/* ABOCOM for pci */
 	USB_DEVICE(0x14ea, 0xab11),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
-	// ASIX 88772a
+	/* ASIX 88772a */
 	USB_DEVICE(0x0db0, 0xa877),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// Asus USB Ethernet Adapter
-	USB_DEVICE (0x0b95, 0x7e2b),
+	/* Asus USB Ethernet Adapter */
+	USB_DEVICE(0x0b95, 0x7e2b),
 	.driver_info = (unsigned long) &ax88772_info,
 },
-	{ },		// END
+	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
 
-- 
1.7.0.4
