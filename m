From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/9] e1000: neaten function declarations
Date: Fri, 11 Jul 2008 15:17:02 -0700
Message-ID: <20080711221702.3255.43654.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62937 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218AbYGKWRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:16 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |  175 +++++-------
 drivers/net/e1000/e1000_hw.c      |  558 +++++++++++++------------------------
 drivers/net/e1000/e1000_main.c    |  307 ++++++++------------
 drivers/net/e1000/e1000_param.c   |   16 -
 4 files changed, 385 insertions(+), 671 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index a3f6a9c..4bcfa37 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -112,8 +112,8 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
 
-static int
-e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int e1000_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -185,8 +185,8 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-static int
-e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int e1000_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -231,9 +231,8 @@ e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-static void
-e1000_get_pauseparam(struct net_device *netdev,
-                     struct ethtool_pauseparam *pause)
+static void e1000_get_pauseparam(struct net_device *netdev,
+				 struct ethtool_pauseparam *pause)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -251,9 +250,8 @@ e1000_get_pauseparam(struct net_device *netdev,
 	}
 }
 
-static int
-e1000_set_pauseparam(struct net_device *netdev,
-                     struct ethtool_pauseparam *pause)
+static int e1000_set_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -289,15 +287,13 @@ e1000_set_pauseparam(struct net_device *netdev,
 	return retval;
 }
 
-static u32
-e1000_get_rx_csum(struct net_device *netdev)
+static u32 e1000_get_rx_csum(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->rx_csum;
 }
 
-static int
-e1000_set_rx_csum(struct net_device *netdev, u32 data)
+static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->rx_csum = data;
@@ -309,14 +305,12 @@ e1000_set_rx_csum(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static u32
-e1000_get_tx_csum(struct net_device *netdev)
+static u32 e1000_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_HW_CSUM) != 0;
 }
 
-static int
-e1000_set_tx_csum(struct net_device *netdev, u32 data)
+static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -334,8 +328,7 @@ e1000_set_tx_csum(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static int
-e1000_set_tso(struct net_device *netdev, u32 data)
+static int e1000_set_tso(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if ((adapter->hw.mac_type < e1000_82544) ||
@@ -357,30 +350,26 @@ e1000_set_tso(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static u32
-e1000_get_msglevel(struct net_device *netdev)
+static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->msg_enable;
 }
 
-static void
-e1000_set_msglevel(struct net_device *netdev, u32 data)
+static void e1000_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
 }
 
-static int
-e1000_get_regs_len(struct net_device *netdev)
+static int e1000_get_regs_len(struct net_device *netdev)
 {
 #define E1000_REGS_LEN 32
 	return E1000_REGS_LEN * sizeof(u32);
 }
 
-static void
-e1000_get_regs(struct net_device *netdev,
-	       struct ethtool_regs *regs, void *p)
+static void e1000_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
+			   void *p)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -468,16 +457,14 @@ e1000_get_regs(struct net_device *netdev,
 	}
 }
 
-static int
-e1000_get_eeprom_len(struct net_device *netdev)
+static int e1000_get_eeprom_len(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->hw.eeprom.word_size * 2;
 }
 
-static int
-e1000_get_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, u8 *bytes)
+static int e1000_get_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -521,9 +508,8 @@ e1000_get_eeprom(struct net_device *netdev,
 	return ret_val;
 }
 
-static int
-e1000_set_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, u8 *bytes)
+static int e1000_set_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -584,9 +570,8 @@ e1000_set_eeprom(struct net_device *netdev,
 	return ret_val;
 }
 
-static void
-e1000_get_drvinfo(struct net_device *netdev,
-                       struct ethtool_drvinfo *drvinfo)
+static void e1000_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *drvinfo)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
@@ -619,9 +604,8 @@ e1000_get_drvinfo(struct net_device *netdev,
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
 
-static void
-e1000_get_ringparam(struct net_device *netdev,
-                    struct ethtool_ringparam *ring)
+static void e1000_get_ringparam(struct net_device *netdev,
+				struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
@@ -640,9 +624,8 @@ e1000_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }
 
-static int
-e1000_set_ringparam(struct net_device *netdev,
-                    struct ethtool_ringparam *ring)
+static int e1000_set_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
@@ -728,8 +711,8 @@ err_setup:
 	return err;
 }
 
-static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
-			     int reg, u32 mask, u32 write)
+static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
+			     u32 mask, u32 write)
 {
 	static const u32 test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
@@ -751,8 +734,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 	return false;
 }
 
-static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
-			      int reg, u32 mask, u32 write)
+static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
+			      u32 mask, u32 write)
 {
 	u8 __iomem *address = adapter->hw.hw_addr + reg;
 	u32 read;
@@ -787,8 +770,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 			return 1;				     \
 	} while (0)
 
-static int
-e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
+static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
 	u32 value, before, after;
 	u32 i, toggle;
@@ -883,8 +865,7 @@ e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	return 0;
 }
 
-static int
-e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
+static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 {
 	u16 temp;
 	u16 checksum = 0;
@@ -907,8 +888,7 @@ e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static irqreturn_t
-e1000_test_intr(int irq, void *data)
+static irqreturn_t e1000_test_intr(int irq, void *data)
 {
 	struct net_device *netdev = (struct net_device *) data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -918,8 +898,7 @@ e1000_test_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static int
-e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
+static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 mask, i = 0;
@@ -1017,8 +996,7 @@ e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static void
-e1000_free_desc_rings(struct e1000_adapter *adapter)
+static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 {
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
@@ -1064,8 +1042,7 @@ e1000_free_desc_rings(struct e1000_adapter *adapter)
 	return;
 }
 
-static int
-e1000_setup_desc_rings(struct e1000_adapter *adapter)
+static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 {
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
@@ -1189,8 +1166,7 @@ err_nomem:
 	return ret_val;
 }
 
-static void
-e1000_phy_disable_receiver(struct e1000_adapter *adapter)
+static void e1000_phy_disable_receiver(struct e1000_adapter *adapter)
 {
 	/* Write out to PHY registers 29 and 30 to disable the Receiver. */
 	e1000_write_phy_reg(&adapter->hw, 29, 0x001F);
@@ -1199,8 +1175,7 @@ e1000_phy_disable_receiver(struct e1000_adapter *adapter)
 	e1000_write_phy_reg(&adapter->hw, 30, 0x8FF0);
 }
 
-static void
-e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
+static void e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 {
 	u16 phy_reg;
 
@@ -1223,8 +1198,7 @@ e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 		M88E1000_PHY_SPEC_CTRL, phy_reg);
 }
 
-static int
-e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
+static int e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 {
 	u32 ctrl_reg;
 	u16 phy_reg;
@@ -1290,8 +1264,7 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static int
-e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
+static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 {
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
@@ -1360,8 +1333,7 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static int
-e1000_set_phy_loopback(struct e1000_adapter *adapter)
+static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 {
 	u16 phy_reg = 0;
 	u16 count = 0;
@@ -1412,8 +1384,7 @@ e1000_set_phy_loopback(struct e1000_adapter *adapter)
 	return 8;
 }
 
-static int
-e1000_setup_loopback_test(struct e1000_adapter *adapter)
+static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
@@ -1447,8 +1418,7 @@ e1000_setup_loopback_test(struct e1000_adapter *adapter)
 	return 7;
 }
 
-static void
-e1000_loopback_cleanup(struct e1000_adapter *adapter)
+static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
@@ -1489,8 +1459,8 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	}
 }
 
-static void
-e1000_create_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
+static void e1000_create_lbtest_frame(struct sk_buff *skb,
+				      unsigned int frame_size)
 {
 	memset(skb->data, 0xFF, frame_size);
 	frame_size &= ~1;
@@ -1499,8 +1469,8 @@ e1000_create_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
 	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
 }
 
-static int
-e1000_check_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
+static int e1000_check_lbtest_frame(struct sk_buff *skb,
+				    unsigned int frame_size)
 {
 	frame_size &= ~1;
 	if (*(skb->data + 3) == 0xFF) {
@@ -1512,8 +1482,7 @@ e1000_check_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
 	return 13;
 }
 
-static int
-e1000_run_loopback_test(struct e1000_adapter *adapter)
+static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 {
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
@@ -1577,8 +1546,7 @@ e1000_run_loopback_test(struct e1000_adapter *adapter)
 	return ret_val;
 }
 
-static int
-e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
+static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
@@ -1602,8 +1570,7 @@ out:
 	return *data;
 }
 
-static int
-e1000_link_test(struct e1000_adapter *adapter, u64 *data)
+static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 {
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
@@ -1632,8 +1599,7 @@ e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static int
-e1000_get_sset_count(struct net_device *netdev, int sset)
+static int e1000_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_TEST:
@@ -1645,9 +1611,8 @@ e1000_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-static void
-e1000_diag_test(struct net_device *netdev,
-		   struct ethtool_test *eth_test, u64 *data)
+static void e1000_diag_test(struct net_device *netdev,
+			    struct ethtool_test *eth_test, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	bool if_running = netif_running(netdev);
@@ -1717,7 +1682,8 @@ e1000_diag_test(struct net_device *netdev,
 	msleep_interruptible(4 * 1000);
 }
 
-static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wolinfo *wol)
+static int e1000_wol_exclusion(struct e1000_adapter *adapter,
+			       struct ethtool_wolinfo *wol)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int retval = 1; /* fail by default */
@@ -1778,8 +1744,8 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	return retval;
 }
 
