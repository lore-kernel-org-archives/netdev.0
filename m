From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/9] e1000: Convert boolean_t to bool
Date: Fri, 21 Mar 2008 11:06:25 -0700
Message-ID: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

On Thu, 2008-03-06 at 10:07 -0800, Kok, Auke wrote:
> send me a patch for e1000 and for ixgb and I'll happily apply those :)

boolean_t to bool
TRUE to true
FALSE to false
comment typo ahread to ahead

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |   26 ++--
 drivers/net/e1000/e1000_ethtool.c |   17 +--
 drivers/net/e1000/e1000_hw.c      |  223 ++++++++++++++++++-------------------
 drivers/net/e1000/e1000_hw.h      |   62 +++++-----
 drivers/net/e1000/e1000_main.c    |   90 +++++++--------
 drivers/net/e1000/e1000_osdep.h   |    7 -
 6 files changed, 209 insertions(+), 216 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3b84028..d73a6c1 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -188,7 +188,7 @@ struct e1000_tx_ring {
 	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
-	boolean_t last_tx_tso;
+	bool last_tx_tso;
 };
 
 struct e1000_rx_ring {
@@ -283,17 +283,17 @@ struct e1000_adapter {
 	uint32_t tx_fifo_size;
 	uint8_t  tx_timeout_factor;
 	atomic_t tx_fifo_stall;
-	boolean_t pcix_82544;
-	boolean_t detect_tx_hung;
+	bool pcix_82544;
+	bool detect_tx_hung;
 
 	/* RX */
 #ifdef CONFIG_E1000_NAPI
-	boolean_t (*clean_rx) (struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring,
-			       int *work_done, int work_to_do);
+	bool (*clean_rx) (struct e1000_adapter *adapter,
+			  struct e1000_rx_ring *rx_ring,
+			  int *work_done, int work_to_do);
 #else
-	boolean_t (*clean_rx) (struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring);
+	bool (*clean_rx) (struct e1000_adapter *adapter,
+			  struct e1000_rx_ring *rx_ring);
 #endif
 	void (*alloc_rx_buf) (struct e1000_adapter *adapter,
 			      struct e1000_rx_ring *rx_ring,
@@ -312,7 +312,7 @@ struct e1000_adapter {
 	uint32_t alloc_rx_buff_failed;
 	uint32_t rx_int_delay;
 	uint32_t rx_abs_int_delay;
-	boolean_t rx_csum;
+	bool rx_csum;
 	unsigned int rx_ps_pages;
 	uint32_t gorcl;
 	uint64_t gorcl_old;
@@ -335,12 +335,12 @@ struct e1000_adapter {
 	struct e1000_rx_ring test_rx_ring;
 
 	int msg_enable;
-	boolean_t have_msi;
+	bool have_msi;
 
 	/* to not mess up cache alignment, always add to the bottom */
-	boolean_t tso_force;
-	boolean_t smart_power_down;	/* phy smart power down */
-	boolean_t quad_port_a;
+	bool tso_force;
+	bool smart_power_down;	/* phy smart power down */
+	bool quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
 };
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 85e66f4..05e1fb3 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -353,7 +353,7 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
 		netdev->features &= ~NETIF_F_TSO6;
 
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
-	adapter->tso_force = TRUE;
+	adapter->tso_force = true;
 	return 0;
 }
 
@@ -922,7 +922,8 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t mask, i=0, shared_int = TRUE;
+	uint32_t mask, i = 0;
+	bool shared_int = true;
 	uint32_t irq = adapter->pdev->irq;
 
 	*data = 0;
@@ -931,7 +932,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 	/* Hook up test interrupt handler just for this test */
 	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
 	                 netdev))
-		shared_int = FALSE;
+		shared_int = false;
 	else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
 	         netdev->name, netdev)) {
 		*data = 1;
@@ -1295,7 +1296,7 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	uint32_t ctrl_reg = 0;
 	uint32_t stat_reg = 0;
 
-	adapter->hw.autoneg = FALSE;
+	adapter->hw.autoneg = false;
 
 	if (adapter->hw.phy_type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
@@ -1473,7 +1474,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	case e1000_82545_rev_3:
 	case e1000_82546_rev_3:
 	default:
-		hw->autoneg = TRUE;
+		hw->autoneg = true;
 		if (hw->phy_type == e1000_phy_gg82563)
 			e1000_write_phy_reg(hw,
 					    GG82563_PHY_KMRN_MODE_CTRL,
@@ -1607,13 +1608,13 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		adapter->hw.serdes_link_down = TRUE;
+		adapter->hw.serdes_link_down = true;
 
 		/* On some blade server designs, link establishment
 		 * could take as long as 2-3 minutes */
 		do {
 			e1000_check_for_link(&adapter->hw);
-			if (adapter->hw.serdes_link_down == FALSE)
+			if (!adapter->hw.serdes_link_down)
 				return *data;
 			msleep(20);
 		} while (i++ < 3750);
@@ -1649,7 +1650,7 @@ e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	boolean_t if_running = netif_running(netdev);
+	bool if_running = netif_running(netdev);
 
 	set_bit(__E1000_TESTING, &adapter->flags);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 7c6888c..b642034 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -46,7 +46,8 @@ static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *pol
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
 static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
-static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw, boolean_t link_up);
+static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
+						  bool link_up);
 static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
 static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
@@ -62,7 +63,7 @@ static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32
 static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
-static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
+static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
 static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, uint8_t *buffer, uint16_t length, uint16_t offset, uint8_t *sum);
