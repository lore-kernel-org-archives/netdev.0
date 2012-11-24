From: Joe Perches <joe@perches.com>
Subject: [PATCH] smsc: Add logging message newlines
Date: Sat, 24 Nov 2012 03:27:49 -0800
Message-ID: <1353756469.6558.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid any possible message logging interleaving by adding
missing newlines.

Align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc75xx.c |  403 ++++++++++++++++++++++----------------------
 drivers/net/usb/smsc95xx.c |  184 ++++++++++----------
 2 files changed, 296 insertions(+), 291 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index c5353cf..953c4f4 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -103,8 +103,8 @@ static int __must_check __smsc75xx_read_reg(struct usbnet *dev, u32 index,
 		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
-		netdev_warn(dev->net,
-			"Failed to read reg index 0x%08x: %d", index, ret);
+		netdev_warn(dev->net, "Failed to read reg index 0x%08x: %d\n",
+			    index, ret);
 
 	le32_to_cpus(&buf);
 	*data = buf;
@@ -133,8 +133,8 @@ static int __must_check __smsc75xx_write_reg(struct usbnet *dev, u32 index,
 		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
-		netdev_warn(dev->net,
-			"Failed to write reg index 0x%08x: %d", index, ret);
+		netdev_warn(dev->net, "Failed to write reg index 0x%08x: %d\n",
+			    index, ret);
 
 	return ret;
 }
@@ -193,7 +193,7 @@ static int smsc75xx_phy_wait_not_busy(struct usbnet *dev)
 
 	do {
 		ret = smsc75xx_read_reg(dev, MII_ACCESS, &val);
-		check_warn_return(ret, "Error reading MII_ACCESS");
+		check_warn_return(ret, "Error reading MII_ACCESS\n");
 
 		if (!(val & MII_ACCESS_BUSY))
 			return 0;
@@ -212,7 +212,7 @@ static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 
 	/* confirm MII not busy */
 	ret = smsc75xx_phy_wait_not_busy(dev);
-	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_read");
+	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_read\n");
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
@@ -221,13 +221,13 @@ static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_READ | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
-	check_warn_goto_done(ret, "Error writing MII_ACCESS");
+	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
 
 	ret = smsc75xx_phy_wait_not_busy(dev);
-	check_warn_goto_done(ret, "Timed out reading MII reg %02X", idx);
+	check_warn_goto_done(ret, "Timed out reading MII reg %02X\n", idx);
 
 	ret = smsc75xx_read_reg(dev, MII_DATA, &val);
-	check_warn_goto_done(ret, "Error reading MII_DATA");
+	check_warn_goto_done(ret, "Error reading MII_DATA\n");
 
 	ret = (u16)(val & 0xFFFF);
 
@@ -247,11 +247,11 @@ static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	ret = smsc75xx_phy_wait_not_busy(dev);
-	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_write");
+	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_write\n");
 
 	val = regval;
 	ret = smsc75xx_write_reg(dev, MII_DATA, val);
-	check_warn_goto_done(ret, "Error writing MII_DATA");
+	check_warn_goto_done(ret, "Error writing MII_DATA\n");
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
@@ -260,10 +260,10 @@ static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
 		| MII_ACCESS_WRITE | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
-	check_warn_goto_done(ret, "Error writing MII_ACCESS");
+	check_warn_goto_done(ret, "Error writing MII_ACCESS\n");
 
 	ret = smsc75xx_phy_wait_not_busy(dev);
-	check_warn_goto_done(ret, "Timed out writing MII reg %02X", idx);
+	check_warn_goto_done(ret, "Timed out writing MII reg %02X\n", idx);
 
 done:
 	mutex_unlock(&dev->phy_mutex);
@@ -277,7 +277,7 @@ static int smsc75xx_wait_eeprom(struct usbnet *dev)
 
 	do {
 		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD");
+		check_warn_return(ret, "Error reading E2P_CMD\n");
 
 		if (!(val & E2P_CMD_BUSY) || (val & E2P_CMD_TIMEOUT))
 			break;
@@ -285,7 +285,7 @@ static int smsc75xx_wait_eeprom(struct usbnet *dev)
 	} while (!time_after(jiffies, start_time + HZ));
 
 	if (val & (E2P_CMD_TIMEOUT | E2P_CMD_BUSY)) {
-		netdev_warn(dev->net, "EEPROM read operation timeout");
+		netdev_warn(dev->net, "EEPROM read operation timeout\n");
 		return -EIO;
 	}
 
@@ -300,7 +300,7 @@ static int smsc75xx_eeprom_confirm_not_busy(struct usbnet *dev)
 
 	do {
 		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD");
+		check_warn_return(ret, "Error reading E2P_CMD\n");
 
 		if (!(val & E2P_CMD_BUSY))
 			return 0;
@@ -308,7 +308,7 @@ static int smsc75xx_eeprom_confirm_not_busy(struct usbnet *dev)
 		udelay(40);
 	} while (!time_after(jiffies, start_time + HZ));
 
-	netdev_warn(dev->net, "EEPROM is busy");
+	netdev_warn(dev->net, "EEPROM is busy\n");
 	return -EIO;
 }
 
@@ -328,14 +328,14 @@ static int smsc75xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_BUSY | E2P_CMD_READ | (offset & E2P_CMD_ADDR);
 		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD");
+		check_warn_return(ret, "Error writing E2P_CMD\n");
 
 		ret = smsc75xx_wait_eeprom(dev);
 		if (ret < 0)
 			return ret;
 
 		ret = smsc75xx_read_reg(dev, E2P_DATA, &val);
-		check_warn_return(ret, "Error reading E2P_DATA");
+		check_warn_return(ret, "Error reading E2P_DATA\n");
 
 		data[i] = val & 0xFF;
 		offset++;
@@ -360,7 +360,7 @@ static int smsc75xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY | E2P_CMD_EWEN;
 	ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-	check_warn_return(ret, "Error writing E2P_CMD");
+	check_warn_return(ret, "Error writing E2P_CMD\n");
 
 	ret = smsc75xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -371,12 +371,12 @@ static int smsc75xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		/* Fill data register */
 		val = data[i];
 		ret = smsc75xx_write_reg(dev, E2P_DATA, val);
-		check_warn_return(ret, "Error writing E2P_DATA");
+		check_warn_return(ret, "Error writing E2P_DATA\n");
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY | E2P_CMD_WRITE | (offset & E2P_CMD_ADDR);
 		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD");
+		check_warn_return(ret, "Error writing E2P_CMD\n");
 
 		ret = smsc75xx_wait_eeprom(dev);
 		if (ret < 0)
@@ -395,7 +395,7 @@ static int smsc75xx_dataport_wait_not_busy(struct usbnet *dev)
 	for (i = 0; i < 100; i++) {
 		u32 dp_sel;
 		ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
-		check_warn_return(ret, "Error reading DP_SEL");
+		check_warn_return(ret, "Error reading DP_SEL\n");
 
 		if (dp_sel & DP_SEL_DPRDY)
 			return 0;
@@ -403,7 +403,7 @@ static int smsc75xx_dataport_wait_not_busy(struct usbnet *dev)
 		udelay(40);
 	}
 
-	netdev_warn(dev->net, "smsc75xx_dataport_wait_not_busy timed out");
+	netdev_warn(dev->net, "smsc75xx_dataport_wait_not_busy timed out\n");
 
 	return -EIO;
 }