-static void
-e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+static void e1000_get_wol(struct net_device *netdev,
+			  struct ethtool_wolinfo *wol)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -1818,8 +1784,7 @@ e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return;
 }
 
-static int
-e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -1863,8 +1828,7 @@ e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 /* bit defines for adapter->led_status */
 #define E1000_LED_ON		0
 
-static void
-e1000_led_blink_callback(unsigned long data)
+static void e1000_led_blink_callback(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 
@@ -1876,8 +1840,7 @@ e1000_led_blink_callback(unsigned long data)
 	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
 }
 
-static int
-e1000_phys_id(struct net_device *netdev, u32 data)
+static int e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -1916,8 +1879,7 @@ e1000_phys_id(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static int
-e1000_nway_reset(struct net_device *netdev)
+static int e1000_nway_reset(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if (netif_running(netdev))
@@ -1925,9 +1887,8 @@ e1000_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
-static void
-e1000_get_ethtool_stats(struct net_device *netdev,
-		struct ethtool_stats *stats, u64 *data)
+static void e1000_get_ethtool_stats(struct net_device *netdev,
+				    struct ethtool_stats *stats, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -1941,8 +1902,8 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
-static void
-e1000_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+static void e1000_get_strings(struct net_device *netdev, u32 stringset,
+			      u8 *data)
 {
 	u8 *p = data;
 	int i;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9a4b6cb..d6c272a 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -42,48 +42,65 @@ static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
 static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw);
 static s32 e1000_check_downshift(struct e1000_hw *hw);
-static s32 e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
+static s32 e1000_check_polarity(struct e1000_hw *hw,
+				e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
 static s32 e1000_commit_shadow_ram(struct e1000_hw *hw);
 static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
-						  bool link_up);
+					      bool link_up);
 static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static s32 e1000_detect_gig_phy(struct e1000_hw *hw);
 static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
-static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
+static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
+				  u16 *max_length);
 static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_get_software_flag(struct e1000_hw *hw);
 static s32 e1000_ich8_cycle_init(struct e1000_hw *hw);
 static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
 static s32 e1000_id_led_init(struct e1000_hw *hw);
-static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, u32 cnf_base_addr, u32 cnf_size);
+static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
+						 u32 cnf_base_addr,
+						 u32 cnf_size);
 static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static s32 e1000_mng_enable_host_if(struct e1000_hw *hw);
-static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length, u16 offset, u8 *sum);
-static s32 e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
+static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length,
+				   u16 offset, u8 *sum);
+static s32 e1000_mng_write_cmd_header(struct e1000_hw* hw,
+				      struct e1000_host_mng_command_header
+				      *hdr);
 static s32 e1000_mng_write_commit(struct e1000_hw *hw);
-static s32 e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static s32 e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_phy_ife_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info);
+static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info);
+static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data);
+static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
+				   u16 *data);
 static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
-static s32 e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
 static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
-static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index,
+					u8 byte);
 static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
 static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
-static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 *data);
-static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 data);
-static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
+				u16 *data);
+static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
+				 u16 data);
+static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data);
+static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+				   u16 *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
@@ -101,23 +118,21 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw);
 static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
 static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
 static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data,
-                                     u16 count);
+				     u16 count);
 static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw);
 static s32 e1000_phy_reset_dsp(struct e1000_hw *hw);
 static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset,
                                       u16 words, u16 *data);
-static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                                            u16 offset, u16 words,
-                                            u16 *data);
+static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
+					u16 words, u16 *data);
 static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw);
 static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd);
 static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd);
-static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data,
-                                    u16 count);
+static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data, u16 count);
 static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
-                                      u16 phy_data);
+				  u16 phy_data);
 static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw,u32 reg_addr,
-                                     u16 *phy_data);
+				 u16 *phy_data);
 static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count);
 static s32 e1000_acquire_eeprom(struct e1000_hw *hw);
 static void e1000_release_eeprom(struct e1000_hw *hw);
@@ -127,8 +142,7 @@ static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static s32 e1000_set_phy_mode(struct e1000_hw *hw);
 static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
 static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
-static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
-                                               u16 duplex);
+static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex);
 static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
 /* IGP cable length table */
