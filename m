From: Joe Perches <joe@perches.com>
Subject: [PATCH] smsc95xx: Remove trailing underscores from macros and uses
Date: Tue,  6 Sep 2016 14:18:59 -0700
Message-ID: <2b60dff11d5548bf2dba460cca44e8111288d41d.1473196511.git.joe@perches.com>
References: <20160906.132738.1194681585026078241.davem@davemloft.net>
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906.132738.1194681585026078241.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the #defines a bit more sensible to read.

Done with:

$ sed -r -i -e 's/\b([A-Z0-9_][A-Za-z0-9_]+)_\b/\U\1\E/g' \
  drivers/net/usb/smsc95xx.[ch]

and a little editing of the .h file to realign tabstop define values.

There are 3 [RT]x_COE_<foo> defines that were also uppercased.

No change in defconfig objects.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc95xx.c | 198 +++++++++++++--------------
 drivers/net/usb/smsc95xx.h | 330 ++++++++++++++++++++++-----------------------
 2 files changed, 264 insertions(+), 264 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 831aa33..c657fe1 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -178,7 +178,7 @@ static int __must_check __smsc95xx_phy_wait_not_busy(struct usbnet *dev,
 			return ret;
 		}
 
-		if (!(val & MII_BUSY_))
+		if (!(val & MII_BUSY))
 			return 0;
 	} while (!time_after(jiffies, start_time + HZ));
 
@@ -204,7 +204,7 @@ static int __smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx,
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
-	addr = (phy_id << 11) | (idx << 6) | MII_READ_ | MII_BUSY_;
+	addr = (phy_id << 11) | (idx << 6) | MII_READ | MII_BUSY;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Error writing MII_ADDR\n");
@@ -256,7 +256,7 @@ static void __smsc95xx_mdio_write(struct net_device *netdev, int phy_id,
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
-	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_ | MII_BUSY_;
+	addr = (phy_id << 11) | (idx << 6) | MII_WRITE | MII_BUSY;
 	ret = __smsc95xx_write_reg(dev, MII_ADDR, addr, in_pm);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Error writing MII_ADDR\n");
@@ -309,12 +309,12 @@ static int __must_check smsc95xx_wait_eeprom(struct usbnet *dev)
 			return ret;
 		}
 
-		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
+		if (!(val & E2P_CMD_BUSY) || (val & E2P_CMD_TIMEOUT))
 			break;
 		udelay(40);
 	} while (!time_after(jiffies, start_time + HZ));
 
-	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
+	if (val & (E2P_CMD_TIMEOUT | E2P_CMD_BUSY)) {
 		netdev_warn(dev->net, "EEPROM read operation timeout\n");
 		return -EIO;
 	}
@@ -335,7 +335,7 @@ static int __must_check smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 			return ret;
 		}
 
-		if (!(val & E2P_CMD_BUSY_))
+		if (!(val & E2P_CMD_BUSY))
 			return 0;
 
 		udelay(40);