@@ -418,28 +418,28 @@ static int smsc75xx_dataport_write(struct usbnet *dev, u32 ram_select, u32 addr,
 	mutex_lock(&pdata->dataport_mutex);
 
 	ret = smsc75xx_dataport_wait_not_busy(dev);
-	check_warn_goto_done(ret, "smsc75xx_dataport_write busy on entry");
+	check_warn_goto_done(ret, "smsc75xx_dataport_write busy on entry\n");
 
 	ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
-	check_warn_goto_done(ret, "Error reading DP_SEL");
+	check_warn_goto_done(ret, "Error reading DP_SEL\n");
 
 	dp_sel &= ~DP_SEL_RSEL;
 	dp_sel |= ram_select;
 	ret = smsc75xx_write_reg(dev, DP_SEL, dp_sel);
-	check_warn_goto_done(ret, "Error writing DP_SEL");
+	check_warn_goto_done(ret, "Error writing DP_SEL\n");
 
 	for (i = 0; i < length; i++) {
 		ret = smsc75xx_write_reg(dev, DP_ADDR, addr + i);
-		check_warn_goto_done(ret, "Error writing DP_ADDR");
+		check_warn_goto_done(ret, "Error writing DP_ADDR\n");
 
 		ret = smsc75xx_write_reg(dev, DP_DATA, buf[i]);
-		check_warn_goto_done(ret, "Error writing DP_DATA");
+		check_warn_goto_done(ret, "Error writing DP_DATA\n");
 
 		ret = smsc75xx_write_reg(dev, DP_CMD, DP_CMD_WRITE);
-		check_warn_goto_done(ret, "Error writing DP_CMD");
+		check_warn_goto_done(ret, "Error writing DP_CMD\n");
 
 		ret = smsc75xx_dataport_wait_not_busy(dev);
-		check_warn_goto_done(ret, "smsc75xx_dataport_write timeout");
+		check_warn_goto_done(ret, "smsc75xx_dataport_write timeout\n");
 	}
 
 done:
@@ -460,14 +460,14 @@ static void smsc75xx_deferred_multicast_write(struct work_struct *param)
 	struct usbnet *dev = pdata->dev;
 	int ret;
 
-	netif_dbg(dev, drv, dev->net, "deferred multicast write 0x%08x",
-		pdata->rfe_ctl);
+	netif_dbg(dev, drv, dev->net, "deferred multicast write 0x%08x\n",
+		  pdata->rfe_ctl);
 
 	smsc75xx_dataport_write(dev, DP_SEL_VHF, DP_SEL_VHF_VLAN_LEN,
 		DP_SEL_VHF_HASH_LEN, pdata->multicast_hash_table);
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn(ret, "Error writing RFE_CRL");
+	check_warn(ret, "Error writing RFE_CRL\n");
 }
 
 static void smsc75xx_set_multicast(struct net_device *netdev)
@@ -487,15 +487,15 @@ static void smsc75xx_set_multicast(struct net_device *netdev)
 		pdata->multicast_hash_table[i] = 0;
 
 	if (dev->net->flags & IFF_PROMISC) {
-		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled");
+		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled\n");
 		pdata->rfe_ctl |= RFE_CTL_AM | RFE_CTL_AU;
 	} else if (dev->net->flags & IFF_ALLMULTI) {
-		netif_dbg(dev, drv, dev->net, "receive all multicast enabled");
+		netif_dbg(dev, drv, dev->net, "receive all multicast enabled\n");
 		pdata->rfe_ctl |= RFE_CTL_AM | RFE_CTL_DPF;
 	} else if (!netdev_mc_empty(dev->net)) {
 		struct netdev_hw_addr *ha;
 
-		netif_dbg(dev, drv, dev->net, "receive multicast hash filter");
+		netif_dbg(dev, drv, dev->net, "receive multicast hash filter\n");
 
 		pdata->rfe_ctl |= RFE_CTL_MHF | RFE_CTL_DPF;
 
@@ -505,7 +505,7 @@ static void smsc75xx_set_multicast(struct net_device *netdev)
 				(1 << (bitnum % 32));
 		}
 	} else {
-		netif_dbg(dev, drv, dev->net, "receive own packets only");
+		netif_dbg(dev, drv, dev->net, "receive own packets only\n");
 		pdata->rfe_ctl |= RFE_CTL_DPF;
 	}
 
@@ -533,18 +533,18 @@ static int smsc75xx_update_flowcontrol(struct usbnet *dev, u8 duplex,
 		if (cap & FLOW_CTRL_RX)
 			flow |= FLOW_RX_FCEN;
 
-		netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s",
-			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
-			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+		netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s\n",
+			  (cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
+			  (cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
 	} else {
-		netif_dbg(dev, link, dev->net, "half duplex");
+		netif_dbg(dev, link, dev->net, "half duplex\n");
 	}
 
 	ret = smsc75xx_write_reg(dev, FLOW, flow);
-	check_warn_return(ret, "Error writing FLOW");
+	check_warn_return(ret, "Error writing FLOW\n");
 
 	ret = smsc75xx_write_reg(dev, FCT_FLOW, fct_flow);
-	check_warn_return(ret, "Error writing FCT_FLOW");
+	check_warn_return(ret, "Error writing FCT_FLOW\n");
 
 	return 0;
 }
@@ -561,16 +561,15 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 		PHY_INT_SRC_CLEAR_ALL);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
-	check_warn_return(ret, "Error writing INT_STS");
+	check_warn_return(ret, "Error writing INT_STS\n");
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 	lcladv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
 	rmtadv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
-	netif_dbg(dev, link, dev->net, "speed: %u duplex: %d lcladv: %04x"
-		  " rmtadv: %04x", ethtool_cmd_speed(&ecmd),
-		  ecmd.duplex, lcladv, rmtadv);
+	netif_dbg(dev, link, dev->net, "speed: %u duplex: %d lcladv: %04x rmtadv: %04x\n",
+		  ethtool_cmd_speed(&ecmd), ecmd.duplex, lcladv, rmtadv);
 
 	return smsc75xx_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
 }
@@ -580,21 +579,21 @@ static void smsc75xx_status(struct usbnet *dev, struct urb *urb)
 	u32 intdata;
 
 	if (urb->actual_length != 4) {
-		netdev_warn(dev->net,
-			"unexpected urb length %d", urb->actual_length);
+		netdev_warn(dev->net, "unexpected urb length %d\n",
+			    urb->actual_length);
 		return;
 	}
 
 	memcpy(&intdata, urb->transfer_buffer, 4);
 	le32_to_cpus(&intdata);
 
-	netif_dbg(dev, link, dev->net, "intdata: 0x%08X", intdata);
+	netif_dbg(dev, link, dev->net, "intdata: 0x%08X\n", intdata);
 
 	if (intdata & INT_ENP_PHY_INT)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
 	else
-		netdev_warn(dev->net,
-			"unexpected interrupt, intdata=0x%08X", intdata);
+		netdev_warn(dev->net, "unexpected interrupt, intdata=0x%08X\n",
+			    intdata);
 }
 
 static int smsc75xx_ethtool_get_eeprom_len(struct net_device *net)
