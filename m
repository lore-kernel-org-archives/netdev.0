From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] lan78xx: Remove locally defined trailing underscores from defines and uses
Date: Tue,  6 Sep 2016 16:04:33 -0700
Message-ID: <c2cbbc1a6d39f6de8adb985617ee98ca37ff5dd2.1473202982.git.joe@perches.com>
References: <cover.1473202982.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0089.hostedemail.com ([216.40.44.89]:46367 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933172AbcIFXEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 19:04:42 -0400
In-Reply-To: <cover.1473202982.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro defines with trailing underscore are hard to read.

These locally defined ones with trailing underscores are all unique
without the trailing underscore, so remove them from the defines and uses.

Global defines that start with LAN88XX_ that are excluded.

Done with:

$ perl -p -i -e 's/\b(?!LAN88XX_)([A-Z0-9_][A-Za-z0-9_]+)_\b/\U\1\E/g' \
  drivers/net/usb/lan78xx.[ch]

and some editing to realign columns in the .h file.

No change in defconfig object.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/lan78xx.c |  340 +++++++--------
 drivers/net/usb/lan78xx.h | 1068 ++++++++++++++++++++++-----------------------
 2 files changed, 704 insertions(+), 704 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 432b8a3..b6d6d0f 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -548,7 +548,7 @@ static int lan78xx_phy_wait_not_busy(struct lan78xx_net *dev)
 		if (unlikely(ret < 0))
 			return -EIO;
 
-		if (!(val & MII_ACC_MII_BUSY_))
+		if (!(val & MII_ACC_MII_BUSY))
 			return 0;
 	} while (!time_after(jiffies, start_time + HZ));
 
@@ -559,13 +559,13 @@ static inline u32 mii_access(int id, int index, int read)
 {
 	u32 ret;
 
-	ret = ((u32)id << MII_ACC_PHY_ADDR_SHIFT_) & MII_ACC_PHY_ADDR_MASK_;
-	ret |= ((u32)index << MII_ACC_MIIRINDA_SHIFT_) & MII_ACC_MIIRINDA_MASK_;
+	ret = ((u32)id << MII_ACC_PHY_ADDR_SHIFT) & MII_ACC_PHY_ADDR_MASK;
+	ret |= ((u32)index << MII_ACC_MIIRINDA_SHIFT) & MII_ACC_MIIRINDA_MASK;
 	if (read)
-		ret |= MII_ACC_MII_READ_;
+		ret |= MII_ACC_MII_READ;
 	else
-		ret |= MII_ACC_MII_WRITE_;
-	ret |= MII_ACC_MII_BUSY_;
+		ret |= MII_ACC_MII_WRITE;
+	ret |= MII_ACC_MII_BUSY;
 
 	return ret;
 }
@@ -581,13 +581,13 @@ static int lan78xx_wait_eeprom(struct lan78xx_net *dev)
 		if (unlikely(ret < 0))
 			return -EIO;
 
-		if (!(val & E2P_CMD_EPC_BUSY_) ||
-		    (val & E2P_CMD_EPC_TIMEOUT_))
+		if (!(val & E2P_CMD_EPC_BUSY) ||
+		    (val & E2P_CMD_EPC_TIMEOUT))
 			break;
 		usleep_range(40, 100);
 	} while (!time_after(jiffies, start_time + HZ));
 
-	if (val & (E2P_CMD_EPC_TIMEOUT_ | E2P_CMD_EPC_BUSY_)) {
+	if (val & (E2P_CMD_EPC_TIMEOUT | E2P_CMD_EPC_BUSY)) {
 		netdev_warn(dev->net, "EEPROM read operation timeout");
 		return -EIO;
 	}
@@ -606,7 +606,7 @@ static int lan78xx_eeprom_confirm_not_busy(struct lan78xx_net *dev)
 		if (unlikely(ret < 0))
 			return -EIO;
 
-		if (!(val & E2P_CMD_EPC_BUSY_))
+		if (!(val & E2P_CMD_EPC_BUSY))
 			return 0;
 
 		usleep_range(40, 100);
@@ -629,8 +629,8 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	 */
 	ret = lan78xx_read_reg(dev, HW_CFG, &val);
 	saved = val;
-	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
-		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
+	if (dev->chipid == ID_REV_CHIP_ID_7800) {
+		val &= ~(HW_CFG_LED1_EN | HW_CFG_LED0_EN);
 		ret = lan78xx_write_reg(dev, HW_CFG, val);
 	}
 
@@ -639,8 +639,8 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 		return retval;
 
 	for (i = 0; i < length; i++) {
-		val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_READ_;
-		val |= (offset & E2P_CMD_EPC_ADDR_MASK_);
+		val = E2P_CMD_EPC_BUSY | E2P_CMD_EPC_CMD_READ;
+		val |= (offset & E2P_CMD_EPC_ADDR_MASK);
 		ret = lan78xx_write_reg(dev, E2P_CMD, val);
 		if (unlikely(ret < 0)) {
 			retval = -EIO;
@@ -663,7 +663,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 
 	retval = 0;
 exit:
-	if (dev->chipid == ID_REV_CHIP_ID_7800_)
+	if (dev->chipid == ID_REV_CHIP_ID_7800)
 		ret = lan78xx_write_reg(dev, HW_CFG, saved);
 
 	return retval;
@@ -697,8 +697,8 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	 */
 	ret = lan78xx_read_reg(dev, HW_CFG, &val);
 	saved = val;
-	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
-		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
+	if (dev->chipid == ID_REV_CHIP_ID_7800) {
+		val &= ~(HW_CFG_LED1_EN | HW_CFG_LED0_EN);
 		ret = lan78xx_write_reg(dev, HW_CFG, val);
 	}
 
@@ -707,7 +707,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 		goto exit;
 
 	/* Issue write/erase enable command */
-	val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_EWEN_;
+	val = E2P_CMD_EPC_BUSY | E2P_CMD_EPC_CMD_EWEN;
 	ret = lan78xx_write_reg(dev, E2P_CMD, val);
 	if (unlikely(ret < 0)) {
 		retval = -EIO;
@@ -728,8 +728,8 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 		}
 
 		/* Send "write" command */
-		val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_WRITE_;
-		val |= (offset & E2P_CMD_EPC_ADDR_MASK_);
+		val = E2P_CMD_EPC_BUSY | E2P_CMD_EPC_CMD_WRITE;
+		val |= (offset & E2P_CMD_EPC_ADDR_MASK);
 		ret = lan78xx_write_reg(dev, E2P_CMD, val);
 		if (ret < 0) {
 			retval = -EIO;
@@ -745,7 +745,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 
 	retval = 0;
 exit:
-	if (dev->chipid == ID_REV_CHIP_ID_7800_)
+	if (dev->chipid == ID_REV_CHIP_ID_7800)
 		ret = lan78xx_write_reg(dev, HW_CFG, saved);
 
 	return retval;
@@ -761,7 +761,7 @@ static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
 
 	ret = lan78xx_read_reg(dev, OTP_PWR_DN, &buf);
 
-	if (buf & OTP_PWR_DN_PWRDN_N_) {
+	if (buf & OTP_PWR_DN_PWRDN_N) {
 		/* clear it and wait to be cleared */
 		ret = lan78xx_write_reg(dev, OTP_PWR_DN, 0);
 
@@ -774,7 +774,7 @@ static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
 					    "timeout on OTP_PWR_DN");
 				return -EIO;
 			}
-		} while (buf & OTP_PWR_DN_PWRDN_N_);
+		} while (buf & OTP_PWR_DN_PWRDN_N);
 	}
 
 	for (i = 0; i < length; i++) {
@@ -783,8 +783,8 @@ static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
 		ret = lan78xx_write_reg(dev, OTP_ADDR2,
 					((offset + i) & OTP_ADDR2_10_3));
 
-		ret = lan78xx_write_reg(dev, OTP_FUNC_CMD, OTP_FUNC_CMD_READ_);
-		ret = lan78xx_write_reg(dev, OTP_CMD_GO, OTP_CMD_GO_GO_);
+		ret = lan78xx_write_reg(dev, OTP_FUNC_CMD, OTP_FUNC_CMD_READ);
+		ret = lan78xx_write_reg(dev, OTP_CMD_GO, OTP_CMD_GO_GO);
 
 		timeout = jiffies + HZ;
 		do {
@@ -795,7 +795,7 @@ static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
 					    "timeout on OTP_STATUS");
 				return -EIO;
 			}
-		} while (buf & OTP_STATUS_BUSY_);
+		} while (buf & OTP_STATUS_BUSY);
 
 		ret = lan78xx_read_reg(dev, OTP_RD_DATA, &buf);
 
@@ -815,7 +815,7 @@ static int lan78xx_write_raw_otp(struct lan78xx_net *dev, u32 offset,
 
 	ret = lan78xx_read_reg(dev, OTP_PWR_DN, &buf);
 
-	if (buf & OTP_PWR_DN_PWRDN_N_) {
+	if (buf & OTP_PWR_DN_PWRDN_N) {
 		/* clear it and wait to be cleared */
 		ret = lan78xx_write_reg(dev, OTP_PWR_DN, 0);
 
@@ -828,11 +828,11 @@ static int lan78xx_write_raw_otp(struct lan78xx_net *dev, u32 offset,
 					    "timeout on OTP_PWR_DN completion");
 				return -EIO;
 			}
-		} while (buf & OTP_PWR_DN_PWRDN_N_);
+		} while (buf & OTP_PWR_DN_PWRDN_N);
 	}
 
 	/* set to BYTE program mode */
-	ret = lan78xx_write_reg(dev, OTP_PRGM_MODE, OTP_PRGM_MODE_BYTE_);
+	ret = lan78xx_write_reg(dev, OTP_PRGM_MODE, OTP_PRGM_MODE_BYTE);
 
 	for (i = 0; i < length; i++) {
 		ret = lan78xx_write_reg(dev, OTP_ADDR1,
@@ -840,8 +840,8 @@ static int lan78xx_write_raw_otp(struct lan78xx_net *dev, u32 offset,
 		ret = lan78xx_write_reg(dev, OTP_ADDR2,
 					((offset + i) & OTP_ADDR2_10_3));
 		ret = lan78xx_write_reg(dev, OTP_PRGM_DATA, data[i]);
-		ret = lan78xx_write_reg(dev, OTP_TST_CMD, OTP_TST_CMD_PRGVRFY_);
-		ret = lan78xx_write_reg(dev, OTP_CMD_GO, OTP_CMD_GO_GO_);
+		ret = lan78xx_write_reg(dev, OTP_TST_CMD, OTP_TST_CMD_PRGVRFY);
+		ret = lan78xx_write_reg(dev, OTP_CMD_GO, OTP_CMD_GO_GO);
 
 		timeout = jiffies + HZ;
 		do {
@@ -852,7 +852,7 @@ static int lan78xx_write_raw_otp(struct lan78xx_net *dev, u32 offset,
 					    "Timeout on OTP_STATUS completion");
 				return -EIO;
 			}
-		} while (buf & OTP_STATUS_BUSY_);
+		} while (buf & OTP_STATUS_BUSY);
 	}
 
 	return 0;
@@ -890,7 +890,7 @@ static int lan78xx_dataport_wait_not_busy(struct lan78xx_net *dev)
 		if (unlikely(ret < 0))
 			return -EIO;
 
-		if (dp_sel & DP_SEL_DPRDY_)
+		if (dp_sel & DP_SEL_DPRDY)
 			return 0;
 
 		usleep_range(40, 100);
