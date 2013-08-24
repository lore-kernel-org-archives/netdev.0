From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB2NET : SR9700 : One chip USB 1.1 USB2NET SR9700
 Device Driver Support
Date: Sat, 24 Aug 2013 11:15:11 -0700
Message-ID: <1377368111.1757.2.camel@joe-AO722>
References: <1377343560-10524-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, horms@verge.net.au, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377343560-10524-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some whitespace and neatening fixups.
Some conversions from 4 indent tabs to normal tabs

Signed-off-by: Joe Perches <joe@perches.com>
---
Just doing this instead of commenting about spacing
again.

 drivers/net/usb/sr9700.c | 127 +++++++++++++++++++++++++----------------------
 1 file changed, 67 insertions(+), 60 deletions(-)

diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 27c86ec..4262b9d 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -29,7 +29,7 @@ static int sr_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 	int err;
 
 	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG,
-					0, reg, data, length);
+			      0, reg, data, length);
 	if ((err != length) && (err >= 0))
 		err = -EINVAL;
 	return err;
@@ -40,7 +40,7 @@ static int sr_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 	int err;
 
 	err = usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
-					0, reg, data, length);
+			       0, reg, data, length);
 	if ((err >= 0) && (err < length))
 		err = -EINVAL;
 	return err;
@@ -54,19 +54,19 @@ static int sr_read_reg(struct usbnet *dev, u8 reg, u8 *value)
 static int sr_write_reg(struct usbnet *dev, u8 reg, u8 value)
 {
 	return usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
-					value, reg, NULL, 0);
+				value, reg, NULL, 0);
 }
 
 static void sr_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
 	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
-					0, reg, data, length);
+			       0, reg, data, length);
 }
 
 static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 {
 	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
-					value, reg, NULL, 0);
+			       value, reg, NULL, 0);
 }
 
 static int wait_phy_eeprom_ready(struct usbnet *dev, int phy)
@@ -89,7 +89,7 @@ static int wait_phy_eeprom_ready(struct usbnet *dev, int phy)
 
 	if (i >= SR_SHARE_TIMEOUT) {
 		netdev_err(dev->net, "%s write timed out!\n",
-						phy ? "phy" : "eeprom");
+			   phy ? "phy" : "eeprom");
 		ret = -EIO;
 		goto out;
 	}
@@ -98,7 +98,8 @@ out:
 	return ret;
 }
 
-static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
+static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg,
+			      __le16 *value)
 {
 	int ret;
 
@@ -115,14 +116,15 @@ static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg, __le16 *value
 	ret = sr_read(dev, EPDR, 2, value);
 
 	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
-					phy, reg, *value, ret);
+		   phy, reg, *value, ret);
 
 out:
 	mutex_unlock(&dev->phy_mutex);
 	return ret;
 }
 
-static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
+static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg,
+			       __le16 value)
 {
 	int ret;
 
@@ -156,7 +158,8 @@ static int sr9700_get_eeprom_len(struct net_device *dev)
 	return SR_EEPROM_LEN;
 }
 
-static int sr9700_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom, u8 *data)
+static int sr9700_get_eeprom(struct net_device *net,
+			     struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct usbnet *dev = netdev_priv(net);
 	__le16 *ebuf = (__le16 *)data;
@@ -168,7 +171,8 @@ static int sr9700_get_eeprom(struct net_device *net, struct ethtool_eeprom *eepr
 		return -EINVAL;
 
 	for (i = 0; i < eeprom->len / 2; i++)
-		ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i, &ebuf[i]);
+		ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i,
+					  &ebuf[i]);
 
 	return ret;
 }
@@ -199,12 +203,13 @@ static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
 		res = le16_to_cpu(res) & ~BMSR_LSTATUS;
 
 	netdev_dbg(dev->net, "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
-					phy_id, loc, res);
+		   phy_id, loc, res);
 
 	return res;
 }
 
-static void sr_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
+static void sr_mdio_write(struct net_device *netdev, int phy_id, int loc,
+			  int val)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 	__le16 res = cpu_to_le16(val);
@@ -215,7 +220,7 @@ static void sr_mdio_write(struct net_device *netdev, int phy_id, int loc, int va
 	}
 
 	netdev_dbg(dev->net, "sr_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
-					phy_id, loc, val);
+		   phy_id, loc, val);
 
 	sr_share_write_word(dev, 1, loc, res);
 }
@@ -242,15 +247,15 @@ static int sr9700_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 }
 
 static const struct ethtool_ops sr9700_ethtool_ops = {
-		.get_drvinfo	= usbnet_get_drvinfo,
-		.get_link		= sr9700_get_link,
-		.get_msglevel	= usbnet_get_msglevel,
-		.set_msglevel	= usbnet_set_msglevel,
-		.get_eeprom_len	= sr9700_get_eeprom_len,
-		.get_eeprom		= sr9700_get_eeprom,
-		.get_settings	= usbnet_get_settings,
-		.set_settings	= usbnet_set_settings,
-		.nway_reset		= usbnet_nway_reset,
+	.get_drvinfo	= usbnet_get_drvinfo,
+	.get_link	= sr9700_get_link,
+	.get_msglevel	= usbnet_get_msglevel,
+	.set_msglevel	= usbnet_set_msglevel,
+	.get_eeprom_len	= sr9700_get_eeprom_len,
+	.get_eeprom	= sr9700_get_eeprom,
+	.get_settings	= usbnet_get_settings,
+	.set_settings	= usbnet_set_settings,
+	.nway_reset	= usbnet_nway_reset,
 };
 
 static void sr9700_set_multicast(struct net_device *net)