@@ -618,8 +617,8 @@ static int smsc75xx_ethtool_set_eeprom(struct net_device *netdev,
 	struct usbnet *dev = netdev_priv(netdev);
 
 	if (ee->magic != LAN75XX_EEPROM_MAGIC) {
-		netdev_warn(dev->net,
-			"EEPROM: magic value mismatch: 0x%x", ee->magic);
+		netdev_warn(dev->net, "EEPROM: magic value mismatch: 0x%x\n",
+			    ee->magic);
 		return -EINVAL;
 	}
 
@@ -679,14 +678,14 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 		if (is_valid_ether_addr(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
 			netif_dbg(dev, ifup, dev->net,
-				"MAC address read from EEPROM");
+				  "MAC address read from EEPROM\n");
 			return;
 		}
 	}
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	eth_hw_addr_random(dev->net);
-	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr");
+	netif_dbg(dev, ifup, dev->net, "MAC address set to eth_random_addr\n");
 }
 
 static int smsc75xx_set_mac_address(struct usbnet *dev)
@@ -696,17 +695,17 @@ static int smsc75xx_set_mac_address(struct usbnet *dev)
 	u32 addr_hi = dev->net->dev_addr[4] | dev->net->dev_addr[5] << 8;
 
 	int ret = smsc75xx_write_reg(dev, RX_ADDRH, addr_hi);
-	check_warn_return(ret, "Failed to write RX_ADDRH: %d", ret);
+	check_warn_return(ret, "Failed to write RX_ADDRH: %d\n", ret);
 
 	ret = smsc75xx_write_reg(dev, RX_ADDRL, addr_lo);
-	check_warn_return(ret, "Failed to write RX_ADDRL: %d", ret);
+	check_warn_return(ret, "Failed to write RX_ADDRL: %d\n", ret);
 
 	addr_hi |= ADDR_FILTX_FB_VALID;
 	ret = smsc75xx_write_reg(dev, ADDR_FILTX, addr_hi);
-	check_warn_return(ret, "Failed to write ADDR_FILTX: %d", ret);
+	check_warn_return(ret, "Failed to write ADDR_FILTX: %d\n", ret);
 
 	ret = smsc75xx_write_reg(dev, ADDR_FILTX + 4, addr_lo);
-	check_warn_return(ret, "Failed to write ADDR_FILTX+4: %d", ret);
+	check_warn_return(ret, "Failed to write ADDR_FILTX+4: %d\n", ret);
 
 	return 0;
 }
@@ -730,12 +729,12 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 	do {
 		msleep(10);
 		bmcr = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
-		check_warn_return(bmcr, "Error reading MII_BMCR");
+		check_warn_return(bmcr, "Error reading MII_BMCR\n");
 		timeout++;
 	} while ((bmcr & BMCR_RESET) && (timeout < 100));
 
 	if (timeout >= 100) {
-		netdev_warn(dev->net, "timeout on PHY Reset");
+		netdev_warn(dev->net, "timeout on PHY Reset\n");
 		return -EIO;
 	}
 
@@ -747,14 +746,14 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 
 	/* read and write to clear phy interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_SRC, 0xffff);
 
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
 		PHY_INT_MASK_DEFAULT);
 	mii_nway_restart(&dev->mii);
 
-	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
+	netif_dbg(dev, ifup, dev->net, "phy initialised successfully\n");
 	return 0;
 }
 
@@ -765,14 +764,14 @@ static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
 	bool rxenabled;
 
 	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
-	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
 
 	rxenabled = ((buf & MAC_RX_RXEN) != 0);
 
 	if (rxenabled) {
 		buf &= ~MAC_RX_RXEN;
 		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-		check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+		check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
 	}
 
 	/* add 4 to size for FCS */
@@ -780,12 +779,12 @@ static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
 	buf |= (((size + 4) << MAC_RX_MAX_SIZE_SHIFT) & MAC_RX_MAX_SIZE);
 
 	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
 
 	if (rxenabled) {
 		buf |= MAC_RX_RXEN;
 		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-		check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+		check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
 	}
 
 	return 0;
@@ -796,7 +795,7 @@ static int smsc75xx_change_mtu(struct net_device *netdev, int new_mtu)
 	struct usbnet *dev = netdev_priv(netdev);
 
 	int ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu);
-	check_warn_return(ret, "Failed to set mac rx frame length");
+	check_warn_return(ret, "Failed to set mac rx frame length\n");
 
 	return usbnet_change_mtu(netdev, new_mtu);
 }
@@ -821,7 +820,7 @@ static int smsc75xx_set_features(struct net_device *netdev,
 	/* it's racing here! */
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn_return(ret, "Error writing RFE_CTL");
+	check_warn_return(ret, "Error writing RFE_CTL\n");
 
 	return 0;
 }
@@ -836,7 +835,7 @@ static int smsc75xx_wait_ready(struct usbnet *dev, int in_pm)
 
 		ret = __smsc75xx_read_reg(dev, PMT_CTL, &buf, in_pm);
 
-		check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+		check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
 
 		if (buf & PMT_CTL_DEV_RDY)
 			return 0;
@@ -845,7 +844,7 @@ static int smsc75xx_wait_ready(struct usbnet *dev, int in_pm)
 		timeout++;
 	} while (timeout < 100);
 
-	netdev_warn(dev->net, "timeout waiting for device ready");
+	netdev_warn(dev->net, "timeout waiting for device ready\n");
 	return -EIO;
 }
 
@@ -855,79 +854,81 @@ static int smsc75xx_reset(struct usbnet *dev)
 	u32 buf;
 	int ret = 0, timeout;
 
-	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset");
+	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset\n");
 
 	ret = smsc75xx_wait_ready(dev, 0);
-	check_warn_return(ret, "device not ready in smsc75xx_reset");
+	check_warn_return(ret, "device not ready in smsc75xx_reset\n");
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
 	buf |= HW_CFG_LRST;
 
 	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-	check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 		timeout++;
 	} while ((buf & HW_CFG_LRST) && (timeout < 100));
 
 	if (timeout >= 100) {
-		netdev_warn(dev->net, "timeout on completion of Lite Reset");
+		netdev_warn(dev->net, "timeout on completion of Lite Reset\n");
 		return -EIO;
 	}
 
-	netif_dbg(dev, ifup, dev->net, "Lite reset complete, resetting PHY");
+	netif_dbg(dev, ifup, dev->net, "Lite reset complete, resetting PHY\n");
 
 	ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
-	check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
 
 	buf |= PMT_CTL_PHY_RST;
 
 	ret = smsc75xx_write_reg(dev, PMT_CTL, buf);
-	check_warn_return(ret, "Failed to write PMT_CTL: %d", ret);
+	check_warn_return(ret, "Failed to write PMT_CTL: %d\n", ret);
 
 	timeout = 0;
 	do {
 		msleep(10);
 		ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
-		check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+		check_warn_return(ret, "Failed to read PMT_CTL: %d\n", ret);
 		timeout++;
 	} while ((buf & PMT_CTL_PHY_RST) && (timeout < 100));
 
 	if (timeout >= 100) {
-		netdev_warn(dev->net, "timeout waiting for PHY Reset");
+		netdev_warn(dev->net, "timeout waiting for PHY Reset\n");
 		return -EIO;
 	}
 
-	netif_dbg(dev, ifup, dev->net, "PHY reset complete");
+	netif_dbg(dev, ifup, dev->net, "PHY reset complete\n");
 
 	smsc75xx_init_mac_address(dev);
 
 	ret = smsc75xx_set_mac_address(dev);
-	check_warn_return(ret, "Failed to set mac address");
+	check_warn_return(ret, "Failed to set mac address\n");
 
-	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM", dev->net->dev_addr);
+	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM\n",
+		  dev->net->dev_addr);
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
+		  buf);
 
 	buf |= HW_CFG_BIR;
 
 	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-	check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+	check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG after "