@@ -84,8 +85,8 @@ static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32
 static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
 static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
-static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, boolean_t active);
-static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, boolean_t active);
+static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
 static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
 static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
@@ -425,22 +426,22 @@ e1000_set_mac_type(struct e1000_hw *hw)
 
 	switch (hw->mac_type) {
 	case e1000_ich8lan:
-		hw->swfwhw_semaphore_present = TRUE;
-		hw->asf_firmware_present = TRUE;
+		hw->swfwhw_semaphore_present = true;
+		hw->asf_firmware_present = true;
 		break;
 	case e1000_80003es2lan:
-		hw->swfw_sync_present = TRUE;
+		hw->swfw_sync_present = true;
 		/* fall through */
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_82573:
-		hw->eeprom_semaphore_present = TRUE;
+		hw->eeprom_semaphore_present = true;
 		/* fall through */
 	case e1000_82541:
 	case e1000_82547:
 	case e1000_82541_rev_2:
 	case e1000_82547_rev_2:
-		hw->asf_firmware_present = TRUE;
+		hw->asf_firmware_present = true;
 		break;
 	default:
 		break;
@@ -450,20 +451,20 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	 * FD mode
 	 */
 	if (hw->mac_type == e1000_82543)
-		hw->bad_tx_carr_stats_fd = TRUE;
+		hw->bad_tx_carr_stats_fd = true;
 
 	/* capable of receiving management packets to the host */
 	if (hw->mac_type >= e1000_82571)
-		hw->has_manc2h = TRUE;
+		hw->has_manc2h = true;
 
 	/* In rare occasions, ESB2 systems would end up started without
 	 * the RX unit being turned on.
 	 */
 	if (hw->mac_type == e1000_80003es2lan)
-		hw->rx_needs_kicking = TRUE;
+		hw->rx_needs_kicking = true;
 
 	if (hw->mac_type > e1000_82544)
-		hw->has_smbus = TRUE;
+		hw->has_smbus = true;
 
 	return E1000_SUCCESS;
 }