@@ -269,7 +274,7 @@ static void sr9700_set_multicast(struct net_device *net)
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= RCR_PRMSC;
 	} else if (net->flags & IFF_ALLMULTI ||
-			  netdev_mc_count(net) > SR_MCAST_MAX) {
+		   netdev_mc_count(net) > SR_MCAST_MAX) {
 		rx_ctl |= RCR_RUNT;
 	} else if (!netdev_mc_empty(net)) {
 		struct netdev_hw_addr *ha;
@@ -290,7 +295,7 @@ static int sr9700_set_mac_address(struct net_device *net, void *p)
 
 	if (!is_valid_ether_addr(addr->sa_data)) {
 		netdev_err(net, "not setting invalid mac address %pM\n",
-						addr->sa_data);
+			   addr->sa_data);
 		return -EINVAL;
 	}
 
@@ -301,15 +306,15 @@ static int sr9700_set_mac_address(struct net_device *net, void *p)
 }
 
 static const struct net_device_ops sr9700_netdev_ops = {
-		.ndo_open			= usbnet_open,
-		.ndo_stop			= usbnet_stop,
-		.ndo_start_xmit		= usbnet_start_xmit,
-		.ndo_tx_timeout		= usbnet_tx_timeout,
-		.ndo_change_mtu		= usbnet_change_mtu,
-		.ndo_validate_addr	= eth_validate_addr,
-		.ndo_do_ioctl		= sr9700_ioctl,
-		.ndo_set_rx_mode	= sr9700_set_multicast,
-		.ndo_set_mac_address	= sr9700_set_mac_address,
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= sr9700_ioctl,
+	.ndo_set_rx_mode	= sr9700_set_multicast,
+	.ndo_set_mac_address	= sr9700_set_mac_address,
 };
 
 static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
@@ -360,7 +365,8 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	sr_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 	sr_mdio_write(dev->net, dev->mii.phy_id,
-					MII_ADVERTISE, ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+		      (MII_ADVERTISE, ADVERTISE_ALL |
+		       ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP));
 	mii_nway_restart(&dev->mii);
 
 out:
@@ -373,11 +379,11 @@ static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	int len;
 
 	/* skb content (packets) format :
-	 *					p0			p1			p2	......	pm
-	 *			     /	  \
-	 *			/				\
-	 *		/							\
-	 *  /										\
+	 *                    p0            p1            p2    ......    pm
+	 *                 /      \
+	 *            /                \
+	 *        /                            \
+	 *  /                                        \
 	 * p0b0 p0b1 p0b2 p0b3 ...... p0b(n-4) p0b(n-3)...p0bn
 	 *
 	 * p0 : packet 0
@@ -431,7 +437,8 @@ static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static struct sk_buff *sr9700_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
+static struct sk_buff *sr9700_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+				       gfp_t flags)
 {
 	int len;
 
@@ -508,40 +515,40 @@ static int sr9700_link_reset(struct usbnet *dev)
 	mii_ethtool_gset(&dev->mii, &ecmd);
 
 	netdev_dbg(dev->net, "link_reset() speed: %d duplex: %d\n",
-					ecmd.speed, ecmd.duplex);
+		   ecmd.speed, ecmd.duplex);
 
 	return 0;
 }
 
 static const struct driver_info sr9700_driver_info = {
-		.description	= "CoreChip SR9700 USB Ethernet",
-		.flags		= FLAG_ETHER,
-		.bind		= sr9700_bind,
-		.rx_fixup	= sr9700_rx_fixup,
-		.tx_fixup	= sr9700_tx_fixup,
-		.status		= sr9700_status,
-		.link_reset	= sr9700_link_reset,
-		.reset		= sr9700_link_reset,
+	.description	= "CoreChip SR9700 USB Ethernet",
+	.flags		= FLAG_ETHER,
+	.bind		= sr9700_bind,
+	.rx_fixup	= sr9700_rx_fixup,
+	.tx_fixup	= sr9700_tx_fixup,
+	.status		= sr9700_status,
+	.link_reset	= sr9700_link_reset,
+	.reset		= sr9700_link_reset,
 };
 
 static const struct usb_device_id products[] = {
 	{
-	 USB_DEVICE(0x0fe6, 0x9700),	/* SR9700 device */
-	 .driver_info = (unsigned long)&sr9700_driver_info,
-	 },
+		USB_DEVICE(0x0fe6, 0x9700),	/* SR9700 device */
+		.driver_info = (unsigned long)&sr9700_driver_info,
+	},
 	{},			/* END */
 };
 
 MODULE_DEVICE_TABLE(usb, products);
 
 static struct usb_driver sr9700_usb_driver = {
-		.name = "sr9700",
-		.id_table = products,
-		.probe = usbnet_probe,
-		.disconnect = usbnet_disconnect,
-		.suspend = usbnet_suspend,
-		.resume = usbnet_resume,
-		.disable_hub_initiated_lpm = 1,
+	.name		= "sr9700",
+	.id_table	= products,
+	.probe		= usbnet_probe,
+	.disconnect	= usbnet_disconnect,
+	.suspend	= usbnet_suspend,
+	.resume		= usbnet_resume,
+	.disable_hub_initiated_lpm = 1,
 };
 
 module_usb_driver(sr9700_usb_driver);