-			"writing HW_CFG_BIR: 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG after writing HW_CFG_BIR: 0x%08x\n",
+		  buf);
 
 	if (!turbo_mode) {
 		buf = 0;
@@ -940,99 +941,102 @@ static int smsc75xx_reset(struct usbnet *dev)
 		dev->rx_urb_size = DEFAULT_FS_BURST_CAP_SIZE;
 	}
 
-	netif_dbg(dev, ifup, dev->net, "rx_urb_size=%ld",
-		(ulong)dev->rx_urb_size);
+	netif_dbg(dev, ifup, dev->net, "rx_urb_size=%ld\n",
+		  (ulong)dev->rx_urb_size);
 
 	ret = smsc75xx_write_reg(dev, BURST_CAP, buf);
-	check_warn_return(ret, "Failed to write BURST_CAP: %d", ret);
+	check_warn_return(ret, "Failed to write BURST_CAP: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, BURST_CAP, &buf);
-	check_warn_return(ret, "Failed to read BURST_CAP: %d", ret);
+	check_warn_return(ret, "Failed to read BURST_CAP: %d\n", ret);
 
 	netif_dbg(dev, ifup, dev->net,
-		"Read Value from BURST_CAP after writing: 0x%08x", buf);
+		  "Read Value from BURST_CAP after writing: 0x%08x\n", buf);
 
 	ret = smsc75xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
-	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d", ret);
+	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, BULK_IN_DLY, &buf);
-	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d", ret);
+	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d\n", ret);
 
 	netif_dbg(dev, ifup, dev->net,
-		"Read Value from BULK_IN_DLY after writing: 0x%08x", buf);
+		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n", buf);
 
 	if (turbo_mode) {
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x", buf);
+		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x\n", buf);
 
 		buf |= (HW_CFG_MEF | HW_CFG_BCE);
 
 		ret = smsc75xx_write_reg(dev, HW_CFG, buf);
-		check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+		check_warn_return(ret, "Failed to write HW_CFG: %d\n", ret);
 
 		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
-		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+		check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x", buf);
+		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x\n", buf);
 	}
 
 	/* set FIFO sizes */
 	buf = (MAX_RX_FIFO_SIZE - 512) / 512;
 	ret = smsc75xx_write_reg(dev, FCT_RX_FIFO_END, buf);
-	check_warn_return(ret, "Failed to write FCT_RX_FIFO_END: %d", ret);
+	check_warn_return(ret, "Failed to write FCT_RX_FIFO_END: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "FCT_RX_FIFO_END set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "FCT_RX_FIFO_END set to 0x%08x\n", buf);
 
 	buf = (MAX_TX_FIFO_SIZE - 512) / 512;
 	ret = smsc75xx_write_reg(dev, FCT_TX_FIFO_END, buf);
-	check_warn_return(ret, "Failed to write FCT_TX_FIFO_END: %d", ret);
+	check_warn_return(ret, "Failed to write FCT_TX_FIFO_END: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "FCT_TX_FIFO_END set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "FCT_TX_FIFO_END set to 0x%08x\n", buf);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
-	check_warn_return(ret, "Failed to write INT_STS: %d", ret);
+	check_warn_return(ret, "Failed to write INT_STS: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, ID_REV, &buf);
-	check_warn_return(ret, "Failed to read ID_REV: %d", ret);
+	check_warn_return(ret, "Failed to read ID_REV: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, E2P_CMD, &buf);
-	check_warn_return(ret, "Failed to read E2P_CMD: %d", ret);
+	check_warn_return(ret, "Failed to read E2P_CMD: %d\n", ret);
 
 	/* only set default GPIO/LED settings if no EEPROM is detected */
 	if (!(buf & E2P_CMD_LOADED)) {
 		ret = smsc75xx_read_reg(dev, LED_GPIO_CFG, &buf);
-		check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d", ret);
+		check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d\n",
+				  ret);
 
 		buf &= ~(LED_GPIO_CFG_LED2_FUN_SEL | LED_GPIO_CFG_LED10_FUN_SEL);
 		buf |= LED_GPIO_CFG_LEDGPIO_EN | LED_GPIO_CFG_LED2_FUN_SEL;
 
 		ret = smsc75xx_write_reg(dev, LED_GPIO_CFG, buf);
-		check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d", ret);
+		check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d\n",
+				  ret);
 	}
 
 	ret = smsc75xx_write_reg(dev, FLOW, 0);
-	check_warn_return(ret, "Failed to write FLOW: %d", ret);
+	check_warn_return(ret, "Failed to write FLOW: %d\n", ret);
 
 	ret = smsc75xx_write_reg(dev, FCT_FLOW, 0);
-	check_warn_return(ret, "Failed to write FCT_FLOW: %d", ret);
+	check_warn_return(ret, "Failed to write FCT_FLOW: %d\n", ret);
 
 	/* Don't need rfe_ctl_lock during initialisation */
 	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to read RFE_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read RFE_CTL: %d\n", ret);
 
 	pdata->rfe_ctl |= RFE_CTL_AB | RFE_CTL_DPF;
 
 	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to write RFE_CTL: %d", ret);