@@ -482,7 +483,7 @@ e1000_set_media_type(struct e1000_hw *hw)
 
     if (hw->mac_type != e1000_82543) {
         /* tbi_compatibility is only valid on 82543 */
-        hw->tbi_compatibility_en = FALSE;
+        hw->tbi_compatibility_en = false;
     }
 
     switch (hw->device_id) {
@@ -513,7 +514,7 @@ e1000_set_media_type(struct e1000_hw *hw)
             if (status & E1000_STATUS_TBIMODE) {
                 hw->media_type = e1000_media_type_fiber;
                 /* tbi_compatibility not valid on fiber */
-                hw->tbi_compatibility_en = FALSE;
+                hw->tbi_compatibility_en = false;
             } else {
                 hw->media_type = e1000_media_type_copper;
             }
@@ -569,7 +570,7 @@ e1000_reset_hw(struct e1000_hw *hw)
     E1000_WRITE_FLUSH(hw);
 
     /* The tbi_compatibility_on Flag must be cleared when Rctl is cleared. */
-    hw->tbi_compatibility_on = FALSE;
+    hw->tbi_compatibility_on = false;
 
     /* Delay to allow any outstanding PCI transactions to complete before
      * resetting the device
@@ -682,7 +683,7 @@ e1000_reset_hw(struct e1000_hw *hw)
             msleep(20);
             break;
         case e1000_82573:
-            if (e1000_is_onboard_nvm_eeprom(hw) == FALSE) {
+            if (!e1000_is_onboard_nvm_eeprom(hw)) {
                 udelay(10);
                 ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
                 ctrl_ext |= E1000_CTRL_EXT_EE_RST;
@@ -1428,7 +1429,7 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
     if (hw->mac_type <= e1000_82543 ||
         hw->mac_type == e1000_82541 || hw->mac_type == e1000_82547 ||
         hw->mac_type == e1000_82541_rev_2 || hw->mac_type == e1000_82547_rev_2)
-        hw->phy_reset_disable = FALSE;
+        hw->phy_reset_disable = false;
 
    return E1000_SUCCESS;
 }
@@ -1470,7 +1471,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
     /* The NVM settings will configure LPLU in D3 for IGP2 and IGP3 PHYs */
     if (hw->phy_type == e1000_phy_igp) {
         /* disable lplu d3 during driver init */
-        ret_val = e1000_set_d3_lplu_state(hw, FALSE);
+        ret_val = e1000_set_d3_lplu_state(hw, false);
         if (ret_val) {
             DEBUGOUT("Error Disabling LPLU D3\n");
             return ret_val;
@@ -1478,7 +1479,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
     }
 
     /* disable lplu d0 during driver init */
-    ret_val = e1000_set_d0_lplu_state(hw, FALSE);
+    ret_val = e1000_set_d0_lplu_state(hw, false);
     if (ret_val) {
         DEBUGOUT("Error Disabling LPLU D0\n");
         return ret_val;
@@ -1691,7 +1692,7 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
          * firmware will have already initialized them.  We only initialize
          * them if the HW is not in IAMT mode.
          */
-        if (e1000_check_mng_mode(hw) == FALSE) {
+        if (!e1000_check_mng_mode(hw)) {
             /* Enable Electrical Idle on the PHY */
             phy_data |= GG82563_PMCR_ENABLE_ELECTRICAL_IDLE;
             ret_val = e1000_write_phy_reg(hw, GG82563_PHY_PWR_MGMT_CTRL,
@@ -1892,7 +1893,7 @@ e1000_copper_link_autoneg(struct e1000_hw *hw)
         }
     }
 
-    hw->get_link_status = TRUE;
+    hw->get_link_status = true;
 
     return E1000_SUCCESS;
 }
@@ -1932,7 +1933,7 @@ e1000_copper_link_postconfig(struct e1000_hw *hw)
 
     /* Config DSP to improve Giga link quality */
     if (hw->phy_type == e1000_phy_igp) {
-        ret_val = e1000_config_dsp_after_link_change(hw, TRUE);
+        ret_val = e1000_config_dsp_after_link_change(hw, true);
         if (ret_val) {
             DEBUGOUT("Error Configuring DSP after link up\n");
             return ret_val;
@@ -2923,7 +2924,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         if (hw->media_type == e1000_media_type_fiber) {
             signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
             if (status & E1000_STATUS_LU)
-                hw->get_link_status = FALSE;
+                hw->get_link_status = false;
         }
     }
 
@@ -2947,7 +2948,7 @@ e1000_check_for_link(struct e1000_hw *hw)
             return ret_val;
 
         if (phy_data & MII_SR_LINK_STATUS) {
-            hw->get_link_status = FALSE;
+            hw->get_link_status = false;
             /* Check if there was DownShift, must be checked immediately after
              * link-up */
             e1000_check_downshift(hw);
@@ -2973,7 +2974,7 @@ e1000_check_for_link(struct e1000_hw *hw)
 
         } else {
             /* No link detected */
-            e1000_config_dsp_after_link_change(hw, FALSE);
+            e1000_config_dsp_after_link_change(hw, false);
             return 0;
         }
 
@@ -2983,7 +2984,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         if (!hw->autoneg) return -E1000_ERR_CONFIG;
 
         /* optimize the dsp settings for the igp phy */
-        e1000_config_dsp_after_link_change(hw, TRUE);
+        e1000_config_dsp_after_link_change(hw, true);
 
         /* We have a M88E1000 PHY and Auto-Neg is enabled.  If we
          * have Si on board that is 82544 or newer, Auto
@@ -3036,7 +3037,7 @@ e1000_check_for_link(struct e1000_hw *hw)
                     rctl = E1000_READ_REG(hw, RCTL);
                     rctl &= ~E1000_RCTL_SBP;
                     E1000_WRITE_REG(hw, RCTL, rctl);
-                    hw->tbi_compatibility_on = FALSE;
+                    hw->tbi_compatibility_on = false;
                 }
             } else {
                 /* If TBI compatibility is was previously off, turn it on. For
@@ -3045,7 +3046,7 @@ e1000_check_for_link(struct e1000_hw *hw)
                  * will look like CRC errors to to the hardware.
                  */
                 if (!hw->tbi_compatibility_on) {
-                    hw->tbi_compatibility_on = TRUE;
+                    hw->tbi_compatibility_on = true;
                     rctl = E1000_READ_REG(hw, RCTL);
                     rctl |= E1000_RCTL_SBP;
                     E1000_WRITE_REG(hw, RCTL, rctl);
@@ -3098,7 +3099,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         E1000_WRITE_REG(hw, TXCW, hw->txcw);
         E1000_WRITE_REG(hw, CTRL, (ctrl & ~E1000_CTRL_SLU));
 
-        hw->serdes_link_down = FALSE;
+        hw->serdes_link_down = false;
     }
     /* If we force link for non-auto-negotiation switch, check link status
      * based on MAC synchronization for internal serdes media type.
@@ -3109,11 +3110,11 @@ e1000_check_for_link(struct e1000_hw *hw)
         udelay(10);
         if (E1000_RXCW_SYNCH & E1000_READ_REG(hw, RXCW)) {
             if (!(rxcw & E1000_RXCW_IV)) {
-                hw->serdes_link_down = FALSE;
+                hw->serdes_link_down = false;
                 DEBUGOUT("SERDES: Link is up.\n");
             }
         } else {
-            hw->serdes_link_down = TRUE;
+            hw->serdes_link_down = true;
             DEBUGOUT("SERDES: Link is down.\n");
         }
     }
@@ -4044,7 +4045,7 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     int32_t phy_init_status, ret_val;
     uint16_t phy_id_high, phy_id_low;
-    boolean_t match = FALSE;
+    bool match = false;
 
     DEBUGFUNC("e1000_detect_gig_phy");
 
@@ -4086,35 +4087,35 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 
     switch (hw->mac_type) {
     case e1000_82543:
-        if (hw->phy_id == M88E1000_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1000_E_PHY_ID) match = true;
         break;
     case e1000_82544:
-        if (hw->phy_id == M88E1000_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1000_I_PHY_ID) match = true;
         break;
     case e1000_82540:
     case e1000_82545:
     case e1000_82545_rev_3:
     case e1000_82546:
     case e1000_82546_rev_3:
-        if (hw->phy_id == M88E1011_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1011_I_PHY_ID) match = true;
         break;
     case e1000_82541:
     case e1000_82541_rev_2:
     case e1000_82547:
     case e1000_82547_rev_2:
-        if (hw->phy_id == IGP01E1000_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == IGP01E1000_I_PHY_ID) match = true;
         break;
     case e1000_82573:
-        if (hw->phy_id == M88E1111_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1111_I_PHY_ID) match = true;
         break;
     case e1000_80003es2lan:
-        if (hw->phy_id == GG82563_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == GG82563_E_PHY_ID) match = true;
         break;
     case e1000_ich8lan:
-        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_C_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_C_E_PHY_ID) match = true;
         break;
     default:
         DEBUGOUT1("Invalid MAC type %d\n", hw->mac_type);
@@ -4455,8 +4456,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         eeprom->opcode_bits = 3;
         eeprom->address_bits = 6;
         eeprom->delay_usec = 50;
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82540:
     case e1000_82545:
@@ -4473,8 +4474,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->word_size = 64;
             eeprom->address_bits = 6;
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82541:
     case e1000_82541_rev_2:
@@ -4503,8 +4504,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
                 eeprom->address_bits = 6;
             }
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82571:
     case e1000_82572:
@@ -4518,8 +4519,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82573:
         eeprom->type = e1000_eeprom_spi;
@@ -4532,9 +4533,9 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = TRUE;
-        eeprom->use_eewr = TRUE;
-        if (e1000_is_onboard_nvm_eeprom(hw) == FALSE) {
+        eeprom->use_eerd = true;
+        eeprom->use_eewr = true;
+        if (!e1000_is_onboard_nvm_eeprom(hw)) {
             eeprom->type = e1000_eeprom_flash;
             eeprom->word_size = 2048;
 
@@ -4555,8 +4556,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = TRUE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = true;
+        eeprom->use_eewr = false;
         break;
     case e1000_ich8lan:
         {
@@ -4564,15 +4565,15 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         uint32_t flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         eeprom->word_size = E1000_SHADOW_RAM_WORDS;
 
         /* Zero the shadow RAM structure. But don't load it from NVM
          * so as to save time for driver init */
         if (hw->eeprom_shadow_ram != NULL) {
             for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].modified = false;
                 hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
             }
         }
@@ -4994,15 +4995,14 @@ e1000_read_eeprom(struct e1000_hw *hw,
      * directly. In this case, we need to acquire the EEPROM so that
      * FW or other port software does not interrupt.
      */
-    if (e1000_is_onboard_nvm_eeprom(hw) == TRUE &&
-        hw->eeprom.use_eerd == FALSE) {
+    if (e1000_is_onboard_nvm_eeprom(hw) && !hw->eeprom.use_eerd) {
         /* Prepare the EEPROM for bit-bang reading */
         if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
             return -E1000_ERR_EEPROM;
     }
 
     /* Eerd register EEPROM access requires no eeprom aquire/release */
-    if (eeprom->use_eerd == TRUE)
+    if (eeprom->use_eerd)
         return e1000_read_eeprom_eerd(hw, offset, words, data);
 
     /* ICH EEPROM access is done via the ICH flash controller */
@@ -5171,7 +5171,7 @@ e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 *
 * hw - Struct containing variables accessed by shared code
 ****************************************************************************/
-static boolean_t
+static bool
 e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 {
     uint32_t eecd = 0;
@@ -5179,7 +5179,7 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
     DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
 
     if (hw->mac_type == e1000_ich8lan)
-        return FALSE;
+        return false;
 
     if (hw->mac_type == e1000_82573) {
         eecd = E1000_READ_REG(hw, EECD);
@@ -5189,10 +5189,10 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 
         /* If both bits are set, device is Flash type */
         if (eecd == 0x03) {
-            return FALSE;
+            return false;
         }
     }
-    return TRUE;
+    return true;
 }
 
 /******************************************************************************
@@ -5212,8 +5212,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_validate_eeprom_checksum");
 
-    if ((hw->mac_type == e1000_82573) &&
-        (e1000_is_onboard_nvm_eeprom(hw) == FALSE)) {
+    if ((hw->mac_type == e1000_82573) && !e1000_is_onboard_nvm_eeprom(hw)) {
         /* Check bit 4 of word 10h.  If it is 0, firmware is done updating
          * 10h-12h.  Checksum may need to be fixed. */
         e1000_read_eeprom(hw, 0x10, 1, &eeprom_data);
@@ -5339,7 +5338,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
     }
 
     /* 82573 writes only through eewr */
-    if (eeprom->use_eewr == TRUE)
+    if (eeprom->use_eewr)
         return e1000_write_eeprom_eewr(hw, offset, words, data);
 
     if (eeprom->type == e1000_eeprom_ich8)
@@ -5536,7 +5535,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
     uint32_t new_bank_offset = 0;
     uint8_t low_byte = 0;
     uint8_t high_byte = 0;
-    boolean_t sector_write_failed = FALSE;
+    bool sector_write_failed = false;
 
     if (hw->mac_type == e1000_82573) {
         /* The flop register will be used to determine if flash type is STM */
@@ -5588,21 +5587,21 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
             e1000_erase_ich8_4k_segment(hw, 0);
         }
 
-        sector_write_failed = FALSE;
+        sector_write_failed = false;
         /* Loop for every byte in the shadow RAM,
          * which is in units of words. */
         for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
             /* Determine whether to write the value stored
              * in the other NVM bank or a modified value stored
              * in the shadow RAM */
-            if (hw->eeprom_shadow_ram[i].modified == TRUE) {
+            if (hw->eeprom_shadow_ram[i].modified) {
                 low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
                 udelay(100);
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset, low_byte);
 
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
                 else {
                     high_byte =
                         (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
@@ -5616,7 +5615,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                             (i << 1) + new_bank_offset, low_byte);
 
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
                 else {
                     e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
                                          &high_byte);
@@ -5624,10 +5623,10 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                 }
             }
 
-            /* If the write of the low byte was successful, go ahread and
+            /* If the write of the low byte was successful, go ahead and
              * write the high byte while checking to make sure that if it
              * is the signature byte, then it is handled properly */
-            if (sector_write_failed == FALSE) {
+            if (!sector_write_failed) {
                 /* If the word is 0x13, then make sure the signature bits
                  * (15:14) are 11b until the commit has completed.
                  * This will allow us to write 10b which indicates the
@@ -5640,7 +5639,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset + 1, high_byte);
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
 
             } else {
                 /* If the write failed then break from the loop and
@@ -5651,7 +5650,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
 
         /* Don't bother writing the segment valid bits if sector
          * programming failed. */
-        if (sector_write_failed == FALSE) {
+        if (!sector_write_failed) {
             /* Finally validate the new segment by setting bit 15:14
              * to 10b in word 0x13 , this can be done without an
              * erase as well since these bits are 11 to start with
@@ -5673,7 +5672,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
 
             /* Clear the now not used entry in the cache */
             for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].modified = false;
                 hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
             }
         }
@@ -5750,7 +5749,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
     /* Reserve a spot for the Locally Administered Address to work around
      * an 82571 issue in which a reset on one port will reload the MAC on
      * the other port. */
-    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present == TRUE))
+    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present))
         rar_num -= 1;
     if (hw->mac_type == e1000_ich8lan)
         rar_num = E1000_RAR_ENTRIES_ICH8LAN;