@@ -919,7 +919,7 @@ static int lan78xx_dataport_write(struct lan78xx_net *dev, u32 ram_select,
 
 	ret = lan78xx_read_reg(dev, DP_SEL, &dp_sel);
 
-	dp_sel &= ~DP_SEL_RSEL_MASK_;
+	dp_sel &= ~DP_SEL_RSEL_MASK;
 	dp_sel |= ram_select;
 	ret = lan78xx_write_reg(dev, DP_SEL, dp_sel);
 
@@ -928,7 +928,7 @@ static int lan78xx_dataport_write(struct lan78xx_net *dev, u32 ram_select,
 
 		ret = lan78xx_write_reg(dev, DP_DATA, buf[i]);
 
-		ret = lan78xx_write_reg(dev, DP_CMD, DP_CMD_WRITE_);
+		ret = lan78xx_write_reg(dev, DP_CMD, DP_CMD_WRITE);
 
 		ret = lan78xx_dataport_wait_not_busy(dev);
 		if (ret < 0)
@@ -955,7 +955,7 @@ static void lan78xx_set_addr_filter(struct lan78xx_priv *pdata,
 		pdata->pfilter_table[index][1] = temp;
 		temp = addr[5];
 		temp = addr[4] | (temp << 8);
-		temp |= MAF_HI_VALID_ | MAF_HI_TYPE_DST_;
+		temp |= MAF_HI_VALID | MAF_HI_TYPE_DST;
 		pdata->pfilter_table[index][0] = temp;
 	}
 }
@@ -977,7 +977,7 @@ static void lan78xx_deferred_multicast_write(struct work_struct *param)
 	netif_dbg(dev, drv, dev->net, "deferred multicast write 0x%08x\n",
 		  pdata->rfe_ctl);
 
-	lan78xx_dataport_write(dev, DP_SEL_RSEL_VLAN_DA_, DP_SEL_VHF_VLAN_LEN,
+	lan78xx_dataport_write(dev, DP_SEL_RSEL_VLAN_DA, DP_SEL_VHF_VLAN_LEN,
 			       DP_SEL_VHF_HASH_LEN, pdata->mchash_table);
 
 	for (i = 1; i < NUM_OF_MAF; i++) {
@@ -1000,8 +1000,8 @@ static void lan78xx_set_multicast(struct net_device *netdev)
 
 	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
 
-	pdata->rfe_ctl &= ~(RFE_CTL_UCAST_EN_ | RFE_CTL_MCAST_EN_ |
-			    RFE_CTL_DA_PERFECT_ | RFE_CTL_MCAST_HASH_);
+	pdata->rfe_ctl &= ~(RFE_CTL_UCAST_EN | RFE_CTL_MCAST_EN |
+			    RFE_CTL_DA_PERFECT | RFE_CTL_MCAST_HASH);
 
 	for (i = 0; i < DP_SEL_VHF_HASH_LEN; i++)
 			pdata->mchash_table[i] = 0;
@@ -1011,16 +1011,16 @@ static void lan78xx_set_multicast(struct net_device *netdev)
 			pdata->pfilter_table[i][1] = 0;
 	}
 
-	pdata->rfe_ctl |= RFE_CTL_BCAST_EN_;
+	pdata->rfe_ctl |= RFE_CTL_BCAST_EN;
 
 	if (dev->net->flags & IFF_PROMISC) {
 		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled");
-		pdata->rfe_ctl |= RFE_CTL_MCAST_EN_ | RFE_CTL_UCAST_EN_;
+		pdata->rfe_ctl |= RFE_CTL_MCAST_EN | RFE_CTL_UCAST_EN;
 	} else {
 		if (dev->net->flags & IFF_ALLMULTI) {
 			netif_dbg(dev, drv, dev->net,
 				  "receive all multicast enabled");
-			pdata->rfe_ctl |= RFE_CTL_MCAST_EN_;
+			pdata->rfe_ctl |= RFE_CTL_MCAST_EN;
 		}
 	}
 
@@ -1030,7 +1030,7 @@ static void lan78xx_set_multicast(struct net_device *netdev)
 
 		netif_dbg(dev, drv, dev->net, "receive multicast hash filter");
 
-		pdata->rfe_ctl |= RFE_CTL_DA_PERFECT_;
+		pdata->rfe_ctl |= RFE_CTL_DA_PERFECT;
 
 		i = 1;
 		netdev_for_each_mc_addr(ha, netdev) {
@@ -1042,7 +1042,7 @@ static void lan78xx_set_multicast(struct net_device *netdev)
 
 				pdata->mchash_table[bitnum / 32] |=
 							(1 << (bitnum % 32));
-				pdata->rfe_ctl |= RFE_CTL_MCAST_HASH_;
+				pdata->rfe_ctl |= RFE_CTL_MCAST_HASH;
 			}
 			i++;
 		}
@@ -1067,10 +1067,10 @@ static int lan78xx_update_flowcontrol(struct lan78xx_net *dev, u8 duplex,
 		cap = dev->fc_request_control;
 
 	if (cap & FLOW_CTRL_TX)
-		flow |= (FLOW_CR_TX_FCEN_ | 0xFFFF);
+		flow |= (FLOW_CR_TX_FCEN | 0xFFFF);
 
 	if (cap & FLOW_CTRL_RX)
-		flow |= FLOW_CR_RX_FCEN_;
+		flow |= FLOW_CR_RX_FCEN;
 
 	if (dev->udev->speed == USB_SPEED_SUPER)
 		fct_flow = 0x817;
@@ -1102,7 +1102,7 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 		return -EIO;
 
 	/* clear LAN78xx interrupt status */
-	ret = lan78xx_write_reg(dev, INT_STS, INT_STS_PHY_INT_);
+	ret = lan78xx_write_reg(dev, INT_STS, INT_STS_PHY_INT);
 	if (unlikely(ret < 0))
 		return -EIO;
 
@@ -1115,7 +1115,7 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 		ret = lan78xx_read_reg(dev, MAC_CR, &buf);
 		if (unlikely(ret < 0))
 			return -EIO;
-		buf |= MAC_CR_RST_;
+		buf |= MAC_CR_RST;
 		ret = lan78xx_write_reg(dev, MAC_CR, buf);
 		if (unlikely(ret < 0))
 			return -EIO;
@@ -1134,17 +1134,17 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 			if (ethtool_cmd_speed(&ecmd) == 1000) {
 				/* disable U2 */
 				ret = lan78xx_read_reg(dev, USB_CFG1, &buf);
-				buf &= ~USB_CFG1_DEV_U2_INIT_EN_;
+				buf &= ~USB_CFG1_DEV_U2_INIT_EN;
 				ret = lan78xx_write_reg(dev, USB_CFG1, buf);
 				/* enable U1 */
 				ret = lan78xx_read_reg(dev, USB_CFG1, &buf);
-				buf |= USB_CFG1_DEV_U1_INIT_EN_;
+				buf |= USB_CFG1_DEV_U1_INIT_EN;
 				ret = lan78xx_write_reg(dev, USB_CFG1, buf);
 			} else {
 				/* enable U1 & U2 */
 				ret = lan78xx_read_reg(dev, USB_CFG1, &buf);
-				buf |= USB_CFG1_DEV_U2_INIT_EN_;
-				buf |= USB_CFG1_DEV_U1_INIT_EN_;
+				buf |= USB_CFG1_DEV_U2_INIT_EN;
+				buf |= USB_CFG1_DEV_U1_INIT_EN;
 				ret = lan78xx_write_reg(dev, USB_CFG1, buf);
 			}
 		}
@@ -1285,7 +1285,7 @@ static void lan78xx_get_wol(struct net_device *netdev,
 		wol->supported = 0;
 		wol->wolopts = 0;
 	} else {
-		if (buf & USB_CFG_RMT_WKP_) {
+		if (buf & USB_CFG_RMT_WKP) {
 			wol->supported = WAKE_ALL;
 			wol->wolopts = pdata->wol;
 		} else {
@@ -1347,7 +1347,7 @@ static int lan78xx_get_eee(struct net_device *net, struct ethtool_eee *edata)
 		goto exit;
 
 	ret = lan78xx_read_reg(dev, MAC_CR, &buf);
-	if (buf & MAC_CR_EEE_EN_) {
+	if (buf & MAC_CR_EEE_EN) {
 		edata->eee_enabled = true;
 		edata->eee_active = !!(edata->advertised &
 				       edata->lp_advertised);
@@ -1381,7 +1381,7 @@ static int lan78xx_set_eee(struct net_device *net, struct ethtool_eee *edata)
 
 	if (edata->eee_enabled) {
 		ret = lan78xx_read_reg(dev, MAC_CR, &buf);
-		buf |= MAC_CR_EEE_EN_;
+		buf |= MAC_CR_EEE_EN;
 		ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 		phy_ethtool_set_eee(net->phydev, edata);
@@ -1390,7 +1390,7 @@ static int lan78xx_set_eee(struct net_device *net, struct ethtool_eee *edata)
 		ret = lan78xx_write_reg(dev, EEE_TX_LPI_REQ_DLY, buf);
 	} else {
 		ret = lan78xx_read_reg(dev, MAC_CR, &buf);
-		buf &= ~MAC_CR_EEE_EN_;
+		buf &= ~MAC_CR_EEE_EN;
 		ret = lan78xx_write_reg(dev, MAC_CR, buf);
 	}
 
@@ -1681,7 +1681,7 @@ static void lan78xx_init_mac_address(struct lan78xx_net *dev)
 	}
 
 	ret = lan78xx_write_reg(dev, MAF_LO(0), addr_lo);
-	ret = lan78xx_write_reg(dev, MAF_HI(0), addr_hi | MAF_HI_VALID_);
+	ret = lan78xx_write_reg(dev, MAF_HI(0), addr_hi | MAF_HI_VALID);
 
 	ether_addr_copy(dev->net->dev_addr, addr);
 }
@@ -1776,8 +1776,8 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
 		 dev->udev->bus->busnum, dev->udev->devnum);
 
 	switch (dev->chipid) {
-	case ID_REV_CHIP_ID_7800_:
-	case ID_REV_CHIP_ID_7850_:
+	case ID_REV_CHIP_ID_7800:
+	case ID_REV_CHIP_ID_7850:
 		/* set to internal PHY id */
 		dev->mdiobus->phy_mask = ~(1 << 1);
 		break;
@@ -1896,21 +1896,21 @@ static int lan78xx_set_rx_max_frame_length(struct lan78xx_net *dev, int size)
 
 	ret = lan78xx_read_reg(dev, MAC_RX, &buf);
 
-	rxenabled = ((buf & MAC_RX_RXEN_) != 0);
+	rxenabled = ((buf & MAC_RX_RXEN) != 0);
 
 	if (rxenabled) {
-		buf &= ~MAC_RX_RXEN_;
+		buf &= ~MAC_RX_RXEN;
 		ret = lan78xx_write_reg(dev, MAC_RX, buf);
 	}
 
 	/* add 4 to size for FCS */
-	buf &= ~MAC_RX_MAX_SIZE_MASK_;
-	buf |= (((size + 4) << MAC_RX_MAX_SIZE_SHIFT_) & MAC_RX_MAX_SIZE_MASK_);
+	buf &= ~MAC_RX_MAX_SIZE_MASK;
+	buf |= (((size + 4) << MAC_RX_MAX_SIZE_SHIFT) & MAC_RX_MAX_SIZE_MASK);
 
 	ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 	if (rxenabled) {
-		buf |= MAC_RX_RXEN_;
+		buf |= MAC_RX_RXEN;
 		ret = lan78xx_write_reg(dev, MAC_RX, buf);
 	}
 
@@ -2037,17 +2037,17 @@ static int lan78xx_set_features(struct net_device *netdev,
 	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
 
 	if (features & NETIF_F_RXCSUM) {
-		pdata->rfe_ctl |= RFE_CTL_TCPUDP_COE_ | RFE_CTL_IP_COE_;
-		pdata->rfe_ctl |= RFE_CTL_ICMP_COE_ | RFE_CTL_IGMP_COE_;
+		pdata->rfe_ctl |= RFE_CTL_TCPUDP_COE | RFE_CTL_IP_COE;
+		pdata->rfe_ctl |= RFE_CTL_ICMP_COE | RFE_CTL_IGMP_COE;
 	} else {
-		pdata->rfe_ctl &= ~(RFE_CTL_TCPUDP_COE_ | RFE_CTL_IP_COE_);
-		pdata->rfe_ctl &= ~(RFE_CTL_ICMP_COE_ | RFE_CTL_IGMP_COE_);
+		pdata->rfe_ctl &= ~(RFE_CTL_TCPUDP_COE | RFE_CTL_IP_COE);
+		pdata->rfe_ctl &= ~(RFE_CTL_ICMP_COE | RFE_CTL_IGMP_COE);
 	}
 
 	if (features & NETIF_F_HW_VLAN_CTAG_RX)
-		pdata->rfe_ctl |= RFE_CTL_VLAN_FILTER_;
+		pdata->rfe_ctl |= RFE_CTL_VLAN_FILTER;
 	else
-		pdata->rfe_ctl &= ~RFE_CTL_VLAN_FILTER_;
+		pdata->rfe_ctl &= ~RFE_CTL_VLAN_FILTER;
 
 	spin_unlock_irqrestore(&pdata->rfe_ctl_lock, flags);
 
@@ -2062,7 +2062,7 @@ static void lan78xx_deferred_vlan_write(struct work_struct *param)
 			container_of(param, struct lan78xx_priv, set_vlan);
 	struct lan78xx_net *dev = pdata->dev;
 
-	lan78xx_dataport_write(dev, DP_SEL_RSEL_VLAN_DA_, 0,
+	lan78xx_dataport_write(dev, DP_SEL_RSEL_VLAN_DA, 0,
 			       DP_SEL_VHF_VLAN_LEN, pdata->vlan_table);
 }
 
@@ -2111,7 +2111,7 @@ static void lan78xx_init_ltm(struct lan78xx_net *dev)
 	u32 regs[6] = { 0 };
 
 	ret = lan78xx_read_reg(dev, USB_CFG1, &buf);
-	if (buf & USB_CFG1_LTM_ENABLE_) {
+	if (buf & USB_CFG1_LTM_ENABLE) {
 		u8 temp[2];
 		/* Get values from EEPROM first */
 		if (lan78xx_read_eeprom(dev, 0x3F, 2, temp) == 0) {
@@ -2151,7 +2151,7 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	unsigned long timeout;
 
 	ret = lan78xx_read_reg(dev, HW_CFG, &buf);
-	buf |= HW_CFG_LRST_;
+	buf |= HW_CFG_LRST;
 	ret = lan78xx_write_reg(dev, HW_CFG, buf);
 
 	timeout = jiffies + HZ;
@@ -2163,18 +2163,18 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 				    "timeout on completion of LiteReset");
 			return -EIO;
 		}
-	} while (buf & HW_CFG_LRST_);
+	} while (buf & HW_CFG_LRST);
 
 	lan78xx_init_mac_address(dev);
 
 	/* save DEVID for later usage */
 	ret = lan78xx_read_reg(dev, ID_REV, &buf);
-	dev->chipid = (buf & ID_REV_CHIP_ID_MASK_) >> 16;
-	dev->chiprev = buf & ID_REV_CHIP_REV_MASK_;
+	dev->chipid = (buf & ID_REV_CHIP_ID_MASK) >> 16;
+	dev->chiprev = buf & ID_REV_CHIP_REV_MASK;
 
 	/* Respond to the IN token with a NAK */
 	ret = lan78xx_read_reg(dev, USB_CFG0, &buf);
-	buf |= USB_CFG_BIR_;
+	buf |= USB_CFG_BIR;
 	ret = lan78xx_write_reg(dev, USB_CFG0, buf);
 
 	/* Init LTM */
@@ -2203,11 +2203,11 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	ret = lan78xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
 
 	ret = lan78xx_read_reg(dev, HW_CFG, &buf);
-	buf |= HW_CFG_MEF_;
+	buf |= HW_CFG_MEF;
 	ret = lan78xx_write_reg(dev, HW_CFG, buf);
 
 	ret = lan78xx_read_reg(dev, USB_CFG0, &buf);
-	buf |= USB_CFG_BCE_;
+	buf |= USB_CFG_BCE;
 	ret = lan78xx_write_reg(dev, USB_CFG0, buf);
 
 	/* set FIFO sizes */
@@ -2217,13 +2217,13 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	buf = (MAX_TX_FIFO_SIZE - 512) / 512;
 	ret = lan78xx_write_reg(dev, FCT_TX_FIFO_END, buf);
 
-	ret = lan78xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL_);
+	ret = lan78xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	ret = lan78xx_write_reg(dev, FLOW, 0);
 	ret = lan78xx_write_reg(dev, FCT_FLOW, 0);
 
 	/* Don't need rfe_ctl_lock during initialisation */
 	ret = lan78xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
-	pdata->rfe_ctl |= RFE_CTL_BCAST_EN_ | RFE_CTL_DA_PERFECT_;
+	pdata->rfe_ctl |= RFE_CTL_BCAST_EN | RFE_CTL_DA_PERFECT;
 	ret = lan78xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
 
 	/* Enable or disable checksum offload engines */
@@ -2233,7 +2233,7 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 
 	/* reset PHY */
 	ret = lan78xx_read_reg(dev, PMT_CTL, &buf);
-	buf |= PMT_CTL_PHY_RST_;
+	buf |= PMT_CTL_PHY_RST;
 	ret = lan78xx_write_reg(dev, PMT_CTL, buf);
 
 	timeout = jiffies + HZ;
@@ -2244,10 +2244,10 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 			netdev_warn(dev->net, "timeout waiting for PHY Reset");
 			return -EIO;
 		}
-	} while ((buf & PMT_CTL_PHY_RST_) || !(buf & PMT_CTL_READY_));
+	} while ((buf & PMT_CTL_PHY_RST) || !(buf & PMT_CTL_READY));
 
 	ret = lan78xx_read_reg(dev, MAC_CR, &buf);
-	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
+	buf |= MAC_CR_AUTO_DUPLEX | MAC_CR_AUTO_SPEED;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
 	/* enable PHY interrupts */