@@ -359,7 +359,7 @@ static int smsc95xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		return ret;
 
 	for (i = 0; i < length; i++) {
-		val = E2P_CMD_BUSY_ | E2P_CMD_READ_ | (offset & E2P_CMD_ADDR_);
+		val = E2P_CMD_BUSY | E2P_CMD_READ | (offset & E2P_CMD_ADDR);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
 		if (ret < 0) {
 			netdev_warn(dev->net, "Error writing E2P_CMD\n");
@@ -397,7 +397,7 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		return ret;
 
 	/* Issue write/erase enable command */
-	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
+	val = E2P_CMD_BUSY | E2P_CMD_EWEN;
 	ret = smsc95xx_write_reg(dev, E2P_CMD, val);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Error writing E2P_DATA\n");
@@ -419,7 +419,7 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		}
 
 		/* Send "write" command */
-		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
+		val = E2P_CMD_BUSY | E2P_CMD_WRITE | (offset & E2P_CMD_ADDR);
 		ret = smsc95xx_write_reg(dev, E2P_CMD, val);
 		if (ret < 0) {
 			netdev_warn(dev->net, "Error writing E2P_CMD\n");
@@ -478,17 +478,17 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 
 	if (dev->net->flags & IFF_PROMISC) {
 		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled\n");
-		pdata->mac_cr |= MAC_CR_PRMS_;
-		pdata->mac_cr &= ~(MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+		pdata->mac_cr |= MAC_CR_PRMS;
+		pdata->mac_cr &= ~(MAC_CR_MCPAS | MAC_CR_HPFILT);
 	} else if (dev->net->flags & IFF_ALLMULTI) {
 		netif_dbg(dev, drv, dev->net, "receive all multicast enabled\n");
-		pdata->mac_cr |= MAC_CR_MCPAS_;
-		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
+		pdata->mac_cr |= MAC_CR_MCPAS;
+		pdata->mac_cr &= ~(MAC_CR_PRMS | MAC_CR_HPFILT);
 	} else if (!netdev_mc_empty(dev->net)) {
 		struct netdev_hw_addr *ha;
 
-		pdata->mac_cr |= MAC_CR_HPFILT_;
-		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_MCPAS_);
+		pdata->mac_cr |= MAC_CR_HPFILT;
+		pdata->mac_cr &= ~(MAC_CR_PRMS | MAC_CR_MCPAS);
 
 		netdev_for_each_mc_addr(ha, netdev) {
 			u32 bitnum = smsc95xx_hash(ha->addr);
@@ -504,7 +504,7 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 	} else {
 		netif_dbg(dev, drv, dev->net, "receive own packets only\n");
 		pdata->mac_cr &=
-			~(MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+			~(MAC_CR_PRMS | MAC_CR_MCPAS | MAC_CR_HPFILT);
 	}
 
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
@@ -575,7 +575,7 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
+	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	if (ret < 0)
 		return ret;
 
@@ -590,11 +590,11 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	if (ecmd.duplex != DUPLEX_FULL) {
-		pdata->mac_cr &= ~MAC_CR_FDPX_;
-		pdata->mac_cr |= MAC_CR_RCVOWN_;
+		pdata->mac_cr &= ~MAC_CR_FDPX;
+		pdata->mac_cr |= MAC_CR_RCVOWN;
 	} else {
-		pdata->mac_cr &= ~MAC_CR_RCVOWN_;
-		pdata->mac_cr |= MAC_CR_FDPX_;
+		pdata->mac_cr &= ~MAC_CR_RCVOWN;
+		pdata->mac_cr |= MAC_CR_FDPX;
 	}
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
@@ -624,7 +624,7 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 
 	netif_dbg(dev, link, dev->net, "intdata: 0x%08X\n", intdata);
 
-	if (intdata & INT_ENP_PHY_INT_)
+	if (intdata & INT_ENP_PHY_INT)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
 	else
 		netdev_warn(dev->net, "unexpected interrupt, intdata=0x%08X\n",
@@ -682,14 +682,14 @@ static int smsc95xx_set_features(struct net_device *netdev,
 		return ret;
 
 	if (features & NETIF_F_HW_CSUM)
-		read_buf |= Tx_COE_EN_;
+		read_buf |= TX_COE_EN;
 	else
-		read_buf &= ~Tx_COE_EN_;
+		read_buf &= ~TX_COE_EN;
 
 	if (features & NETIF_F_RXCSUM)
-		read_buf |= Rx_COE_EN_;
+		read_buf |= RX_COE_EN;
 	else
-		read_buf &= ~Rx_COE_EN_;
+		read_buf &= ~RX_COE_EN;
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
 	if (ret < 0)
@@ -791,14 +791,14 @@ static int get_mdix_status(struct net_device *net)
 	int buf;
 
 	buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, SPECIAL_CTRL_STS);
-	if (buf & SPECIAL_CTRL_STS_OVRRD_AMDIX_) {
-		if (buf & SPECIAL_CTRL_STS_AMDIX_ENABLE_)
+	if (buf & SPECIAL_CTRL_STS_OVRRD_AMDIX) {
+		if (buf & SPECIAL_CTRL_STS_AMDIX_ENABLE)
 			return ETH_TP_MDI_AUTO;
-		else if (buf & SPECIAL_CTRL_STS_AMDIX_STATE_)
+		else if (buf & SPECIAL_CTRL_STS_AMDIX_STATE)
 			return ETH_TP_MDI_X;
 	} else {
 		buf = smsc95xx_read_reg(dev, STRAP_STATUS, &val);
-		if (val & STRAP_STATUS_AMDIX_EN_)
+		if (val & STRAP_STATUS_AMDIX_EN)
 			return ETH_TP_MDI_AUTO;
 	}
 
@@ -811,14 +811,14 @@ static void set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int buf;
 
-	if ((pdata->chip_id == ID_REV_CHIP_ID_9500A_) ||
-	    (pdata->chip_id == ID_REV_CHIP_ID_9530_) ||
-	    (pdata->chip_id == ID_REV_CHIP_ID_89530_) ||
-	    (pdata->chip_id == ID_REV_CHIP_ID_9730_)) {
+	if ((pdata->chip_id == ID_REV_CHIP_ID_9500A) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_9530) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_89530) ||
+	    (pdata->chip_id == ID_REV_CHIP_ID_9730)) {
 		/* Extend Manual AutoMDIX timer for 9500A/9500Ai */
 		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
 					 PHY_EDPD_CONFIG);
-		buf |= PHY_EDPD_CONFIG_EXT_CROSSOVER_;
+		buf |= PHY_EDPD_CONFIG_EXT_CROSSOVER;
 		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
 				    PHY_EDPD_CONFIG, buf);
 	}
@@ -826,27 +826,27 @@ static void set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
 	if (mdix_ctrl == ETH_TP_MDI) {
 		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
 					 SPECIAL_CTRL_STS);
-		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX_;
-		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
-			 SPECIAL_CTRL_STS_AMDIX_STATE_);
+		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE |
+			 SPECIAL_CTRL_STS_AMDIX_STATE);
 		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
 				    SPECIAL_CTRL_STS, buf);
 	} else if (mdix_ctrl == ETH_TP_MDI_X) {
 		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
 					 SPECIAL_CTRL_STS);
-		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX_;
-		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
-			 SPECIAL_CTRL_STS_AMDIX_STATE_);
-		buf |= SPECIAL_CTRL_STS_AMDIX_STATE_;
+		buf |= SPECIAL_CTRL_STS_OVRRD_AMDIX;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE |
+			 SPECIAL_CTRL_STS_AMDIX_STATE);
+		buf |= SPECIAL_CTRL_STS_AMDIX_STATE;
 		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
 				    SPECIAL_CTRL_STS, buf);
 	} else if (mdix_ctrl == ETH_TP_MDI_AUTO) {
 		buf = smsc95xx_mdio_read(dev->net, dev->mii.phy_id,
 					 SPECIAL_CTRL_STS);
-		buf &= ~SPECIAL_CTRL_STS_OVRRD_AMDIX_;
-		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE_ |
-			 SPECIAL_CTRL_STS_AMDIX_STATE_);
-		buf |= SPECIAL_CTRL_STS_AMDIX_ENABLE_;
+		buf &= ~SPECIAL_CTRL_STS_OVRRD_AMDIX;
+		buf &= ~(SPECIAL_CTRL_STS_AMDIX_ENABLE |
+			 SPECIAL_CTRL_STS_AMDIX_STATE);
+		buf |= SPECIAL_CTRL_STS_AMDIX_ENABLE;
 		smsc95xx_mdio_write(dev->net, dev->mii.phy_id,
 				    SPECIAL_CTRL_STS, buf);
 	}
@@ -959,7 +959,7 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 
 	/* Enable Tx at MAC */
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
-	pdata->mac_cr |= MAC_CR_TXEN_;
+	pdata->mac_cr |= MAC_CR_TXEN;
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	ret = smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
@@ -967,7 +967,7 @@ static int smsc95xx_start_tx_path(struct usbnet *dev)
 		return ret;
 
 	/* Enable Tx at SCSRs */
-	return smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON_);
+	return smsc95xx_write_reg(dev, TX_CFG, TX_CFG_ON);
 }
 
 /* Starts the Receive path */
@@ -977,7 +977,7 @@ static int smsc95xx_start_rx_path(struct usbnet *dev, int in_pm)
 	unsigned long flags;
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
-	pdata->mac_cr |= MAC_CR_RXEN_;
+	pdata->mac_cr |= MAC_CR_RXEN;
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	return __smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr, in_pm);
@@ -1021,7 +1021,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	}
 
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
-		PHY_INT_MASK_DEFAULT_);
+		PHY_INT_MASK_DEFAULT);
 	mii_nway_restart(&dev->mii);
 
 	netif_dbg(dev, ifup, dev->net, "phy initialised successfully\n");