@@ -5922,7 +5921,7 @@ e1000_rar_set(struct e1000_hw *hw,
     case e1000_82571:
     case e1000_82572:
     case e1000_80003es2lan:
-        if (hw->leave_av_bit_off == TRUE)
+        if (hw->leave_av_bit_off)
             break;
     default:
         /* Indicate to hardware the Address is Valid. */
@@ -6425,7 +6424,7 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Call this after e1000_init_hw. You may override the IFS defaults by setting
- * hw->ifs_params_forced to TRUE. However, you must initialize hw->
+ * hw->ifs_params_forced to true. However, you must initialize hw->
  * current_ifs_val, ifs_min_val, ifs_max_val, ifs_step_size, and ifs_ratio
  * before calling this function.
  *****************************************************************************/
@@ -6442,7 +6441,7 @@ e1000_reset_adaptive(struct e1000_hw *hw)
             hw->ifs_step_size = IFS_STEP;
             hw->ifs_ratio = IFS_RATIO;
         }
-        hw->in_ifs_mode = FALSE;
+        hw->in_ifs_mode = false;
         E1000_WRITE_REG(hw, AIT, 0);
     } else {
         DEBUGOUT("Not in Adaptive IFS mode!\n");
@@ -6465,7 +6464,7 @@ e1000_update_adaptive(struct e1000_hw *hw)
     if (hw->adaptive_ifs) {
         if ((hw->collision_delta * hw->ifs_ratio) > hw->tx_packet_delta) {
             if (hw->tx_packet_delta > MIN_NUM_XMITS) {
-                hw->in_ifs_mode = TRUE;
+                hw->in_ifs_mode = true;
                 if (hw->current_ifs_val < hw->ifs_max_val) {
                     if (hw->current_ifs_val == 0)
                         hw->current_ifs_val = hw->ifs_min_val;
@@ -6477,7 +6476,7 @@ e1000_update_adaptive(struct e1000_hw *hw)
         } else {
             if (hw->in_ifs_mode && (hw->tx_packet_delta <= MIN_NUM_XMITS)) {
                 hw->current_ifs_val = 0;
-                hw->in_ifs_mode = FALSE;
+                hw->in_ifs_mode = false;
                 E1000_WRITE_REG(hw, AIT, 0);
             }
         }
@@ -6968,7 +6967,7 @@ e1000_check_downshift(struct e1000_hw *hw)
                                M88E1000_PSSR_DOWNSHIFT_SHIFT;
     } else if (hw->phy_type == e1000_phy_ife) {
         /* e1000_phy_ife supports 10/100 speed only */
-        hw->speed_downgraded = FALSE;
+        hw->speed_downgraded = false;
     }
 
     return E1000_SUCCESS;
@@ -6988,7 +6987,7 @@ e1000_check_downshift(struct e1000_hw *hw)
 
 static int32_t
 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
-                                   boolean_t link_up)
+                                   bool link_up)
 {
     int32_t ret_val;
     uint16_t phy_data, phy_saved_data, speed, duplex, i;
@@ -7198,7 +7197,7 @@ e1000_set_phy_mode(struct e1000_hw *hw)
             if (ret_val)
                 return ret_val;
 
-            hw->phy_reset_disable = FALSE;
+            hw->phy_reset_disable = false;
         }
     }
 