@@ -2256,21 +2256,21 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	ret = lan78xx_write_reg(dev, INT_EP_CTL, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-	buf |= MAC_TX_TXEN_;
+	buf |= MAC_TX_TXEN;
 	ret = lan78xx_write_reg(dev, MAC_TX, buf);
 
 	ret = lan78xx_read_reg(dev, FCT_TX_CTL, &buf);
-	buf |= FCT_TX_CTL_EN_;
+	buf |= FCT_TX_CTL_EN;
 	ret = lan78xx_write_reg(dev, FCT_TX_CTL, buf);
 
 	ret = lan78xx_set_rx_max_frame_length(dev, dev->net->mtu + ETH_HLEN);
 
 	ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-	buf |= MAC_RX_RXEN_;
+	buf |= MAC_RX_RXEN;
 	ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 	ret = lan78xx_read_reg(dev, FCT_RX_CTL, &buf);
-	buf |= FCT_RX_CTL_EN_;
+	buf |= FCT_RX_CTL_EN;
 	ret = lan78xx_write_reg(dev, FCT_RX_CTL, buf);
 
 	return 0;
@@ -2432,23 +2432,23 @@ static struct sk_buff *lan78xx_tx_prep(struct lan78xx_net *dev,
 	if (lan78xx_linearize(skb) < 0)
 		return NULL;
 
-	tx_cmd_a = (u32)(skb->len & TX_CMD_A_LEN_MASK_) | TX_CMD_A_FCS_;
+	tx_cmd_a = (u32)(skb->len & TX_CMD_A_LEN_MASK) | TX_CMD_A_FCS;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		tx_cmd_a |= TX_CMD_A_IPE_ | TX_CMD_A_TPE_;
+		tx_cmd_a |= TX_CMD_A_IPE | TX_CMD_A_TPE;
 
 	tx_cmd_b = 0;
 	if (skb_is_gso(skb)) {
-		u16 mss = max(skb_shinfo(skb)->gso_size, TX_CMD_B_MSS_MIN_);
+		u16 mss = max(skb_shinfo(skb)->gso_size, TX_CMD_B_MSS_MIN);
 
-		tx_cmd_b = (mss << TX_CMD_B_MSS_SHIFT_) & TX_CMD_B_MSS_MASK_;
+		tx_cmd_b = (mss << TX_CMD_B_MSS_SHIFT) & TX_CMD_B_MSS_MASK;
 
-		tx_cmd_a |= TX_CMD_A_LSO_;
+		tx_cmd_a |= TX_CMD_A_LSO;
 	}
 
 	if (skb_vlan_tag_present(skb)) {
-		tx_cmd_a |= TX_CMD_A_IVTG_;
-		tx_cmd_b |= skb_vlan_tag_get(skb) & TX_CMD_B_VTAG_MASK_;
+		tx_cmd_a |= TX_CMD_A_IVTG;
+		tx_cmd_b |= skb_vlan_tag_get(skb) & TX_CMD_B_VTAG_MASK;
 	}
 
 	skb_push(skb, 4);
@@ -2692,10 +2692,10 @@ static void lan78xx_rx_csum_offload(struct lan78xx_net *dev,
 				    u32 rx_cmd_a, u32 rx_cmd_b)
 {
 	if (!(dev->net->features & NETIF_F_RXCSUM) ||
-	    unlikely(rx_cmd_a & RX_CMD_A_ICSM_)) {
+	    unlikely(rx_cmd_a & RX_CMD_A_ICSM)) {
 		skb->ip_summed = CHECKSUM_NONE;
 	} else {
-		skb->csum = ntohs((u16)(rx_cmd_b >> RX_CMD_B_CSUM_SHIFT_));
+		skb->csum = ntohs((u16)(rx_cmd_b >> RX_CMD_B_CSUM_SHIFT));
 		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 }
@@ -2753,10 +2753,10 @@ static int lan78xx_rx(struct lan78xx_net *dev, struct sk_buff *skb)
 		packet = skb->data;
 
 		/* get the packet length */
-		size = (rx_cmd_a & RX_CMD_A_LEN_MASK_);
+		size = (rx_cmd_a & RX_CMD_A_LEN_MASK);
 		align_count = (4 - ((size + RXW_PADDING) % 4)) % 4;
 
-		if (unlikely(rx_cmd_a & RX_CMD_A_RED_)) {
+		if (unlikely(rx_cmd_a & RX_CMD_A_RED)) {
 			netif_dbg(dev, rx_err, dev->net,
 				  "Error rx_cmd_a=0x%08x", rx_cmd_a);
 		} else {
@@ -3473,10 +3473,10 @@ static int lan78xx_set_suspend(struct lan78xx_net *dev, u32 wol)
 	const u8 arp_type[2] = { 0x08, 0x06 };
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-	buf &= ~MAC_TX_TXEN_;
+	buf &= ~MAC_TX_TXEN;
 	ret = lan78xx_write_reg(dev, MAC_TX, buf);
 	ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-	buf &= ~MAC_RX_RXEN_;
+	buf &= ~MAC_RX_RXEN;
 	ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 	ret = lan78xx_write_reg(dev, WUCSR, 0);
@@ -3487,44 +3487,44 @@ static int lan78xx_set_suspend(struct lan78xx_net *dev, u32 wol)
 
 	temp_pmt_ctl = 0;
 	ret = lan78xx_read_reg(dev, PMT_CTL, &temp_pmt_ctl);
-	temp_pmt_ctl &= ~PMT_CTL_RES_CLR_WKP_EN_;
-	temp_pmt_ctl |= PMT_CTL_RES_CLR_WKP_STS_;
+	temp_pmt_ctl &= ~PMT_CTL_RES_CLR_WKP_EN;
+	temp_pmt_ctl |= PMT_CTL_RES_CLR_WKP_STS;
 
 	for (mask_index = 0; mask_index < NUM_OF_WUF_CFG; mask_index++)
 		ret = lan78xx_write_reg(dev, WUF_CFG(mask_index), 0);
 
 	mask_index = 0;
 	if (wol & WAKE_PHY) {
-		temp_pmt_ctl |= PMT_CTL_PHY_WAKE_EN_;
+		temp_pmt_ctl |= PMT_CTL_PHY_WAKE_EN;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 	if (wol & WAKE_MAGIC) {
-		temp_wucsr |= WUCSR_MPEN_;
+		temp_wucsr |= WUCSR_MPEN;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_3_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_3;
 	}
 	if (wol & WAKE_BCAST) {
-		temp_wucsr |= WUCSR_BCST_EN_;
+		temp_wucsr |= WUCSR_BCST_EN;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 	if (wol & WAKE_MCAST) {
-		temp_wucsr |= WUCSR_WAKE_EN_;
+		temp_wucsr |= WUCSR_WAKE_EN;
 
 		/* set WUF_CFG & WUF_MASK for IPv4 Multicast */
 		crc = lan78xx_wakeframe_crc16(ipv4_multicast, 3);
 		ret = lan78xx_write_reg(dev, WUF_CFG(mask_index),
-					WUF_CFGX_EN_ |
-					WUF_CFGX_TYPE_MCAST_ |
-					(0 << WUF_CFGX_OFFSET_SHIFT_) |
-					(crc & WUF_CFGX_CRC16_MASK_));
+					WUF_CFGX_EN |
+					WUF_CFGX_TYPE_MCAST |
+					(0 << WUF_CFGX_OFFSET_SHIFT) |
+					(crc & WUF_CFGX_CRC16_MASK));
 
 		ret = lan78xx_write_reg(dev, WUF_MASK0(mask_index), 7);
 		ret = lan78xx_write_reg(dev, WUF_MASK1(mask_index), 0);
@@ -3535,10 +3535,10 @@ static int lan78xx_set_suspend(struct lan78xx_net *dev, u32 wol)
 		/* for IPv6 Multicast */
 		crc = lan78xx_wakeframe_crc16(ipv6_multicast, 2);
 		ret = lan78xx_write_reg(dev, WUF_CFG(mask_index),
-					WUF_CFGX_EN_ |
-					WUF_CFGX_TYPE_MCAST_ |
-					(0 << WUF_CFGX_OFFSET_SHIFT_) |
-					(crc & WUF_CFGX_CRC16_MASK_));
+					WUF_CFGX_EN |
+					WUF_CFGX_TYPE_MCAST |
+					(0 << WUF_CFGX_OFFSET_SHIFT) |
+					(crc & WUF_CFGX_CRC16_MASK));
 
 		ret = lan78xx_write_reg(dev, WUF_MASK0(mask_index), 3);
 		ret = lan78xx_write_reg(dev, WUF_MASK1(mask_index), 0);
@@ -3546,29 +3546,29 @@ static int lan78xx_set_suspend(struct lan78xx_net *dev, u32 wol)
 		ret = lan78xx_write_reg(dev, WUF_MASK3(mask_index), 0);
 		mask_index++;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 	if (wol & WAKE_UCAST) {
-		temp_wucsr |= WUCSR_PFDA_EN_;
+		temp_wucsr |= WUCSR_PFDA_EN;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 	if (wol & WAKE_ARP) {
-		temp_wucsr |= WUCSR_WAKE_EN_;
+		temp_wucsr |= WUCSR_WAKE_EN;
 
 		/* set WUF_CFG & WUF_MASK
 		 * for packettype (offset 12,13) = ARP (0x0806)
 		 */
 		crc = lan78xx_wakeframe_crc16(arp_type, 2);
 		ret = lan78xx_write_reg(dev, WUF_CFG(mask_index),
-					WUF_CFGX_EN_ |
-					WUF_CFGX_TYPE_ALL_ |
-					(0 << WUF_CFGX_OFFSET_SHIFT_) |
-					(crc & WUF_CFGX_CRC16_MASK_));
+					WUF_CFGX_EN |
+					WUF_CFGX_TYPE_ALL |
+					(0 << WUF_CFGX_OFFSET_SHIFT) |
+					(crc & WUF_CFGX_CRC16_MASK));
 
 		ret = lan78xx_write_reg(dev, WUF_MASK0(mask_index), 0x3000);
 		ret = lan78xx_write_reg(dev, WUF_MASK1(mask_index), 0);
@@ -3576,28 +3576,28 @@ static int lan78xx_set_suspend(struct lan78xx_net *dev, u32 wol)
 		ret = lan78xx_write_reg(dev, WUF_MASK3(mask_index), 0);
 		mask_index++;
 
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 
 	ret = lan78xx_write_reg(dev, WUCSR, temp_wucsr);
 
 	/* when multiple WOL bits are set */
 	if (hweight_long((unsigned long)wol) > 1) {
-		temp_pmt_ctl |= PMT_CTL_WOL_EN_;
-		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK_;
-		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0_;
+		temp_pmt_ctl |= PMT_CTL_WOL_EN;
+		temp_pmt_ctl &= ~PMT_CTL_SUS_MODE_MASK;
+		temp_pmt_ctl |= PMT_CTL_SUS_MODE_0;
 	}
 	ret = lan78xx_write_reg(dev, PMT_CTL, temp_pmt_ctl);
 
 	/* clear WUPS */
 	ret = lan78xx_read_reg(dev, PMT_CTL, &buf);
-	buf |= PMT_CTL_WUPS_MASK_;
+	buf |= PMT_CTL_WUPS_MASK;
 	ret = lan78xx_write_reg(dev, PMT_CTL, buf);
 
 	ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-	buf |= MAC_RX_RXEN_;
+	buf |= MAC_RX_RXEN;
 	ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 	return 0;
@@ -3629,10 +3629,10 @@ int lan78xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* stop TX & RX */
 		ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-		buf &= ~MAC_TX_TXEN_;
+		buf &= ~MAC_TX_TXEN;
 		ret = lan78xx_write_reg(dev, MAC_TX, buf);
 		ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-		buf &= ~MAC_RX_RXEN_;
+		buf &= ~MAC_RX_RXEN;
 		ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 		/* empty out the rx and queues */
@@ -3650,10 +3650,10 @@ int lan78xx_suspend(struct usb_interface *intf, pm_message_t message)
 		if (PMSG_IS_AUTO(message)) {
 			/* auto suspend (selective suspend) */
 			ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-			buf &= ~MAC_TX_TXEN_;
+			buf &= ~MAC_TX_TXEN;
 			ret = lan78xx_write_reg(dev, MAC_TX, buf);
 			ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-			buf &= ~MAC_RX_RXEN_;
+			buf &= ~MAC_RX_RXEN;
 			ret = lan78xx_write_reg(dev, MAC_RX, buf);
 
 			ret = lan78xx_write_reg(dev, WUCSR, 0);
@@ -3663,31 +3663,31 @@ int lan78xx_suspend(struct usb_interface *intf, pm_message_t message)
 			/* set goodframe wakeup */
 			ret = lan78xx_read_reg(dev, WUCSR, &buf);
 
-			buf |= WUCSR_RFE_WAKE_EN_;
-			buf |= WUCSR_STORE_WAKE_;
+			buf |= WUCSR_RFE_WAKE_EN;
+			buf |= WUCSR_STORE_WAKE;
 
 			ret = lan78xx_write_reg(dev, WUCSR, buf);
 
 			ret = lan78xx_read_reg(dev, PMT_CTL, &buf);
 
-			buf &= ~PMT_CTL_RES_CLR_WKP_EN_;
-			buf |= PMT_CTL_RES_CLR_WKP_STS_;
+			buf &= ~PMT_CTL_RES_CLR_WKP_EN;
+			buf |= PMT_CTL_RES_CLR_WKP_STS;
 
-			buf |= PMT_CTL_PHY_WAKE_EN_;
-			buf |= PMT_CTL_WOL_EN_;
-			buf &= ~PMT_CTL_SUS_MODE_MASK_;
-			buf |= PMT_CTL_SUS_MODE_3_;
+			buf |= PMT_CTL_PHY_WAKE_EN;
+			buf |= PMT_CTL_WOL_EN;
+			buf &= ~PMT_CTL_SUS_MODE_MASK;
+			buf |= PMT_CTL_SUS_MODE_3;
 
 			ret = lan78xx_write_reg(dev, PMT_CTL, buf);
 
 			ret = lan78xx_read_reg(dev, PMT_CTL, &buf);
 
-			buf |= PMT_CTL_WUPS_MASK_;
+			buf |= PMT_CTL_WUPS_MASK;
 
 			ret = lan78xx_write_reg(dev, PMT_CTL, buf);
 
 			ret = lan78xx_read_reg(dev, MAC_RX, &buf);
-			buf |= MAC_RX_RXEN_;
+			buf |= MAC_RX_RXEN;
 			ret = lan78xx_write_reg(dev, MAC_RX, buf);
 		} else {
 			lan78xx_set_suspend(dev, pdata->wol);
@@ -3746,21 +3746,21 @@ int lan78xx_resume(struct usb_interface *intf)
 	ret = lan78xx_write_reg(dev, WUCSR, 0);
 	ret = lan78xx_write_reg(dev, WK_SRC, 0xFFF1FF1FUL);
 
-	ret = lan78xx_write_reg(dev, WUCSR2, WUCSR2_NS_RCD_ |
-					     WUCSR2_ARP_RCD_ |
-					     WUCSR2_IPV6_TCPSYN_RCD_ |
-					     WUCSR2_IPV4_TCPSYN_RCD_);
+	ret = lan78xx_write_reg(dev, WUCSR2, WUCSR2_NS_RCD |
+					     WUCSR2_ARP_RCD |
+					     WUCSR2_IPV6_TCPSYN_RCD |
+					     WUCSR2_IPV4_TCPSYN_RCD);
 
-	ret = lan78xx_write_reg(dev, WUCSR, WUCSR_EEE_TX_WAKE_ |
-					    WUCSR_EEE_RX_WAKE_ |
-					    WUCSR_PFDA_FR_ |
-					    WUCSR_RFE_WAKE_FR_ |
-					    WUCSR_WUFR_ |
-					    WUCSR_MPR_ |
-					    WUCSR_BCST_FR_);
+	ret = lan78xx_write_reg(dev, WUCSR, WUCSR_EEE_TX_WAKE |
+					    WUCSR_EEE_RX_WAKE |
+					    WUCSR_PFDA_FR |
+					    WUCSR_RFE_WAKE_FR |
+					    WUCSR_WUFR |
+					    WUCSR_MPR |
+					    WUCSR_BCST_FR);
 
 	ret = lan78xx_read_reg(dev, MAC_TX, &buf);
-	buf |= MAC_TX_TXEN_;
+	buf |= MAC_TX_TXEN;
 	ret = lan78xx_write_reg(dev, MAC_TX, buf);
 
 	return 0;
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index 4092790..7e87564 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -41,637 +41,637 @@
 #define RX_PKT_ALIGNMENT			4
 
 /* Tx Command A */
-#define TX_CMD_A_IGE_			(0x20000000)
-#define TX_CMD_A_ICE_			(0x10000000)
-#define TX_CMD_A_LSO_			(0x08000000)
-#define TX_CMD_A_IPE_			(0x04000000)
-#define TX_CMD_A_TPE_			(0x02000000)
-#define TX_CMD_A_IVTG_			(0x01000000)
-#define TX_CMD_A_RVTG_			(0x00800000)
-#define TX_CMD_A_FCS_			(0x00400000)
-#define TX_CMD_A_LEN_MASK_		(0x000FFFFF)
+#define TX_CMD_A_IGE			(0x20000000)
+#define TX_CMD_A_ICE			(0x10000000)
+#define TX_CMD_A_LSO			(0x08000000)
+#define TX_CMD_A_IPE			(0x04000000)
+#define TX_CMD_A_TPE			(0x02000000)
+#define TX_CMD_A_IVTG			(0x01000000)
+#define TX_CMD_A_RVTG			(0x00800000)
+#define TX_CMD_A_FCS			(0x00400000)
+#define TX_CMD_A_LEN_MASK		(0x000FFFFF)
 
 /* Tx Command B */
-#define TX_CMD_B_MSS_SHIFT_		(16)
-#define TX_CMD_B_MSS_MASK_		(0x3FFF0000)
-#define TX_CMD_B_MSS_MIN_		((unsigned short)8)
-#define TX_CMD_B_VTAG_MASK_		(0x0000FFFF)
-#define TX_CMD_B_VTAG_PRI_MASK_		(0x0000E000)
-#define TX_CMD_B_VTAG_CFI_MASK_		(0x00001000)
-#define TX_CMD_B_VTAG_VID_MASK_		(0x00000FFF)
+#define TX_CMD_B_MSS_SHIFT		(16)
+#define TX_CMD_B_MSS_MASK		(0x3FFF0000)
+#define TX_CMD_B_MSS_MIN		((unsigned short)8)
+#define TX_CMD_B_VTAG_MASK		(0x0000FFFF)
+#define TX_CMD_B_VTAG_PRI_MASK		(0x0000E000)
+#define TX_CMD_B_VTAG_CFI_MASK		(0x00001000)
+#define TX_CMD_B_VTAG_VID_MASK		(0x00000FFF)
 
 /* Rx Command A */
-#define RX_CMD_A_ICE_			(0x80000000)
-#define RX_CMD_A_TCE_			(0x40000000)
-#define RX_CMD_A_CSE_MASK_		(0xC0000000)
-#define RX_CMD_A_IPV_			(0x20000000)
-#define RX_CMD_A_PID_MASK_		(0x18000000)
-#define RX_CMD_A_PID_NONE_IP_		(0x00000000)
-#define RX_CMD_A_PID_TCP_IP_		(0x08000000)
-#define RX_CMD_A_PID_UDP_IP_		(0x10000000)
-#define RX_CMD_A_PID_IP_		(0x18000000)
-#define RX_CMD_A_PFF_			(0x04000000)
-#define RX_CMD_A_BAM_			(0x02000000)
-#define RX_CMD_A_MAM_			(0x01000000)
-#define RX_CMD_A_FVTG_			(0x00800000)
-#define RX_CMD_A_RED_			(0x00400000)
-#define RX_CMD_A_RX_ERRS_MASK_		(0xC03F0000)
-#define RX_CMD_A_RWT_			(0x00200000)
-#define RX_CMD_A_RUNT_			(0x00100000)
-#define RX_CMD_A_LONG_			(0x00080000)
-#define RX_CMD_A_RXE_			(0x00040000)
-#define RX_CMD_A_DRB_			(0x00020000)
-#define RX_CMD_A_FCS_			(0x00010000)
-#define RX_CMD_A_UAM_			(0x00008000)
-#define RX_CMD_A_ICSM_			(0x00004000)
-#define RX_CMD_A_LEN_MASK_		(0x00003FFF)
+#define RX_CMD_A_ICE			(0x80000000)
+#define RX_CMD_A_TCE			(0x40000000)
+#define RX_CMD_A_CSE_MASK		(0xC0000000)
+#define RX_CMD_A_IPV			(0x20000000)
+#define RX_CMD_A_PID_MASK		(0x18000000)
+#define RX_CMD_A_PID_NONE_IP		(0x00000000)
+#define RX_CMD_A_PID_TCP_IP		(0x08000000)
+#define RX_CMD_A_PID_UDP_IP		(0x10000000)
+#define RX_CMD_A_PID_IP			(0x18000000)
+#define RX_CMD_A_PFF			(0x04000000)
+#define RX_CMD_A_BAM			(0x02000000)
+#define RX_CMD_A_MAM			(0x01000000)
+#define RX_CMD_A_FVTG			(0x00800000)
+#define RX_CMD_A_RED			(0x00400000)
+#define RX_CMD_A_RX_ERRS_MASK		(0xC03F0000)
+#define RX_CMD_A_RWT			(0x00200000)
+#define RX_CMD_A_RUNT			(0x00100000)
+#define RX_CMD_A_LONG			(0x00080000)
+#define RX_CMD_A_RXE			(0x00040000)
+#define RX_CMD_A_DRB			(0x00020000)
+#define RX_CMD_A_FCS			(0x00010000)
+#define RX_CMD_A_UAM			(0x00008000)
+#define RX_CMD_A_ICSM			(0x00004000)
+#define RX_CMD_A_LEN_MASK		(0x00003FFF)
 
 /* Rx Command B */
-#define RX_CMD_B_CSUM_SHIFT_		(16)
-#define RX_CMD_B_CSUM_MASK_		(0xFFFF0000)
-#define RX_CMD_B_VTAG_MASK_		(0x0000FFFF)
-#define RX_CMD_B_VTAG_PRI_MASK_		(0x0000E000)
-#define RX_CMD_B_VTAG_CFI_MASK_		(0x00001000)
-#define RX_CMD_B_VTAG_VID_MASK_		(0x00000FFF)
+#define RX_CMD_B_CSUM_SHIFT		(16)
+#define RX_CMD_B_CSUM_MASK		(0xFFFF0000)
+#define RX_CMD_B_VTAG_MASK		(0x0000FFFF)
+#define RX_CMD_B_VTAG_PRI_MASK		(0x0000E000)
+#define RX_CMD_B_VTAG_CFI_MASK		(0x00001000)
+#define RX_CMD_B_VTAG_VID_MASK		(0x00000FFF)
 
 /* Rx Command C */
-#define RX_CMD_C_WAKE_SHIFT_		(15)
-#define RX_CMD_C_WAKE_			(0x8000)
-#define RX_CMD_C_REF_FAIL_SHIFT_	(14)
-#define RX_CMD_C_REF_FAIL_		(0x4000)
+#define RX_CMD_C_WAKE_SHIFT		(15)
+#define RX_CMD_C_WAKE			(0x8000)
+#define RX_CMD_C_REF_FAIL_SHIFT		(14)
+#define RX_CMD_C_REF_FAIL		(0x4000)
 
 /* SCSRs */
 #define NUMBER_OF_REGS			(193)
 
 #define ID_REV				(0x00)
-#define ID_REV_CHIP_ID_MASK_		(0xFFFF0000)
-#define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
-#define ID_REV_CHIP_ID_7800_		(0x7800)
-#define ID_REV_CHIP_ID_7850_		(0x7850)
+#define ID_REV_CHIP_ID_MASK		(0xFFFF0000)
+#define ID_REV_CHIP_REV_MASK		(0x0000FFFF)
+#define ID_REV_CHIP_ID_7800		(0x7800)
+#define ID_REV_CHIP_ID_7850		(0x7850)
 
 #define FPGA_REV			(0x04)
-#define FPGA_REV_MINOR_MASK_		(0x0000FF00)
-#define FPGA_REV_MAJOR_MASK_		(0x000000FF)
+#define FPGA_REV_MINOR_MASK		(0x0000FF00)
+#define FPGA_REV_MAJOR_MASK		(0x000000FF)
 
 #define INT_STS				(0x0C)
-#define INT_STS_CLEAR_ALL_		(0xFFFFFFFF)
-#define INT_STS_EEE_TX_LPI_STRT_	(0x04000000)
-#define INT_STS_EEE_TX_LPI_STOP_	(0x02000000)
-#define INT_STS_EEE_RX_LPI_		(0x01000000)
-#define INT_STS_RDFO_			(0x00400000)
-#define INT_STS_TXE_			(0x00200000)
-#define INT_STS_TX_DIS_			(0x00080000)
-#define INT_STS_RX_DIS_			(0x00040000)
-#define INT_STS_PHY_INT_		(0x00020000)
-#define INT_STS_DP_INT_			(0x00010000)
-#define INT_STS_MAC_ERR_		(0x00008000)
-#define INT_STS_TDFU_			(0x00004000)
-#define INT_STS_TDFO_			(0x00002000)
-#define INT_STS_UFX_FP_			(0x00001000)
-#define INT_STS_GPIO_MASK_		(0x00000FFF)
-#define INT_STS_GPIO11_			(0x00000800)
-#define INT_STS_GPIO10_			(0x00000400)
-#define INT_STS_GPIO9_			(0x00000200)
-#define INT_STS_GPIO8_			(0x00000100)
-#define INT_STS_GPIO7_			(0x00000080)
-#define INT_STS_GPIO6_			(0x00000040)
-#define INT_STS_GPIO5_			(0x00000020)
-#define INT_STS_GPIO4_			(0x00000010)
-#define INT_STS_GPIO3_			(0x00000008)
-#define INT_STS_GPIO2_			(0x00000004)
-#define INT_STS_GPIO1_			(0x00000002)
-#define INT_STS_GPIO0_			(0x00000001)
+#define INT_STS_CLEAR_ALL		(0xFFFFFFFF)
+#define INT_STS_EEE_TX_LPI_STRT		(0x04000000)
+#define INT_STS_EEE_TX_LPI_STOP		(0x02000000)
+#define INT_STS_EEE_RX_LPI		(0x01000000)
+#define INT_STS_RDFO			(0x00400000)
+#define INT_STS_TXE			(0x00200000)
+#define INT_STS_TX_DIS			(0x00080000)
+#define INT_STS_RX_DIS			(0x00040000)
+#define INT_STS_PHY_INT			(0x00020000)
+#define INT_STS_DP_INT			(0x00010000)
+#define INT_STS_MAC_ERR			(0x00008000)
+#define INT_STS_TDFU			(0x00004000)
+#define INT_STS_TDFO			(0x00002000)
+#define INT_STS_UFX_FP			(0x00001000)
+#define INT_STS_GPIO_MASK		(0x00000FFF)
+#define INT_STS_GPIO11			(0x00000800)
+#define INT_STS_GPIO10			(0x00000400)
+#define INT_STS_GPIO9			(0x00000200)
+#define INT_STS_GPIO8			(0x00000100)
+#define INT_STS_GPIO7			(0x00000080)
+#define INT_STS_GPIO6			(0x00000040)
+#define INT_STS_GPIO5			(0x00000020)
+#define INT_STS_GPIO4			(0x00000010)
+#define INT_STS_GPIO3			(0x00000008)
+#define INT_STS_GPIO2			(0x00000004)
+#define INT_STS_GPIO1			(0x00000002)
+#define INT_STS_GPIO0			(0x00000001)
 
 #define HW_CFG				(0x010)
-#define HW_CFG_CLK125_EN_		(0x02000000)
-#define HW_CFG_REFCLK25_EN_		(0x01000000)
-#define HW_CFG_LED3_EN_			(0x00800000)
-#define HW_CFG_LED2_EN_			(0x00400000)
-#define HW_CFG_LED1_EN_			(0x00200000)
-#define HW_CFG_LED0_EN_			(0x00100000)
-#define HW_CFG_EEE_PHY_LUSU_		(0x00020000)
-#define HW_CFG_EEE_TSU_			(0x00010000)
-#define HW_CFG_NETDET_STS_		(0x00008000)
-#define HW_CFG_NETDET_EN_		(0x00004000)
-#define HW_CFG_EEM_			(0x00002000)
-#define HW_CFG_RST_PROTECT_		(0x00001000)
-#define HW_CFG_CONNECT_BUF_		(0x00000400)
-#define HW_CFG_CONNECT_EN_		(0x00000200)
-#define HW_CFG_CONNECT_POL_		(0x00000100)
-#define HW_CFG_SUSPEND_N_SEL_MASK_	(0x000000C0)
+#define HW_CFG_CLK125_EN		(0x02000000)
+#define HW_CFG_REFCLK25_EN		(0x01000000)
+#define HW_CFG_LED3_EN			(0x00800000)
+#define HW_CFG_LED2_EN			(0x00400000)
+#define HW_CFG_LED1_EN			(0x00200000)
+#define HW_CFG_LED0_EN			(0x00100000)
+#define HW_CFG_EEE_PHY_LUSU		(0x00020000)
+#define HW_CFG_EEE_TSU			(0x00010000)
+#define HW_CFG_NETDET_STS		(0x00008000)
+#define HW_CFG_NETDET_EN		(0x00004000)
+#define HW_CFG_EEM			(0x00002000)
+#define HW_CFG_RST_PROTECT		(0x00001000)
+#define HW_CFG_CONNECT_BUF		(0x00000400)
+#define HW_CFG_CONNECT_EN		(0x00000200)
+#define HW_CFG_CONNECT_POL		(0x00000100)
+#define HW_CFG_SUSPEND_N_SEL_MASK	(0x000000C0)
 #define HW_CFG_SUSPEND_N_SEL_2		(0x00000000)
 #define HW_CFG_SUSPEND_N_SEL_12N	(0x00000040)
 #define HW_CFG_SUSPEND_N_SEL_012N	(0x00000080)
 #define HW_CFG_SUSPEND_N_SEL_0123N	(0x000000C0)
-#define HW_CFG_SUSPEND_N_POL_		(0x00000020)
-#define HW_CFG_MEF_			(0x00000010)
-#define HW_CFG_ETC_			(0x00000008)
-#define HW_CFG_LRST_			(0x00000002)
-#define HW_CFG_SRST_			(0x00000001)
+#define HW_CFG_SUSPEND_N_POL		(0x00000020)
+#define HW_CFG_MEF			(0x00000010)
+#define HW_CFG_ETC			(0x00000008)
+#define HW_CFG_LRST			(0x00000002)
+#define HW_CFG_SRST			(0x00000001)
 
 #define PMT_CTL				(0x014)
-#define PMT_CTL_EEE_WAKEUP_EN_		(0x00002000)
-#define PMT_CTL_EEE_WUPS_		(0x00001000)
-#define PMT_CTL_MAC_SRST_		(0x00000800)
-#define PMT_CTL_PHY_PWRUP_		(0x00000400)
-#define PMT_CTL_RES_CLR_WKP_MASK_	(0x00000300)
-#define PMT_CTL_RES_CLR_WKP_STS_	(0x00000200)
-#define PMT_CTL_RES_CLR_WKP_EN_		(0x00000100)
-#define PMT_CTL_READY_			(0x00000080)
-#define PMT_CTL_SUS_MODE_MASK_		(0x00000060)
-#define PMT_CTL_SUS_MODE_0_		(0x00000000)
-#define PMT_CTL_SUS_MODE_1_		(0x00000020)
-#define PMT_CTL_SUS_MODE_2_		(0x00000040)
-#define PMT_CTL_SUS_MODE_3_		(0x00000060)
-#define PMT_CTL_PHY_RST_		(0x00000010)
-#define PMT_CTL_WOL_EN_			(0x00000008)
-#define PMT_CTL_PHY_WAKE_EN_		(0x00000004)
-#define PMT_CTL_WUPS_MASK_		(0x00000003)
-#define PMT_CTL_WUPS_MLT_		(0x00000003)
-#define PMT_CTL_WUPS_MAC_		(0x00000002)
-#define PMT_CTL_WUPS_PHY_		(0x00000001)
+#define PMT_CTL_EEE_WAKEUP_EN		(0x00002000)
+#define PMT_CTL_EEE_WUPS		(0x00001000)
+#define PMT_CTL_MAC_SRST		(0x00000800)
+#define PMT_CTL_PHY_PWRUP		(0x00000400)
+#define PMT_CTL_RES_CLR_WKP_MASK	(0x00000300)
+#define PMT_CTL_RES_CLR_WKP_STS		(0x00000200)
+#define PMT_CTL_RES_CLR_WKP_EN		(0x00000100)
+#define PMT_CTL_READY			(0x00000080)
+#define PMT_CTL_SUS_MODE_MASK		(0x00000060)
+#define PMT_CTL_SUS_MODE_0		(0x00000000)
+#define PMT_CTL_SUS_MODE_1		(0x00000020)
+#define PMT_CTL_SUS_MODE_2		(0x00000040)
+#define PMT_CTL_SUS_MODE_3		(0x00000060)
+#define PMT_CTL_PHY_RST			(0x00000010)
+#define PMT_CTL_WOL_EN			(0x00000008)
+#define PMT_CTL_PHY_WAKE_EN		(0x00000004)
+#define PMT_CTL_WUPS_MASK		(0x00000003)
+#define PMT_CTL_WUPS_MLT		(0x00000003)
+#define PMT_CTL_WUPS_MAC		(0x00000002)
+#define PMT_CTL_WUPS_PHY		(0x00000001)
 
 #define GPIO_CFG0			(0x018)
-#define GPIO_CFG0_GPIOEN_MASK_		(0x0000F000)
-#define GPIO_CFG0_GPIOEN3_		(0x00008000)
-#define GPIO_CFG0_GPIOEN2_		(0x00004000)
-#define GPIO_CFG0_GPIOEN1_		(0x00002000)
-#define GPIO_CFG0_GPIOEN0_		(0x00001000)
-#define GPIO_CFG0_GPIOBUF_MASK_		(0x00000F00)
-#define GPIO_CFG0_GPIOBUF3_		(0x00000800)
-#define GPIO_CFG0_GPIOBUF2_		(0x00000400)
-#define GPIO_CFG0_GPIOBUF1_		(0x00000200)
-#define GPIO_CFG0_GPIOBUF0_		(0x00000100)
-#define GPIO_CFG0_GPIODIR_MASK_		(0x000000F0)
-#define GPIO_CFG0_GPIODIR3_		(0x00000080)
-#define GPIO_CFG0_GPIODIR2_		(0x00000040)
-#define GPIO_CFG0_GPIODIR1_		(0x00000020)
-#define GPIO_CFG0_GPIODIR0_		(0x00000010)
-#define GPIO_CFG0_GPIOD_MASK_		(0x0000000F)
-#define GPIO_CFG0_GPIOD3_		(0x00000008)
-#define GPIO_CFG0_GPIOD2_		(0x00000004)
-#define GPIO_CFG0_GPIOD1_		(0x00000002)
-#define GPIO_CFG0_GPIOD0_		(0x00000001)
+#define GPIO_CFG0_GPIOEN_MASK		(0x0000F000)
+#define GPIO_CFG0_GPIOEN3		(0x00008000)
+#define GPIO_CFG0_GPIOEN2		(0x00004000)
+#define GPIO_CFG0_GPIOEN1		(0x00002000)
+#define GPIO_CFG0_GPIOEN0		(0x00001000)
+#define GPIO_CFG0_GPIOBUF_MASK		(0x00000F00)
+#define GPIO_CFG0_GPIOBUF3		(0x00000800)
+#define GPIO_CFG0_GPIOBUF2		(0x00000400)
+#define GPIO_CFG0_GPIOBUF1		(0x00000200)
+#define GPIO_CFG0_GPIOBUF0		(0x00000100)
+#define GPIO_CFG0_GPIODIR_MASK		(0x000000F0)
+#define GPIO_CFG0_GPIODIR3		(0x00000080)
+#define GPIO_CFG0_GPIODIR2		(0x00000040)
+#define GPIO_CFG0_GPIODIR1		(0x00000020)
+#define GPIO_CFG0_GPIODIR0		(0x00000010)
+#define GPIO_CFG0_GPIOD_MASK		(0x0000000F)
+#define GPIO_CFG0_GPIOD3		(0x00000008)
+#define GPIO_CFG0_GPIOD2		(0x00000004)
+#define GPIO_CFG0_GPIOD1		(0x00000002)
+#define GPIO_CFG0_GPIOD0		(0x00000001)
 
 #define GPIO_CFG1			(0x01C)
-#define GPIO_CFG1_GPIOEN_MASK_		(0xFF000000)
-#define GPIO_CFG1_GPIOEN11_		(0x80000000)
-#define GPIO_CFG1_GPIOEN10_		(0x40000000)
-#define GPIO_CFG1_GPIOEN9_		(0x20000000)
-#define GPIO_CFG1_GPIOEN8_		(0x10000000)
-#define GPIO_CFG1_GPIOEN7_		(0x08000000)
-#define GPIO_CFG1_GPIOEN6_		(0x04000000)
-#define GPIO_CFG1_GPIOEN5_		(0x02000000)
-#define GPIO_CFG1_GPIOEN4_		(0x01000000)
-#define GPIO_CFG1_GPIOBUF_MASK_		(0x00FF0000)
-#define GPIO_CFG1_GPIOBUF11_		(0x00800000)
-#define GPIO_CFG1_GPIOBUF10_		(0x00400000)
-#define GPIO_CFG1_GPIOBUF9_		(0x00200000)
-#define GPIO_CFG1_GPIOBUF8_		(0x00100000)
-#define GPIO_CFG1_GPIOBUF7_		(0x00080000)
-#define GPIO_CFG1_GPIOBUF6_		(0x00040000)
-#define GPIO_CFG1_GPIOBUF5_		(0x00020000)
-#define GPIO_CFG1_GPIOBUF4_		(0x00010000)
-#define GPIO_CFG1_GPIODIR_MASK_		(0x0000FF00)
-#define GPIO_CFG1_GPIODIR11_		(0x00008000)
-#define GPIO_CFG1_GPIODIR10_		(0x00004000)
-#define GPIO_CFG1_GPIODIR9_		(0x00002000)
-#define GPIO_CFG1_GPIODIR8_		(0x00001000)
-#define GPIO_CFG1_GPIODIR7_		(0x00000800)
-#define GPIO_CFG1_GPIODIR6_		(0x00000400)
-#define GPIO_CFG1_GPIODIR5_		(0x00000200)
-#define GPIO_CFG1_GPIODIR4_		(0x00000100)
-#define GPIO_CFG1_GPIOD_MASK_		(0x000000FF)
-#define GPIO_CFG1_GPIOD11_		(0x00000080)
-#define GPIO_CFG1_GPIOD10_		(0x00000040)
-#define GPIO_CFG1_GPIOD9_		(0x00000020)
-#define GPIO_CFG1_GPIOD8_		(0x00000010)
-#define GPIO_CFG1_GPIOD7_		(0x00000008)
-#define GPIO_CFG1_GPIOD6_		(0x00000004)
-#define GPIO_CFG1_GPIOD6_		(0x00000004)
-#define GPIO_CFG1_GPIOD5_		(0x00000002)
-#define GPIO_CFG1_GPIOD4_		(0x00000001)
+#define GPIO_CFG1_GPIOEN_MASK		(0xFF000000)
+#define GPIO_CFG1_GPIOEN11		(0x80000000)
+#define GPIO_CFG1_GPIOEN10		(0x40000000)
+#define GPIO_CFG1_GPIOEN9		(0x20000000)
+#define GPIO_CFG1_GPIOEN8		(0x10000000)
+#define GPIO_CFG1_GPIOEN7		(0x08000000)
+#define GPIO_CFG1_GPIOEN6		(0x04000000)
+#define GPIO_CFG1_GPIOEN5		(0x02000000)
+#define GPIO_CFG1_GPIOEN4		(0x01000000)
+#define GPIO_CFG1_GPIOBUF_MASK		(0x00FF0000)
+#define GPIO_CFG1_GPIOBUF11		(0x00800000)
+#define GPIO_CFG1_GPIOBUF10		(0x00400000)
+#define GPIO_CFG1_GPIOBUF9		(0x00200000)
+#define GPIO_CFG1_GPIOBUF8		(0x00100000)
+#define GPIO_CFG1_GPIOBUF7		(0x00080000)
+#define GPIO_CFG1_GPIOBUF6		(0x00040000)
+#define GPIO_CFG1_GPIOBUF5		(0x00020000)
+#define GPIO_CFG1_GPIOBUF4		(0x00010000)
+#define GPIO_CFG1_GPIODIR_MASK		(0x0000FF00)
+#define GPIO_CFG1_GPIODIR11		(0x00008000)
+#define GPIO_CFG1_GPIODIR10		(0x00004000)
+#define GPIO_CFG1_GPIODIR9		(0x00002000)
+#define GPIO_CFG1_GPIODIR8		(0x00001000)
+#define GPIO_CFG1_GPIODIR7		(0x00000800)
+#define GPIO_CFG1_GPIODIR6		(0x00000400)
+#define GPIO_CFG1_GPIODIR5		(0x00000200)
+#define GPIO_CFG1_GPIODIR4		(0x00000100)
+#define GPIO_CFG1_GPIOD_MASK		(0x000000FF)
+#define GPIO_CFG1_GPIOD11		(0x00000080)
+#define GPIO_CFG1_GPIOD10		(0x00000040)
+#define GPIO_CFG1_GPIOD9		(0x00000020)
+#define GPIO_CFG1_GPIOD8		(0x00000010)
+#define GPIO_CFG1_GPIOD7		(0x00000008)
+#define GPIO_CFG1_GPIOD6		(0x00000004)
+#define GPIO_CFG1_GPIOD6		(0x00000004)
+#define GPIO_CFG1_GPIOD5		(0x00000002)
+#define GPIO_CFG1_GPIOD4		(0x00000001)
 
 #define GPIO_WAKE			(0x020)
-#define GPIO_WAKE_GPIOPOL_MASK_		(0x0FFF0000)
-#define GPIO_WAKE_GPIOPOL11_		(0x08000000)
-#define GPIO_WAKE_GPIOPOL10_		(0x04000000)
-#define GPIO_WAKE_GPIOPOL9_		(0x02000000)
-#define GPIO_WAKE_GPIOPOL8_		(0x01000000)
-#define GPIO_WAKE_GPIOPOL7_		(0x00800000)
-#define GPIO_WAKE_GPIOPOL6_		(0x00400000)
-#define GPIO_WAKE_GPIOPOL5_		(0x00200000)
-#define GPIO_WAKE_GPIOPOL4_		(0x00100000)
-#define GPIO_WAKE_GPIOPOL3_		(0x00080000)
-#define GPIO_WAKE_GPIOPOL2_		(0x00040000)
-#define GPIO_WAKE_GPIOPOL1_		(0x00020000)
-#define GPIO_WAKE_GPIOPOL0_		(0x00010000)
-#define GPIO_WAKE_GPIOWK_MASK_		(0x00000FFF)
-#define GPIO_WAKE_GPIOWK11_		(0x00000800)
-#define GPIO_WAKE_GPIOWK10_		(0x00000400)
-#define GPIO_WAKE_GPIOWK9_		(0x00000200)
-#define GPIO_WAKE_GPIOWK8_		(0x00000100)
-#define GPIO_WAKE_GPIOWK7_		(0x00000080)
-#define GPIO_WAKE_GPIOWK6_		(0x00000040)
-#define GPIO_WAKE_GPIOWK5_		(0x00000020)
-#define GPIO_WAKE_GPIOWK4_		(0x00000010)
-#define GPIO_WAKE_GPIOWK3_		(0x00000008)
-#define GPIO_WAKE_GPIOWK2_		(0x00000004)
-#define GPIO_WAKE_GPIOWK1_		(0x00000002)
-#define GPIO_WAKE_GPIOWK0_		(0x00000001)
+#define GPIO_WAKE_GPIOPOL_MASK		(0x0FFF0000)
+#define GPIO_WAKE_GPIOPOL11		(0x08000000)
+#define GPIO_WAKE_GPIOPOL10		(0x04000000)
+#define GPIO_WAKE_GPIOPOL9		(0x02000000)
+#define GPIO_WAKE_GPIOPOL8		(0x01000000)
+#define GPIO_WAKE_GPIOPOL7		(0x00800000)
+#define GPIO_WAKE_GPIOPOL6		(0x00400000)
+#define GPIO_WAKE_GPIOPOL5		(0x00200000)
+#define GPIO_WAKE_GPIOPOL4		(0x00100000)
+#define GPIO_WAKE_GPIOPOL3		(0x00080000)
+#define GPIO_WAKE_GPIOPOL2		(0x00040000)
+#define GPIO_WAKE_GPIOPOL1		(0x00020000)
+#define GPIO_WAKE_GPIOPOL0		(0x00010000)
+#define GPIO_WAKE_GPIOWK_MASK		(0x00000FFF)
+#define GPIO_WAKE_GPIOWK11		(0x00000800)
+#define GPIO_WAKE_GPIOWK10		(0x00000400)
+#define GPIO_WAKE_GPIOWK9		(0x00000200)
+#define GPIO_WAKE_GPIOWK8		(0x00000100)
+#define GPIO_WAKE_GPIOWK7		(0x00000080)
+#define GPIO_WAKE_GPIOWK6		(0x00000040)
+#define GPIO_WAKE_GPIOWK5		(0x00000020)
+#define GPIO_WAKE_GPIOWK4		(0x00000010)
+#define GPIO_WAKE_GPIOWK3		(0x00000008)
+#define GPIO_WAKE_GPIOWK2		(0x00000004)
+#define GPIO_WAKE_GPIOWK1		(0x00000002)
+#define GPIO_WAKE_GPIOWK0		(0x00000001)
 
 #define DP_SEL				(0x024)
-#define DP_SEL_DPRDY_			(0x80000000)
-#define DP_SEL_RSEL_MASK_		(0x0000000F)
-#define DP_SEL_RSEL_USB_PHY_CSRS_	(0x0000000F)
-#define DP_SEL_RSEL_OTP_64BIT_		(0x00000009)
-#define DP_SEL_RSEL_OTP_8BIT_		(0x00000008)
-#define DP_SEL_RSEL_UTX_BUF_RAM_	(0x00000007)
-#define DP_SEL_RSEL_DESC_RAM_		(0x00000005)
-#define DP_SEL_RSEL_TXFIFO_		(0x00000004)
-#define DP_SEL_RSEL_RXFIFO_		(0x00000003)
-#define DP_SEL_RSEL_LSO_		(0x00000002)
-#define DP_SEL_RSEL_VLAN_DA_		(0x00000001)
-#define DP_SEL_RSEL_URXBUF_		(0x00000000)
+#define DP_SEL_DPRDY			(0x80000000)
+#define DP_SEL_RSEL_MASK		(0x0000000F)
+#define DP_SEL_RSEL_USB_PHY_CSRS	(0x0000000F)
+#define DP_SEL_RSEL_OTP_64BIT		(0x00000009)
+#define DP_SEL_RSEL_OTP_8BIT		(0x00000008)
+#define DP_SEL_RSEL_UTX_BUF_RAM		(0x00000007)
+#define DP_SEL_RSEL_DESC_RAM		(0x00000005)
+#define DP_SEL_RSEL_TXFIFO		(0x00000004)
+#define DP_SEL_RSEL_RXFIFO		(0x00000003)
+#define DP_SEL_RSEL_LSO			(0x00000002)
+#define DP_SEL_RSEL_VLAN_DA		(0x00000001)
+#define DP_SEL_RSEL_URXBUF		(0x00000000)
 #define DP_SEL_VHF_HASH_LEN		(16)
 #define DP_SEL_VHF_VLAN_LEN		(128)
 
 #define DP_CMD				(0x028)
-#define DP_CMD_WRITE_			(0x00000001)
-#define DP_CMD_READ_			(0x00000000)
+#define DP_CMD_WRITE			(0x00000001)
+#define DP_CMD_READ			(0x00000000)
 
 #define DP_ADDR				(0x02C)
-#define DP_ADDR_MASK_			(0x00003FFF)
+#define DP_ADDR_MASK			(0x00003FFF)
 
 #define DP_DATA				(0x030)
 
 #define E2P_CMD				(0x040)
-#define E2P_CMD_EPC_BUSY_		(0x80000000)
-#define E2P_CMD_EPC_CMD_MASK_		(0x70000000)
-#define E2P_CMD_EPC_CMD_RELOAD_		(0x70000000)
-#define E2P_CMD_EPC_CMD_ERAL_		(0x60000000)
-#define E2P_CMD_EPC_CMD_ERASE_		(0x50000000)
-#define E2P_CMD_EPC_CMD_WRAL_		(0x40000000)
-#define E2P_CMD_EPC_CMD_WRITE_		(0x30000000)
-#define E2P_CMD_EPC_CMD_EWEN_		(0x20000000)
-#define E2P_CMD_EPC_CMD_EWDS_		(0x10000000)
-#define E2P_CMD_EPC_CMD_READ_		(0x00000000)
-#define E2P_CMD_EPC_TIMEOUT_		(0x00000400)
-#define E2P_CMD_EPC_DL_			(0x00000200)
-#define E2P_CMD_EPC_ADDR_MASK_		(0x000001FF)
+#define E2P_CMD_EPC_BUSY		(0x80000000)
+#define E2P_CMD_EPC_CMD_MASK		(0x70000000)
+#define E2P_CMD_EPC_CMD_RELOAD		(0x70000000)
+#define E2P_CMD_EPC_CMD_ERAL		(0x60000000)
+#define E2P_CMD_EPC_CMD_ERASE		(0x50000000)
+#define E2P_CMD_EPC_CMD_WRAL		(0x40000000)
+#define E2P_CMD_EPC_CMD_WRITE		(0x30000000)
+#define E2P_CMD_EPC_CMD_EWEN		(0x20000000)
+#define E2P_CMD_EPC_CMD_EWDS		(0x10000000)
+#define E2P_CMD_EPC_CMD_READ		(0x00000000)
+#define E2P_CMD_EPC_TIMEOUT		(0x00000400)
+#define E2P_CMD_EPC_DL			(0x00000200)
+#define E2P_CMD_EPC_ADDR_MASK		(0x000001FF)
 
 #define E2P_DATA			(0x044)
-#define E2P_DATA_EEPROM_DATA_MASK_	(0x000000FF)
+#define E2P_DATA_EEPROM_DATA_MASK	(0x000000FF)
 
 #define BOS_ATTR			(0x050)
-#define BOS_ATTR_BLOCK_SIZE_MASK_	(0x000000FF)
+#define BOS_ATTR_BLOCK_SIZE_MASK	(0x000000FF)
 
 #define SS_ATTR				(0x054)
-#define SS_ATTR_POLL_INT_MASK_		(0x00FF0000)
-#define SS_ATTR_DEV_DESC_SIZE_MASK_	(0x0000FF00)
-#define SS_ATTR_CFG_BLK_SIZE_MASK_	(0x000000FF)
+#define SS_ATTR_POLL_INT_MASK		(0x00FF0000)
+#define SS_ATTR_DEV_DESC_SIZE_MASK	(0x0000FF00)
+#define SS_ATTR_CFG_BLK_SIZE_MASK	(0x000000FF)
 
 #define HS_ATTR				(0x058)
-#define HS_ATTR_POLL_INT_MASK_		(0x00FF0000)
-#define HS_ATTR_DEV_DESC_SIZE_MASK_	(0x0000FF00)
-#define HS_ATTR_CFG_BLK_SIZE_MASK_	(0x000000FF)
+#define HS_ATTR_POLL_INT_MASK		(0x00FF0000)
+#define HS_ATTR_DEV_DESC_SIZE_MASK	(0x0000FF00)
+#define HS_ATTR_CFG_BLK_SIZE_MASK	(0x000000FF)
 
 #define FS_ATTR				(0x05C)
-#define FS_ATTR_POLL_INT_MASK_		(0x00FF0000)
-#define FS_ATTR_DEV_DESC_SIZE_MASK_	(0x0000FF00)
-#define FS_ATTR_CFG_BLK_SIZE_MASK_	(0x000000FF)
+#define FS_ATTR_POLL_INT_MASK		(0x00FF0000)
+#define FS_ATTR_DEV_DESC_SIZE_MASK	(0x0000FF00)
+#define FS_ATTR_CFG_BLK_SIZE_MASK	(0x000000FF)
 
-#define STR_ATTR0			    (0x060)
-#define STR_ATTR0_CFGSTR_DESC_SIZE_MASK_    (0xFF000000)
-#define STR_ATTR0_SERSTR_DESC_SIZE_MASK_    (0x00FF0000)
-#define STR_ATTR0_PRODSTR_DESC_SIZE_MASK_   (0x0000FF00)
-#define STR_ATTR0_MANUF_DESC_SIZE_MASK_     (0x000000FF)
+#define STR_ATTR0			(0x060)
+#define STR_ATTR0_CFGSTR_DESC_SIZE_MASK	(0xFF000000)
+#define STR_ATTR0_SERSTR_DESC_SIZE_MASK	(0x00FF0000)
+#define STR_ATTR0_PRODSTR_DESC_SIZE_MASK (0x0000FF00)
+#define STR_ATTR0_MANUF_DESC_SIZE_MASK	(0x000000FF)
 
-#define STR_ATTR1			    (0x064)
-#define STR_ATTR1_INTSTR_DESC_SIZE_MASK_    (0x000000FF)
+#define STR_ATTR1			(0x064)
+#define STR_ATTR1_INTSTR_DESC_SIZE_MASK	(0x000000FF)
 
-#define STR_FLAG_ATTR			    (0x068)
-#define STR_FLAG_ATTR_PME_FLAGS_MASK_	    (0x000000FF)
+#define STR_FLAG_ATTR			(0x068)
+#define STR_FLAG_ATTR_PME_FLAGS_MASK	(0x000000FF)
 
 #define USB_CFG0			(0x080)
-#define USB_CFG_LPM_RESPONSE_		(0x80000000)
-#define USB_CFG_LPM_CAPABILITY_		(0x40000000)
-#define USB_CFG_LPM_ENBL_SLPM_		(0x20000000)
-#define USB_CFG_HIRD_THR_MASK_		(0x1F000000)
-#define USB_CFG_HIRD_THR_960_		(0x1C000000)
-#define USB_CFG_HIRD_THR_885_		(0x1B000000)
-#define USB_CFG_HIRD_THR_810_		(0x1A000000)
-#define USB_CFG_HIRD_THR_735_		(0x19000000)
-#define USB_CFG_HIRD_THR_660_		(0x18000000)
-#define USB_CFG_HIRD_THR_585_		(0x17000000)
-#define USB_CFG_HIRD_THR_510_		(0x16000000)
-#define USB_CFG_HIRD_THR_435_		(0x15000000)
-#define USB_CFG_HIRD_THR_360_		(0x14000000)
-#define USB_CFG_HIRD_THR_285_		(0x13000000)
-#define USB_CFG_HIRD_THR_210_		(0x12000000)
-#define USB_CFG_HIRD_THR_135_		(0x11000000)
-#define USB_CFG_HIRD_THR_60_		(0x10000000)
-#define USB_CFG_MAX_BURST_BI_MASK_	(0x00F00000)
-#define USB_CFG_MAX_BURST_BO_MASK_	(0x000F0000)
-#define USB_CFG_MAX_DEV_SPEED_MASK_	(0x0000E000)
-#define USB_CFG_MAX_DEV_SPEED_SS_	(0x00008000)
-#define USB_CFG_MAX_DEV_SPEED_HS_	(0x00000000)
-#define USB_CFG_MAX_DEV_SPEED_FS_	(0x00002000)
-#define USB_CFG_PHY_BOOST_MASK_		(0x00000180)
-#define USB_CFG_PHY_BOOST_PLUS_12_	(0x00000180)
-#define USB_CFG_PHY_BOOST_PLUS_8_	(0x00000100)
-#define USB_CFG_PHY_BOOST_PLUS_4_	(0x00000080)
-#define USB_CFG_PHY_BOOST_NORMAL_	(0x00000000)
-#define USB_CFG_BIR_			(0x00000040)
-#define USB_CFG_BCE_			(0x00000020)
-#define USB_CFG_PORT_SWAP_		(0x00000010)
-#define USB_CFG_LPM_EN_			(0x00000008)
-#define USB_CFG_RMT_WKP_		(0x00000004)
-#define USB_CFG_PWR_SEL_		(0x00000002)
-#define USB_CFG_STALL_BO_DIS_		(0x00000001)
+#define USB_CFG_LPM_RESPONSE		(0x80000000)
+#define USB_CFG_LPM_CAPABILITY		(0x40000000)
+#define USB_CFG_LPM_ENBL_SLPM		(0x20000000)
+#define USB_CFG_HIRD_THR_MASK		(0x1F000000)
+#define USB_CFG_HIRD_THR_960		(0x1C000000)
+#define USB_CFG_HIRD_THR_885		(0x1B000000)
+#define USB_CFG_HIRD_THR_810		(0x1A000000)
+#define USB_CFG_HIRD_THR_735		(0x19000000)
+#define USB_CFG_HIRD_THR_660		(0x18000000)
+#define USB_CFG_HIRD_THR_585		(0x17000000)
+#define USB_CFG_HIRD_THR_510		(0x16000000)
+#define USB_CFG_HIRD_THR_435		(0x15000000)
+#define USB_CFG_HIRD_THR_360		(0x14000000)
+#define USB_CFG_HIRD_THR_285		(0x13000000)
+#define USB_CFG_HIRD_THR_210		(0x12000000)
+#define USB_CFG_HIRD_THR_135		(0x11000000)
+#define USB_CFG_HIRD_THR_60		(0x10000000)
+#define USB_CFG_MAX_BURST_BI_MASK	(0x00F00000)
+#define USB_CFG_MAX_BURST_BO_MASK	(0x000F0000)
+#define USB_CFG_MAX_DEV_SPEED_MASK	(0x0000E000)
+#define USB_CFG_MAX_DEV_SPEED_SS	(0x00008000)
+#define USB_CFG_MAX_DEV_SPEED_HS	(0x00000000)
+#define USB_CFG_MAX_DEV_SPEED_FS	(0x00002000)
+#define USB_CFG_PHY_BOOST_MASK		(0x00000180)
+#define USB_CFG_PHY_BOOST_PLUS_12	(0x00000180)
+#define USB_CFG_PHY_BOOST_PLUS_8	(0x00000100)
+#define USB_CFG_PHY_BOOST_PLUS_4	(0x00000080)
+#define USB_CFG_PHY_BOOST_NORMAL	(0x00000000)
+#define USB_CFG_BIR			(0x00000040)
+#define USB_CFG_BCE			(0x00000020)
+#define USB_CFG_PORT_SWAP		(0x00000010)
+#define USB_CFG_LPM_EN			(0x00000008)
+#define USB_CFG_RMT_WKP			(0x00000004)
+#define USB_CFG_PWR_SEL			(0x00000002)
+#define USB_CFG_STALL_BO_DIS		(0x00000001)
 
 #define USB_CFG1			(0x084)
-#define USB_CFG1_U1_TIMEOUT_MASK_	(0xFF000000)
-#define USB_CFG1_U2_TIMEOUT_MASK_	(0x00FF0000)
-#define USB_CFG1_HS_TOUT_CAL_MASK_	(0x0000E000)
-#define USB_CFG1_DEV_U2_INIT_EN_	(0x00001000)
-#define USB_CFG1_DEV_U2_EN_		(0x00000800)
-#define USB_CFG1_DEV_U1_INIT_EN_	(0x00000400)
-#define USB_CFG1_DEV_U1_EN_		(0x00000200)
-#define USB_CFG1_LTM_ENABLE_		(0x00000100)
-#define USB_CFG1_FS_TOUT_CAL_MASK_	(0x00000070)
-#define USB_CFG1_SCALE_DOWN_MASK_	(0x00000003)
-#define USB_CFG1_SCALE_DOWN_MODE3_	(0x00000003)
-#define USB_CFG1_SCALE_DOWN_MODE2_	(0x00000002)
-#define USB_CFG1_SCALE_DOWN_MODE1_	(0x00000001)
-#define USB_CFG1_SCALE_DOWN_MODE0_	(0x00000000)
-
-#define USB_CFG2			    (0x088)
-#define USB_CFG2_SS_DETACH_TIME_MASK_	    (0xFFFF0000)
-#define USB_CFG2_HS_DETACH_TIME_MASK_	    (0x0000FFFF)
+#define USB_CFG1_U1_TIMEOUT_MASK	(0xFF000000)
+#define USB_CFG1_U2_TIMEOUT_MASK	(0x00FF0000)
+#define USB_CFG1_HS_TOUT_CAL_MASK	(0x0000E000)
+#define USB_CFG1_DEV_U2_INIT_EN		(0x00001000)
+#define USB_CFG1_DEV_U2_EN		(0x00000800)
+#define USB_CFG1_DEV_U1_INIT_EN		(0x00000400)
+#define USB_CFG1_DEV_U1_EN		(0x00000200)
+#define USB_CFG1_LTM_ENABLE		(0x00000100)
+#define USB_CFG1_FS_TOUT_CAL_MASK	(0x00000070)
+#define USB_CFG1_SCALE_DOWN_MASK	(0x00000003)
+#define USB_CFG1_SCALE_DOWN_MODE3	(0x00000003)
+#define USB_CFG1_SCALE_DOWN_MODE2	(0x00000002)
+#define USB_CFG1_SCALE_DOWN_MODE1	(0x00000001)
+#define USB_CFG1_SCALE_DOWN_MODE0	(0x00000000)
+
+#define USB_CFG2			(0x088)
+#define USB_CFG2_SS_DETACH_TIME_MASK	(0xFFFF0000)
+#define USB_CFG2_HS_DETACH_TIME_MASK	(0x0000FFFF)
 
 #define BURST_CAP			(0x090)
-#define BURST_CAP_SIZE_MASK_		(0x000000FF)
+#define BURST_CAP_SIZE_MASK		(0x000000FF)
 
 #define BULK_IN_DLY			(0x094)
-#define BULK_IN_DLY_MASK_		(0x0000FFFF)
+#define BULK_IN_DLY_MASK		(0x0000FFFF)
 
 #define INT_EP_CTL			(0x098)
-#define INT_EP_INTEP_ON_		(0x80000000)
-#define INT_STS_EEE_TX_LPI_STRT_EN_	(0x04000000)
-#define INT_STS_EEE_TX_LPI_STOP_EN_	(0x02000000)
-#define INT_STS_EEE_RX_LPI_EN_		(0x01000000)
-#define INT_EP_RDFO_EN_			(0x00400000)
-#define INT_EP_TXE_EN_			(0x00200000)
-#define INT_EP_TX_DIS_EN_		(0x00080000)
-#define INT_EP_RX_DIS_EN_		(0x00040000)
-#define INT_EP_PHY_INT_EN_		(0x00020000)
-#define INT_EP_DP_INT_EN_		(0x00010000)
-#define INT_EP_MAC_ERR_EN_		(0x00008000)
-#define INT_EP_TDFU_EN_			(0x00004000)
-#define INT_EP_TDFO_EN_			(0x00002000)
-#define INT_EP_UTX_FP_EN_		(0x00001000)
-#define INT_EP_GPIO_EN_MASK_		(0x00000FFF)
+#define INT_EP_INTEP_ON			(0x80000000)
+#define INT_STS_EEE_TX_LPI_STRT_EN	(0x04000000)
+#define INT_STS_EEE_TX_LPI_STOP_EN	(0x02000000)
+#define INT_STS_EEE_RX_LPI_EN		(0x01000000)
+#define INT_EP_RDFO_EN			(0x00400000)
+#define INT_EP_TXE_EN			(0x00200000)
+#define INT_EP_TX_DIS_EN		(0x00080000)
+#define INT_EP_RX_DIS_EN		(0x00040000)
+#define INT_EP_PHY_INT_EN		(0x00020000)
+#define INT_EP_DP_INT_EN		(0x00010000)
+#define INT_EP_MAC_ERR_EN		(0x00008000)
+#define INT_EP_TDFU_EN			(0x00004000)
+#define INT_EP_TDFO_EN			(0x00002000)
+#define INT_EP_UTX_FP_EN		(0x00001000)
+#define INT_EP_GPIO_EN_MASK		(0x00000FFF)
 
 #define PIPE_CTL			(0x09C)
-#define PIPE_CTL_TXSWING_		(0x00000040)
-#define PIPE_CTL_TXMARGIN_MASK_		(0x00000038)
-#define PIPE_CTL_TXDEEMPHASIS_MASK_	(0x00000006)
-#define PIPE_CTL_ELASTICITYBUFFERMODE_	(0x00000001)
+#define PIPE_CTL_TXSWING		(0x00000040)
+#define PIPE_CTL_TXMARGIN_MASK		(0x00000038)
+#define PIPE_CTL_TXDEEMPHASIS_MASK	(0x00000006)
+#define PIPE_CTL_ELASTICITYBUFFERMODE	(0x00000001)
 
 #define U1_LATENCY			(0xA0)
 #define U2_LATENCY			(0xA4)
 
 #define USB_STATUS			(0x0A8)
-#define USB_STATUS_REMOTE_WK_		(0x00100000)
-#define USB_STATUS_FUNC_REMOTE_WK_	(0x00080000)
-#define USB_STATUS_LTM_ENABLE_		(0x00040000)
-#define USB_STATUS_U2_ENABLE_		(0x00020000)
-#define USB_STATUS_U1_ENABLE_		(0x00010000)
-#define USB_STATUS_SET_SEL_		(0x00000020)
-#define USB_STATUS_REMOTE_WK_STS_	(0x00000010)
-#define USB_STATUS_FUNC_REMOTE_WK_STS_	(0x00000008)
-#define USB_STATUS_LTM_ENABLE_STS_	(0x00000004)
-#define USB_STATUS_U2_ENABLE_STS_	(0x00000002)
-#define USB_STATUS_U1_ENABLE_STS_	(0x00000001)
+#define USB_STATUS_REMOTE_WK		(0x00100000)
+#define USB_STATUS_FUNC_REMOTE_WK	(0x00080000)
+#define USB_STATUS_LTM_ENABLE		(0x00040000)
+#define USB_STATUS_U2_ENABLE		(0x00020000)
+#define USB_STATUS_U1_ENABLE		(0x00010000)
+#define USB_STATUS_SET_SEL		(0x00000020)
+#define USB_STATUS_REMOTE_WK_STS	(0x00000010)
+#define USB_STATUS_FUNC_REMOTE_WK_STS	(0x00000008)
+#define USB_STATUS_LTM_ENABLE_STS	(0x00000004)
+#define USB_STATUS_U2_ENABLE_STS	(0x00000002)
+#define USB_STATUS_U1_ENABLE_STS	(0x00000001)
 
 #define USB_CFG3			(0x0AC)
-#define USB_CFG3_EN_U2_LTM_		(0x40000000)
-#define USB_CFG3_BULK_OUT_NUMP_OVR_	(0x20000000)
-#define USB_CFG3_DIS_FAST_U1_EXIT_	(0x10000000)
-#define USB_CFG3_LPM_NYET_THR_		(0x0F000000)
-#define USB_CFG3_RX_DET_2_POL_LFPS_	(0x00800000)
-#define USB_CFG3_LFPS_FILT_		(0x00400000)
-#define USB_CFG3_SKIP_RX_DET_		(0x00200000)
-#define USB_CFG3_DELAY_P1P2P3_		(0x001C0000)
-#define USB_CFG3_DELAY_PHY_PWR_CHG_	(0x00020000)
-#define USB_CFG3_U1U2_EXIT_FR_		(0x00010000)
+#define USB_CFG3_EN_U2_LTM		(0x40000000)
+#define USB_CFG3_BULK_OUT_NUMP_OVR	(0x20000000)
+#define USB_CFG3_DIS_FAST_U1_EXIT	(0x10000000)
+#define USB_CFG3_LPM_NYET_THR		(0x0F000000)
+#define USB_CFG3_RX_DET_2_POL_LFPS	(0x00800000)
+#define USB_CFG3_LFPS_FILT		(0x00400000)
+#define USB_CFG3_SKIP_RX_DET		(0x00200000)
+#define USB_CFG3_DELAY_P1P2P3		(0x001C0000)
+#define USB_CFG3_DELAY_PHY_PWR_CHG	(0x00020000)
+#define USB_CFG3_U1U2_EXIT_FR		(0x00010000)
 #define USB_CFG3_REQ_P1P2P3		(0x00008000)
-#define USB_CFG3_HST_PRT_CMPL_		(0x00004000)
-#define USB_CFG3_DIS_SCRAMB_		(0x00002000)
-#define USB_CFG3_PWR_DN_SCALE_		(0x00001FFF)
+#define USB_CFG3_HST_PRT_CMPL		(0x00004000)
+#define USB_CFG3_DIS_SCRAMB		(0x00002000)
+#define USB_CFG3_PWR_DN_SCALE		(0x00001FFF)
 
 #define RFE_CTL				(0x0B0)
-#define RFE_CTL_IGMP_COE_		(0x00004000)
-#define RFE_CTL_ICMP_COE_		(0x00002000)
-#define RFE_CTL_TCPUDP_COE_		(0x00001000)
-#define RFE_CTL_IP_COE_			(0x00000800)
-#define RFE_CTL_BCAST_EN_		(0x00000400)
-#define RFE_CTL_MCAST_EN_		(0x00000200)
-#define RFE_CTL_UCAST_EN_		(0x00000100)
-#define RFE_CTL_VLAN_STRIP_		(0x00000080)
-#define RFE_CTL_DISCARD_UNTAGGED_	(0x00000040)
-#define RFE_CTL_VLAN_FILTER_		(0x00000020)
-#define RFE_CTL_SA_FILTER_		(0x00000010)
-#define RFE_CTL_MCAST_HASH_		(0x00000008)
-#define RFE_CTL_DA_HASH_		(0x00000004)
-#define RFE_CTL_DA_PERFECT_		(0x00000002)
-#define RFE_CTL_RST_			(0x00000001)
+#define RFE_CTL_IGMP_COE		(0x00004000)
+#define RFE_CTL_ICMP_COE		(0x00002000)
+#define RFE_CTL_TCPUDP_COE		(0x00001000)
+#define RFE_CTL_IP_COE			(0x00000800)
+#define RFE_CTL_BCAST_EN		(0x00000400)
+#define RFE_CTL_MCAST_EN		(0x00000200)
+#define RFE_CTL_UCAST_EN		(0x00000100)
+#define RFE_CTL_VLAN_STRIP		(0x00000080)
+#define RFE_CTL_DISCARD_UNTAGGED	(0x00000040)
+#define RFE_CTL_VLAN_FILTER		(0x00000020)
+#define RFE_CTL_SA_FILTER		(0x00000010)
+#define RFE_CTL_MCAST_HASH		(0x00000008)
+#define RFE_CTL_DA_HASH			(0x00000004)
+#define RFE_CTL_DA_PERFECT		(0x00000002)
+#define RFE_CTL_RST			(0x00000001)
 
 #define VLAN_TYPE			(0x0B4)
-#define VLAN_TYPE_MASK_			(0x0000FFFF)
+#define VLAN_TYPE_MASK			(0x0000FFFF)
 
 #define FCT_RX_CTL			(0x0C0)
-#define FCT_RX_CTL_EN_			(0x80000000)
-#define FCT_RX_CTL_RST_			(0x40000000)
-#define FCT_RX_CTL_SBF_			(0x02000000)
-#define FCT_RX_CTL_OVFL_		(0x01000000)
-#define FCT_RX_CTL_DROP_		(0x00800000)
-#define FCT_RX_CTL_NOT_EMPTY_		(0x00400000)
-#define FCT_RX_CTL_EMPTY_		(0x00200000)
-#define FCT_RX_CTL_DIS_			(0x00100000)
-#define FCT_RX_CTL_USED_MASK_		(0x0000FFFF)
+#define FCT_RX_CTL_EN			(0x80000000)
+#define FCT_RX_CTL_RST			(0x40000000)
+#define FCT_RX_CTL_SBF			(0x02000000)
+#define FCT_RX_CTL_OVFL			(0x01000000)
+#define FCT_RX_CTL_DROP			(0x00800000)
+#define FCT_RX_CTL_NOT_EMPTY		(0x00400000)
+#define FCT_RX_CTL_EMPTY		(0x00200000)
+#define FCT_RX_CTL_DIS			(0x00100000)
+#define FCT_RX_CTL_USED_MASK		(0x0000FFFF)
 
 #define FCT_TX_CTL			(0x0C4)
-#define FCT_TX_CTL_EN_			(0x80000000)
-#define FCT_TX_CTL_RST_			(0x40000000)
-#define FCT_TX_CTL_NOT_EMPTY_		(0x00400000)
-#define FCT_TX_CTL_EMPTY_		(0x00200000)
-#define FCT_TX_CTL_DIS_			(0x00100000)
-#define FCT_TX_CTL_USED_MASK_		(0x0000FFFF)
+#define FCT_TX_CTL_EN			(0x80000000)
+#define FCT_TX_CTL_RST			(0x40000000)
+#define FCT_TX_CTL_NOT_EMPTY		(0x00400000)
+#define FCT_TX_CTL_EMPTY		(0x00200000)
+#define FCT_TX_CTL_DIS			(0x00100000)
+#define FCT_TX_CTL_USED_MASK		(0x0000FFFF)
 
 #define FCT_RX_FIFO_END			(0x0C8)
-#define FCT_RX_FIFO_END_MASK_		(0x0000007F)
+#define FCT_RX_FIFO_END_MASK		(0x0000007F)
 
 #define FCT_TX_FIFO_END			(0x0CC)
-#define FCT_TX_FIFO_END_MASK_		(0x0000003F)
+#define FCT_TX_FIFO_END_MASK		(0x0000003F)
 
 #define FCT_FLOW			(0x0D0)
-#define FCT_FLOW_OFF_MASK_		(0x00007F00)
-#define FCT_FLOW_ON_MASK_		(0x0000007F)
+#define FCT_FLOW_OFF_MASK		(0x00007F00)
+#define FCT_FLOW_ON_MASK		(0x0000007F)
 
 #define RX_DP_STOR			(0x0D4)
-#define RX_DP_STORE_TOT_RXUSED_MASK_	(0xFFFF0000)
-#define RX_DP_STORE_UTX_RXUSED_MASK_	(0x0000FFFF)
+#define RX_DP_STORE_TOT_RXUSED_MASK	(0xFFFF0000)
+#define RX_DP_STORE_UTX_RXUSED_MASK	(0x0000FFFF)
 
 #define TX_DP_STOR			(0x0D8)
-#define TX_DP_STORE_TOT_TXUSED_MASK_	(0xFFFF0000)
-#define TX_DP_STORE_URX_TXUSED_MASK_	(0x0000FFFF)
+#define TX_DP_STORE_TOT_TXUSED_MASK	(0xFFFF0000)
+#define TX_DP_STORE_URX_TXUSED_MASK	(0x0000FFFF)
 
 #define LTM_BELT_IDLE0			(0x0E0)
-#define LTM_BELT_IDLE0_IDLE1000_	(0x0FFF0000)
-#define LTM_BELT_IDLE0_IDLE100_		(0x00000FFF)
+#define LTM_BELT_IDLE0_IDLE1000		(0x0FFF0000)
+#define LTM_BELT_IDLE0_IDLE100		(0x00000FFF)
 
 #define LTM_BELT_IDLE1			(0x0E4)
-#define LTM_BELT_IDLE1_IDLE10_		(0x00000FFF)
+#define LTM_BELT_IDLE1_IDLE10		(0x00000FFF)
 
 #define LTM_BELT_ACT0			(0x0E8)
-#define LTM_BELT_ACT0_ACT1000_		(0x0FFF0000)
-#define LTM_BELT_ACT0_ACT100_		(0x00000FFF)
+#define LTM_BELT_ACT0_ACT1000		(0x0FFF0000)
+#define LTM_BELT_ACT0_ACT100		(0x00000FFF)
 
 #define LTM_BELT_ACT1			(0x0EC)
-#define LTM_BELT_ACT1_ACT10_		(0x00000FFF)
+#define LTM_BELT_ACT1_ACT10		(0x00000FFF)
 
 #define LTM_INACTIVE0			(0x0F0)
-#define LTM_INACTIVE0_TIMER1000_	(0xFFFF0000)
-#define LTM_INACTIVE0_TIMER100_		(0x0000FFFF)
+#define LTM_INACTIVE0_TIMER1000		(0xFFFF0000)
+#define LTM_INACTIVE0_TIMER100		(0x0000FFFF)
 
 #define LTM_INACTIVE1			(0x0F4)
-#define LTM_INACTIVE1_TIMER10_		(0x0000FFFF)
+#define LTM_INACTIVE1_TIMER10		(0x0000FFFF)
 
 #define MAC_CR				(0x100)
-#define MAC_CR_EEE_TX_CLK_STOP_EN_	(0x00040000)
-#define MAC_CR_EEE_EN_			(0x00020000)
-#define MAC_CR_EEE_TLAR_EN_		(0x00010000)
-#define MAC_CR_ADP_			(0x00002000)
-#define MAC_CR_AUTO_DUPLEX_		(0x00001000)
-#define MAC_CR_AUTO_SPEED_		(0x00000800)
-#define MAC_CR_LOOPBACK_		(0x00000400)
-#define MAC_CR_BOLMT_MASK_		(0x000000C0)
-#define MAC_CR_FULL_DUPLEX_		(0x00000008)
-#define MAC_CR_SPEED_MASK_		(0x00000006)
-#define MAC_CR_SPEED_1000_		(0x00000004)
-#define MAC_CR_SPEED_100_		(0x00000002)
-#define MAC_CR_SPEED_10_		(0x00000000)
-#define MAC_CR_RST_			(0x00000001)
+#define MAC_CR_EEE_TX_CLK_STOP_EN	(0x00040000)
+#define MAC_CR_EEE_EN			(0x00020000)
+#define MAC_CR_EEE_TLAR_EN		(0x00010000)
+#define MAC_CR_ADP			(0x00002000)
+#define MAC_CR_AUTO_DUPLEX		(0x00001000)
+#define MAC_CR_AUTO_SPEED		(0x00000800)
+#define MAC_CR_LOOPBACK			(0x00000400)
+#define MAC_CR_BOLMT_MASK		(0x000000C0)
+#define MAC_CR_FULL_DUPLEX		(0x00000008)
+#define MAC_CR_SPEED_MASK		(0x00000006)
+#define MAC_CR_SPEED_1000		(0x00000004)
+#define MAC_CR_SPEED_100		(0x00000002)
+#define MAC_CR_SPEED_10			(0x00000000)
+#define MAC_CR_RST			(0x00000001)
 
 #define MAC_RX				(0x104)
-#define MAC_RX_MAX_SIZE_SHIFT_		(16)
-#define MAC_RX_MAX_SIZE_MASK_		(0x3FFF0000)
-#define MAC_RX_FCS_STRIP_		(0x00000010)
-#define MAC_RX_VLAN_FSE_		(0x00000004)
-#define MAC_RX_RXD_			(0x00000002)
-#define MAC_RX_RXEN_			(0x00000001)
+#define MAC_RX_MAX_SIZE_SHIFT		(16)
+#define MAC_RX_MAX_SIZE_MASK		(0x3FFF0000)
+#define MAC_RX_FCS_STRIP		(0x00000010)
+#define MAC_RX_VLAN_FSE			(0x00000004)
+#define MAC_RX_RXD			(0x00000002)
+#define MAC_RX_RXEN			(0x00000001)
 
 #define MAC_TX				(0x108)
-#define MAC_TX_BAD_FCS_			(0x00000004)
-#define MAC_TX_TXD_			(0x00000002)
-#define MAC_TX_TXEN_			(0x00000001)
+#define MAC_TX_BAD_FCS			(0x00000004)
+#define MAC_TX_TXD			(0x00000002)
+#define MAC_TX_TXEN			(0x00000001)
 
 #define FLOW				(0x10C)
-#define FLOW_CR_FORCE_FC_		(0x80000000)
-#define FLOW_CR_TX_FCEN_		(0x40000000)
-#define FLOW_CR_RX_FCEN_		(0x20000000)
-#define FLOW_CR_FPF_			(0x10000000)
-#define FLOW_CR_FCPT_MASK_		(0x0000FFFF)
+#define FLOW_CR_FORCE_FC		(0x80000000)
+#define FLOW_CR_TX_FCEN			(0x40000000)
+#define FLOW_CR_RX_FCEN			(0x20000000)
+#define FLOW_CR_FPF			(0x10000000)
+#define FLOW_CR_FCPT_MASK		(0x0000FFFF)
 
 #define RAND_SEED			(0x110)
-#define RAND_SEED_MASK_			(0x0000FFFF)
+#define RAND_SEED_MASK			(0x0000FFFF)
 
 #define ERR_STS				(0x114)
-#define ERR_STS_FERR_			(0x00000100)
-#define ERR_STS_LERR_			(0x00000080)
-#define ERR_STS_RFERR_			(0x00000040)
-#define ERR_STS_ECERR_			(0x00000010)
-#define ERR_STS_ALERR_			(0x00000008)
-#define ERR_STS_URERR_			(0x00000004)
+#define ERR_STS_FERR			(0x00000100)
+#define ERR_STS_LERR			(0x00000080)
+#define ERR_STS_RFERR			(0x00000040)
+#define ERR_STS_ECERR			(0x00000010)
+#define ERR_STS_ALERR			(0x00000008)
+#define ERR_STS_URERR			(0x00000004)
 
 #define RX_ADDRH			(0x118)
-#define RX_ADDRH_MASK_			(0x0000FFFF)
+#define RX_ADDRH_MASK			(0x0000FFFF)
 
 #define RX_ADDRL			(0x11C)
-#define RX_ADDRL_MASK_			(0xFFFFFFFF)
+#define RX_ADDRL_MASK			(0xFFFFFFFF)
 
 #define MII_ACC				(0x120)
-#define MII_ACC_PHY_ADDR_SHIFT_		(11)
-#define MII_ACC_PHY_ADDR_MASK_		(0x0000F800)
-#define MII_ACC_MIIRINDA_SHIFT_		(6)
-#define MII_ACC_MIIRINDA_MASK_		(0x000007C0)
-#define MII_ACC_MII_READ_		(0x00000000)
-#define MII_ACC_MII_WRITE_		(0x00000002)
-#define MII_ACC_MII_BUSY_		(0x00000001)
+#define MII_ACC_PHY_ADDR_SHIFT		(11)
+#define MII_ACC_PHY_ADDR_MASK		(0x0000F800)
+#define MII_ACC_MIIRINDA_SHIFT		(6)
+#define MII_ACC_MIIRINDA_MASK		(0x000007C0)
+#define MII_ACC_MII_READ		(0x00000000)
+#define MII_ACC_MII_WRITE		(0x00000002)
+#define MII_ACC_MII_BUSY		(0x00000001)
 
 #define MII_DATA			(0x124)
-#define MII_DATA_MASK_			(0x0000FFFF)
+#define MII_DATA_MASK			(0x0000FFFF)
 
 #define MAC_RGMII_ID			(0x128)
-#define MAC_RGMII_ID_TXC_DELAY_EN_	(0x00000002)
-#define MAC_RGMII_ID_RXC_DELAY_EN_	(0x00000001)
+#define MAC_RGMII_ID_TXC_DELAY_EN	(0x00000002)
+#define MAC_RGMII_ID_RXC_DELAY_EN	(0x00000001)
 
 #define EEE_TX_LPI_REQ_DLY		(0x130)
-#define EEE_TX_LPI_REQ_DLY_CNT_MASK_	(0xFFFFFFFF)
+#define EEE_TX_LPI_REQ_DLY_CNT_MASK	(0xFFFFFFFF)
 
 #define EEE_TW_TX_SYS			(0x134)
-#define EEE_TW_TX_SYS_CNT1G_MASK_	(0xFFFF0000)
-#define EEE_TW_TX_SYS_CNT100M_MASK_	(0x0000FFFF)
+#define EEE_TW_TX_SYS_CNT1G_MASK	(0xFFFF0000)
+#define EEE_TW_TX_SYS_CNT100M_MASK	(0x0000FFFF)
 
 #define EEE_TX_LPI_REM_DLY		(0x138)
-#define EEE_TX_LPI_REM_DLY_CNT_		(0x00FFFFFF)
+#define EEE_TX_LPI_REM_DLY_CNT		(0x00FFFFFF)
 
 #define WUCSR				(0x140)
-#define WUCSR_TESTMODE_			(0x80000000)
-#define WUCSR_RFE_WAKE_EN_		(0x00004000)
-#define WUCSR_EEE_TX_WAKE_		(0x00002000)
-#define WUCSR_EEE_TX_WAKE_EN_		(0x00001000)
-#define WUCSR_EEE_RX_WAKE_		(0x00000800)
-#define WUCSR_EEE_RX_WAKE_EN_		(0x00000400)
-#define WUCSR_RFE_WAKE_FR_		(0x00000200)
-#define WUCSR_STORE_WAKE_		(0x00000100)
-#define WUCSR_PFDA_FR_			(0x00000080)
-#define WUCSR_WUFR_			(0x00000040)
-#define WUCSR_MPR_			(0x00000020)
-#define WUCSR_BCST_FR_			(0x00000010)
-#define WUCSR_PFDA_EN_			(0x00000008)
-#define WUCSR_WAKE_EN_			(0x00000004)
-#define WUCSR_MPEN_			(0x00000002)
-#define WUCSR_BCST_EN_			(0x00000001)
+#define WUCSR_TESTMODE			(0x80000000)
+#define WUCSR_RFE_WAKE_EN		(0x00004000)
+#define WUCSR_EEE_TX_WAKE		(0x00002000)
+#define WUCSR_EEE_TX_WAKE_EN		(0x00001000)
+#define WUCSR_EEE_RX_WAKE		(0x00000800)
+#define WUCSR_EEE_RX_WAKE_EN		(0x00000400)
+#define WUCSR_RFE_WAKE_FR		(0x00000200)
+#define WUCSR_STORE_WAKE		(0x00000100)
+#define WUCSR_PFDA_FR			(0x00000080)
+#define WUCSR_WUFR			(0x00000040)
+#define WUCSR_MPR			(0x00000020)
+#define WUCSR_BCST_FR			(0x00000010)
+#define WUCSR_PFDA_EN			(0x00000008)
+#define WUCSR_WAKE_EN			(0x00000004)
+#define WUCSR_MPEN			(0x00000002)
+#define WUCSR_BCST_EN			(0x00000001)
 
 #define WK_SRC				(0x144)
-#define WK_SRC_GPIOX_INT_WK_SHIFT_	(20)
-#define WK_SRC_GPIOX_INT_WK_MASK_	(0xFFF00000)
-#define WK_SRC_IPV6_TCPSYN_RCD_WK_	(0x00010000)
-#define WK_SRC_IPV4_TCPSYN_RCD_WK_	(0x00008000)
-#define WK_SRC_EEE_TX_WK_		(0x00004000)
-#define WK_SRC_EEE_RX_WK_		(0x00002000)
-#define WK_SRC_GOOD_FR_WK_		(0x00001000)
-#define WK_SRC_PFDA_FR_WK_		(0x00000800)
-#define WK_SRC_MP_FR_WK_		(0x00000400)
-#define WK_SRC_BCAST_FR_WK_		(0x00000200)
-#define WK_SRC_WU_FR_WK_		(0x00000100)
-#define WK_SRC_WUFF_MATCH_MASK_		(0x0000001F)
+#define WK_SRC_GPIOX_INT_WK_SHIFT	(20)
+#define WK_SRC_GPIOX_INT_WK_MASK	(0xFFF00000)
+#define WK_SRC_IPV6_TCPSYN_RCD_WK	(0x00010000)
+#define WK_SRC_IPV4_TCPSYN_RCD_WK	(0x00008000)
+#define WK_SRC_EEE_TX_WK		(0x00004000)
+#define WK_SRC_EEE_RX_WK		(0x00002000)
+#define WK_SRC_GOOD_FR_WK		(0x00001000)
+#define WK_SRC_PFDA_FR_WK		(0x00000800)
+#define WK_SRC_MP_FR_WK			(0x00000400)
+#define WK_SRC_BCAST_FR_WK		(0x00000200)
+#define WK_SRC_WU_FR_WK			(0x00000100)
+#define WK_SRC_WUFF_MATCH_MASK		(0x0000001F)
 
 #define WUF_CFG0			(0x150)
 #define NUM_OF_WUF_CFG			(32)
 #define WUF_CFG_BEGIN			(WUF_CFG0)
 #define WUF_CFG(index)			(WUF_CFG_BEGIN + (4 * (index)))
-#define WUF_CFGX_EN_			(0x80000000)
-#define WUF_CFGX_TYPE_MASK_		(0x03000000)
-#define WUF_CFGX_TYPE_MCAST_		(0x02000000)
-#define WUF_CFGX_TYPE_ALL_		(0x01000000)
-#define WUF_CFGX_TYPE_UCAST_		(0x00000000)
-#define WUF_CFGX_OFFSET_SHIFT_		(16)
-#define WUF_CFGX_OFFSET_MASK_		(0x00FF0000)
-#define WUF_CFGX_CRC16_MASK_		(0x0000FFFF)
+#define WUF_CFGX_EN			(0x80000000)
+#define WUF_CFGX_TYPE_MASK		(0x03000000)
+#define WUF_CFGX_TYPE_MCAST		(0x02000000)
+#define WUF_CFGX_TYPE_ALL		(0x01000000)
+#define WUF_CFGX_TYPE_UCAST		(0x00000000)
+#define WUF_CFGX_OFFSET_SHIFT		(16)
+#define WUF_CFGX_OFFSET_MASK		(0x00FF0000)
+#define WUF_CFGX_CRC16_MASK		(0x0000FFFF)
 
 #define WUF_MASK0_0			(0x200)
 #define WUF_MASK0_1			(0x204)
@@ -695,24 +695,24 @@
 #define MAF_LO_BEGIN			(MAF_BASE + MAF_LOX)
 #define MAF_HI(index)			(MAF_BASE + (8 * (index)) + (MAF_HIX))
 #define MAF_LO(index)			(MAF_BASE + (8 * (index)) + (MAF_LOX))
-#define MAF_HI_VALID_			(0x80000000)
-#define MAF_HI_TYPE_MASK_		(0x40000000)
-#define MAF_HI_TYPE_SRC_		(0x40000000)
-#define MAF_HI_TYPE_DST_		(0x00000000)
+#define MAF_HI_VALID			(0x80000000)
+#define MAF_HI_TYPE_MASK		(0x40000000)
+#define MAF_HI_TYPE_SRC			(0x40000000)
+#define MAF_HI_TYPE_DST			(0x00000000)
 #define MAF_HI_ADDR_MASK		(0x0000FFFF)
 #define MAF_LO_ADDR_MASK		(0xFFFFFFFF)
 
 #define WUCSR2				(0x600)
-#define WUCSR2_CSUM_DISABLE_		(0x80000000)
-#define WUCSR2_NA_SA_SEL_		(0x00000100)
-#define WUCSR2_NS_RCD_			(0x00000080)
-#define WUCSR2_ARP_RCD_			(0x00000040)
-#define WUCSR2_IPV6_TCPSYN_RCD_		(0x00000020)
-#define WUCSR2_IPV4_TCPSYN_RCD_		(0x00000010)
-#define WUCSR2_NS_OFFLOAD_EN_		(0x00000008)
-#define WUCSR2_ARP_OFFLOAD_EN_		(0x00000004)
-#define WUCSR2_IPV6_TCPSYN_WAKE_EN_	(0x00000002)
-#define WUCSR2_IPV4_TCPSYN_WAKE_EN_	(0x00000001)
+#define WUCSR2_CSUM_DISABLE		(0x80000000)
+#define WUCSR2_NA_SA_SEL		(0x00000100)
+#define WUCSR2_NS_RCD			(0x00000080)
+#define WUCSR2_ARP_RCD			(0x00000040)
+#define WUCSR2_IPV6_TCPSYN_RCD		(0x00000020)
+#define WUCSR2_IPV4_TCPSYN_RCD		(0x00000010)
+#define WUCSR2_NS_OFFLOAD_EN		(0x00000008)
+#define WUCSR2_ARP_OFFLOAD_EN		(0x00000004)
+#define WUCSR2_IPV6_TCPSYN_WAKE_EN	(0x00000002)
+#define WUCSR2_IPV4_TCPSYN_WAKE_EN	(0x00000001)
 
 #define NS1_IPV6_ADDR_DEST0		(0x610)
 #define NS1_IPV6_ADDR_DEST1		(0x614)
@@ -757,9 +757,9 @@
 #define SYN_IPV4_ADDR_SRC		(0x690)
 #define SYN_IPV4_ADDR_DEST		(0x694)
 #define SYN_IPV4_TCP_PORTS		(0x698)
-#define SYN_IPV4_TCP_PORTS_IPV4_DEST_PORT_SHIFT_    (16)
-#define SYN_IPV4_TCP_PORTS_IPV4_DEST_PORT_MASK_     (0xFFFF0000)
-#define SYN_IPV4_TCP_PORTS_IPV4_SRC_PORT_MASK_	    (0x0000FFFF)
+#define SYN_IPV4_TCP_PORTS_IPV4_DEST_PORT_SHIFT	(16)
+#define SYN_IPV4_TCP_PORTS_IPV4_DEST_PORT_MASK	(0xFFFF0000)
+#define SYN_IPV4_TCP_PORTS_IPV4_SRC_PORT_MASK	(0x0000FFFF)
 
 #define SYN_IPV6_ADDR_SRC0		(0x69C)
 #define SYN_IPV6_ADDR_SRC1		(0x6A0)
@@ -772,26 +772,26 @@
 #define SYN_IPV6_ADDR_DEST3		(0x6B8)
 
 #define SYN_IPV6_TCP_PORTS		(0x6BC)
-#define SYN_IPV6_TCP_PORTS_IPV6_DEST_PORT_SHIFT_    (16)
-#define SYN_IPV6_TCP_PORTS_IPV6_DEST_PORT_MASK_     (0xFFFF0000)
-#define SYN_IPV6_TCP_PORTS_IPV6_SRC_PORT_MASK_	    (0x0000FFFF)
+#define SYN_IPV6_TCP_PORTS_IPV6_DEST_PORT_SHIFT	(16)
+#define SYN_IPV6_TCP_PORTS_IPV6_DEST_PORT_MASK	(0xFFFF0000)
+#define SYN_IPV6_TCP_PORTS_IPV6_SRC_PORT_MASK	(0x0000FFFF)
 
 #define ARP_SPA				(0x6C0)
 #define ARP_TPA				(0x6C4)
 
 #define PHY_DEV_ID			(0x700)
-#define PHY_DEV_ID_REV_SHIFT_		(28)
-#define PHY_DEV_ID_REV_SHIFT_		(28)
-#define PHY_DEV_ID_REV_MASK_		(0xF0000000)
-#define PHY_DEV_ID_MODEL_SHIFT_		(22)
-#define PHY_DEV_ID_MODEL_MASK_		(0x0FC00000)
-#define PHY_DEV_ID_OUI_MASK_		(0x003FFFFF)
+#define PHY_DEV_ID_REV_SHIFT		(28)
+#define PHY_DEV_ID_REV_SHIFT		(28)
+#define PHY_DEV_ID_REV_MASK		(0xF0000000)
+#define PHY_DEV_ID_MODEL_SHIFT		(22)
+#define PHY_DEV_ID_MODEL_MASK		(0x0FC00000)
+#define PHY_DEV_ID_OUI_MASK		(0x003FFFFF)
 
 #define OTP_BASE_ADDR			(0x00001000)
-#define OTP_ADDR_RANGE_			(0x1FF)
+#define OTP_ADDR_RANGE			(0x1FF)
 
 #define OTP_PWR_DN			(OTP_BASE_ADDR + 4 * 0x00)
-#define OTP_PWR_DN_PWRDN_N_		(0x01)
+#define OTP_PWR_DN_PWRDN_N		(0x01)
 
 #define OTP_ADDR1			(OTP_BASE_ADDR + 4 * 0x01)
 #define OTP_ADDR1_15_11			(0x1F)
@@ -805,44 +805,44 @@
 #define OTP_PRGM_DATA			(OTP_BASE_ADDR + 4 * 0x04)
 
 #define OTP_PRGM_MODE			(OTP_BASE_ADDR + 4 * 0x05)
-#define OTP_PRGM_MODE_BYTE_		(0x01)
+#define OTP_PRGM_MODE_BYTE		(0x01)
 
 #define OTP_RD_DATA			(OTP_BASE_ADDR + 4 * 0x06)
 
 #define OTP_FUNC_CMD			(OTP_BASE_ADDR + 4 * 0x08)
-#define OTP_FUNC_CMD_RESET_		(0x04)
-#define OTP_FUNC_CMD_PROGRAM_		(0x02)
-#define OTP_FUNC_CMD_READ_		(0x01)
+#define OTP_FUNC_CMD_RESET		(0x04)
+#define OTP_FUNC_CMD_PROGRAM		(0x02)
+#define OTP_FUNC_CMD_READ		(0x01)
 
 #define OTP_TST_CMD			(OTP_BASE_ADDR + 4 * 0x09)
-#define OTP_TST_CMD_TEST_DEC_SEL_	(0x10)
-#define OTP_TST_CMD_PRGVRFY_		(0x08)
-#define OTP_TST_CMD_WRTEST_		(0x04)
-#define OTP_TST_CMD_TESTDEC_		(0x02)
-#define OTP_TST_CMD_BLANKCHECK_		(0x01)
+#define OTP_TST_CMD_TEST_DEC_SEL	(0x10)
+#define OTP_TST_CMD_PRGVRFY		(0x08)
+#define OTP_TST_CMD_WRTEST		(0x04)
+#define OTP_TST_CMD_TESTDEC		(0x02)
+#define OTP_TST_CMD_BLANKCHECK		(0x01)
 
 #define OTP_CMD_GO			(OTP_BASE_ADDR + 4 * 0x0A)
-#define OTP_CMD_GO_GO_			(0x01)
+#define OTP_CMD_GO_GO			(0x01)
 
 #define OTP_PASS_FAIL			(OTP_BASE_ADDR + 4 * 0x0B)
-#define OTP_PASS_FAIL_PASS_		(0x02)
-#define OTP_PASS_FAIL_FAIL_		(0x01)
+#define OTP_PASS_FAIL_PASS		(0x02)
+#define OTP_PASS_FAIL_FAIL		(0x01)
 
 #define OTP_STATUS			(OTP_BASE_ADDR + 4 * 0x0C)
-#define OTP_STATUS_OTP_LOCK_		(0x10)
-#define OTP_STATUS_WEB_			(0x08)
+#define OTP_STATUS_OTP_LOCK		(0x10)
+#define OTP_STATUS_WEB			(0x08)
 #define OTP_STATUS_PGMEN		(0x04)
-#define OTP_STATUS_CPUMPEN_		(0x02)
-#define OTP_STATUS_BUSY_		(0x01)
+#define OTP_STATUS_CPUMPEN		(0x02)
+#define OTP_STATUS_BUSY			(0x01)
 
 #define OTP_MAX_PRG			(OTP_BASE_ADDR + 4 * 0x0D)
 #define OTP_MAX_PRG_MAX_PROG		(0x1F)
 
 #define OTP_INTR_STATUS			(OTP_BASE_ADDR + 4 * 0x10)
-#define OTP_INTR_STATUS_READY_		(0x01)
+#define OTP_INTR_STATUS_READY		(0x01)
 
 #define OTP_INTR_MASK			(OTP_BASE_ADDR + 4 * 0x11)
-#define OTP_INTR_MASK_READY_		(0x01)
+#define OTP_INTR_MASK_READY		(0x01)
 
 #define OTP_RSTB_PW1			(OTP_BASE_ADDR + 4 * 0x14)
 #define OTP_RSTB_PW2			(OTP_BASE_ADDR + 4 * 0x15)
-- 
2.10.0.rc2.1.g053435c