@@ -1036,7 +1036,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
-	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST_);
+	ret = smsc95xx_write_reg(dev, HW_CFG, HW_CFG_LRST);
 	if (ret < 0)
 		return ret;
 
@@ -1047,14 +1047,14 @@ static int smsc95xx_reset(struct usbnet *dev)
 		if (ret < 0)
 			return ret;
 		timeout++;
-	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
+	} while ((read_buf & HW_CFG_LRST) && (timeout < 100));
 
 	if (timeout >= 100) {
 		netdev_warn(dev->net, "timeout waiting for completion of Lite Reset\n");
 		return ret;
 	}
 
-	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST_);
+	ret = smsc95xx_write_reg(dev, PM_CTRL, PM_CTL_PHY_RST);
 	if (ret < 0)
 		return ret;
 
@@ -1065,7 +1065,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		if (ret < 0)
 			return ret;
 		timeout++;
-	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
+	} while ((read_buf & PM_CTL_PHY_RST) && (timeout < 100));
 
 	if (timeout >= 100) {
 		netdev_warn(dev->net, "timeout waiting for PHY Reset\n");
@@ -1086,7 +1086,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x\n",
 		  read_buf);
 
-	read_buf |= HW_CFG_BIR_;
+	read_buf |= HW_CFG_BIR;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
 	if (ret < 0)
@@ -1097,7 +1097,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 
 	netif_dbg(dev, ifup, dev->net,
-		  "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
+		  "Read Value from HW_CFG after writing HW_CFG_BIR: 0x%08x\n",
 		  read_buf);
 
 	if (!turbo_mode) {
@@ -1146,9 +1146,9 @@ static int smsc95xx_reset(struct usbnet *dev)
 		  read_buf);
 
 	if (turbo_mode)
-		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
+		read_buf |= (HW_CFG_MEF | HW_CFG_BCE);
 
-	read_buf &= ~HW_CFG_RXDOFF_;
+	read_buf &= ~HW_CFG_RXDOFF;
 
 	/* set Rx data offset=2, Make IP header aligns on word boundary. */
 	read_buf |= NET_IP_ALIGN << 9;
@@ -1164,7 +1164,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net,
 		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
-	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
+	ret = smsc95xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	if (ret < 0)
 		return ret;
 
@@ -1220,7 +1220,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 
 	/* enable PHY interrupts */
-	read_buf |= INT_EP_CTL_PHY_INT_;
+	read_buf |= INT_EP_CTL_PHY_INT;
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
 	if (ret < 0)
@@ -1298,12 +1298,12 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	pdata->chip_id = val;
 	pdata->mdix_ctrl = get_mdix_status(dev->net);
 
-	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
-	    (val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
+	if ((val == ID_REV_CHIP_ID_9500A) || (val == ID_REV_CHIP_ID_9530) ||
+	    (val == ID_REV_CHIP_ID_89530) || (val == ID_REV_CHIP_ID_9730))
 		pdata->features = (FEATURE_8_WAKEUP_FILTERS |
 			FEATURE_PHY_NLP_CROSSOVER |
 			FEATURE_REMOTE_WAKEUP);
-	else if (val == ID_REV_CHIP_ID_9512_)
+	else if (val == ID_REV_CHIP_ID_9512)
 		pdata->features = FEATURE_8_WAKEUP_FILTERS;
 
 	dev->net->netdev_ops = &smsc95xx_netdev_ops;
@@ -1389,7 +1389,7 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
+	val &= (~(PM_CTL_SUS_MODE | PM_CTL_WUPS | PM_CTL_PHY_RST));
 	val |= PM_CTL_SUS_MODE_0;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
@@ -1397,12 +1397,12 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 		return ret;
 
 	/* clear wol status */
-	val &= ~PM_CTL_WUPS_;
-	val |= PM_CTL_WUPS_WOL_;
+	val &= ~PM_CTL_WUPS;
+	val |= PM_CTL_WUPS_WOL;
 
 	/* enable energy detection */
 	if (pdata->wolopts & WAKE_PHY)
-		val |= PM_CTL_WUPS_ED_;
+		val |= PM_CTL_WUPS_ED;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
@@ -1437,7 +1437,7 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	ret |= MODE_CTRL_STS_EDPWRDOWN_;
+	ret |= MODE_CTRL_STS_EDPWRDOWN;
 
 	smsc95xx_mdio_write_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS, ret);
 
@@ -1446,7 +1446,7 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val &= ~(PM_CTL_SUS_MODE | PM_CTL_WUPS | PM_CTL_PHY_RST);
 	val |= PM_CTL_SUS_MODE_1;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
@@ -1454,8 +1454,8 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 		return ret;
 
 	/* clear wol status, enable energy detection */