@@ -7221,7 +7220,7 @@ e1000_set_phy_mode(struct e1000_hw *hw)
 
 static int32_t
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
-                        boolean_t active)
+                        bool active)
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
@@ -7351,7 +7350,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
 
 static int32_t
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
-                        boolean_t active)
+                        bool active)
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
@@ -7689,9 +7688,9 @@ e1000_mng_write_commit(struct e1000_hw * hw)
 /*****************************************************************************
  * This function checks the mode of the firmware.
  *
- * returns  - TRUE when the mode is IAMT or FALSE.
+ * returns  - true when the mode is IAMT or false.
  ****************************************************************************/
-boolean_t
+bool
 e1000_check_mng_mode(struct e1000_hw *hw)
 {
     uint32_t fwsm;
@@ -7701,12 +7700,12 @@ e1000_check_mng_mode(struct e1000_hw *hw)
     if (hw->mac_type == e1000_ich8lan) {
         if ((fwsm & E1000_FWSM_MODE_MASK) ==
             (E1000_MNG_ICH_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-            return TRUE;
+            return true;
     } else if ((fwsm & E1000_FWSM_MODE_MASK) ==
                (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-        return TRUE;
+        return true;
 
-    return FALSE;
+    return false;
 }
 
 
@@ -7763,15 +7762,15 @@ e1000_calculate_mng_checksum(char *buffer, uint32_t length)
 /*****************************************************************************
  * This function checks whether tx pkt filtering needs to be enabled or not.
  *
- * returns  - TRUE for packet filtering or FALSE.
+ * returns  - true for packet filtering or false.
  ****************************************************************************/
-boolean_t
+bool
 e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
     /* called in init as well as watchdog timer functions */
 
     int32_t ret_val, checksum;
-    boolean_t tx_filter = FALSE;
+    bool tx_filter = false;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
     uint8_t *buffer = (uint8_t *) &(hw->mng_cookie);
 
@@ -7787,11 +7786,11 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
                                                E1000_MNG_DHCP_COOKIE_LENGTH)) {
                     if (hdr->status &
                         E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT)
-                        tx_filter = TRUE;
+                        tx_filter = true;
                 } else
-                    tx_filter = TRUE;
+                    tx_filter = true;
             } else
-                tx_filter = TRUE;
+                tx_filter = true;
         }
     }
 
