From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 5/7] Topcliff GbE: Add The Hardware layer codes [2/2]
Date: Fri, 23 Apr 2010 21:00:58 +0900
Message-ID: <003501cae2dd$20f530f0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=2;
	id="01CAE2DD.1F1610B0@tsmail03";
	number=2
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34081 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757337Ab0DWMEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


+ */
+s32
+pch_gbe_phy_led_off(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_phy_led_off\n");
+
+ pch_gbe_hal_write_phy_reg(hw, PHY_LED_CONTROL, PHY_LED_CTRL_OFF);
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_cleanup(struct pch_gbe_hw *hw)
+ * @brief   Cleanup led control
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ */
+s32
+pch_gbe_phy_led_cleanup(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_phy_led_cleanup\n");
+
+ pch_gbe_hal_write_phy_reg(hw, PHY_LED_CONTROL, PHY_LED_CTRL_CLEANUP);
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_setup(struct pch_gbe_hw *hw)
+ * @brief   Setup led control
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ */
+s32
+pch_gbe_phy_led_setup(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_phy_led_setup\n");
+
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_power_up(struct pch_gbe_hw *hw)
+ * @brief   restore link in case the phy was powered down
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ * @remarks
+ *  The phy may be powered down to save power and turn off link when the
+ *  driver is unloaded and wake on lan is not enabled (among others)
+ *  *** this routine MUST be followed by a call to pch_gbe_reset ***
+ */
+void pch_gbe_phy_power_up(struct pch_gbe_hw *hw)
+{
+ u16 mii_reg;
+
+ PCH_DEBUG("pch_gbe_phy_power_up\n");
+
+ mii_reg = 0;
+ /* Just clear the power down bit to wake the phy back up */
+ /* according to the manual, the phy will retain its
+  * settings across a power-down/up cycle */
+ pch_gbe_hal_read_phy_reg(hw, PHY_CONTROL, &mii_reg);
+ mii_reg &= ~MII_CR_POWER_DOWN;
+ pch_gbe_hal_write_phy_reg(hw, PHY_CONTROL, mii_reg);
+
+#ifdef DEBUG_TEST
+ pch_gbe_hal_read_phy_reg(hw, PHY_CONTROL, &mii_reg);
+ PCH_DEBUG("PHY_CONTROL reg : 0x%08x\n", mii_reg);
+#endif
+ return;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
+ * @brief   Power down PHY
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ */
+void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
+{
+ u16 mii_reg;
+
+ PCH_DEBUG("pch_gbe_phy_power_down\n");
+
+ mii_reg = 0;
+ /* Power down the PHY so no link is implied when interface is down *
+  * The PHY cannot be powered down if any of the following is TRUE *
+  * (a) WoL is enabled
+  * (b) AMT is active
+  */
+ pch_gbe_hal_read_phy_reg(hw, PHY_CONTROL, &mii_reg);
+ mii_reg |= MII_CR_POWER_DOWN;
+ pch_gbe_hal_write_phy_reg(hw, PHY_CONTROL, mii_reg);
+ mdelay(1);
+
+#ifdef DEBUG_TEST
+ pch_gbe_hal_read_phy_reg(hw, PHY_CONTROL, &mii_reg);
+ PCH_DEBUG("PHY_CONTROL reg : 0x%08x\n", mii_reg);
+#endif
+ return;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+ * @brief   RGMII interface setting
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ */
+#ifdef FPGA
+void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+{
+ u16 mii_reg;
+
+ PCH_DEBUG("pch_gbe_phy_set_rgmii\n");
+
+ pch_gbe_hal_read_phy_reg(hw, PHY_EXT_PHYSP_STATUS, &mii_reg);
+ mii_reg &= ~HWCFG_MODE_MASK;
+ mii_reg |= HWCFG_MODE_RGMII_COPPER;
+ pch_gbe_hal_write_phy_reg(hw, PHY_EXT_PHYSP_STATUS, mii_reg);
+ pch_gbe_hal_read_phy_reg(hw, PHY_EXT_PHYSP_CONTROL, &mii_reg);
+ mii_reg |= 0x01; /* Transfer enable */
+ mii_reg |= 0x02; /* add delay to GTX_CLK */
+ mii_reg |= 0x80; /* add delay to RX_CLK */
+ pch_gbe_hal_write_phy_reg(hw, PHY_EXT_PHYSP_CONTROL, mii_reg);
+ pch_gbe_hal_phy_sw_reset(hw);
+
+#ifdef DEBUG_TEST
+ pch_gbe_hal_read_phy_reg(hw, PHY_EXT_PHYSP_STATUS, &mii_reg);
+ PCH_DEBUG("PHY_EXT_PHYSP_STATUS reg : 0x%08x\n", mii_reg);
+ pch_gbe_hal_read_phy_reg(hw, PHY_EXT_PHYSP_CONTROL, &mii_reg);
+ PCH_DEBUG("PHY_EXT_PHYSP_CONTROL reg : 0x%08x\n", mii_reg);
+#endif
+ return;
+}
+#else
+void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_phy_set_rgmii\n");
+
+ pch_gbe_hal_phy_sw_reset(hw);
+ return;
+}
+#endif
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
+ * @brief   PHY initial setting
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ */
+void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
+{
+ struct pch_gbe_adapter *adapter;
+ struct ethtool_cmd     cmd;
+ int ret;
+ u16 mii_reg;
+
+ PCH_DEBUG("pch_gbe_phy_init_setting\n");
+
+ adapter = container_of(hw, struct pch_gbe_adapter, hw);
+ ret = mii_ethtool_gset(&adapter->mii, &cmd);
+ if (ret != 0)
+  PCH_LOG(KERN_ERR, "Error: mii_ethtool_gset\n");
+
+ cmd.speed = hw->mac.link_speed;
+ cmd.duplex = hw->mac.link_duplex;
+ cmd.advertising = hw->phy.autoneg_advertised;
+ cmd.autoneg = hw->mac.autoneg;
+ pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
+ ret = mii_ethtool_sset(&adapter->mii, &cmd);
+ if (ret != 0)
+  PCH_LOG(KERN_ERR, "Error: mii_ethtool_sset\n");
+
+ pch_gbe_hal_phy_sw_reset(hw);
+
+ pch_gbe_hal_read_phy_reg(hw, PHY_PHYSP_CONTROL, &mii_reg);
+ mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
+ pch_gbe_hal_write_phy_reg(hw, PHY_PHYSP_CONTROL, mii_reg);
+
+}
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.h 2010-04-13
18:26:41.000000000 +0900
@@ -0,0 +1,135 @@
+/*!
+ * @file pch_gbe_phy.h
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (PHY)
header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_PHY_H_
+#define _PCH_GBE_PHY_H_
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
+ * @brief   Retrieve the PHY ID and revision
+ */
+s32  pch_gbe_phy_get_id(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw,
+ *                                        u32 offset, u16 *data)
+ * @brief   Read MII control register
+ */
+s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16
*data);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw,
+ *                                         u32 offset, u16 data)
+ * @brief   Write MII control register
+ */
+s32 pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16
data);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_setup_link_fpga(struct pch_gbe_hw *hw)
+ * @brief   Configure link settings for FPGA
+ */
+s32  pch_gbe_phy_setup_link_fpga(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw)
+ * @brief   PHY software reset
+ */
+void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw)
+ * @brief   PHY hardware reset
+ */
+void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_on(struct pch_gbe_hw *hw)
+ * @brief   Set ting of led on
+ */
+s32 pch_gbe_phy_led_on(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_off(struct pch_gbe_hw *hw)
+ * @brief   Set ting of led off
+ */
+s32 pch_gbe_phy_led_off(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_cleanup(struct pch_gbe_hw *hw)
+ * @brief   Cleanup led control
+ */
+s32 pch_gbe_phy_led_cleanup(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_setup(struct pch_gbe_hw *hw)
+ * @brief   Setup led control
+ */
+s32 pch_gbe_phy_led_setup(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_power_up(struct pch_gbe_hw *hw)
+ * @brief   restore link in case the phy was powered down
+ */
+void pch_gbe_phy_power_up(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
+ * @brief   Power down PHY
+ */
+void pch_gbe_phy_power_down(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+ * @brief   RGMII interface setting
+ */
+void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
+ * @brief   PHY initial setting
+ */
+void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw);
+
+
+#endif /* _PCH_GBE_PHY_H_ */