@@ -159,8 +173,7 @@ u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static s32
-e1000_set_phy_type(struct e1000_hw *hw)
+static s32 e1000_set_phy_type(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_set_phy_type");
 
@@ -210,8 +223,7 @@ e1000_set_phy_type(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void
-e1000_phy_init_script(struct e1000_hw *hw)
+static void e1000_phy_init_script(struct e1000_hw *hw)
 {
     u32 ret_val;
     u16 phy_saved_data;
@@ -306,8 +318,7 @@ e1000_phy_init_script(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_set_mac_type(struct e1000_hw *hw)
+s32 e1000_set_mac_type(struct e1000_hw *hw)
 {
 	DEBUGFUNC("e1000_set_mac_type");
 
@@ -474,8 +485,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  * **************************************************************************/
-void
-e1000_set_media_type(struct e1000_hw *hw)
+void e1000_set_media_type(struct e1000_hw *hw)
 {
     u32 status;
 
@@ -528,8 +538,7 @@ e1000_set_media_type(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_reset_hw(struct e1000_hw *hw)
+s32 e1000_reset_hw(struct e1000_hw *hw)
 {
     u32 ctrl;
     u32 ctrl_ext;
@@ -747,8 +756,7 @@ e1000_reset_hw(struct e1000_hw *hw)
  * This function contains hardware limitation workarounds for PCI-E adapters
  *
  *****************************************************************************/
-static void
-e1000_initialize_hardware_bits(struct e1000_hw *hw)
+static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
 {
     if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
         /* Settings common to all PCI-express silicon */
@@ -866,8 +874,7 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
  * configuration and flow control settings. Clears all on-chip counters. Leaves
  * the transmit and receive units disabled and uninitialized.
  *****************************************************************************/
-s32
-e1000_init_hw(struct e1000_hw *hw)
+s32 e1000_init_hw(struct e1000_hw *hw)
 {
     u32 ctrl;
     u32 i;
@@ -1054,8 +1061,7 @@ e1000_init_hw(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code.
  *****************************************************************************/
-static s32
-e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
+static s32 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 {
     u16 eeprom_data;
     s32  ret_val;
@@ -1100,8 +1106,7 @@ e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
  * established. Assumes the hardware has previously been reset and the
  * transmitter and receiver are not enabled.
  *****************************************************************************/
-s32
-e1000_setup_link(struct e1000_hw *hw)
+s32 e1000_setup_link(struct e1000_hw *hw)
 {
     u32 ctrl_ext;
     s32 ret_val;
@@ -1233,8 +1238,7 @@ e1000_setup_link(struct e1000_hw *hw)
  * link. Assumes the hardware has been previously reset and the transmitter
  * and receiver are not enabled.
  *****************************************************************************/
-static s32
-e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
+static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
     u32 ctrl;
     u32 status;
@@ -1380,8 +1384,7 @@ e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_copper_link_preconfig(struct e1000_hw *hw)
+static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
 {
     u32 ctrl;
     s32 ret_val;
@@ -1440,8 +1443,7 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static s32
-e1000_copper_link_igp_setup(struct e1000_hw *hw)
+static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 {
     u32 led_ctrl;
     s32 ret_val;
@@ -1587,8 +1589,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static s32
-e1000_copper_link_ggp_setup(struct e1000_hw *hw)
+static s32 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 phy_data;
@@ -1735,8 +1736,7 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static s32
-e1000_copper_link_mgp_setup(struct e1000_hw *hw)
+static s32 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 phy_data;
@@ -1839,8 +1839,7 @@ e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static s32
-e1000_copper_link_autoneg(struct e1000_hw *hw)
+static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 phy_data;
@@ -1910,8 +1909,7 @@ e1000_copper_link_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_copper_link_postconfig(struct e1000_hw *hw)
+static s32 e1000_copper_link_postconfig(struct e1000_hw *hw)
 {
     s32 ret_val;
     DEBUGFUNC("e1000_copper_link_postconfig");
@@ -1948,8 +1946,7 @@ e1000_copper_link_postconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_setup_copper_link(struct e1000_hw *hw)
+static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 i;
@@ -2062,8 +2059,7 @@ e1000_setup_copper_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
+static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
 {
     s32 ret_val = E1000_SUCCESS;
     u32 tipg;
@@ -2098,8 +2094,7 @@ e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
     return ret_val;
 }
 
-static s32
-e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
+static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 {
     s32 ret_val = E1000_SUCCESS;
     u16 reg_data;
@@ -2135,8 +2130,7 @@ e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-s32
-e1000_phy_setup_autoneg(struct e1000_hw *hw)
+s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 mii_autoneg_adv_reg;
@@ -2284,8 +2278,7 @@ e1000_phy_setup_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_phy_force_speed_duplex(struct e1000_hw *hw)
+static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
     u32 ctrl;
     s32 ret_val;
@@ -2535,8 +2528,7 @@ e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 * Link should have been established previously. Reads the speed and duplex
 * information from the Device Status register.
 ******************************************************************************/
-void
-e1000_config_collision_dist(struct e1000_hw *hw)
+void e1000_config_collision_dist(struct e1000_hw *hw)
 {
     u32 tctl, coll_dist;
 
@@ -2565,8 +2557,7 @@ e1000_config_collision_dist(struct e1000_hw *hw)
 * The contents of the PHY register containing the needed information need to
 * be passed in.
 ******************************************************************************/
-static s32
-e1000_config_mac_to_phy(struct e1000_hw *hw)
+static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
     u32 ctrl;
     s32 ret_val;
@@ -2624,8 +2615,7 @@ e1000_config_mac_to_phy(struct e1000_hw *hw)
  * by the PHY rather than the MAC. Software must also configure these
  * bits when link is forced on a fiber connection.
  *****************************************************************************/
-s32
-e1000_force_mac_fc(struct e1000_hw *hw)
+s32 e1000_force_mac_fc(struct e1000_hw *hw)
 {
     u32 ctrl;
 
@@ -2691,8 +2681,7 @@ e1000_force_mac_fc(struct e1000_hw *hw)
  * based on the flow control negotiated by the PHY. In TBI mode, the TFCE
  * and RFCE bits will be automaticaly set to the negotiated flow control mode.
  *****************************************************************************/
-static s32
-e1000_config_fc_after_link_up(struct e1000_hw *hw)
+static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 mii_status_reg;
@@ -2896,8 +2885,7 @@ e1000_config_fc_after_link_up(struct e1000_hw *hw)
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-s32
-e1000_check_for_link(struct e1000_hw *hw)
+s32 e1000_check_for_link(struct e1000_hw *hw)
 {
     u32 rxcw = 0;
     u32 ctrl;
@@ -3132,10 +3120,7 @@ e1000_check_for_link(struct e1000_hw *hw)
  * speed - Speed of the connection
  * duplex - Duplex setting of the connection
  *****************************************************************************/
-s32
-e1000_get_speed_and_duplex(struct e1000_hw *hw,
-                           u16 *speed,
-                           u16 *duplex)
+s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
 {
     u32 status;
     s32 ret_val;
@@ -3214,8 +3199,7 @@ e1000_get_speed_and_duplex(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_wait_autoneg(struct e1000_hw *hw)
+static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 i;
@@ -3249,9 +3233,7 @@ e1000_wait_autoneg(struct e1000_hw *hw)
 * hw - Struct containing variables accessed by shared code
 * ctrl - Device control register's current value
 ******************************************************************************/
-static void
-e1000_raise_mdi_clk(struct e1000_hw *hw,
-                    u32 *ctrl)
+static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl)
 {
     /* Raise the clock input to the Management Data Clock (by setting the MDC
      * bit), and then delay 10 microseconds.
@@ -3267,9 +3249,7 @@ e1000_raise_mdi_clk(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * ctrl - Device control register's current value
 ******************************************************************************/
-static void
-e1000_lower_mdi_clk(struct e1000_hw *hw,
-                    u32 *ctrl)
+static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl)
 {
     /* Lower the clock input to the Management Data Clock (by clearing the MDC
      * bit), and then delay 10 microseconds.
@@ -3288,10 +3268,7 @@ e1000_lower_mdi_clk(struct e1000_hw *hw,
 *
 * Bits are shifted out in MSB to LSB order.
 ******************************************************************************/
-static void
-e1000_shift_out_mdi_bits(struct e1000_hw *hw,
-                         u32 data,
-                         u16 count)
+static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data, u16 count)
 {
     u32 ctrl;
     u32 mask;
@@ -3338,8 +3315,7 @@ e1000_shift_out_mdi_bits(struct e1000_hw *hw,
 *
 * Bits are shifted in in MSB to LSB order.
 ******************************************************************************/
-static u16
-e1000_shift_in_mdi_bits(struct e1000_hw *hw)
+static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 {
     u32 ctrl;
     u16 data = 0;
@@ -3384,8 +3360,7 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
     return data;
 }
 
-static s32
-e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
+static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 {
     u32 swfw_sync = 0;
     u32 swmask = mask;
@@ -3428,8 +3403,7 @@ e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
     return E1000_SUCCESS;
 }
 
-static void
-e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
+static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 {
     u32 swfw_sync;
     u32 swmask = mask;
@@ -3464,10 +3438,7 @@ e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 * hw - Struct containing variables accessed by shared code
 * reg_addr - address of the PHY register to read
 ******************************************************************************/
-s32
-e1000_read_phy_reg(struct e1000_hw *hw,
-                   u32 reg_addr,
-                   u16 *phy_data)
+s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 {
     u32 ret_val;
     u16 swfw;
@@ -3523,9 +3494,8 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     return ret_val;
 }
 
-static s32
-e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
-                      u16 *phy_data)
+static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+				 u16 *phy_data)
 {
     u32 i;
     u32 mdic = 0;
@@ -3603,9 +3573,7 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 * reg_addr - address of the PHY register to write
 * data - data to write to the PHY
 ******************************************************************************/
-s32
-e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
-                    u16 phy_data)
+s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
 {
     u32 ret_val;
     u16 swfw;
@@ -3661,9 +3629,8 @@ e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
     return ret_val;
 }
 
-static s32
-e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
-                       u16 phy_data)
+static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+				  u16 phy_data)
 {
     u32 i;
     u32 mdic = 0;
@@ -3723,10 +3690,7 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
     return E1000_SUCCESS;
 }
 
-static s32
-e1000_read_kmrn_reg(struct e1000_hw *hw,
-                    u32 reg_addr,
-                    u16 *data)
+static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data)
 {
     u32 reg_val;
     u16 swfw;
@@ -3756,10 +3720,7 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
     return E1000_SUCCESS;
 }
 
-static s32
-e1000_write_kmrn_reg(struct e1000_hw *hw,
-                     u32 reg_addr,
-                     u16 data)
+static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data)
 {
     u32 reg_val;
     u16 swfw;
@@ -3788,8 +3749,7 @@ e1000_write_kmrn_reg(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-s32
-e1000_phy_hw_reset(struct e1000_hw *hw)
+s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
     u32 ctrl, ctrl_ext;
     u32 led_ctrl;
@@ -3882,8 +3842,7 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
 *
 * Sets bit 15 of the MII Control register
 ******************************************************************************/
-s32
-e1000_phy_reset(struct e1000_hw *hw)
+s32 e1000_phy_reset(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 phy_data;
@@ -3934,8 +3893,7 @@ e1000_phy_reset(struct e1000_hw *hw)
 *
 * hw - struct containing variables accessed by shared code
 ******************************************************************************/
-void
-e1000_phy_powerdown_workaround(struct e1000_hw *hw)
+void e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 {
     s32 reg;
     u16 phy_data;
@@ -3987,8 +3945,7 @@ e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 *
 * hw - struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
+static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 {
     s32 ret_val;
     s32 reg;
@@ -4040,8 +3997,7 @@ e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_detect_gig_phy(struct e1000_hw *hw)
+static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     s32 phy_init_status, ret_val;
     u16 phy_id_high, phy_id_low;
@@ -4136,8 +4092,7 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static s32
-e1000_phy_reset_dsp(struct e1000_hw *hw)
+static s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
     s32 ret_val;
     DEBUGFUNC("e1000_phy_reset_dsp");
@@ -4163,9 +4118,8 @@ e1000_phy_reset_dsp(struct e1000_hw *hw)
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static s32
-e1000_phy_igp_get_info(struct e1000_hw *hw,
-                       struct e1000_phy_info *phy_info)
+static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info)
 {
     s32 ret_val;
     u16 phy_data, min_length, max_length, average;
@@ -4240,9 +4194,8 @@ e1000_phy_igp_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static s32
-e1000_phy_ife_get_info(struct e1000_hw *hw,
-                       struct e1000_phy_info *phy_info)
+static s32 e1000_phy_ife_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info)
 {
     s32 ret_val;
     u16 phy_data;
@@ -4290,9 +4243,8 @@ e1000_phy_ife_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static s32
-e1000_phy_m88_get_info(struct e1000_hw *hw,
-                       struct e1000_phy_info *phy_info)
+static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
+				  struct e1000_phy_info *phy_info)
 {
     s32 ret_val;
     u16 phy_data;
@@ -4369,9 +4321,7 @@ e1000_phy_m88_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-s32
-e1000_phy_get_info(struct e1000_hw *hw,
-                   struct e1000_phy_info *phy_info)
+s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 {
     s32 ret_val;
     u16 phy_data;
@@ -4415,8 +4365,7 @@ e1000_phy_get_info(struct e1000_hw *hw,
         return e1000_phy_m88_get_info(hw, phy_info);
 }
 
-s32
-e1000_validate_mdi_setting(struct e1000_hw *hw)
+s32 e1000_validate_mdi_setting(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_validate_mdi_settings");
 
@@ -4436,8 +4385,7 @@ e1000_validate_mdi_setting(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_init_eeprom_params(struct e1000_hw *hw)
+s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd = E1000_READ_REG(hw, EECD);
@@ -4626,9 +4574,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  * eecd - EECD's current value
  *****************************************************************************/
-static void
-e1000_raise_ee_clk(struct e1000_hw *hw,
-                   u32 *eecd)
+static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd)
 {
     /* Raise the clock input to the EEPROM (by setting the SK bit), and then
      * wait <delay> microseconds.
@@ -4645,9 +4591,7 @@ e1000_raise_ee_clk(struct e1000_hw *hw,
  * hw - Struct containing variables accessed by shared code
  * eecd - EECD's current value
  *****************************************************************************/
-static void
-e1000_lower_ee_clk(struct e1000_hw *hw,
-                   u32 *eecd)
+static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd)
 {
     /* Lower the clock input to the EEPROM (by clearing the SK bit), and then
      * wait 50 microseconds.
@@ -4665,10 +4609,7 @@ e1000_lower_ee_clk(struct e1000_hw *hw,
  * data - data to send to the EEPROM
  * count - number of bits to shift out
  *****************************************************************************/
-static void
-e1000_shift_out_ee_bits(struct e1000_hw *hw,
-                        u16 data,
-                        u16 count)
+static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data, u16 count)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd;
@@ -4718,9 +4659,7 @@ e1000_shift_out_ee_bits(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static u16
-e1000_shift_in_ee_bits(struct e1000_hw *hw,
-                       u16 count)
+static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count)
 {
     u32 eecd;
     u32 i;
@@ -4762,8 +4701,7 @@ e1000_shift_in_ee_bits(struct e1000_hw *hw,
  * Lowers EEPROM clock. Clears input pin. Sets the chip select pin. This
  * function should be called before issuing a command to the EEPROM.
  *****************************************************************************/
-static s32
-e1000_acquire_eeprom(struct e1000_hw *hw)
+static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd, i=0;
@@ -4821,8 +4759,7 @@ e1000_acquire_eeprom(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void
-e1000_standby_eeprom(struct e1000_hw *hw)
+static void e1000_standby_eeprom(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd;
@@ -4870,8 +4807,7 @@ e1000_standby_eeprom(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void
-e1000_release_eeprom(struct e1000_hw *hw)
+static void e1000_release_eeprom(struct e1000_hw *hw)
 {
     u32 eecd;
 
@@ -4921,8 +4857,7 @@ e1000_release_eeprom(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static s32
-e1000_spi_eeprom_ready(struct e1000_hw *hw)
+static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
     u16 retry_count = 0;
     u8 spi_stat_reg;
@@ -4967,11 +4902,7 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-s32
-e1000_read_eeprom(struct e1000_hw *hw,
-                  u16 offset,
-                  u16 words,
-                  u16 *data)
+s32 e1000_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 i = 0;
@@ -5068,11 +4999,8 @@ e1000_read_eeprom(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static s32
-e1000_read_eeprom_eerd(struct e1000_hw *hw,
-                  u16 offset,
-                  u16 words,
-                  u16 *data)
+static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
     u32 i, eerd = 0;
     s32 error = 0;
@@ -5102,11 +5030,8 @@ e1000_read_eeprom_eerd(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static s32
-e1000_write_eeprom_eewr(struct e1000_hw *hw,
-                   u16 offset,
-                   u16 words,
-                   u16 *data)
+static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
+				   u16 *data)
 {
     u32    register_value = 0;
     u32    i              = 0;
@@ -5143,8 +5068,7 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static s32
-e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
+static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 {
     u32 attempts = 100000;
     u32 i, reg = 0;
@@ -5171,8 +5095,7 @@ e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 *
 * hw - Struct containing variables accessed by shared code
 ****************************************************************************/
-static bool
-e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
+static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 {
     u32 eecd = 0;
 
@@ -5204,8 +5127,7 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
  * If the the sum of the 64 16 bit words is 0xBABA, the EEPROM's checksum is
  * valid.
  *****************************************************************************/
-s32
-e1000_validate_eeprom_checksum(struct e1000_hw *hw)
+s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 {
     u16 checksum = 0;
     u16 i, eeprom_data;
@@ -5268,8 +5190,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
  * Sums the first 63 16 bit words of the EEPROM. Subtracts the sum from 0xBABA.
  * Writes the difference to word offset 63 of the EEPROM.
  *****************************************************************************/
-s32
-e1000_update_eeprom_checksum(struct e1000_hw *hw)
+s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
     u32 ctrl_ext;
     u16 checksum = 0;
@@ -5313,11 +5234,7 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
  * If e1000_update_eeprom_checksum is not called after this function, the
  * EEPROM will most likely contain an invalid checksum.
  *****************************************************************************/
-s32
-e1000_write_eeprom(struct e1000_hw *hw,
-                   u16 offset,
-                   u16 words,
-                   u16 *data)
+s32 e1000_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     s32 status = 0;
@@ -5370,11 +5287,8 @@ e1000_write_eeprom(struct e1000_hw *hw,
  * data - pointer to array of 8 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static s32
-e1000_write_eeprom_spi(struct e1000_hw *hw,
-                       u16 offset,
-                       u16 words,
-                       u16 *data)
+static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u16 widx = 0;
@@ -5436,11 +5350,8 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
  * data - pointer to array of 16 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static s32
-e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                             u16 offset,
-                             u16 words,
-                             u16 *data)
+static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
+					u16 words, u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd;
@@ -5523,8 +5434,7 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static s32
-e1000_commit_shadow_ram(struct e1000_hw *hw)
+static s32 e1000_commit_shadow_ram(struct e1000_hw *hw)
 {
     u32 attempts = 100000;
     u32 eecd = 0;
@@ -5687,8 +5597,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_read_mac_addr(struct e1000_hw * hw)
+s32 e1000_read_mac_addr(struct e1000_hw *hw)
 {
     u16 offset;
     u16 eeprom_data, i;
@@ -5731,8 +5640,7 @@ e1000_read_mac_addr(struct e1000_hw * hw)
  * of the receive addresss registers. Clears the multicast table. Assumes
  * the receiver is in reset when the routine is called.
  *****************************************************************************/
-static void
-e1000_init_rx_addrs(struct e1000_hw *hw)
+static void e1000_init_rx_addrs(struct e1000_hw *hw)
 {
     u32 i;
     u32 rar_num;
@@ -5770,9 +5678,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  * mc_addr - the multicast address to hash
  *****************************************************************************/
-u32
-e1000_hash_mc_addr(struct e1000_hw *hw,
-                   u8 *mc_addr)
+u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 {
     u32 hash_value = 0;
 
@@ -5835,9 +5741,7 @@ e1000_hash_mc_addr(struct e1000_hw *hw,
  * hw - Struct containing variables accessed by shared code
  * hash_value - Multicast address hash value
  *****************************************************************************/
-void
-e1000_mta_set(struct e1000_hw *hw,
-              u32 hash_value)
+void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
 {
     u32 hash_bit, hash_reg;
     u32 mta;
@@ -5884,10 +5788,7 @@ e1000_mta_set(struct e1000_hw *hw,
  * addr - Address to put into receive address register
  * index - Receive address register to write
  *****************************************************************************/
-void
-e1000_rar_set(struct e1000_hw *hw,
-              u8 *addr,
-              u32 index)
+void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 {
     u32 rar_low, rar_high;
 
@@ -5942,10 +5843,7 @@ e1000_rar_set(struct e1000_hw *hw,
  * offset - Offset in VLAN filer table to write
  * value - Value to write into VLAN filter table
  *****************************************************************************/
-void
-e1000_write_vfta(struct e1000_hw *hw,
-                 u32 offset,
-                 u32 value)
+void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 {
     u32 temp;
 
@@ -5969,8 +5867,7 @@ e1000_write_vfta(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void
-e1000_clear_vfta(struct e1000_hw *hw)
+static void e1000_clear_vfta(struct e1000_hw *hw)
 {
     u32 offset;
     u32 vfta_value = 0;
@@ -6003,8 +5900,7 @@ e1000_clear_vfta(struct e1000_hw *hw)
     }
 }
 
-static s32
-e1000_id_led_init(struct e1000_hw * hw)
+static s32 e1000_id_led_init(struct e1000_hw *hw)
 {
     u32 ledctl;
     const u32 ledctl_mask = 0x000000FF;
@@ -6086,8 +5982,7 @@ e1000_id_led_init(struct e1000_hw * hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_setup_led(struct e1000_hw *hw)
+s32 e1000_setup_led(struct e1000_hw *hw)
 {
     u32 ledctl;
     s32 ret_val = E1000_SUCCESS;
@@ -6145,8 +6040,7 @@ e1000_setup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_blink_led_start(struct e1000_hw *hw)
+s32 e1000_blink_led_start(struct e1000_hw *hw)
 {
     s16  i;
     u32 ledctl_blink = 0;
@@ -6180,8 +6074,7 @@ e1000_blink_led_start(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_cleanup_led(struct e1000_hw *hw)
+s32 e1000_cleanup_led(struct e1000_hw *hw)
 {
     s32 ret_val = E1000_SUCCESS;
 
@@ -6222,8 +6115,7 @@ e1000_cleanup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_led_on(struct e1000_hw *hw)
+s32 e1000_led_on(struct e1000_hw *hw)
 {
     u32 ctrl = E1000_READ_REG(hw, CTRL);
 
@@ -6273,8 +6165,7 @@ e1000_led_on(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-s32
-e1000_led_off(struct e1000_hw *hw)
+s32 e1000_led_off(struct e1000_hw *hw)
 {
     u32 ctrl = E1000_READ_REG(hw, CTRL);
 
@@ -6324,8 +6215,7 @@ e1000_led_off(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void
-e1000_clear_hw_cntrs(struct e1000_hw *hw)
+static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
 {
     volatile u32 temp;
 
@@ -6428,8 +6318,7 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw)
  * current_ifs_val, ifs_min_val, ifs_max_val, ifs_step_size, and ifs_ratio
  * before calling this function.
  *****************************************************************************/
-void
-e1000_reset_adaptive(struct e1000_hw *hw)
+void e1000_reset_adaptive(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_reset_adaptive");
 
@@ -6456,8 +6345,7 @@ e1000_reset_adaptive(struct e1000_hw *hw)
  * tx_packets - Number of transmits since last callback
  * total_collisions - Number of collisions since last callback
  *****************************************************************************/
-void
-e1000_update_adaptive(struct e1000_hw *hw)
+void e1000_update_adaptive(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_update_adaptive");
 
@@ -6492,11 +6380,8 @@ e1000_update_adaptive(struct e1000_hw *hw)
  * frame_len - The length of the frame in question
  * mac_addr - The Ethernet destination address of the frame in question
  *****************************************************************************/
-void
-e1000_tbi_adjust_stats(struct e1000_hw *hw,
-                       struct e1000_hw_stats *stats,
-                       u32 frame_len,
-                       u8 *mac_addr)
+void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
+			    u32 frame_len, u8 *mac_addr)
 {
     u64 carry_bit;
 
@@ -6570,8 +6455,7 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void
-e1000_get_bus_info(struct e1000_hw *hw)
+void e1000_get_bus_info(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 pci_ex_link_status;
@@ -6645,10 +6529,7 @@ e1000_get_bus_info(struct e1000_hw *hw)
  * offset - offset to write to
  * value - value to write
  *****************************************************************************/
-static void
-e1000_write_reg_io(struct e1000_hw *hw,
-                   u32 offset,
-                   u32 value)
+static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value)
 {
     unsigned long io_addr = hw->io_base;
     unsigned long io_data = hw->io_base + 4;
@@ -6672,10 +6553,8 @@ e1000_write_reg_io(struct e1000_hw *hw,
  * register to the minimum and maximum range.
  * For IGP phy's, the function calculates the range by the AGC registers.
  *****************************************************************************/
-static s32
-e1000_get_cable_length(struct e1000_hw *hw,
-                       u16 *min_length,
-                       u16 *max_length)
+static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
+				  u16 *max_length)
 {
     s32 ret_val;
     u16 agc_value = 0;
@@ -6863,9 +6742,8 @@ e1000_get_cable_length(struct e1000_hw *hw,
  * return 0.  If the link speed is 1000 Mbps the polarity status is in the
  * IGP01E1000_PHY_PCS_INIT_REG.
  *****************************************************************************/
-static s32
-e1000_check_polarity(struct e1000_hw *hw,
-                     e1000_rev_polarity *polarity)
+static s32 e1000_check_polarity(struct e1000_hw *hw,
+				e1000_rev_polarity *polarity)
 {
     s32 ret_val;
     u16 phy_data;
@@ -6939,8 +6817,7 @@ e1000_check_polarity(struct e1000_hw *hw,
  * Link Health register.  In IGP this bit is latched high, so the driver must
  * read it immediately after link is established.
  *****************************************************************************/
-static s32
-e1000_check_downshift(struct e1000_hw *hw)
+static s32 e1000_check_downshift(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 phy_data;
@@ -6985,9 +6862,7 @@ e1000_check_downshift(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static s32
-e1000_config_dsp_after_link_change(struct e1000_hw *hw,
-                                   bool link_up)
+static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 {
     s32 ret_val;
     u16 phy_data, phy_saved_data, speed, duplex, i;
@@ -7173,8 +7048,7 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  ****************************************************************************/
-static s32
-e1000_set_phy_mode(struct e1000_hw *hw)
+static s32 e1000_set_phy_mode(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 eeprom_data;
@@ -7218,9 +7092,7 @@ e1000_set_phy_mode(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static s32
-e1000_set_d3_lplu_state(struct e1000_hw *hw,
-                        bool active)
+static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
     u32 phy_ctrl = 0;
     s32 ret_val;
@@ -7348,9 +7220,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
  *
  ****************************************************************************/
 
-static s32
-e1000_set_d0_lplu_state(struct e1000_hw *hw,
-                        bool active)
+static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 {
     u32 phy_ctrl = 0;
     s32 ret_val;
@@ -7439,8 +7309,7 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static s32
-e1000_set_vco_speed(struct e1000_hw *hw)
+static s32 e1000_set_vco_speed(struct e1000_hw *hw)
 {
     s32  ret_val;
     u16 default_page = 0;
@@ -7503,8 +7372,7 @@ e1000_set_vco_speed(struct e1000_hw *hw)
  *
  * returns: - E1000_SUCCESS .
  ****************************************************************************/
-static s32
-e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
+static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer)
 {
     u8 i;
     u32 offset = E1000_MNG_DHCP_COOKIE_OFFSET;
@@ -7530,8 +7398,7 @@ e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
  *            timeout
  *          - E1000_SUCCESS for success.
  ****************************************************************************/
-static s32
-e1000_mng_enable_host_if(struct e1000_hw * hw)
+static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 {
     u32 hicr;
     u8 i;
@@ -7564,9 +7431,8 @@ e1000_mng_enable_host_if(struct e1000_hw * hw)
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static s32
-e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
-                        u16 length, u16 offset, u8 *sum)
+static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length,
+				   u16 offset, u8 *sum)
 {
     u8 *tmp;
     u8 *bufptr = buffer;
@@ -7632,9 +7498,8 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static s32
-e1000_mng_write_cmd_header(struct e1000_hw * hw,
-                           struct e1000_host_mng_command_header * hdr)
+static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
+				      struct e1000_host_mng_command_header *hdr)
 {
     u16 i;
     u8 sum;
@@ -7672,8 +7537,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static s32
-e1000_mng_write_commit(struct e1000_hw * hw)
+static s32 e1000_mng_write_commit(struct e1000_hw *hw)
 {
     u32 hicr;
 
@@ -7690,8 +7554,7 @@ e1000_mng_write_commit(struct e1000_hw * hw)
  *
  * returns  - true when the mode is IAMT or false.
  ****************************************************************************/
-bool
-e1000_check_mng_mode(struct e1000_hw *hw)
+bool e1000_check_mng_mode(struct e1000_hw *hw)
 {
     u32 fwsm;
 
@@ -7712,9 +7575,7 @@ e1000_check_mng_mode(struct e1000_hw *hw)
 /*****************************************************************************
  * This function writes the dhcp info .
  ****************************************************************************/
-s32
-e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
-                          u16 length)
+s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
 {
     s32 ret_val;
     struct e1000_host_mng_command_header hdr;
@@ -7744,8 +7605,7 @@ e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
  *
  * returns  - checksum of buffer contents.
  ****************************************************************************/
-static u8
-e1000_calculate_mng_checksum(char *buffer, u32 length)
+static u8 e1000_calculate_mng_checksum(char *buffer, u32 length)
 {
     u8 sum = 0;
     u32 i;
@@ -7764,8 +7624,7 @@ e1000_calculate_mng_checksum(char *buffer, u32 length)
  *
  * returns  - true for packet filtering or false.
  ****************************************************************************/
-bool
-e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
+bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
     /* called in init as well as watchdog timer functions */
 
@@ -7806,8 +7665,7 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
  * returns: - true/false
  *
  *****************************************************************************/
-u32
-e1000_enable_mng_pass_thru(struct e1000_hw *hw)
+u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 {
     u32 manc;
     u32 fwsm, factps;
@@ -7832,8 +7690,7 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
     return false;
 }
 
-static s32
-e1000_polarity_reversal_workaround(struct e1000_hw *hw)
+static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
     s32 ret_val;
     u16 mii_status_reg;
@@ -7926,8 +7783,7 @@ e1000_polarity_reversal_workaround(struct e1000_hw *hw)
  * returns: - none.
  *
  ***************************************************************************/
-static void
-e1000_set_pci_express_master_disable(struct e1000_hw *hw)
+static void e1000_set_pci_express_master_disable(struct e1000_hw *hw)
 {
     u32 ctrl;
 
@@ -7952,8 +7808,7 @@ e1000_set_pci_express_master_disable(struct e1000_hw *hw)
  *            E1000_SUCCESS master requests disabled.
  *
  ******************************************************************************/
-s32
-e1000_disable_pciex_master(struct e1000_hw *hw)
+s32 e1000_disable_pciex_master(struct e1000_hw *hw)
 {
     s32 timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
 
@@ -7990,8 +7845,7 @@ e1000_disable_pciex_master(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ******************************************************************************/
-static s32
-e1000_get_auto_rd_done(struct e1000_hw *hw)
+static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
     s32 timeout = AUTO_READ_DONE_TIMEOUT;
 
@@ -8038,8 +7892,7 @@ e1000_get_auto_rd_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static s32
-e1000_get_phy_cfg_done(struct e1000_hw *hw)
+static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
     s32 timeout = PHY_CFG_TIMEOUT;
     u32 cfg_mask = E1000_EEPROM_CFG_DONE;
@@ -8085,8 +7938,7 @@ e1000_get_phy_cfg_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static s32
-e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
+static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
     s32 timeout;
     u32 swsm;
@@ -8135,8 +7987,7 @@ e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
  * returns: - None.
  *
  ***************************************************************************/
-static void
-e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
+static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
     u32 swsm;
 
@@ -8164,8 +8015,7 @@ e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static s32
-e1000_get_software_semaphore(struct e1000_hw *hw)
+static s32 e1000_get_software_semaphore(struct e1000_hw *hw)
 {
     s32 timeout = hw->eeprom.word_size + 1;
     u32 swsm;
@@ -8200,8 +8050,7 @@ e1000_get_software_semaphore(struct e1000_hw *hw)
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-static void
-e1000_release_software_semaphore(struct e1000_hw *hw)
+static void e1000_release_software_semaphore(struct e1000_hw *hw)
 {
     u32 swsm;
 
@@ -8228,8 +8077,7 @@ e1000_release_software_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS
  *
  *****************************************************************************/
-s32
-e1000_check_phy_reset_block(struct e1000_hw *hw)
+s32 e1000_check_phy_reset_block(struct e1000_hw *hw)
 {
     u32 manc = 0;
     u32 fwsm = 0;
@@ -8246,8 +8094,7 @@ e1000_check_phy_reset_block(struct e1000_hw *hw)
         E1000_BLK_PHY_RESET : E1000_SUCCESS;
 }
 
-static u8
-e1000_arc_subsystem_valid(struct e1000_hw *hw)
+static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw)
 {
     u32 fwsm;
 
@@ -8283,8 +8130,7 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
  * returns: E1000_SUCCESS
  *
  *****************************************************************************/
-static s32
-e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
+static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
 {
     u32 gcr_reg = 0;
 
@@ -8324,8 +8170,7 @@ e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-static s32
-e1000_get_software_flag(struct e1000_hw *hw)
+static s32 e1000_get_software_flag(struct e1000_hw *hw)
 {
     s32 timeout = PHY_CFG_TIMEOUT;
     u32 extcnf_ctrl;
@@ -8363,8 +8208,7 @@ e1000_get_software_flag(struct e1000_hw *hw)
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-static void
-e1000_release_software_flag(struct e1000_hw *hw)
+static void e1000_release_software_flag(struct e1000_hw *hw)
 {
     u32 extcnf_ctrl;
 
@@ -8388,9 +8232,8 @@ e1000_release_software_flag(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static s32
-e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-                       u16 *data)
+static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
     s32  error = E1000_SUCCESS;
     u32 flash_bank = 0;
@@ -8444,9 +8287,8 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
  * words - number of words to write
  * data - words to write to the EEPROM
  *****************************************************************************/
-static s32
-e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-                        u16 *data)
+static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+				   u16 *data)
 {
     u32 i = 0;
     s32 error = E1000_SUCCESS;
@@ -8491,8 +8333,7 @@ e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static s32
-e1000_ich8_cycle_init(struct e1000_hw *hw)
+static s32 e1000_ich8_cycle_init(struct e1000_hw *hw)
 {
     union ich8_hws_flash_status hsfsts;
     s32 error = E1000_ERR_EEPROM;
@@ -8558,8 +8399,7 @@ e1000_ich8_cycle_init(struct e1000_hw *hw)
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static s32
-e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
+static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
 {
     union ich8_hws_flash_ctrl hsflctl;
     union ich8_hws_flash_status hsfsts;
@@ -8593,9 +8433,8 @@ e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
  * size - Size of data to read, 1=byte 2=word
  * data - Pointer to the word to store the value read.
  *****************************************************************************/
-static s32
-e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
-                     u32 size, u16* data)
+static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
+				u16 *data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
@@ -8672,9 +8511,8 @@ e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
  * size - Size of data to read, 1=byte 2=word
  * data - The byte(s) to write to the NVM.
  *****************************************************************************/
-static s32
-e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
-                      u16 data)
+static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
+				 u16 data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
@@ -8747,8 +8585,7 @@ e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
  * index - The index of the byte to read.
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
-static s32
-e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
+static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data)
 {
     s32 status = E1000_SUCCESS;
     u16 word = 0;
@@ -8770,8 +8607,7 @@ e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
  * index - The index of the byte to write.
  * byte - The byte to write to the NVM.
  *****************************************************************************/
-static s32
-e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
+static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
 {
     s32 error = E1000_SUCCESS;
     s32 program_retries = 0;
@@ -8803,8 +8639,7 @@ e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
  * index - The index of the byte to read.
  * data - The byte to write to the NVM.
  *****************************************************************************/
-static s32
-e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
+static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
 {
     s32 status = E1000_SUCCESS;
     u16 word = (u16)data;
@@ -8821,8 +8656,7 @@ e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
  * index - The starting byte index of the word to read.
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
-static s32
-e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
+static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
 {
     s32 status = E1000_SUCCESS;
     status = e1000_read_ich8_data(hw, index, 2, data);
@@ -8840,8 +8674,7 @@ e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
  * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-static s32
-e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
+static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
@@ -8930,9 +8763,9 @@ e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
     return error;
 }
 
-static s32
-e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
-                                      u32 cnf_base_addr, u32 cnf_size)
+static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
+						 u32 cnf_base_addr,
+						 u32 cnf_size)
 {
     u32 ret_val = E1000_SUCCESS;
     u16 word_addr, reg_data, reg_addr;
@@ -8972,8 +8805,7 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
  *
  * hw: Struct containing variables accessed by shared code
  *****************************************************************************/
-static s32
-e1000_init_lcd_from_nvm(struct e1000_hw *hw)
+static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
     u32 reg_data, cnf_base_addr, cnf_size, ret_val, loop;
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7aa458f..09abaec 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -232,8 +232,7 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
  * loaded. All it does is register with the PCI subsystem.
  **/
 
-static int __init
-e1000_init_module(void)
+static int __init e1000_init_module(void)
 {
 	int ret;
 	printk(KERN_INFO "%s - version %s\n",
@@ -261,8 +260,7 @@ module_init(e1000_init_module);
  * from memory.
  **/
 
-static void __exit
-e1000_exit_module(void)
+static void __exit e1000_exit_module(void)
 {
 	pci_unregister_driver(&e1000_driver);
 }
@@ -311,8 +309,7 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
  * @adapter: board private structure
  **/
 
-static void
-e1000_irq_disable(struct e1000_adapter *adapter)
+static void e1000_irq_disable(struct e1000_adapter *adapter)
 {
 	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
 	E1000_WRITE_FLUSH(&adapter->hw);
@@ -324,15 +321,13 @@ e1000_irq_disable(struct e1000_adapter *adapter)
  * @adapter: board private structure
  **/
 
-static void
-e1000_irq_enable(struct e1000_adapter *adapter)
+static void e1000_irq_enable(struct e1000_adapter *adapter)
 {
 	E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
 	E1000_WRITE_FLUSH(&adapter->hw);
 }
 
-static void
-e1000_update_mng_vlan(struct e1000_adapter *adapter)
+static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u16 vid = adapter->hw.mng_cookie.vlan_id;
@@ -366,8 +361,7 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
  *
  **/
 
-static void
-e1000_release_hw_control(struct e1000_adapter *adapter)
+static void e1000_release_hw_control(struct e1000_adapter *adapter)
 {
 	u32 ctrl_ext;
 	u32 swsm;
@@ -403,8 +397,7 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
  *
  **/
 
-static void
-e1000_get_hw_control(struct e1000_adapter *adapter)
+static void e1000_get_hw_control(struct e1000_adapter *adapter)
 {
 	u32 ctrl_ext;
 	u32 swsm;
@@ -429,8 +422,7 @@ e1000_get_hw_control(struct e1000_adapter *adapter)
 	}
 }
 
-static void
-e1000_init_manageability(struct e1000_adapter *adapter)
+static void e1000_init_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
 		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
@@ -456,8 +448,7 @@ e1000_init_manageability(struct e1000_adapter *adapter)
 	}
 }
 
-static void
-e1000_release_manageability(struct e1000_adapter *adapter)
+static void e1000_release_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
 		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
@@ -591,8 +582,7 @@ out:
 	return;
 }
 
-void
-e1000_down(struct e1000_adapter *adapter)
+void e1000_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -620,8 +610,7 @@ e1000_down(struct e1000_adapter *adapter)
 	e1000_clean_all_rx_rings(adapter);
 }
 
-void
-e1000_reinit_locked(struct e1000_adapter *adapter)
+void e1000_reinit_locked(struct e1000_adapter *adapter)
 {
 	WARN_ON(in_interrupt());
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
@@ -631,8 +620,7 @@ e1000_reinit_locked(struct e1000_adapter *adapter)
 	clear_bit(__E1000_RESETTING, &adapter->flags);
 }
 
-void
-e1000_reset(struct e1000_adapter *adapter)
+void e1000_reset(struct e1000_adapter *adapter)
 {
 	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
 	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
@@ -1231,8 +1219,7 @@ err_dma:
  * memory.
  **/
 
-static void __devexit
-e1000_remove(struct pci_dev *pdev)
+static void __devexit e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1283,8 +1270,7 @@ e1000_remove(struct pci_dev *pdev)
  * OS network device settings (MTU size).
  **/
 
-static int __devinit
-e1000_sw_init(struct e1000_adapter *adapter)
+static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -1377,8 +1363,7 @@ e1000_sw_init(struct e1000_adapter *adapter)
  * intended for Multiqueue, but should work fine with a single queue.
  **/
 
-static int __devinit
-e1000_alloc_queues(struct e1000_adapter *adapter)
+static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 {
 	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
 	                           sizeof(struct e1000_tx_ring), GFP_KERNEL);
@@ -1419,8 +1404,7 @@ e1000_alloc_queues(struct e1000_adapter *adapter)
  * and the stack is notified that the interface is ready.
  **/
 
-static int
-e1000_open(struct net_device *netdev)
+static int e1000_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int err;
@@ -1501,8 +1485,7 @@ err_setup_tx:
  * hardware, and all transmit and receive resources are freed.
  **/
 
-static int
-e1000_close(struct net_device *netdev)
+static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -1538,9 +1521,8 @@ e1000_close(struct net_device *netdev)
  * @start: address of beginning of memory
  * @len: length of memory
  **/
-static bool
-e1000_check_64k_bound(struct e1000_adapter *adapter,
-		      void *start, unsigned long len)
+static bool e1000_check_64k_bound(struct e1000_adapter *adapter, void *start,
+				  unsigned long len)
 {
 	unsigned long begin = (unsigned long) start;
 	unsigned long end = begin + len;
@@ -1563,9 +1545,8 @@ e1000_check_64k_bound(struct e1000_adapter *adapter,
  * Return 0 on success, negative on failure
  **/
 
-static int
-e1000_setup_tx_resources(struct e1000_adapter *adapter,
-                         struct e1000_tx_ring *txdr)
+static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
+				    struct e1000_tx_ring *txdr)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
@@ -1639,8 +1620,7 @@ setup_tx_desc_die:
  * Return 0 on success, negative on failure
  **/
 
-int
-e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
+int e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 {
 	int i, err = 0;
 
@@ -1666,8 +1646,7 @@ e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
  * Configure the Tx unit of the MAC after a reset.
  **/
 
-static void
-e1000_configure_tx(struct e1000_adapter *adapter)
+static void e1000_configure_tx(struct e1000_adapter *adapter)
 {
 	u64 tdba;
 	struct e1000_hw *hw = &adapter->hw;
@@ -1780,9 +1759,8 @@ e1000_configure_tx(struct e1000_adapter *adapter)
  * Returns 0 on success, negative on failure
  **/
 
-static int
-e1000_setup_rx_resources(struct e1000_adapter *adapter,
-                         struct e1000_rx_ring *rxdr)
+static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
+				    struct e1000_rx_ring *rxdr)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size, desc_len;
@@ -1885,8 +1863,7 @@ setup_rx_desc_die:
  * Return 0 on success, negative on failure
  **/
 
-int
-e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
+int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 {
 	int i, err = 0;
 
@@ -1911,8 +1888,7 @@ e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
  **/
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
 			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
-static void
-e1000_setup_rctl(struct e1000_adapter *adapter)
+static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	u32 rctl, rfctl;
 	u32 psrctl = 0;
@@ -2029,8 +2005,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
  * Configure the Rx unit of the MAC after a reset.
  **/
 
-static void
-e1000_configure_rx(struct e1000_adapter *adapter)
+static void e1000_configure_rx(struct e1000_adapter *adapter)
 {
 	u64 rdba;
 	struct e1000_hw *hw = &adapter->hw;
@@ -2129,9 +2104,8 @@ e1000_configure_rx(struct e1000_adapter *adapter)
  * Free all transmit software resources
  **/
 
-static void
-e1000_free_tx_resources(struct e1000_adapter *adapter,
-                        struct e1000_tx_ring *tx_ring)
+static void e1000_free_tx_resources(struct e1000_adapter *adapter,
+				    struct e1000_tx_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -2152,8 +2126,7 @@ e1000_free_tx_resources(struct e1000_adapter *adapter,
  * Free all transmit software resources
  **/
 
-void
-e1000_free_all_tx_resources(struct e1000_adapter *adapter)
+void e1000_free_all_tx_resources(struct e1000_adapter *adapter)
 {
 	int i;
 
@@ -2161,9 +2134,8 @@ e1000_free_all_tx_resources(struct e1000_adapter *adapter)
 		e1000_free_tx_resources(adapter, &adapter->tx_ring[i]);
 }
 
-static void
-e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
-			struct e1000_buffer *buffer_info)
+static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
+					     struct e1000_buffer *buffer_info)
 {
 	if (buffer_info->dma) {
 		pci_unmap_page(adapter->pdev,
@@ -2185,9 +2157,8 @@ e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
  * @tx_ring: ring to be cleaned
  **/
 
-static void
-e1000_clean_tx_ring(struct e1000_adapter *adapter,
-                    struct e1000_tx_ring *tx_ring)
+static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
+				struct e1000_tx_ring *tx_ring)
 {
 	struct e1000_buffer *buffer_info;
 	unsigned long size;
@@ -2220,8 +2191,7 @@ e1000_clean_tx_ring(struct e1000_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static void
-e1000_clean_all_tx_rings(struct e1000_adapter *adapter)
+static void e1000_clean_all_tx_rings(struct e1000_adapter *adapter)
 {
 	int i;
 
@@ -2237,9 +2207,8 @@ e1000_clean_all_tx_rings(struct e1000_adapter *adapter)
  * Free all receive software resources
  **/
 
-static void
-e1000_free_rx_resources(struct e1000_adapter *adapter,
-                        struct e1000_rx_ring *rx_ring)
+static void e1000_free_rx_resources(struct e1000_adapter *adapter,
+				    struct e1000_rx_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -2264,8 +2233,7 @@ e1000_free_rx_resources(struct e1000_adapter *adapter,
  * Free all receive software resources
  **/
 
-void
-e1000_free_all_rx_resources(struct e1000_adapter *adapter)
+void e1000_free_all_rx_resources(struct e1000_adapter *adapter)
 {
 	int i;
 
@@ -2279,9 +2247,8 @@ e1000_free_all_rx_resources(struct e1000_adapter *adapter)
  * @rx_ring: ring to free buffers from
  **/
 
-static void
-e1000_clean_rx_ring(struct e1000_adapter *adapter,
-                    struct e1000_rx_ring *rx_ring)
+static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
+				struct e1000_rx_ring *rx_ring)
 {
 	struct e1000_buffer *buffer_info;
 	struct e1000_ps_page *ps_page;
@@ -2338,8 +2305,7 @@ e1000_clean_rx_ring(struct e1000_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static void
-e1000_clean_all_rx_rings(struct e1000_adapter *adapter)
+static void e1000_clean_all_rx_rings(struct e1000_adapter *adapter)
 {
 	int i;
 
@@ -2350,8 +2316,7 @@ e1000_clean_all_rx_rings(struct e1000_adapter *adapter)
 /* The 82542 2.0 (revision 2) needs to have the receive unit in reset
  * and memory write and invalidate disabled for certain operations
  */
-static void
-e1000_enter_82542_rst(struct e1000_adapter *adapter)
+static void e1000_enter_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl;
@@ -2368,8 +2333,7 @@ e1000_enter_82542_rst(struct e1000_adapter *adapter)
 		e1000_clean_all_rx_rings(adapter);
 }
 
-static void
-e1000_leave_82542_rst(struct e1000_adapter *adapter)
+static void e1000_leave_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl;
@@ -2399,8 +2363,7 @@ e1000_leave_82542_rst(struct e1000_adapter *adapter)
  * Returns 0 on success, negative on failure
  **/
 
-static int
-e1000_set_mac(struct net_device *netdev, void *p)
+static int e1000_set_mac(struct net_device *netdev, void *p)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
@@ -2450,8 +2413,7 @@ e1000_set_mac(struct net_device *netdev, void *p)
  * promiscuous mode, and all-multi behavior.
  **/
 
-static void
-e1000_set_rx_mode(struct net_device *netdev)
+static void e1000_set_rx_mode(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -2545,8 +2507,7 @@ e1000_set_rx_mode(struct net_device *netdev)
 /* Need to wait a few seconds after link up to get diagnostic information from
  * the phy */
 
-static void
-e1000_update_phy_info(unsigned long data)
+static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
@@ -2557,8 +2518,7 @@ e1000_update_phy_info(unsigned long data)
  * @data: pointer to adapter cast into an unsigned long
  **/
 
-static void
-e1000_82547_tx_fifo_stall(unsigned long data)
+static void e1000_82547_tx_fifo_stall(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
@@ -2598,8 +2558,7 @@ e1000_82547_tx_fifo_stall(unsigned long data)
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void
-e1000_watchdog(unsigned long data)
+static void e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
@@ -2799,9 +2758,7 @@ enum latency_range {
  * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
-                                   u16 itr_setting,
-                                   int packets,
-                                   int bytes)
+				     u16 itr_setting, int packets, int bytes)
 {
 	unsigned int retval = itr_setting;
 	struct e1000_hw *hw = &adapter->hw;
@@ -2919,9 +2876,8 @@ set_itr_now:
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
-static int
-e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
-          struct sk_buff *skb)
+static int e1000_tso(struct e1000_adapter *adapter,
+		     struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
 {
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
@@ -2992,9 +2948,8 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	return false;
 }
 
-static bool
-e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
-              struct sk_buff *skb)
+static bool e1000_tx_csum(struct e1000_adapter *adapter,
+			  struct e1000_tx_ring *tx_ring, struct sk_buff *skb)
 {
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
@@ -3031,10 +2986,11 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 #define E1000_MAX_TXD_PWR	12
 #define E1000_MAX_DATA_PER_TXD	(1<<E1000_MAX_TXD_PWR)
 
-static int
-e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
-             struct sk_buff *skb, unsigned int first, unsigned int max_per_txd,
-             unsigned int nr_frags, unsigned int mss)
+static int e1000_tx_map(struct e1000_adapter *adapter,
+			struct e1000_tx_ring *tx_ring,
+			struct sk_buff *skb, unsigned int first,
+			unsigned int max_per_txd, unsigned int nr_frags,
+			unsigned int mss)
 {
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb->len;
@@ -3138,9 +3094,9 @@ e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	return count;
 }
 
-static void
-e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
-               int tx_flags, int count)
+static void e1000_tx_queue(struct e1000_adapter *adapter,
+			   struct e1000_tx_ring *tx_ring, int tx_flags,
+			   int count)
 {
 	struct e1000_tx_desc *tx_desc = NULL;
 	struct e1000_buffer *buffer_info;
@@ -3205,8 +3161,8 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 #define E1000_FIFO_HDR			0x10
 #define E1000_82547_PAD_LEN		0x3E0
 
-static int
-e1000_82547_fifo_workaround(struct e1000_adapter *adapter, struct sk_buff *skb)
+static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
+				       struct sk_buff *skb)
 {
 	u32 fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
 	u32 skb_fifo_len = skb->len + E1000_FIFO_HDR;
@@ -3232,8 +3188,8 @@ no_fifo_stall_required:
 }
 
 #define MINIMUM_DHCP_PACKET_SIZE 282
-static int
-e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
+static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
+				    struct sk_buff *skb)
 {
 	struct e1000_hw *hw =  &adapter->hw;
 	u16 length, offset;
@@ -3297,8 +3253,7 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int
-e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_tx_ring *tx_ring;
@@ -3475,8 +3430,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
  * @netdev: network interface device structure
  **/
 
-static void
-e1000_tx_timeout(struct net_device *netdev)
+static void e1000_tx_timeout(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -3485,8 +3439,7 @@ e1000_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->reset_task);
 }
 
-static void
-e1000_reset_task(struct work_struct *work)
+static void e1000_reset_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter =
 		container_of(work, struct e1000_adapter, reset_task);
@@ -3502,8 +3455,7 @@ e1000_reset_task(struct work_struct *work)
  * The statistics are actually updated from the timer callback.
  **/
 
-static struct net_device_stats *
-e1000_get_stats(struct net_device *netdev)
+static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -3519,8 +3471,7 @@ e1000_get_stats(struct net_device *netdev)
  * Returns 0 on success, negative on failure
  **/
 
-static int
-e1000_change_mtu(struct net_device *netdev, int new_mtu)
+static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
@@ -3613,8 +3564,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
  * @adapter: board private structure
  **/
 
-void
-e1000_update_stats(struct e1000_adapter *adapter)
+void e1000_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -3787,8 +3737,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
  * @data: pointer to a network interface device structure
  **/
 
-static irqreturn_t
-e1000_intr_msi(int irq, void *data)
+static irqreturn_t e1000_intr_msi(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -3849,8 +3798,7 @@ e1000_intr_msi(int irq, void *data)
  * @data: pointer to a network interface device structure
  **/
 
-static irqreturn_t
-e1000_intr(int irq, void *data)
+static irqreturn_t e1000_intr(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -3947,8 +3895,7 @@ e1000_intr(int irq, void *data)
  * @adapter: board private structure
  **/
 
-static int
-e1000_clean(struct napi_struct *napi, int budget)
+static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
@@ -3990,9 +3937,8 @@ e1000_clean(struct napi_struct *napi, int budget)
  * @adapter: board private structure
  **/
 
-static bool
-e1000_clean_tx_irq(struct e1000_adapter *adapter,
-                   struct e1000_tx_ring *tx_ring)
+static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
+			       struct e1000_tx_ring *tx_ring)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc, *eop_desc;
@@ -4104,10 +4050,8 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
  * @sk_buff:     socket buffer with received data
  **/
 
-static void
-e1000_rx_checksum(struct e1000_adapter *adapter,
-		  u32 status_err, u32 csum,
-		  struct sk_buff *skb)
+static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
+			      u32 csum, struct sk_buff *skb)
 {
 	u16 status = (u16)status_err;
 	u8 errors = (u8)(status_err >> 24);
@@ -4151,15 +4095,13 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  **/
-
-static bool
 #ifdef CONFIG_E1000_NAPI
-e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                   struct e1000_rx_ring *rx_ring,
-                   int *work_done, int work_to_do)
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring,
+			       int *work_done, int work_to_do)
 #else
-e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                   struct e1000_rx_ring *rx_ring)
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring)
 #endif
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4323,14 +4265,13 @@ next_desc:
  * @adapter: board private structure
  **/
 
-static bool
 #ifdef CONFIG_E1000_NAPI
-e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                      struct e1000_rx_ring *rx_ring,
-                      int *work_done, int work_to_do)
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring,
+				  int *work_done, int work_to_do)
 #else
-e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                      struct e1000_rx_ring *rx_ring)
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring)
 #endif
 {
 	union e1000_rx_desc_packet_split *rx_desc, *next_rxd;
@@ -4510,10 +4451,9 @@ next_desc:
  * @adapter: address of board private structure
  **/
 
-static void
-e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
-                       struct e1000_rx_ring *rx_ring,
-		       int cleaned_count)
+static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
+				   struct e1000_rx_ring *rx_ring,
+				   int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -4621,10 +4561,9 @@ map_skb:
  * @adapter: address of board private structure
  **/
 
-static void
-e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-                          struct e1000_rx_ring *rx_ring,
-			  int cleaned_count)
+static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
+				      struct e1000_rx_ring *rx_ring,
+				      int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -4719,8 +4658,7 @@ no_buffers:
  * @adapter:
  **/
 
-static void
-e1000_smartspeed(struct e1000_adapter *adapter)
+static void e1000_smartspeed(struct e1000_adapter *adapter)
 {
 	u16 phy_status;
 	u16 phy_ctrl;
@@ -4776,8 +4714,7 @@ e1000_smartspeed(struct e1000_adapter *adapter)
  * @cmd:
  **/
 
-static int
-e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -4796,8 +4733,8 @@ e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
  * @cmd:
  **/
 
-static int
-e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
+			   int cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(ifr);
@@ -4890,8 +4827,7 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return E1000_SUCCESS;
 }
 
-void
-e1000_pci_set_mwi(struct e1000_hw *hw)
+void e1000_pci_set_mwi(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
 	int ret_val = pci_set_mwi(adapter->pdev);
@@ -4900,30 +4836,26 @@ e1000_pci_set_mwi(struct e1000_hw *hw)
 		DPRINTK(PROBE, ERR, "Error in setting MWI\n");
 }
 
-void
-e1000_pci_clear_mwi(struct e1000_hw *hw)
+void e1000_pci_clear_mwi(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
 
 	pci_clear_mwi(adapter->pdev);
 }
 
-int
-e1000_pcix_get_mmrbc(struct e1000_hw *hw)
+int e1000_pcix_get_mmrbc(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
 	return pcix_get_mmrbc(adapter->pdev);
 }
 
-void
-e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
+void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 {
 	struct e1000_adapter *adapter = hw->back;
 	pcix_set_mmrbc(adapter->pdev, mmrbc);
 }
 
-s32
-e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
+s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
     struct e1000_adapter *adapter = hw->back;
     u16 cap_offset;
@@ -4937,14 +4869,13 @@ e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
     return E1000_SUCCESS;
 }
 
-void
-e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
+void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
 {
 	outl(value, port);
 }
 
-static void
-e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
+static void e1000_vlan_rx_register(struct net_device *netdev,
+				   struct vlan_group *grp)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl, rctl;
@@ -4991,8 +4922,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		e1000_irq_enable(adapter);
 }
 
-static void
-e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	u32 vfta, index;
@@ -5008,8 +4938,7 @@ e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	e1000_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void
-e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	u32 vfta, index;
@@ -5035,8 +4964,7 @@ e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	e1000_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void
-e1000_restore_vlan(struct e1000_adapter *adapter)
+static void e1000_restore_vlan(struct e1000_adapter *adapter)
 {
 	e1000_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
@@ -5050,8 +4978,7 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 	}
 }
 
-int
-e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
+int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	adapter->hw.autoneg = 0;
 
@@ -5087,8 +5014,7 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	return 0;
 }
 
-static int
-e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -5185,8 +5111,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 }
 
 #ifdef CONFIG_PM
-static int
-e1000_resume(struct pci_dev *pdev)
+static int e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -5240,8 +5165,7 @@ static void e1000_shutdown(struct pci_dev *pdev)
  * without having to re-enable interrupts. It's not called while
  * the interrupt routine is executing.
  */
-static void
-e1000_netpoll(struct net_device *netdev)
+static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -5262,7 +5186,8 @@ e1000_netpoll(struct net_device *netdev)
  * This function is called after a PCI bus error affecting
  * this device has been detected.
  */
-static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
+static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e6565ce..b9f90a5 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -213,10 +213,9 @@ struct e1000_option {
 	} arg;
 };
 
-static int __devinit
-e1000_validate_option(unsigned int *value,
-		      const struct e1000_option *opt,
-		      struct e1000_adapter *adapter)
+static int __devinit e1000_validate_option(unsigned int *value,
+					   const struct e1000_option *opt,
+					   struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -278,8 +277,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter);
  * in a variable in the adapter structure.
  **/
 
-void __devinit
-e1000_check_options(struct e1000_adapter *adapter)
+void __devinit e1000_check_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (bd >= E1000_MAX_NIC) {
@@ -551,8 +549,7 @@ e1000_check_options(struct e1000_adapter *adapter)
  * Handles speed and duplex options on fiber adapters
  **/
 
-static void __devinit
-e1000_check_fiber_options(struct e1000_adapter *adapter)
+static void __devinit e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (num_Speed > bd) {
@@ -579,8 +576,7 @@ e1000_check_fiber_options(struct e1000_adapter *adapter)
  * Handles speed and duplex options on copper adapters
  **/
 
-static void __devinit
-e1000_check_copper_options(struct e1000_adapter *adapter)
+static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 {
 	unsigned int speed, dplx, an;
 	int bd = adapter->bd_number;