@@ -7804,7 +7803,7 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *
- * returns: - TRUE/FALSE
+ * returns: - true/false
  *
  *****************************************************************************/
 uint32_t
@@ -7818,19 +7817,19 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 
         if (!(manc & E1000_MANC_RCV_TCO_EN) ||
             !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
-            return FALSE;
-        if (e1000_arc_subsystem_valid(hw) == TRUE) {
+            return false;
+        if (e1000_arc_subsystem_valid(hw)) {
             fwsm = E1000_READ_REG(hw, FWSM);
             factps = E1000_READ_REG(hw, FACTPS);
 
             if ((((fwsm & E1000_FWSM_MODE_MASK) >> E1000_FWSM_MODE_SHIFT) ==
                    e1000_mng_mode_pt) && !(factps & E1000_FACTPS_MNGCG))
-                return TRUE;
+                return true;
         } else
             if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
-                return TRUE;
+                return true;
     }
-    return FALSE;
+    return false;
 }
 
 static int32_t
@@ -8264,14 +8263,14 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
     case e1000_80003es2lan:
         fwsm = E1000_READ_REG(hw, FWSM);
         if ((fwsm & E1000_FWSM_MODE_MASK) != 0)
-            return TRUE;
+            return true;
         break;
     case e1000_ich8lan:
-        return TRUE;
+        return true;
     default:
         break;
     }
-    return FALSE;
+    return false;
 }
 
 
