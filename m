From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 3/7] Topcliff GbE: Add The Ethtool code [2/2]
Date: Fri, 23 Apr 2010 21:00:29 +0900
Message-ID: <003201cae2dd$204987a0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=2;
	id="01CAE2DD.1F139FB0@tsmail03";
	number=2
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34066 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757319Ab0DWMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


+   pch_gbe_gstrings_stats[i].stat_offset;
+  data[i] =
+   (pch_gbe_gstrings_stats[i].sizeof_stat ==
+   (int)sizeof(u64)) ? *(u64 *) p:(*(u32 *) p);
+ }
+}
+
+/*!
+ * @ingroup Ethtool driver Layer
+ * @struct  pch_gbe_ethtool_ops
+ * @brief   Store the pointers of ethtool interfaces to kernel
+ */
+static struct ethtool_ops pch_gbe_ethtool_ops = {
+ .get_settings = pch_gbe_get_settings,
+ .set_settings = pch_gbe_set_settings,
+ .get_drvinfo = pch_gbe_get_drvinfo,
+ .get_regs_len = pch_gbe_get_regs_len,
+ .get_regs = pch_gbe_get_regs,
+ .get_wol = pch_gbe_get_wol,
+ .set_wol = pch_gbe_set_wol,
+ .get_msglevel = pch_gbe_get_msglevel,
+ .set_msglevel = pch_gbe_set_msglevel,
+ .nway_reset = pch_gbe_nway_reset,
+ .get_link = ethtool_op_get_link,
+#ifdef CONFIG_PCH_PHUB
+ .get_eeprom_len = pch_gbe_get_eeprom_len,
+ .get_eeprom = pch_gbe_get_eeprom,
+ .set_eeprom = pch_gbe_set_eeprom,
+#endif
+ .get_ringparam = pch_gbe_get_ringparam,
+ .set_ringparam = pch_gbe_set_ringparam,
+ .get_pauseparam = pch_gbe_get_pauseparam,
+ .set_pauseparam = pch_gbe_set_pauseparam,
+ .get_rx_csum = pch_gbe_get_rx_csum,
+ .set_rx_csum = pch_gbe_set_rx_csum,
+ .get_tx_csum = pch_gbe_get_tx_csum,
+ .set_tx_csum = pch_gbe_set_tx_csum,
+ .self_test = pch_gbe_diag_test,
+ .get_strings = pch_gbe_get_strings,
+ .phys_id = pch_gbe_phys_id,
+ .get_ethtool_stats = pch_gbe_get_ethtool_stats,
+};
+
+/*!
+ * @ingroup Ethtool driver internal functions
+ * @fn      void pch_gbe_set_ethtool_ops(struct net_device *netdev)
+ * @brief   Set the Ethtool to network device data
+ * @param   netdev [INOUT] Network interface device structure
+ * @return  None
+ */
+void pch_gbe_set_ethtool_ops(struct net_device *netdev)
+{
+ PCH_DEBUG("ethtool: pch_gbe_set_ethtool_ops\n");
+
+ SET_ETHTOOL_OPS(netdev, &pch_gbe_ethtool_ops);
+}
+
+#define PCH_GBE_REG_PATTERN_TEST(reg, mask, write) \
+ do { \
+  if (reg_pattern_test(adapter, data, \
+   PCH_GBE_##reg, mask, write)) \
+   return 1; \
+ } while (0)
+
+/*!
+ * @ingroup Ethtool driver internal functions
+ * @fn      static int pch_gbe_reg_test(struct pch_gbe_adapter *adapter,
uint64_t *data)
+ * @brief   Register test
+ * @param   adapter  [IN] Board private structure
+ * @param   data     [INOUT] Pointer to test result data
+ * @return  PCH_GBE_SUCCESS
+ */
+static int pch_gbe_reg_test(struct pch_gbe_adapter *adapter, uint64_t
*data)
+{
+ PCH_DEBUG("ethtool: pch_gbe_reg_test\n");
+
+ pch_gbe_reset(adapter);
+ PCH_GBE_REG_PATTERN_TEST(INT_EN, 0x11111F3F, 0x11111F3F);
+ PCH_GBE_REG_PATTERN_TEST(MODE, 0xC2000000, 0xC2000000);
+ PCH_GBE_REG_PATTERN_TEST(TCPIP_ACC, 0x0000000F, 0x0000000F);
+ PCH_GBE_REG_PATTERN_TEST(EX_LIST, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(PHY_INT_CTRL, 0x00010003, 0x00010003);
+ PCH_GBE_REG_PATTERN_TEST(MAC_RX_EN, 0x00000001, 0x00000001);
+ PCH_GBE_REG_PATTERN_TEST(RX_FCTRL, 0x80000000, 0x80000000);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_REQ, 0x80000000, 0x80000000);
+ PCH_GBE_REG_PATTERN_TEST(RX_MODE, 0xC000FE00, 0xC000FE00);
+ PCH_GBE_REG_PATTERN_TEST(TX_MODE, 0xF800FE00, 0xF800FE00);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_PKT1, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_PKT2, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_PKT3, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_PKT4, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(PAUSE_PKT5, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR1A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR1B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR2A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR2B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR3A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR3B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR4A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR4B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR5A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR5B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR6A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR6B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR7A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR7B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR8A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR8B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR9A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR9B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR10A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR10B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR11A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR11B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR12A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR12B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR13A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR13B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR14A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR14B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR15A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR15B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR16A, 0xFFFFFFFF, 0xFFFFFFFF);
+ PCH_GBE_REG_PATTERN_TEST(MAC_ADR16B, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(ADDR_MASK, 0x0000FFFF, 0x0000FFFF);
+ PCH_GBE_REG_PATTERN_TEST(RGMII_CTRL, 0x0000001F, 0x0000001F);
+ PCH_GBE_REG_PATTERN_TEST(DMA_CTRL, 0x00000003, 0x00000003);
+ PCH_GBE_REG_PATTERN_TEST(RX_DSC_BASE, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(RX_DSC_SIZE, 0x0000FFF0, 0x0000FFF0);
+ PCH_GBE_REG_PATTERN_TEST(RX_DSC_HW_P, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(RX_DSC_SW_P, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(TX_DSC_BASE, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(TX_DSC_SIZE, 0x0000FFF0, 0x0000FFF0);
+ PCH_GBE_REG_PATTERN_TEST(TX_DSC_HW_P, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(TX_DSC_SW_P, 0xFFFFFFF0, 0xFFFFFFF0);
+ PCH_GBE_REG_PATTERN_TEST(WOL_ST, 0x0000000F, 0x0000000F);
+ PCH_GBE_REG_PATTERN_TEST(WOL_CTRL, 0x0001017F, 0x0001017F);
+ PCH_GBE_REG_PATTERN_TEST(WOL_ADDR_MASK, 0x0000FFFF, 0x0000FFFF);
+
+ *data = 0;
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Ethtool driver internal functions
+ * @fn      static bool reg_pattern_test(struct pch_gbe_adapter *adapter,
+ *                                       uint64_t *data,   int reg,
+ *                                       uint32_t mask,    uint32_t write)
+ * @brief   Register pattern test
+ * @param   adapter  [IN] Board private structure
+ * @param   data     [INOUT] Pointer to test result data
+ * @param   reg      [INOUT] Register address
+ * @param   mask     [INOUT] Mask pattern
+ * @param   write    [INOUT] Write data
+ * @return  true     : Successfully
+ * @return  false    : Failed
+ */
+static bool
+reg_pattern_test(struct pch_gbe_adapter *adapter,
+   uint64_t *data, int reg, uint32_t mask, uint32_t write)
+{
+ static const uint32_t test[] = {
+  0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+ };
+ uint8_t __iomem *address = adapter->hw.hw_addr + reg;
+ uint32_t read;
+ int i;
+
+ for (i = 0; i < ARRAY_SIZE(test); i++) {
+  writel(write & test[i], address);
+  read = (readl(address) & mask);
+  if (read != (write & test[i] & mask)) {
+   DPRINTK(HW, ERR, "pattern test reg %04X failed: "
+    "got 0x%08X expected 0x%08X\n",
+    reg, read, (write & test[i] & mask));
+   *data = reg;
+   return true;
+  }
+ }
+ return false;
+}