-	val &= ~PM_CTL_WUPS_;
-	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
+	val &= ~PM_CTL_WUPS;
+	val |= (PM_CTL_WUPS_ED | PM_CTL_ED_EN);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
@@ -1476,7 +1476,7 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val &= ~(PM_CTL_SUS_MODE | PM_CTL_WUPS | PM_CTL_PHY_RST);
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
@@ -1507,7 +1507,7 @@ static int smsc95xx_enter_suspend3(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val &= ~(PM_CTL_SUS_MODE | PM_CTL_WUPS | PM_CTL_PHY_RST);
 	val |= PM_CTL_SUS_MODE_3 | PM_CTL_RES_CLR_WKP_STS;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
@@ -1515,8 +1515,8 @@ static int smsc95xx_enter_suspend3(struct usbnet *dev)
 		return ret;
 
 	/* clear wol status */
-	val &= ~PM_CTL_WUPS_;
-	val |= PM_CTL_WUPS_WOL_;
+	val &= ~PM_CTL_WUPS;
+	val |= PM_CTL_WUPS_WOL;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
@@ -1552,7 +1552,7 @@ static int smsc95xx_autosuspend(struct usbnet *dev, u32 link_up)
 
 		/* enable PHY wakeup events for if cable is attached */
 		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
-			PHY_INT_MASK_ANEG_COMP_);
+			PHY_INT_MASK_ANEG_COMP);
 		if (ret < 0) {
 			netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
 			return ret;
@@ -1564,7 +1564,7 @@ static int smsc95xx_autosuspend(struct usbnet *dev, u32 link_up)
 
 	/* enable PHY wakeup events so we remote wakeup if cable is pulled */
 	ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
-		PHY_INT_MASK_LINK_DOWN_);
+		PHY_INT_MASK_LINK_DOWN);
 	if (ret < 0) {
 		netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
 		return ret;
@@ -1614,7 +1614,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		if (ret < 0)
 			goto done;
 
-		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
+		val &= ~(WUCSR_MPEN | WUCSR_WAKE_EN);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
 		if (ret < 0)
@@ -1624,7 +1624,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		if (ret < 0)
 			goto done;
 
-		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
+		val &= ~(PM_CTL_ED_EN | PM_CTL_WOL_EN);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 		if (ret < 0)
@@ -1636,7 +1636,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
-			(PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_LINK_DOWN_));
+			(PHY_INT_MASK_ANEG_COMP | PHY_INT_MASK_LINK_DOWN));
 		if (ret < 0) {
 			netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
 			goto done;
@@ -1755,7 +1755,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		if (ret < 0)
 			goto done;
 
-		val |= WUCSR_WUFR_;
+		val |= WUCSR_WUFR;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
 		if (ret < 0)
@@ -1768,7 +1768,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		if (ret < 0)
 			goto done;
 
-		val |= WUCSR_MPR_;
+		val |= WUCSR_MPR;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
 		if (ret < 0)
@@ -1782,18 +1782,18 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		netdev_info(dev->net, "enabling pattern match wakeup\n");
-		val |= WUCSR_WAKE_EN_;
+		val |= WUCSR_WAKE_EN;
 	} else {
 		netdev_info(dev->net, "disabling pattern match wakeup\n");
-		val &= ~WUCSR_WAKE_EN_;
+		val &= ~WUCSR_WAKE_EN;
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		netdev_info(dev->net, "enabling magic packet wakeup\n");
-		val |= WUCSR_MPEN_;
+		val |= WUCSR_MPEN;
 	} else {
 		netdev_info(dev->net, "disabling magic packet wakeup\n");
-		val &= ~WUCSR_MPEN_;
+		val &= ~WUCSR_MPEN;
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
@@ -1805,11 +1805,11 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	if (ret < 0)
 		goto done;
 
-	val |= PM_CTL_WOL_EN_;
+	val |= PM_CTL_WOL_EN;
 
 	/* phy energy detect wakeup source */
 	if (pdata->wolopts & WAKE_PHY)
-		val |= PM_CTL_ED_EN_;
+		val |= PM_CTL_ED_EN;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	if (ret < 0)
@@ -1856,7 +1856,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
 		if (ret < 0)
 			return ret;
 
-		val &= ~(WUCSR_WAKE_EN_ | WUCSR_MPEN_);
+		val &= ~(WUCSR_WAKE_EN | WUCSR_MPEN);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
 		if (ret < 0)
@@ -1867,8 +1867,8 @@ static int smsc95xx_resume(struct usb_interface *intf)
 		if (ret < 0)
 			return ret;
 
-		val &= ~PM_CTL_WOL_EN_;
-		val |= PM_CTL_WUPS_;
+		val &= ~PM_CTL_WOL_EN;
+		val |= PM_CTL_WUPS;
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 		if (ret < 0)
@@ -1919,23 +1919,23 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		packet = skb->data;
 
 		/* get the packet length */
-		size = (u16)((header & RX_STS_FL_) >> 16);
+		size = (u16)((header & RX_STS_FL) >> 16);
 		align_count = (4 - ((size + NET_IP_ALIGN) % 4)) % 4;
 
-		if (unlikely(header & RX_STS_ES_)) {
+		if (unlikely(header & RX_STS_ES)) {
 			netif_dbg(dev, rx_err, dev->net,
 				  "Error header=0x%08x\n", header);
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_dropped++;
 
-			if (header & RX_STS_CRC_) {
+			if (header & RX_STS_CRC) {
 				dev->net->stats.rx_crc_errors++;
 			} else {
-				if (header & (RX_STS_TL_ | RX_STS_RF_))
+				if (header & (RX_STS_TL | RX_STS_RF))
 					dev->net->stats.rx_frame_errors++;
 
-				if ((header & RX_STS_LE_) &&
-					(!(header & RX_STS_FT_)))
+				if ((header & RX_STS_LE) &&
+					(!(header & RX_STS_FT)))
 					dev->net->stats.rx_length_errors++;
 			}
 		} else {
@@ -2037,8 +2037,8 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	memcpy(skb->data, &tx_cmd_b, 4);
 
 	skb_push(skb, 4);
-	tx_cmd_a = (u32)(skb->len - 8) | TX_CMD_A_FIRST_SEG_ |
-		TX_CMD_A_LAST_SEG_;
+	tx_cmd_a = (u32)(skb->len - 8) | TX_CMD_A_FIRST_SEG |
+		TX_CMD_A_LAST_SEG;
 	cpu_to_le32s(&tx_cmd_a);
 	memcpy(skb->data, &tx_cmd_a, 4);
 
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 29a4d9e..6d51424 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -21,91 +21,91 @@
 #define _SMSC95XX_H
 
 /* Tx command words */
-#define TX_CMD_A_DATA_OFFSET_		(0x001F0000)
-#define TX_CMD_A_FIRST_SEG_		(0x00002000)
-#define TX_CMD_A_LAST_SEG_		(0x00001000)
-#define TX_CMD_A_BUF_SIZE_		(0x000007FF)
+#define TX_CMD_A_DATA_OFFSET		(0x001F0000)
+#define TX_CMD_A_FIRST_SEG		(0x00002000)
+#define TX_CMD_A_LAST_SEG		(0x00001000)
+#define TX_CMD_A_BUF_SIZE		(0x000007FF)
 
 #define TX_CMD_B_CSUM_ENABLE		(0x00004000)
-#define TX_CMD_B_ADD_CRC_DISABLE_	(0x00002000)
-#define TX_CMD_B_DISABLE_PADDING_	(0x00001000)
-#define TX_CMD_B_PKT_BYTE_LENGTH_	(0x000007FF)
+#define TX_CMD_B_ADD_CRC_DISABLE	(0x00002000)
+#define TX_CMD_B_DISABLE_PADDING	(0x00001000)
+#define TX_CMD_B_PKT_BYTE_LENGTH	(0x000007FF)
 
 /* Rx status word */
-#define RX_STS_FF_			(0x40000000)	/* Filter Fail */
-#define RX_STS_FL_			(0x3FFF0000)	/* Frame Length */
-#define RX_STS_ES_			(0x00008000)	/* Error Summary */
-#define RX_STS_BF_			(0x00002000)	/* Broadcast Frame */
-#define RX_STS_LE_			(0x00001000)	/* Length Error */
-#define RX_STS_RF_			(0x00000800)	/* Runt Frame */
-#define RX_STS_MF_			(0x00000400)	/* Multicast Frame */
-#define RX_STS_TL_			(0x00000080)	/* Frame too long */
-#define RX_STS_CS_			(0x00000040)	/* Collision Seen */
-#define RX_STS_FT_			(0x00000020)	/* Frame Type */
-#define RX_STS_RW_			(0x00000010)	/* Receive Watchdog */
-#define RX_STS_ME_			(0x00000008)	/* Mii Error */
-#define RX_STS_DB_			(0x00000004)	/* Dribbling */
-#define RX_STS_CRC_			(0x00000002)	/* CRC Error */
+#define RX_STS_FF			(0x40000000)	/* Filter Fail */
+#define RX_STS_FL			(0x3FFF0000)	/* Frame Length */
+#define RX_STS_ES			(0x00008000)	/* Error Summary */
+#define RX_STS_BF			(0x00002000)	/* Broadcast Frame */
+#define RX_STS_LE			(0x00001000)	/* Length Error */
+#define RX_STS_RF			(0x00000800)	/* Runt Frame */
+#define RX_STS_MF			(0x00000400)	/* Multicast Frame */
+#define RX_STS_TL			(0x00000080)	/* Frame too long */
+#define RX_STS_CS			(0x00000040)	/* Collision Seen */
+#define RX_STS_FT			(0x00000020)	/* Frame Type */
+#define RX_STS_RW			(0x00000010)	/* Receive Watchdog */
+#define RX_STS_ME			(0x00000008)	/* Mii Error */
+#define RX_STS_DB			(0x00000004)	/* Dribbling */
+#define RX_STS_CRC			(0x00000002)	/* CRC Error */
 
 /* SCSRs */
 #define ID_REV				(0x00)
-#define ID_REV_CHIP_ID_MASK_		(0xFFFF0000)
-#define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
-#define ID_REV_CHIP_ID_9500_		(0x9500)
-#define ID_REV_CHIP_ID_9500A_		(0x9E00)
-#define ID_REV_CHIP_ID_9512_		(0xEC00)
-#define ID_REV_CHIP_ID_9530_		(0x9530)
-#define ID_REV_CHIP_ID_89530_		(0x9E08)
-#define ID_REV_CHIP_ID_9730_		(0x9730)
+#define ID_REV_CHIP_ID_MASK		(0xFFFF0000)
+#define ID_REV_CHIP_REV_MASK		(0x0000FFFF)
+#define ID_REV_CHIP_ID_9500		(0x9500)
+#define ID_REV_CHIP_ID_9500A		(0x9E00)
+#define ID_REV_CHIP_ID_9512		(0xEC00)
+#define ID_REV_CHIP_ID_9530		(0x9530)
+#define ID_REV_CHIP_ID_89530		(0x9E08)
+#define ID_REV_CHIP_ID_9730		(0x9730)
 
 #define INT_STS				(0x08)
-#define INT_STS_TX_STOP_		(0x00020000)
-#define INT_STS_RX_STOP_		(0x00010000)
-#define INT_STS_PHY_INT_		(0x00008000)
-#define INT_STS_TXE_			(0x00004000)
-#define INT_STS_TDFU_			(0x00002000)
-#define INT_STS_TDFO_			(0x00001000)
-#define INT_STS_RXDF_			(0x00000800)
-#define INT_STS_GPIOS_			(0x000007FF)
-#define INT_STS_CLEAR_ALL_		(0xFFFFFFFF)
+#define INT_STS_TX_STOP			(0x00020000)
+#define INT_STS_RX_STOP			(0x00010000)
+#define INT_STS_PHY_INT			(0x00008000)
+#define INT_STS_TXE			(0x00004000)
+#define INT_STS_TDFU			(0x00002000)
+#define INT_STS_TDFO			(0x00001000)
+#define INT_STS_RXDF			(0x00000800)
+#define INT_STS_GPIOS			(0x000007FF)
+#define INT_STS_CLEAR_ALL		(0xFFFFFFFF)
 
 #define RX_CFG				(0x0C)
-#define RX_FIFO_FLUSH_			(0x00000001)
+#define RX_FIFO_FLUSH			(0x00000001)
 
 #define TX_CFG				(0x10)
-#define TX_CFG_ON_			(0x00000004)
-#define TX_CFG_STOP_			(0x00000002)
-#define TX_CFG_FIFO_FLUSH_		(0x00000001)
+#define TX_CFG_ON			(0x00000004)
+#define TX_CFG_STOP			(0x00000002)
+#define TX_CFG_FIFO_FLUSH		(0x00000001)
 
 #define HW_CFG				(0x14)
-#define HW_CFG_BIR_			(0x00001000)
-#define HW_CFG_LEDB_			(0x00000800)
-#define HW_CFG_RXDOFF_			(0x00000600)
-#define HW_CFG_DRP_			(0x00000040)
-#define HW_CFG_MEF_			(0x00000020)
-#define HW_CFG_LRST_			(0x00000008)
-#define HW_CFG_PSEL_			(0x00000004)
-#define HW_CFG_BCE_			(0x00000002)
-#define HW_CFG_SRST_			(0x00000001)
+#define HW_CFG_BIR			(0x00001000)
+#define HW_CFG_LEDB			(0x00000800)
+#define HW_CFG_RXDOFF			(0x00000600)
+#define HW_CFG_DRP			(0x00000040)
+#define HW_CFG_MEF			(0x00000020)
+#define HW_CFG_LRST			(0x00000008)
+#define HW_CFG_PSEL			(0x00000004)
+#define HW_CFG_BCE			(0x00000002)
+#define HW_CFG_SRST			(0x00000001)
 
 #define RX_FIFO_INF			(0x18)
 
 #define PM_CTRL				(0x20)
 #define PM_CTL_RES_CLR_WKP_STS		(0x00000200)
-#define PM_CTL_DEV_RDY_			(0x00000080)
-#define PM_CTL_SUS_MODE_		(0x00000060)
+#define PM_CTL_DEV_RDY			(0x00000080)
+#define PM_CTL_SUS_MODE			(0x00000060)
 #define PM_CTL_SUS_MODE_0		(0x00000000)
 #define PM_CTL_SUS_MODE_1		(0x00000020)
 #define PM_CTL_SUS_MODE_2		(0x00000040)
 #define PM_CTL_SUS_MODE_3		(0x00000060)
-#define PM_CTL_PHY_RST_			(0x00000010)
-#define PM_CTL_WOL_EN_			(0x00000008)
-#define PM_CTL_ED_EN_			(0x00000004)
-#define PM_CTL_WUPS_			(0x00000003)
-#define PM_CTL_WUPS_NO_			(0x00000000)
-#define PM_CTL_WUPS_ED_			(0x00000001)
-#define PM_CTL_WUPS_WOL_		(0x00000002)
-#define PM_CTL_WUPS_MULTI_		(0x00000003)
+#define PM_CTL_PHY_RST			(0x00000010)
+#define PM_CTL_WOL_EN			(0x00000008)
+#define PM_CTL_ED_EN			(0x00000004)
+#define PM_CTL_WUPS			(0x00000003)
+#define PM_CTL_WUPS_NO			(0x00000000)
+#define PM_CTL_WUPS_ED			(0x00000001)
+#define PM_CTL_WUPS_WOL			(0x00000002)
+#define PM_CTL_WUPS_MULTI		(0x00000003)
 
 #define LED_GPIO_CFG			(0x24)
 #define LED_GPIO_CFG_SPD_LED		(0x01000000)
@@ -123,71 +123,71 @@
 #define AFC_CFG_DEFAULT			(0x00F830A1)
 
 #define E2P_CMD				(0x30)
-#define E2P_CMD_BUSY_			(0x80000000)
-#define E2P_CMD_MASK_			(0x70000000)
-#define E2P_CMD_READ_			(0x00000000)
-#define E2P_CMD_EWDS_			(0x10000000)
-#define E2P_CMD_EWEN_			(0x20000000)
-#define E2P_CMD_WRITE_			(0x30000000)
-#define E2P_CMD_WRAL_			(0x40000000)
-#define E2P_CMD_ERASE_			(0x50000000)
-#define E2P_CMD_ERAL_			(0x60000000)
-#define E2P_CMD_RELOAD_			(0x70000000)
-#define E2P_CMD_TIMEOUT_		(0x00000400)
-#define E2P_CMD_LOADED_			(0x00000200)
-#define E2P_CMD_ADDR_			(0x000001FF)
+#define E2P_CMD_BUSY			(0x80000000)
+#define E2P_CMD_MASK			(0x70000000)
+#define E2P_CMD_READ			(0x00000000)
+#define E2P_CMD_EWDS			(0x10000000)
+#define E2P_CMD_EWEN			(0x20000000)
+#define E2P_CMD_WRITE			(0x30000000)
+#define E2P_CMD_WRAL			(0x40000000)
+#define E2P_CMD_ERASE			(0x50000000)
+#define E2P_CMD_ERAL			(0x60000000)
+#define E2P_CMD_RELOAD			(0x70000000)
+#define E2P_CMD_TIMEOUT			(0x00000400)
+#define E2P_CMD_LOADED			(0x00000200)
+#define E2P_CMD_ADDR			(0x000001FF)
 
 #define MAX_EEPROM_SIZE			(512)
 
 #define E2P_DATA			(0x34)
-#define E2P_DATA_MASK_			(0x000000FF)
+#define E2P_DATA_MASK			(0x000000FF)
 
 #define BURST_CAP			(0x38)
 
 #define	STRAP_STATUS			(0x3C)
-#define	STRAP_STATUS_PWR_SEL_		(0x00000020)
-#define	STRAP_STATUS_AMDIX_EN_		(0x00000010)
-#define	STRAP_STATUS_PORT_SWAP_		(0x00000008)
-#define	STRAP_STATUS_EEP_SIZE_		(0x00000004)
-#define	STRAP_STATUS_RMT_WKP_		(0x00000002)
-#define	STRAP_STATUS_EEP_DISABLE_	(0x00000001)
+#define	STRAP_STATUS_PWR_SEL		(0x00000020)
+#define	STRAP_STATUS_AMDIX_EN		(0x00000010)
+#define	STRAP_STATUS_PORT_SWAP		(0x00000008)
+#define	STRAP_STATUS_EEP_SIZE		(0x00000004)
+#define	STRAP_STATUS_RMT_WKP		(0x00000002)
+#define	STRAP_STATUS_EEP_DISABLE	(0x00000001)
 
 #define GPIO_WAKE			(0x64)
 
 #define INT_EP_CTL			(0x68)
-#define INT_EP_CTL_INTEP_		(0x80000000)
-#define INT_EP_CTL_MACRTO_		(0x00080000)
-#define INT_EP_CTL_TX_STOP_		(0x00020000)
-#define INT_EP_CTL_RX_STOP_		(0x00010000)
-#define INT_EP_CTL_PHY_INT_		(0x00008000)
-#define INT_EP_CTL_TXE_			(0x00004000)
-#define INT_EP_CTL_TDFU_		(0x00002000)
-#define INT_EP_CTL_TDFO_		(0x00001000)
-#define INT_EP_CTL_RXDF_		(0x00000800)
-#define INT_EP_CTL_GPIOS_		(0x000007FF)
+#define INT_EP_CTL_INTEP		(0x80000000)
+#define INT_EP_CTL_MACRTO		(0x00080000)
+#define INT_EP_CTL_TX_STOP		(0x00020000)
+#define INT_EP_CTL_RX_STOP		(0x00010000)
+#define INT_EP_CTL_PHY_INT		(0x00008000)
+#define INT_EP_CTL_TXE			(0x00004000)
+#define INT_EP_CTL_TDFU			(0x00002000)
+#define INT_EP_CTL_TDFO			(0x00001000)
+#define INT_EP_CTL_RXDF			(0x00000800)
+#define INT_EP_CTL_GPIOS		(0x000007FF)
 
 #define BULK_IN_DLY			(0x6C)
 
 /* MAC CSRs */
 #define MAC_CR				(0x100)
-#define MAC_CR_RXALL_			(0x80000000)
-#define MAC_CR_RCVOWN_			(0x00800000)
-#define MAC_CR_LOOPBK_			(0x00200000)
-#define MAC_CR_FDPX_			(0x00100000)
-#define MAC_CR_MCPAS_			(0x00080000)
-#define MAC_CR_PRMS_			(0x00040000)
-#define MAC_CR_INVFILT_			(0x00020000)
-#define MAC_CR_PASSBAD_			(0x00010000)
-#define MAC_CR_HFILT_			(0x00008000)
-#define MAC_CR_HPFILT_			(0x00002000)
-#define MAC_CR_LCOLL_			(0x00001000)
-#define MAC_CR_BCAST_			(0x00000800)
-#define MAC_CR_DISRTY_			(0x00000400)
-#define MAC_CR_PADSTR_			(0x00000100)
+#define MAC_CR_RXALL			(0x80000000)
+#define MAC_CR_RCVOWN			(0x00800000)
+#define MAC_CR_LOOPBK			(0x00200000)
+#define MAC_CR_FDPX			(0x00100000)
+#define MAC_CR_MCPAS			(0x00080000)
+#define MAC_CR_PRMS			(0x00040000)
+#define MAC_CR_INVFILT			(0x00020000)
+#define MAC_CR_PASSBAD			(0x00010000)
+#define MAC_CR_HFILT			(0x00008000)
+#define MAC_CR_HPFILT			(0x00002000)
+#define MAC_CR_LCOLL			(0x00001000)
+#define MAC_CR_BCAST			(0x00000800)
+#define MAC_CR_DISRTY			(0x00000400)
+#define MAC_CR_PADSTR			(0x00000100)
 #define MAC_CR_BOLMT_MASK		(0x000000C0)
-#define MAC_CR_DFCHK_			(0x00000020)
-#define MAC_CR_TXEN_			(0x00000008)
-#define MAC_CR_RXEN_			(0x00000004)
+#define MAC_CR_DFCHK			(0x00000020)
+#define MAC_CR_TXEN			(0x00000008)
+#define MAC_CR_RXEN			(0x00000004)
 
 #define ADDRH				(0x104)
 
@@ -198,17 +198,17 @@
 #define HASHL				(0x110)
 
 #define MII_ADDR			(0x114)
-#define MII_WRITE_			(0x02)
-#define MII_BUSY_			(0x01)
-#define MII_READ_			(0x00) /* ~of MII Write bit */
+#define MII_WRITE			(0x02)
+#define MII_BUSY			(0x01)
+#define MII_READ			(0x00) /* ~of MII Write bit */
 
 #define MII_DATA			(0x118)
 
 #define FLOW				(0x11C)
-#define FLOW_FCPT_			(0xFFFF0000)
-#define FLOW_FCPASS_			(0x00000004)
-#define FLOW_FCEN_			(0x00000002)
-#define FLOW_FCBSY_			(0x00000001)
+#define FLOW_FCPT			(0xFFFF0000)
+#define FLOW_FCPASS			(0x00000004)
+#define FLOW_FCEN			(0x00000002)
+#define FLOW_FCBSY			(0x00000001)
 
 #define VLAN1				(0x120)
 
@@ -219,67 +219,67 @@
 #define LAN9500A_WUFF_NUM		(8)
 
 #define WUCSR				(0x12C)
-#define WUCSR_WFF_PTR_RST_		(0x80000000)
-#define WUCSR_GUE_			(0x00000200)
-#define WUCSR_WUFR_			(0x00000040)
-#define WUCSR_MPR_			(0x00000020)
-#define WUCSR_WAKE_EN_			(0x00000004)
-#define WUCSR_MPEN_			(0x00000002)
+#define WUCSR_WFF_PTR_RST		(0x80000000)
+#define WUCSR_GUE			(0x00000200)
+#define WUCSR_WUFR			(0x00000040)
+#define WUCSR_MPR			(0x00000020)
+#define WUCSR_WAKE_EN			(0x00000004)
+#define WUCSR_MPEN			(0x00000002)
 
 #define COE_CR				(0x130)
-#define Tx_COE_EN_			(0x00010000)
-#define Rx_COE_MODE_			(0x00000002)
-#define Rx_COE_EN_			(0x00000001)
+#define TX_COE_EN			(0x00010000)
+#define RX_COE_MODE			(0x00000002)
+#define RX_COE_EN			(0x00000001)
 
 /* Vendor-specific PHY Definitions */
 
 /* EDPD NLP / crossover time configuration (LAN9500A only) */
 #define PHY_EDPD_CONFIG			(16)
-#define PHY_EDPD_CONFIG_TX_NLP_EN_	((u16)0x8000)
-#define PHY_EDPD_CONFIG_TX_NLP_1000_	((u16)0x0000)
-#define PHY_EDPD_CONFIG_TX_NLP_768_	((u16)0x2000)
-#define PHY_EDPD_CONFIG_TX_NLP_512_	((u16)0x4000)
-#define PHY_EDPD_CONFIG_TX_NLP_256_	((u16)0x6000)
-#define PHY_EDPD_CONFIG_RX_1_NLP_	((u16)0x1000)
-#define PHY_EDPD_CONFIG_RX_NLP_64_	((u16)0x0000)
-#define PHY_EDPD_CONFIG_RX_NLP_256_	((u16)0x0400)
-#define PHY_EDPD_CONFIG_RX_NLP_512_	((u16)0x0800)
-#define PHY_EDPD_CONFIG_RX_NLP_1000_	((u16)0x0C00)
-#define PHY_EDPD_CONFIG_EXT_CROSSOVER_	((u16)0x0001)
-#define PHY_EDPD_CONFIG_DEFAULT		(PHY_EDPD_CONFIG_TX_NLP_EN_ | \
-					 PHY_EDPD_CONFIG_TX_NLP_768_ | \
-					 PHY_EDPD_CONFIG_RX_1_NLP_)
+#define PHY_EDPD_CONFIG_TX_NLP_EN	((u16)0x8000)
+#define PHY_EDPD_CONFIG_TX_NLP_1000	((u16)0x0000)
+#define PHY_EDPD_CONFIG_TX_NLP_768	((u16)0x2000)
+#define PHY_EDPD_CONFIG_TX_NLP_512	((u16)0x4000)
+#define PHY_EDPD_CONFIG_TX_NLP_256	((u16)0x6000)
+#define PHY_EDPD_CONFIG_RX_1_NLP	((u16)0x1000)
+#define PHY_EDPD_CONFIG_RX_NLP_64	((u16)0x0000)
+#define PHY_EDPD_CONFIG_RX_NLP_256	((u16)0x0400)
+#define PHY_EDPD_CONFIG_RX_NLP_512	((u16)0x0800)
+#define PHY_EDPD_CONFIG_RX_NLP_1000	((u16)0x0C00)
+#define PHY_EDPD_CONFIG_EXT_CROSSOVER	((u16)0x0001)
+#define PHY_EDPD_CONFIG_DEFAULT		(PHY_EDPD_CONFIG_TX_NLP_EN | \
+					 PHY_EDPD_CONFIG_TX_NLP_768 | \
+					 PHY_EDPD_CONFIG_RX_1_NLP)
 
 /* Mode Control/Status Register */
 #define PHY_MODE_CTRL_STS		(17)
-#define MODE_CTRL_STS_EDPWRDOWN_	((u16)0x2000)
-#define MODE_CTRL_STS_ENERGYON_		((u16)0x0002)
+#define MODE_CTRL_STS_EDPWRDOWN		((u16)0x2000)
+#define MODE_CTRL_STS_ENERGYON		((u16)0x0002)
 
 #define SPECIAL_CTRL_STS		(27)
-#define SPECIAL_CTRL_STS_OVRRD_AMDIX_	((u16)0x8000)
-#define SPECIAL_CTRL_STS_AMDIX_ENABLE_	((u16)0x4000)
-#define SPECIAL_CTRL_STS_AMDIX_STATE_	((u16)0x2000)
+#define SPECIAL_CTRL_STS_OVRRD_AMDIX	((u16)0x8000)
+#define SPECIAL_CTRL_STS_AMDIX_ENABLE	((u16)0x4000)
+#define SPECIAL_CTRL_STS_AMDIX_STATE	((u16)0x2000)
 
 #define PHY_INT_SRC			(29)
-#define PHY_INT_SRC_ENERGY_ON_		((u16)0x0080)
-#define PHY_INT_SRC_ANEG_COMP_		((u16)0x0040)
-#define PHY_INT_SRC_REMOTE_FAULT_	((u16)0x0020)
-#define PHY_INT_SRC_LINK_DOWN_		((u16)0x0010)
+#define PHY_INT_SRC_ENERGY_ON		((u16)0x0080)
+#define PHY_INT_SRC_ANEG_COMP		((u16)0x0040)
+#define PHY_INT_SRC_REMOTE_FAULT	((u16)0x0020)
+#define PHY_INT_SRC_LINK_DOWN		((u16)0x0010)
 
 #define PHY_INT_MASK			(30)
-#define PHY_INT_MASK_ENERGY_ON_		((u16)0x0080)
-#define PHY_INT_MASK_ANEG_COMP_		((u16)0x0040)
-#define PHY_INT_MASK_REMOTE_FAULT_	((u16)0x0020)
-#define PHY_INT_MASK_LINK_DOWN_		((u16)0x0010)
-#define PHY_INT_MASK_DEFAULT_		(PHY_INT_MASK_ANEG_COMP_ | \
-					 PHY_INT_MASK_LINK_DOWN_)
+#define PHY_INT_MASK_ENERGY_ON		((u16)0x0080)
+#define PHY_INT_MASK_ANEG_COMP		((u16)0x0040)
+#define PHY_INT_MASK_REMOTE_FAULT	((u16)0x0020)
+#define PHY_INT_MASK_LINK_DOWN		((u16)0x0010)
+#define PHY_INT_MASK_DEFAULT		(PHY_INT_MASK_ANEG_COMP | \
+					 PHY_INT_MASK_LINK_DOWN)
 
 #define PHY_SPECIAL			(31)