@@ -8417,7 +8416,7 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
 
     for (i = 0; i < words; i++) {
         if (hw->eeprom_shadow_ram != NULL &&
-            hw->eeprom_shadow_ram[offset+i].modified == TRUE) {
+            hw->eeprom_shadow_ram[offset+i].modified) {
             data[i] = hw->eeprom_shadow_ram[offset+i].eeprom_word;
         } else {
             /* The NVM part needs a byte offset, hence * 2 */
@@ -8466,7 +8465,7 @@ e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
     if (hw->eeprom_shadow_ram != NULL) {
         for (i = 0; i < words; i++) {
             if ((offset + i) < E1000_SHADOW_RAM_WORDS) {
-                hw->eeprom_shadow_ram[offset+i].modified = TRUE;
+                hw->eeprom_shadow_ram[offset+i].modified = true;
                 hw->eeprom_shadow_ram[offset+i].eeprom_word = data[i];
             } else {
                 error = -E1000_ERR_EEPROM;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a6c3c34..572a7b6 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -100,8 +100,8 @@ typedef enum {
 } e1000_fc_type;
 
 struct e1000_shadow_ram {
-    uint16_t    eeprom_word;
-    boolean_t   modified;
+    uint16_t eeprom_word;
+    bool modified;
 };
 
 /* PCI bus types */
@@ -274,8 +274,8 @@ struct e1000_eeprom_info {
     uint16_t address_bits;
     uint16_t delay_usec;
     uint16_t page_size;
-    boolean_t use_eerd;
-    boolean_t use_eewr;
+    bool use_eerd;
+    bool use_eewr;
 };
 
 /* Flex ASF Information */
@@ -391,8 +391,8 @@ struct e1000_host_mng_dhcp_cookie{
 
 int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer,
                                   uint16_t length);
-boolean_t e1000_check_mng_mode(struct e1000_hw *hw);
-boolean_t e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
+bool e1000_check_mng_mode(struct e1000_hw *hw);
+bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
 int32_t e1000_read_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
 int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
@@ -1420,7 +1420,7 @@ struct e1000_hw {
 	uint32_t		ledctl_default;
 	uint32_t		ledctl_mode1;
 	uint32_t		ledctl_mode2;
-	boolean_t		tx_pkt_filtering;
+	bool			tx_pkt_filtering;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
 	uint16_t		phy_spd_default;
 	uint16_t		autoneg_advertised;
@@ -1445,30 +1445,30 @@ struct e1000_hw {
 	uint8_t			dma_fairness;
 	uint8_t			mac_addr[NODE_ADDRESS_SIZE];
 	uint8_t			perm_mac_addr[NODE_ADDRESS_SIZE];
-	boolean_t		disable_polarity_correction;
-	boolean_t		speed_downgraded;
+	bool			disable_polarity_correction;
+	bool			speed_downgraded;
 	e1000_smart_speed	smart_speed;
 	e1000_dsp_config	dsp_config_state;
-	boolean_t		get_link_status;
-	boolean_t		serdes_link_down;
-	boolean_t		tbi_compatibility_en;
-	boolean_t		tbi_compatibility_on;
-	boolean_t		laa_is_present;
-	boolean_t		phy_reset_disable;
-	boolean_t		initialize_hw_bits_disable;
-	boolean_t		fc_send_xon;
-	boolean_t		fc_strict_ieee;
-	boolean_t		report_tx_early;
-	boolean_t		adaptive_ifs;
-	boolean_t		ifs_params_forced;
-	boolean_t		in_ifs_mode;
-	boolean_t		mng_reg_access_disabled;
-	boolean_t		leave_av_bit_off;
-	boolean_t		kmrn_lock_loss_workaround_disabled;
-	boolean_t		bad_tx_carr_stats_fd;
-	boolean_t		has_manc2h;
-	boolean_t		rx_needs_kicking;
-	boolean_t		has_smbus;
+	bool			get_link_status;
+	bool			serdes_link_down;
+	bool			tbi_compatibility_en;
+	bool			tbi_compatibility_on;
+	bool			laa_is_present;
+	bool			phy_reset_disable;
+	bool			initialize_hw_bits_disable;
+	bool			fc_send_xon;
+	bool			fc_strict_ieee;
+	bool			report_tx_early;
+	bool			adaptive_ifs;
+	bool			ifs_params_forced;
+	bool			in_ifs_mode;
+	bool			mng_reg_access_disabled;
+	bool			leave_av_bit_off;
+	bool			kmrn_lock_loss_workaround_disabled;
+	bool			bad_tx_carr_stats_fd;
+	bool			has_manc2h;
+	bool			rx_needs_kicking;
+	bool			has_smbus;
 };
 
 
@@ -2518,11 +2518,11 @@ struct e1000_host_command_info {
  * Typical use:
  *  ...
  *  if (TBI_ACCEPT) {
- *      accept_frame = TRUE;
+ *      accept_frame = true;
  *      e1000_tbi_adjust_stats(adapter, MacAddress);
  *      frame_length--;
  *  } else {
- *      accept_frame = FALSE;
+ *      accept_frame = false;
  *  }
  *  ...
  */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0991648..37c4655 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -169,21 +169,21 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
 static irqreturn_t e1000_intr_msi(int irq, void *data);
-static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_tx_ring *tx_ring);
+static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
+			       struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
 static int e1000_clean(struct napi_struct *napi, int budget);
-static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rx_ring,
-                                    int *work_done, int work_to_do);
-static boolean_t e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                                       struct e1000_rx_ring *rx_ring,
-                                       int *work_done, int work_to_do);
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring,
+			       int *work_done, int work_to_do);
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring,
+				  int *work_done, int work_to_do);
 #else
-static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rx_ring);
-static boolean_t e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                                       struct e1000_rx_ring *rx_ring);
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring);
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring);
 #endif
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
                                    struct e1000_rx_ring *rx_ring,
@@ -584,7 +584,7 @@ void e1000_power_up_phy(struct e1000_adapter *adapter)
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
 	/* Power down the PHY so no link is implied when interface is down *
-	 * The PHY cannot be powered down if any of the following is TRUE *
+	 * The PHY cannot be powered down if any of the following is true *
 	 * (a) WoL is enabled
 	 * (b) AMT is active
 	 * (c) SoL/IDER session is active */
@@ -673,7 +673,7 @@ e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
-	boolean_t legacy_pba_adjust = FALSE;
+	bool legacy_pba_adjust = false;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -687,7 +687,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	case e1000_82540:
 	case e1000_82541:
 	case e1000_82541_rev_2:
-		legacy_pba_adjust = TRUE;
+		legacy_pba_adjust = true;
 		pba = E1000_PBA_48K;
 		break;
 	case e1000_82545:
@@ -698,7 +698,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		break;
 	case e1000_82547:
 	case e1000_82547_rev_2:
-		legacy_pba_adjust = TRUE;
+		legacy_pba_adjust = true;
 		pba = E1000_PBA_30K;
 		break;
 	case e1000_82571:
@@ -716,7 +716,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		break;
 	}
 
-	if (legacy_pba_adjust == TRUE) {
+	if (legacy_pba_adjust) {
 		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
 			pba -= 8; /* allocate more FIFO for Tx */
 
@@ -1366,15 +1366,15 @@ e1000_sw_init(struct e1000_adapter *adapter)
 
 	e1000_set_media_type(hw);
 
-	hw->wait_autoneg_complete = FALSE;
-	hw->tbi_compatibility_en = TRUE;
-	hw->adaptive_ifs = TRUE;
+	hw->wait_autoneg_complete = false;
+	hw->tbi_compatibility_en = true;
+	hw->adaptive_ifs = true;
 
 	/* Copper options */
 
 	if (hw->media_type == e1000_media_type_copper) {
 		hw->mdix = AUTO_ALL_MODES;
-		hw->disable_polarity_correction = FALSE;
+		hw->disable_polarity_correction = false;
 		hw->master_slave = E1000_MASTER_SLAVE;
 	}
 
@@ -1576,7 +1576,7 @@ e1000_close(struct net_device *netdev)
  * @start: address of beginning of memory
  * @len: length of memory
  **/
-static boolean_t
+static bool
 e1000_check_64k_bound(struct e1000_adapter *adapter,
 		      void *start, unsigned long len)
 {
@@ -1587,10 +1587,10 @@ e1000_check_64k_bound(struct e1000_adapter *adapter,
 	 * write location to cross 64k boundary due to errata 23 */
 	if (adapter->hw.mac_type == e1000_82545 ||
 	    adapter->hw.mac_type == e1000_82546) {
-		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
+		return ((begin ^ (end - 1)) >> 16) != 0 ? false : true;
 	}
 
-	return TRUE;
+	return true;
 }
 
 /**
@@ -2133,7 +2133,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
 		rxcsum = E1000_READ_REG(hw, RXCSUM);
-		if (adapter->rx_csum == TRUE) {
+		if (adapter->rx_csum) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
 
 			/* Enable 82571 IPv4 payload checksum for UDP fragments
@@ -2669,7 +2669,7 @@ e1000_watchdog(unsigned long data)
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			uint32_t ctrl;
-			boolean_t txb2b = 1;
+			bool txb2b = true;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
@@ -2691,12 +2691,12 @@ e1000_watchdog(unsigned long data)
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				txb2b = 0;
+				txb2b = false;
 				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 8;
 				break;
 			case SPEED_100:
-				txb2b = 0;
+				txb2b = false;
 				netdev->tx_queue_len = 100;
 				/* maybe add some timeout factor ? */
 				break;
@@ -2704,7 +2704,7 @@ e1000_watchdog(unsigned long data)
 
 			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
-			    txb2b == 0) {
+			    !txb2b) {
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
 				tarc0 &= ~(1 << 21);
@@ -2802,7 +2802,7 @@ e1000_watchdog(unsigned long data)
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = TRUE;
+	adapter->detect_tx_hung = true;
 
 	/* With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
@@ -3025,12 +3025,12 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		if (++i == tx_ring->count) i = 0;
 		tx_ring->next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
-	return FALSE;
+	return false;
 }
 
-static boolean_t
+static bool
 e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
               struct sk_buff *skb)
 {
@@ -3060,10 +3060,10 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		if (unlikely(++i == tx_ring->count)) i = 0;
 		tx_ring->next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
 
-	return FALSE;
+	return false;
 }
 
 #define E1000_MAX_TXD_PWR	12
@@ -4038,7 +4038,7 @@ e1000_clean(struct napi_struct *napi, int budget)
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 e1000_clean_tx_irq(struct e1000_adapter *adapter,
                    struct e1000_tx_ring *tx_ring)
 {
@@ -4049,7 +4049,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 #ifdef CONFIG_E1000_NAPI
 	unsigned int count = 0;
 #endif
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
@@ -4057,7 +4057,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while (eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		for (cleaned = FALSE; !cleaned; ) {
+		for (cleaned = false; !cleaned; ) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -4105,7 +4105,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	if (adapter->detect_tx_hung) {
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
-		adapter->detect_tx_hung = FALSE;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
@@ -4200,7 +4200,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_E1000_NAPI
 e1000_clean_rx_irq(struct e1000_adapter *adapter,
                    struct e1000_rx_ring *rx_ring,
@@ -4219,7 +4219,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	uint8_t last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
@@ -4247,7 +4247,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = TRUE;
+		cleaned = true;
 		cleaned_count++;
 		pci_unmap_single(pdev,
 		                 buffer_info->dma,
@@ -4373,7 +4373,7 @@ next_desc:
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_E1000_NAPI
 e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
                       struct e1000_rx_ring *rx_ring,
@@ -4393,7 +4393,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 	unsigned int i, j;
 	uint32_t length, staterr;
 	int cleaned_count = 0;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
@@ -4420,7 +4420,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = TRUE;
+		cleaned = true;
 		cleaned_count++;
 		pci_unmap_single(pdev, buffer_info->dma,
 				 buffer_info->length,
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 10af742..365626d 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -41,13 +41,6 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 
-typedef enum {
-#undef FALSE
-    FALSE = 0,
-#undef TRUE
-    TRUE = 1
-} boolean_t;
-
 #ifdef DBG
 #define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
 #define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