+	check_warn_return(ret, "Failed to write RFE_CTL: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
-	check_warn_return(ret, "Failed to read RFE_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read RFE_CTL: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ctl);
+	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x\n",
+		  pdata->rfe_ctl);
 
 	/* Enable or disable checksum offload engines */
 	smsc75xx_set_features(dev->net, dev->net->features);
@@ -1040,69 +1044,69 @@ static int smsc75xx_reset(struct usbnet *dev)
 	smsc75xx_set_multicast(dev->net);
 
 	ret = smsc75xx_phy_initialize(dev);
-	check_warn_return(ret, "Failed to initialize PHY: %d", ret);
+	check_warn_return(ret, "Failed to initialize PHY: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, INT_EP_CTL, &buf);
-	check_warn_return(ret, "Failed to read INT_EP_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read INT_EP_CTL: %d\n", ret);
 
 	/* enable PHY interrupts */
 	buf |= INT_ENP_PHY_INT;
 
 	ret = smsc75xx_write_reg(dev, INT_EP_CTL, buf);
-	check_warn_return(ret, "Failed to write INT_EP_CTL: %d", ret);
+	check_warn_return(ret, "Failed to write INT_EP_CTL: %d\n", ret);
 
 	/* allow mac to detect speed and duplex from phy */
 	ret = smsc75xx_read_reg(dev, MAC_CR, &buf);
-	check_warn_return(ret, "Failed to read MAC_CR: %d", ret);
+	check_warn_return(ret, "Failed to read MAC_CR: %d\n", ret);
 
 	buf |= (MAC_CR_ADD | MAC_CR_ASD);
 	ret = smsc75xx_write_reg(dev, MAC_CR, buf);
-	check_warn_return(ret, "Failed to write MAC_CR: %d", ret);
+	check_warn_return(ret, "Failed to write MAC_CR: %d\n", ret);
 
 	ret = smsc75xx_read_reg(dev, MAC_TX, &buf);
-	check_warn_return(ret, "Failed to read MAC_TX: %d", ret);
+	check_warn_return(ret, "Failed to read MAC_TX: %d\n", ret);
 
 	buf |= MAC_TX_TXEN;
 
 	ret = smsc75xx_write_reg(dev, MAC_TX, buf);
-	check_warn_return(ret, "Failed to write MAC_TX: %d", ret);
+	check_warn_return(ret, "Failed to write MAC_TX: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "MAC_TX set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "MAC_TX set to 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, FCT_TX_CTL, &buf);
-	check_warn_return(ret, "Failed to read FCT_TX_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read FCT_TX_CTL: %d\n", ret);
 
 	buf |= FCT_TX_CTL_EN;
 
 	ret = smsc75xx_write_reg(dev, FCT_TX_CTL, buf);
-	check_warn_return(ret, "Failed to write FCT_TX_CTL: %d", ret);
+	check_warn_return(ret, "Failed to write FCT_TX_CTL: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "FCT_TX_CTL set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "FCT_TX_CTL set to 0x%08x\n", buf);
 
 	ret = smsc75xx_set_rx_max_frame_length(dev, 1514);
-	check_warn_return(ret, "Failed to set max rx frame length");
+	check_warn_return(ret, "Failed to set max rx frame length\n");
 
 	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
-	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
 
 	buf |= MAC_RX_RXEN;
 
 	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
-	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "MAC_RX set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "MAC_RX set to 0x%08x\n", buf);
 
 	ret = smsc75xx_read_reg(dev, FCT_RX_CTL, &buf);
-	check_warn_return(ret, "Failed to read FCT_RX_CTL: %d", ret);
+	check_warn_return(ret, "Failed to read FCT_RX_CTL: %d\n", ret);
 
 	buf |= FCT_RX_CTL_EN;
 
 	ret = smsc75xx_write_reg(dev, FCT_RX_CTL, buf);
-	check_warn_return(ret, "Failed to write FCT_RX_CTL: %d", ret);
+	check_warn_return(ret, "Failed to write FCT_RX_CTL: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net, "FCT_RX_CTL set to 0x%08x", buf);
+	netif_dbg(dev, ifup, dev->net, "FCT_RX_CTL set to 0x%08x\n", buf);
 
-	netif_dbg(dev, ifup, dev->net, "smsc75xx_reset, return 0");
+	netif_dbg(dev, ifup, dev->net, "smsc75xx_reset, return 0\n");
 	return 0;
 }
 
@@ -1127,14 +1131,14 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
 
 	ret = usbnet_get_endpoints(dev, intf);
-	check_warn_return(ret, "usbnet_get_endpoints failed: %d", ret);
+	check_warn_return(ret, "usbnet_get_endpoints failed: %d\n", ret);
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc75xx_priv),
 		GFP_KERNEL);
 
 	pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	if (!pdata) {
-		netdev_warn(dev->net, "Unable to allocate smsc75xx_priv");
+		netdev_warn(dev->net, "Unable to allocate smsc75xx_priv\n");
 		return -ENOMEM;
 	}
 
@@ -1172,7 +1176,7 @@ static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
 	if (pdata) {
-		netif_dbg(dev, ifdown, dev->net, "free pdata");
+		netif_dbg(dev, ifdown, dev->net, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
 		dev->data[0] = 0;
@@ -1192,19 +1196,19 @@ static int smsc75xx_write_wuff(struct usbnet *dev, int filter, u32 wuf_cfg,
 	int ret;
 
 	ret = smsc75xx_write_reg(dev, cfg_base, wuf_cfg);
-	check_warn_return(ret, "Error writing WUF_CFGX");
+	check_warn_return(ret, "Error writing WUF_CFGX\n");
 
 	ret = smsc75xx_write_reg(dev, mask_base, wuf_mask1);
-	check_warn_return(ret, "Error writing WUF_MASKX");
+	check_warn_return(ret, "Error writing WUF_MASKX\n");
 
 	ret = smsc75xx_write_reg(dev, mask_base + 4, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX");
+	check_warn_return(ret, "Error writing WUF_MASKX\n");
 
 	ret = smsc75xx_write_reg(dev, mask_base + 8, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX");
+	check_warn_return(ret, "Error writing WUF_MASKX\n");
 
 	ret = smsc75xx_write_reg(dev, mask_base + 12, 0);
-	check_warn_return(ret, "Error writing WUF_MASKX");
+	check_warn_return(ret, "Error writing WUF_MASKX\n");
 
 	return 0;
 }
@@ -1217,38 +1221,38 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	u32 val;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_return(ret, "usbnet_suspend error");
+	check_warn_return(ret, "usbnet_suspend error\n");
 
 	/* if no wol options set, enter lowest power SUSPEND2 mode */
 	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
-		netdev_info(dev->net, "entering SUSPEND2 mode");
+		netdev_info(dev->net, "entering SUSPEND2 mode\n");
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_MPEN | WUCSR_WUEN);
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL");
+		check_warn_return(ret, "Error reading PMT_CTL\n");
 
 		val &= ~(PMT_CTL_ED_EN | PMT_CTL_WOL_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL");
+		check_warn_return(ret, "Error writing PMT_CTL\n");
 
 		/* enter suspend2 mode */
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL");
+		check_warn_return(ret, "Error reading PMT_CTL\n");
 
 		val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
 		val |= PMT_CTL_SUS_MODE_2;
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL");
+		check_warn_return(ret, "Error writing PMT_CTL\n");
 
 		return 0;
 	}
@@ -1259,120 +1263,120 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		/* disable all filters */
 		for (i = 0; i < WUF_NUM; i++) {
 			ret = smsc75xx_write_reg_nopm(dev, WUF_CFGX + i * 4, 0);
-			check_warn_return(ret, "Error writing WUF_CFGX");
+			check_warn_return(ret, "Error writing WUF_CFGX\n");
 		}
 
 		if (pdata->wolopts & WAKE_MCAST) {
 			const u8 mcast[] = {0x01, 0x00, 0x5E};
-			netdev_info(dev->net, "enabling multicast detection");
+			netdev_info(dev->net, "enabling multicast detection\n");
 
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_MULTICAST
 				| smsc_crc(mcast, 3);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0007);
-			check_warn_return(ret, "Error writing wakeup filter");
+			check_warn_return(ret, "Error writing wakeup filter\n");
 		}
 
 		if (pdata->wolopts & WAKE_ARP) {
 			const u8 arp[] = {0x08, 0x06};
-			netdev_info(dev->net, "enabling ARP detection");
+			netdev_info(dev->net, "enabling ARP detection\n");
 
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_ALL | (0x0C << 16)
 				| smsc_crc(arp, 2);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0003);
-			check_warn_return(ret, "Error writing wakeup filter");
+			check_warn_return(ret, "Error writing wakeup filter\n");
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 
-		netdev_info(dev->net, "enabling packet match detection");
+		netdev_info(dev->net, "enabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	} else {
-		netdev_info(dev->net, "disabling packet match detection");
+		netdev_info(dev->net, "disabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val &= ~WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	/* disable magic, bcast & unicast wakeup sources */
 	ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_return(ret, "Error reading WUCSR");
+	check_warn_return(ret, "Error reading WUCSR\n");
 
 	val &= ~(WUCSR_MPEN | WUCSR_BCST_EN | WUCSR_PFDA_EN);
 
 	ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_return(ret, "Error writing WUCSR");
+	check_warn_return(ret, "Error writing WUCSR\n");
 
 	if (pdata->wolopts & WAKE_MAGIC) {
-		netdev_info(dev->net, "enabling magic packet wakeup");
+		netdev_info(dev->net, "enabling magic packet wakeup\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		/* clear any pending magic packet status */
 		val |= WUCSR_MPR | WUCSR_MPEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_BCAST) {
-		netdev_info(dev->net, "enabling broadcast detection");
+		netdev_info(dev->net, "enabling broadcast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_BCAST_FR | WUCSR_BCST_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_UCAST) {
-		netdev_info(dev->net, "enabling unicast detection");
+		netdev_info(dev->net, "enabling unicast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR | WUCSR_PFDA_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	/* enable receiver to enable frame reception */
 	ret = smsc75xx_read_reg_nopm(dev, MAC_RX, &val);
-	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
 
 	val |= MAC_RX_RXEN;
 
 	ret = smsc75xx_write_reg_nopm(dev, MAC_RX, val);
-	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
 
 	/* some wol options are enabled, so enter SUSPEND0 */
-	netdev_info(dev->net, "entering SUSPEND0 mode");
+	netdev_info(dev->net, "entering SUSPEND0 mode\n");
 
 	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL");
+	check_warn_return(ret, "Error reading PMT_CTL\n");
 
 	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
 	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
 
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL");
+	check_warn_return(ret, "Error writing PMT_CTL\n");
 
 	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
@@ -1387,43 +1391,43 @@ static int smsc75xx_resume(struct usb_interface *intf)
 	u32 val;
 
 	if (pdata->wolopts) {
-		netdev_info(dev->net, "resuming from SUSPEND0");
+		netdev_info(dev->net, "resuming from SUSPEND0\n");
 
 		smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
 		/* Disable wakeup sources */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_WUEN | WUCSR_MPEN | WUCSR_PFDA_EN
 			| WUCSR_BCST_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 
 		/* clear wake-up status */
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL");
+		check_warn_return(ret, "Error reading PMT_CTL\n");
 
 		val &= ~PMT_CTL_WOL_EN;
 		val |= PMT_CTL_WUPS;
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL");
+		check_warn_return(ret, "Error writing PMT_CTL\n");
 	} else {
-		netdev_info(dev->net, "resuming from SUSPEND2");
+		netdev_info(dev->net, "resuming from SUSPEND2\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL");
+		check_warn_return(ret, "Error reading PMT_CTL\n");
 
 		val |= PMT_CTL_PHY_PWRUP;
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL");
+		check_warn_return(ret, "Error writing PMT_CTL\n");
 	}
 
 	ret = smsc75xx_wait_ready(dev, 1);
-	check_warn_return(ret, "device not ready in smsc75xx_resume");
+	check_warn_return(ret, "device not ready in smsc75xx_resume\n");
 
 	return usbnet_resume(intf);
 }
@@ -1463,7 +1467,7 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		if (unlikely(rx_cmd_a & RX_CMD_A_RED)) {
 			netif_dbg(dev, rx_err, dev->net,
-				"Error rx_cmd_a=0x%08x", rx_cmd_a);
+				  "Error rx_cmd_a=0x%08x\n", rx_cmd_a);
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_dropped++;
 
@@ -1475,7 +1479,8 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
 			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
 				netif_dbg(dev, rx_err, dev->net,
-					"size err rx_cmd_a=0x%08x", rx_cmd_a);
+					  "size err rx_cmd_a=0x%08x\n",
+					  rx_cmd_a);
 				return 0;
 			}
 
@@ -1492,7 +1497,7 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			ax_skb = skb_clone(skb, GFP_ATOMIC);
 			if (unlikely(!ax_skb)) {
-				netdev_warn(dev->net, "Error allocating skb");
+				netdev_warn(dev->net, "Error allocating skb\n");
 				return 0;
 			}
 
@@ -1517,7 +1522,7 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	if (unlikely(skb->len < 0)) {
-		netdev_warn(dev->net, "invalid rx length<0 %d", skb->len);
+		netdev_warn(dev->net, "invalid rx length<0 %d\n", skb->len);
 		return 0;
 	}
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index bf88543..79d495d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -95,8 +95,8 @@ static int __must_check __smsc95xx_read_reg(struct usbnet *dev, u32 index,
 		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
-		netdev_warn(dev->net,
-			"Failed to read reg index 0x%08x: %d", index, ret);
+		netdev_warn(dev->net, "Failed to read reg index 0x%08x: %d\n",
+			    index, ret);
 
 	le32_to_cpus(&buf);
 	*data = buf;
@@ -125,8 +125,8 @@ static int __must_check __smsc95xx_write_reg(struct usbnet *dev, u32 index,
 		 | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		 0, index, &buf, 4);
 	if (unlikely(ret < 0))
-		netdev_warn(dev->net,
-			"Failed to write reg index 0x%08x: %d", index, ret);
+		netdev_warn(dev->net, "Failed to write reg index 0x%08x: %d\n",
+			    index, ret);
 
 	return ret;
 }
@@ -185,7 +185,7 @@ static int __must_check __smsc95xx_phy_wait_not_busy(struct usbnet *dev,
 
 	do {
 		ret = __smsc95xx_read_reg(dev, MII_ADDR, &val, in_pm);
-		check_warn_return(ret, "Error reading MII_ACCESS");
+		check_warn_return(ret, "Error reading MII_ACCESS\n");
 		if (!(val & MII_BUSY_))
 			return 0;
 	} while (!time_after(jiffies, start_time + HZ));
@@ -204,20 +204,20 @@ static int __smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_read");
+	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_read\n");
 
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_READ_ | MII_BUSY_;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ADDR");
+	check_warn_goto_done(ret, "Error writing MII_ADDR\n");
 
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out reading MII reg %02X", idx);
+	check_warn_goto_done(ret, "Timed out reading MII reg %02X\n", idx);
 
 	ret = __smsc95xx_read_reg(dev, MII_DATA, &val, in_pm);
-	check_warn_goto_done(ret, "Error reading MII_DATA");
+	check_warn_goto_done(ret, "Error reading MII_DATA\n");
 
 	ret = (u16)(val & 0xFFFF);
 
@@ -237,21 +237,21 @@ static void __smsc95xx_mdio_write(struct net_device *netdev, int phy_id,
 
 	/* confirm MII not busy */
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_write");
+	check_warn_goto_done(ret, "MII is busy in smsc95xx_mdio_write\n");
 
 	val = regval;
 	ret = __smsc95xx_write_reg(dev, MII_DATA, val, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_DATA");
+	check_warn_goto_done(ret, "Error writing MII_DATA\n");
 
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
 	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_ | MII_BUSY_;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
-	check_warn_goto_done(ret, "Error writing MII_ADDR");
+	check_warn_goto_done(ret, "Error writing MII_ADDR\n");
 
 	ret = __smsc95xx_phy_wait_not_busy(dev, in_pm);
-	check_warn_goto_done(ret, "Timed out writing MII reg %02X", idx);
+	check_warn_goto_done(ret, "Timed out writing MII reg %02X\n", idx);
 
 done:
 	mutex_unlock(&dev->phy_mutex);
@@ -288,7 +288,7 @@ static int __must_check smsc95xx_wait_eeprom(struct usbnet *dev)
 
 	do {
 		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD");
+		check_warn_return(ret, "Error reading E2P_CMD\n");
 		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
 			break;
 		udelay(40);
@@ -310,7 +310,7 @@ static int __must_check smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 
 	do {
 		ret = smsc95xx_read_reg(dev, E2P_CMD, &val);
-		check_warn_return(ret, "Error reading E2P_CMD");
+		check_warn_return(ret, "Error reading E2P_CMD\n");
 
 		if (!(val & E2P_CMD_BUSY_))
 			return 0;
@@ -338,14 +338,14 @@ static int smsc95xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_BUSY_ | E2P_CMD_READ_ | (offset & E2P_CMD_ADDR_);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD");
+		check_warn_return(ret, "Error writing E2P_CMD\n");
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
 			return ret;
 
 		ret = smsc95xx_read_reg(dev, E2P_DATA, &val);
-		check_warn_return(ret, "Error reading E2P_DATA");
+		check_warn_return(ret, "Error reading E2P_DATA\n");
 
 		data[i] = val & 0xFF;
 		offset++;
@@ -370,7 +370,7 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
 	ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-	check_warn_return(ret, "Error writing E2P_DATA");
+	check_warn_return(ret, "Error writing E2P_DATA\n");
 
 	ret = smsc95xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -381,12 +381,12 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		/* Fill data register */
 		val = data[i];
 		ret = smsc95xx_write_reg(dev, E2P_DATA, val);
-		check_warn_return(ret, "Error writing E2P_DATA");
+		check_warn_return(ret, "Error writing E2P_DATA\n");
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-		check_warn_return(ret, "Error writing E2P_CMD");
+		check_warn_return(ret, "Error writing E2P_CMD\n");
 
 		ret = smsc95xx_wait_eeprom(dev);
 		if (ret < 0)
@@ -469,13 +469,13 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 
 	/* Initiate async writes, as we can't wait for completion here */
 	ret = smsc95xx_write_reg_async(dev, HASHH, &pdata->hash_hi);
-	check_warn(ret, "failed to initiate async write to HASHH");
+	check_warn(ret, "failed to initiate async write to HASHH\n");
 
 	ret = smsc95xx_write_reg_async(dev, HASHL, &pdata->hash_lo);
-	check_warn(ret, "failed to initiate async write to HASHL");
+	check_warn(ret, "failed to initiate async write to HASHL\n");
 
 	ret = smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
-	check_warn(ret, "failed to initiate async write to MAC_CR");
+	check_warn(ret, "failed to initiate async write to MAC_CR\n");
 }
 
 static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
@@ -484,7 +484,7 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	u32 flow, afc_cfg = 0;
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
-	check_warn_return(ret, "Error reading AFC_CFG");
+	check_warn_return(ret, "Error reading AFC_CFG\n");
 
 	if (duplex == DUPLEX_FULL) {
 		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
@@ -509,10 +509,10 @@ static int smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 	}
 
 	ret = smsc95xx_write_reg(dev, FLOW, flow);
-	check_warn_return(ret, "Error writing FLOW");
+	check_warn_return(ret, "Error writing FLOW\n");
 
 	ret = smsc95xx_write_reg(dev, AFC_CFG, afc_cfg);
-	check_warn_return(ret, "Error writing AFC_CFG");
+	check_warn_return(ret, "Error writing AFC_CFG\n");
 
 	return 0;
 }
@@ -528,10 +528,10 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 
 	/* clear interrupt status */
 	ret = smsc95xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
 
 	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
-	check_warn_return(ret, "Error writing INT_STS");
+	check_warn_return(ret, "Error writing INT_STS\n");
 
 	mii_check_media(mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -553,10 +553,10 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
-	check_warn_return(ret, "Error writing MAC_CR");
+	check_warn_return(ret, "Error writing MAC_CR\n");
 
 	ret = smsc95xx_phy_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
-	check_warn_return(ret, "Error updating PHY flow control");
+	check_warn_return(ret, "Error updating PHY flow control\n");
 
 	return 0;
 }
@@ -821,7 +821,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 
 	/* read to clear */
 	ret = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Failed to read PHY_INT_SRC during init");
+	check_warn_return(ret, "Failed to read PHY_INT_SRC during init\n");
 
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
 		PHY_INT_MASK_DEFAULT_);
@@ -875,14 +875,14 @@ static int smsc95xx_reset(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	netif_dbg(dev, ifup, dev->net,
-		  "MAC Address: %pM\n", dev->net->dev_addr);
+	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM\n",
+		  dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net,
-		  "Read Value from HW_CFG : 0x%08x\n", read_buf);
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
+		  read_buf);
 
 	read_buf |= HW_CFG_BIR_;
 
@@ -906,8 +906,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 		dev->rx_urb_size = DEFAULT_FS_BURST_CAP_SIZE;
 	}
 
-	netif_dbg(dev, ifup, dev->net,
-		  "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
+	netif_dbg(dev, ifup, dev->net, "rx_urb_size=%ld\n",
+		  (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
 	check_warn_return(ret, "Failed to write BURST_CAP: %d\n", ret);
@@ -932,8 +932,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	check_warn_return(ret, "Failed to read HW_CFG: %d\n", ret);
 
-	netif_dbg(dev, ifup, dev->net,
-		  "Read Value from HW_CFG: 0x%08x\n", read_buf);
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG: 0x%08x\n",
+		  read_buf);
 
 	if (turbo_mode)
 		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
@@ -983,12 +983,12 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	/* Enable or disable checksum offload engines */
 	ret = smsc95xx_set_features(dev->net, dev->net->features);
-	check_warn_return(ret, "Failed to set checksum offload features");
+	check_warn_return(ret, "Failed to set checksum offload features\n");
 
 	smsc95xx_set_multicast(dev->net);
 
 	ret = smsc95xx_phy_initialize(dev);
-	check_warn_return(ret, "Failed to init PHY");
+	check_warn_return(ret, "Failed to init PHY\n");
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
 	check_warn_return(ret, "Failed to read INT_EP_CTL: %d\n", ret);
@@ -1000,10 +1000,10 @@ static int smsc95xx_reset(struct usbnet *dev)
 	check_warn_return(ret, "Failed to write INT_EP_CTL: %d\n", ret);
 
 	ret = smsc95xx_start_tx_path(dev);
-	check_warn_return(ret, "Failed to start TX path");
+	check_warn_return(ret, "Failed to start TX path\n");
 
 	ret = smsc95xx_start_rx_path(dev, 0);
-	check_warn_return(ret, "Failed to start RX path");
+	check_warn_return(ret, "Failed to start RX path\n");
 
 	netif_dbg(dev, ifup, dev->net, "smsc95xx_reset, return 0\n");
 	return 0;
@@ -1098,15 +1098,15 @@ static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
 	struct mii_if_info *mii = &dev->mii;
 	int ret;
 
-	netdev_dbg(dev->net, "enabling PHY wakeup interrupts");
+	netdev_dbg(dev->net, "enabling PHY wakeup interrupts\n");
 
 	/* read to clear */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	check_warn_return(ret, "Error reading PHY_INT_SRC\n");
 
 	/* enable interrupt source */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_INT_MASK);
-	check_warn_return(ret, "Error reading PHY_INT_MASK");
+	check_warn_return(ret, "Error reading PHY_INT_MASK\n");
 
 	ret |= mask;
 
@@ -1122,10 +1122,10 @@ static int smsc95xx_link_ok_nopm(struct usbnet *dev)
 
 	/* first, a dummy read, needed to latch some MII phys */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR");
+	check_warn_return(ret, "Error reading MII_BMSR\n");
 
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
-	check_warn_return(ret, "Error reading MII_BMSR");
+	check_warn_return(ret, "Error reading MII_BMSR\n");
 
 	return !!(ret & BMSR_LSTATUS);
 }
@@ -1137,13 +1137,13 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
+	check_warn_return(ret, "Error reading PM_CTRL\n");
 
 	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
 	val |= PM_CTL_SUS_MODE_0;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	/* clear wol status */
 	val &= ~PM_CTL_WUPS_;
@@ -1154,11 +1154,11 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 		val |= PM_CTL_WUPS_ED_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	/* read back PM_CTRL */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
+	check_warn_return(ret, "Error reading PM_CTRL\n");
 
 	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
@@ -1181,7 +1181,7 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enable energy detect power-down mode */
 	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS);
-	check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS");
+	check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS\n");
 
 	ret |= MODE_CTRL_STS_EDPWRDOWN_;
 
@@ -1189,20 +1189,20 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enter SUSPEND1 mode */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
+	check_warn_return(ret, "Error reading PM_CTRL\n");
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_1;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	/* clear wol status, enable energy detection */
 	val &= ~PM_CTL_WUPS_;
 	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
 
@@ -1215,13 +1215,13 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
+	check_warn_return(ret, "Error reading PM_CTRL\n");
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	return 0;
 }
@@ -1234,7 +1234,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_return(ret, "usbnet_suspend error");
+	check_warn_return(ret, "usbnet_suspend error\n");
 
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc95xx_link_ok_nopm(dev);
@@ -1244,24 +1244,24 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	 */
 	if (!(pdata->wolopts & SUPPORTED_WAKE) ||
 		!(link_up || (pdata->wolopts & WAKE_PHY))) {
-		netdev_info(dev->net, "entering SUSPEND2 mode");
+		netdev_info(dev->net, "entering SUSPEND2 mode\n");
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_return(ret, "Error reading PM_CTRL");
+		check_warn_return(ret, "Error reading PM_CTRL\n");
 
 		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_return(ret, "Error writing PM_CTRL");
+		check_warn_return(ret, "Error writing PM_CTRL\n");
 
 		return smsc95xx_enter_suspend2(dev);
 	}
@@ -1269,13 +1269,13 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
 			(PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_LINK_DOWN_));
-		check_warn_return(ret, "error enabling PHY wakeup ints");
+		check_warn_return(ret, "error enabling PHY wakeup ints\n");
 
 		/* if link is down then configure EDPD and enter SUSPEND1,
 		 * otherwise enter SUSPEND0 below
 		 */
 		if (!link_up) {
-			netdev_info(dev->net, "entering SUSPEND1 mode");
+			netdev_info(dev->net, "entering SUSPEND1 mode\n");
 			return smsc95xx_enter_suspend1(dev);
 		}
 	}
@@ -1296,7 +1296,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		if (pdata->wolopts & WAKE_BCAST) {
 			const u8 bcast[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
-			netdev_info(dev->net, "enabling broadcast detection");
+			netdev_info(dev->net, "enabling broadcast detection\n");
 			filter_mask[filter * 4] = 0x003F;
 			filter_mask[filter * 4 + 1] = 0x00;
 			filter_mask[filter * 4 + 2] = 0x00;
@@ -1309,7 +1309,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		if (pdata->wolopts & WAKE_MCAST) {
 			const u8 mcast[] = {0x01, 0x00, 0x5E};
-			netdev_info(dev->net, "enabling multicast detection");
+			netdev_info(dev->net, "enabling multicast detection\n");
 			filter_mask[filter * 4] = 0x0007;
 			filter_mask[filter * 4 + 1] = 0x00;
 			filter_mask[filter * 4 + 2] = 0x00;
@@ -1322,7 +1322,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		if (pdata->wolopts & WAKE_ARP) {
 			const u8 arp[] = {0x08, 0x06};
-			netdev_info(dev->net, "enabling ARP detection");
+			netdev_info(dev->net, "enabling ARP detection\n");
 			filter_mask[filter * 4] = 0x0003;
 			filter_mask[filter * 4 + 1] = 0x00;
 			filter_mask[filter * 4 + 2] = 0x00;
@@ -1334,7 +1334,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		}
 
 		if (pdata->wolopts & WAKE_UCAST) {
-			netdev_info(dev->net, "enabling unicast detection");
+			netdev_info(dev->net, "enabling unicast detection\n");
 			filter_mask[filter * 4] = 0x003F;
 			filter_mask[filter * 4 + 1] = 0x00;
 			filter_mask[filter * 4 + 2] = 0x00;
@@ -1349,72 +1349,72 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
 			if (ret < 0)
 				kfree(filter_mask);
-			check_warn_return(ret, "Error writing WUFF");
+			check_warn_return(ret, "Error writing WUFF\n");
 		}
 		kfree(filter_mask);
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
-			check_warn_return(ret, "Error writing WUFF");
+			check_warn_return(ret, "Error writing WUFF\n");
 		}
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
-			check_warn_return(ret, "Error writing WUFF");
+			check_warn_return(ret, "Error writing WUFF\n");
 		}
 
 		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
-			check_warn_return(ret, "Error writing WUFF");
+			check_warn_return(ret, "Error writing WUFF\n");
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_MPR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 	}
 
 	/* enable/disable wakeup sources */
 	ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_return(ret, "Error reading WUCSR");
+	check_warn_return(ret, "Error reading WUCSR\n");
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
-		netdev_info(dev->net, "enabling pattern match wakeup");
+		netdev_info(dev->net, "enabling pattern match wakeup\n");
 		val |= WUCSR_WAKE_EN_;
 	} else {
-		netdev_info(dev->net, "disabling pattern match wakeup");
+		netdev_info(dev->net, "disabling pattern match wakeup\n");
 		val &= ~WUCSR_WAKE_EN_;
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
-		netdev_info(dev->net, "enabling magic packet wakeup");
+		netdev_info(dev->net, "enabling magic packet wakeup\n");
 		val |= WUCSR_MPEN_;
 	} else {
-		netdev_info(dev->net, "disabling magic packet wakeup");
+		netdev_info(dev->net, "disabling magic packet wakeup\n");
 		val &= ~WUCSR_MPEN_;
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_return(ret, "Error writing WUCSR");
+	check_warn_return(ret, "Error writing WUCSR\n");
 
 	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
+	check_warn_return(ret, "Error reading PM_CTRL\n");
 
 	val |= PM_CTL_WOL_EN_;
 
@@ -1423,13 +1423,13 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val |= PM_CTL_ED_EN_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
+	check_warn_return(ret, "Error writing PM_CTRL\n");
 
 	/* enable receiver to enable frame reception */
 	smsc95xx_start_rx_path(dev, 1);
 
 	/* some wol options are enabled, so enter SUSPEND0 */
-	netdev_info(dev->net, "entering SUSPEND0 mode");
+	netdev_info(dev->net, "entering SUSPEND0 mode\n");
 	return smsc95xx_enter_suspend0(dev);
 }
 
@@ -1447,26 +1447,26 @@ static int smsc95xx_resume(struct usb_interface *intf)
 
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR");
+		check_warn_return(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_WAKE_EN_ | WUCSR_MPEN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR");
+		check_warn_return(ret, "Error writing WUCSR\n");
 
 		/* clear wake-up status */
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_return(ret, "Error reading PM_CTRL");
+		check_warn_return(ret, "Error reading PM_CTRL\n");
 
 		val &= ~PM_CTL_WOL_EN_;
 		val |= PM_CTL_WUPS_;
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_return(ret, "Error writing PM_CTRL");
+		check_warn_return(ret, "Error writing PM_CTRL\n");
 	}
 
 	ret = usbnet_resume(intf);
-	check_warn_return(ret, "usbnet_resume error");
+	check_warn_return(ret, "usbnet_resume error\n");
 
 	return 0;
 }