-#define PHY_SPECIAL_SPD_		((u16)0x001C)
-#define PHY_SPECIAL_SPD_10HALF_		((u16)0x0004)
-#define PHY_SPECIAL_SPD_10FULL_		((u16)0x0014)
-#define PHY_SPECIAL_SPD_100HALF_	((u16)0x0008)
-#define PHY_SPECIAL_SPD_100FULL_	((u16)0x0018)
+#define PHY_SPECIAL_SPD			((u16)0x001C)
+#define PHY_SPECIAL_SPD_10HALF		((u16)0x0004)
+#define PHY_SPECIAL_SPD_10FULL		((u16)0x0014)
+#define PHY_SPECIAL_SPD_100HALF		((u16)0x0008)
+#define PHY_SPECIAL_SPD_100FULL		((u16)0x0018)
 
 /* USB Vendor Requests */
 #define USB_VENDOR_REQUEST_WRITE_REGISTER	0xA0
@@ -287,12 +287,12 @@
 #define USB_VENDOR_REQUEST_GET_STATS		0xA2
 
 /* Interrupt Endpoint status word bitfields */
-#define INT_ENP_TX_STOP_		((u32)BIT(17))
-#define INT_ENP_RX_STOP_		((u32)BIT(16))
-#define INT_ENP_PHY_INT_		((u32)BIT(15))
-#define INT_ENP_TXE_			((u32)BIT(14))
-#define INT_ENP_TDFU_			((u32)BIT(13))
-#define INT_ENP_TDFO_			((u32)BIT(12))
-#define INT_ENP_RXDF_			((u32)BIT(11))
+#define INT_ENP_TX_STOP			((u32)BIT(17))
+#define INT_ENP_RX_STOP			((u32)BIT(16))
+#define INT_ENP_PHY_INT			((u32)BIT(15))
+#define INT_ENP_TXE			((u32)BIT(14))
+#define INT_ENP_TDFU			((u32)BIT(13))
+#define INT_ENP_TDFO			((u32)BIT(12))
+#define INT_ENP_RXDF			((u32)BIT(11))
 
 #endif /* _SMSC95XX_H */
-- 
2.10.0.rc2.1.g053435c
