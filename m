From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 6/7] drivers/net/e1000e: Use
	pr_<level> and netdev_<level>
Date: Mon, 22 Feb 2010 18:57:02 -0800
Message-ID: <78b154eab5d37da22dda3bf3e77fe32013009fa3.1266893508.git.joe@perches.com>
References: <cover.1266893507.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1266893507.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert e_<level> to netdev_<level>
Remove #define PFX
Use #define pr_fmt
Convert a few printks to pr_<level>
Coalesce long formats
Typo spelling fix

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000e/82571.c   |   57 +++++++++++-------
 drivers/net/e1000e/e1000.h   |   21 -------
 drivers/net/e1000e/es2lan.c  |   27 +++++----
 drivers/net/e1000e/ethtool.c |   37 ++++++------
 drivers/net/e1000e/ich8lan.c |   90 +++++++++++++++++------------
 drivers/net/e1000e/lib.c     |  131 +++++++++++++++++++++---------------------
 drivers/net/e1000e/netdev.c  |   95 +++++++++++++++---------------
 drivers/net/e1000e/param.c   |   20 +++---
 drivers/net/e1000e/phy.c     |  114 ++++++++++++++++++------------------
 9 files changed, 302 insertions(+), 290 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 3c95acb..a5fefb6 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -317,13 +317,14 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 			 * indicates that the bootagent or EFI code has
 			 * improperly left this bit enabled
 			 */
-			e_dbg("Please update your 82571 Bootagent\n");
+			netdev_dbg(adapter->netdev,
+				   "Please update your 82571 Bootagent\n");
 		}
 		ew32(SWSM, swsm & ~E1000_SWSM_SMBI);
 	}
 
 	/*
-	 * Initialze device specific counter of SMBI acquisition
+	 * Initialize device specific counter of SMBI acquisition
 	 * timeouts.
 	 */
 	 hw->dev_spec.e82571.smb_counter = 0;
@@ -491,7 +492,8 @@ static s32 e1000_get_hw_semaphore_82571(struct e1000_hw *hw)
 	}
 
 	if (i == sw_timeout) {
-		e_dbg("Driver can't access device - SMBI bit is set.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Driver can't access device - SMBI bit is set\n");
 		hw->dev_spec.e82571.smb_counter++;
 	}
 	/* Get the FW semaphore. */
@@ -509,7 +511,7 @@ static s32 e1000_get_hw_semaphore_82571(struct e1000_hw *hw)
 	if (i == fw_timeout) {
 		/* Release semaphores */
 		e1000_put_hw_semaphore_82571(hw);
-		e_dbg("Driver can't access the NVM\n");
+		netdev_dbg(hw->adapter->netdev, "Driver can't access the NVM\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -715,7 +717,8 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "nvm parameter(s) out of bounds\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -756,7 +759,8 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 		timeout--;
 	}
 	if (!timeout) {
-		e_dbg("MNG configuration cycle has not completed.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "MNG configuration cycle has not completed\n");
 		return -E1000_ERR_RESET;
 	}
 
@@ -851,9 +855,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val)
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "PCI-E Master disable polling has failed\n");
 
-	e_dbg("Masking off all interrupts\n");
+	netdev_dbg(hw->adapter->netdev, "Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
 	ew32(RCTL, 0);
@@ -892,7 +897,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 
 	ctrl = er32(CTRL);
 
-	e_dbg("Issuing a global reset to MAC\n");
+	netdev_dbg(hw->adapter->netdev, "Issuing a global reset to MAC\n");
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
 
 	if (hw->nvm.type == e1000_nvm_flash_hw) {
@@ -960,11 +965,12 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = e1000e_id_led_init(hw);
 	if (ret_val)
-		e_dbg("Error initializing identification LED\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
-	e_dbg("Initializing the IEEE VLAN\n");
+	netdev_dbg(hw->adapter->netdev, "Initializing the IEEE VLAN\n");
 	mac->ops.clear_vfta(hw);
 
 	/* Setup the receive address. */
@@ -978,7 +984,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	e1000e_init_rx_addrs(hw, rar_count);
 
 	/* Zero out the Multicast HASH table */
-	e_dbg("Zeroing the MTA\n");
+	netdev_dbg(hw->adapter->netdev, "Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 
@@ -1375,7 +1381,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				mac->serdes_link_state =
 				    e1000_serdes_link_autoneg_progress;
 				mac->serdes_has_link = false;
-				e_dbg("AN_UP     -> AN_PROG\n");
+				netdev_dbg(hw->adapter->netdev,
+					   "AN_UP     -> AN_PROG\n");
 			}
 		break;
 
@@ -1393,7 +1400,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				mac->serdes_link_state =
 				    e1000_serdes_link_autoneg_progress;
 				mac->serdes_has_link = false;
-				e_dbg("FORCED_UP -> AN_PROG\n");
+				netdev_dbg(hw->adapter->netdev,
+					   "FORCED_UP -> AN_PROG\n");
 			}
 			break;
 
@@ -1407,13 +1415,15 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				if (status & E1000_STATUS_LU) {
 					mac->serdes_link_state =
 					    e1000_serdes_link_autoneg_complete;
-					e_dbg("AN_PROG   -> AN_UP\n");
+					netdev_dbg(hw->adapter->netdev,
+						   "AN_PROG   -> AN_UP\n");
 					mac->serdes_has_link = true;
 				} else {
 					/* Autoneg completed, but failed. */
 					mac->serdes_link_state =
 					    e1000_serdes_link_down;
-					e_dbg("AN_PROG   -> DOWN\n");
+					netdev_dbg(hw->adapter->netdev,
+						   "AN_PROG   -> DOWN\n");
 				}
 			} else {
 				/*
@@ -1428,13 +1438,15 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				/* Configure Flow Control after link up. */
 				ret_val = e1000e_config_fc_after_link_up(hw);
 				if (ret_val) {
-					e_dbg("Error config flow control\n");
+					netdev_dbg(hw->adapter->netdev,
+						   "Error config flow control\n");
 					break;
 				}
 				mac->serdes_link_state =
 				    e1000_serdes_link_forced_up;
 				mac->serdes_has_link = true;
-				e_dbg("AN_PROG   -> FORCED_UP\n");
+				netdev_dbg(hw->adapter->netdev,
+					   "AN_PROG   -> FORCED_UP\n");
 			}
 			break;
 
@@ -1449,14 +1461,14 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 			mac->serdes_link_state =
 			    e1000_serdes_link_autoneg_progress;
-			e_dbg("DOWN      -> AN_PROG\n");
+			netdev_dbg(hw->adapter->netdev, "DOWN      -> AN_PROG\n");
 			break;
 		}
 	} else {
 		if (!(rxcw & E1000_RXCW_SYNCH)) {
 			mac->serdes_has_link = false;
 			mac->serdes_link_state = e1000_serdes_link_down;
-			e_dbg("ANYSTATE  -> DOWN\n");
+			netdev_dbg(hw->adapter->netdev, "ANYSTATE  -> DOWN\n");
 		} else {
 			/*
 			 * We have sync, and can tolerate one invalid (IV)
@@ -1468,7 +1480,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			if (rxcw & E1000_RXCW_IV) {
 				mac->serdes_link_state = e1000_serdes_link_down;
 				mac->serdes_has_link = false;
-				e_dbg("ANYSTATE  -> DOWN\n");
+				netdev_dbg(hw->adapter->netdev,
+					   "ANYSTATE  -> DOWN\n");
 			}
 		}
 	}
@@ -1490,7 +1503,7 @@ static s32 e1000_valid_led_default_82571(struct e1000_hw *hw, u16 *data)
 
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c2ec095..3df5648 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -42,27 +42,6 @@
 
 struct e1000_info;
 
-#define e_printk(level, adapter, format, arg...) \
-	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
-	       adapter->netdev->name, ## arg)
-
-#ifdef DEBUG
-#define e_dbg(format, arg...) \
-	e_printk(KERN_DEBUG , hw->adapter, format, ## arg)
-#else
-#define e_dbg(format, arg...) do { (void)(hw); } while (0)
-#endif
-
-#define e_err(format, arg...) \
-	e_printk(KERN_ERR, adapter, format, ## arg)
-#define e_info(format, arg...) \
-	e_printk(KERN_INFO, adapter, format, ## arg)
-#define e_warn(format, arg...) \
-	e_printk(KERN_WARNING, adapter, format, ## arg)
-#define e_notice(format, arg...) \
-	e_printk(KERN_NOTICE, adapter, format, ## arg)
-
-
 /* Interrupt modes, as used by the IntMode parameter */
 #define E1000E_INT_MODE_LEGACY		0
 #define E1000E_INT_MODE_MSI		1
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 27d2158..814511d 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -399,7 +399,8 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 	}
 
 	if (i == timeout) {
-		e_dbg("Driver can't access resource, SW_FW_SYNC timeout.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Driver can't access resource, SW_FW_SYNC timeout\n");
 		return -E1000_ERR_SWFW_SYNC;
 	}
 
@@ -613,7 +614,8 @@ static s32 e1000_get_cfg_done_80003es2lan(struct e1000_hw *hw)
 		timeout--;
 	}
 	if (!timeout) {
-		e_dbg("MNG configuration cycle has not completed.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "MNG configuration cycle has not completed\n");
 		return -E1000_ERR_RESET;
 	}
 
@@ -646,7 +648,7 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e_dbg("GG82563 PSCR: %X\n", phy_data);
+	netdev_dbg(hw->adapter->netdev, "GG82563 PSCR: %X\n", phy_data);
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
@@ -664,8 +666,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	udelay(1);
 
 	if (hw->phy.autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link "
-			 "on GG82563 phy.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Waiting for forced speed/duplex link on GG82563 phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
@@ -790,9 +792,10 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val)
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "PCI-E Master disable polling has failed\n");
 
-	e_dbg("Masking off all interrupts\n");
+	netdev_dbg(hw->adapter->netdev, "Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
 	ew32(RCTL, 0);
@@ -804,7 +807,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	ctrl = er32(CTRL);
 
 	ret_val = e1000_acquire_phy_80003es2lan(hw);
-	e_dbg("Issuing a global reset to MAC\n");
+	netdev_dbg(hw->adapter->netdev, "Issuing a global reset to MAC\n");
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
 	e1000_release_phy_80003es2lan(hw);
 
@@ -840,18 +843,18 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = e1000e_id_led_init(hw);
 	if (ret_val)
-		e_dbg("Error initializing identification LED\n");
+		netdev_dbg(hw->adapter->netdev, "Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
-	e_dbg("Initializing the IEEE VLAN\n");
+	netdev_dbg(hw->adapter->netdev, "Initializing the IEEE VLAN\n");
 	mac->ops.clear_vfta(hw);
 
 	/* Setup the receive address. */
 	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
 
 	/* Zero out the Multicast HASH table */
-	e_dbg("Zeroing the MTA\n");
+	netdev_dbg(hw->adapter->netdev, "Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 
@@ -1021,7 +1024,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	/* SW Reset the PHY so all changes take effect */
 	ret_val = e1000e_commit_phy(hw);
 	if (ret_val) {
-		e_dbg("Error Resetting the PHY\n");
+		netdev_dbg(hw->adapter->netdev, "Error Resetting the PHY\n");
 		return ret_val;
 	}
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b33e3cb..2d7f6d2 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -214,7 +214,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		e_err("Unsupported Speed/Duplex configuration\n");
+		netdev_err(adapter->netdev, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 
@@ -237,7 +237,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		e_err("Unsupported Speed/Duplex configuration\n");
+		netdev_err(adapter->netdev, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -254,8 +254,7 @@ static int e1000_set_settings(struct net_device *netdev,
 	 * cannot be changed
 	 */
 	if (e1000_check_reset_block(hw)) {
-		e_err("Cannot change link characteristics when SoL/IDER is "
-		      "active.\n");
+		netdev_err(adapter->netdev, "Cannot change link characteristics when SoL/IDER is active\n");
 		return -EINVAL;
 	}
 
@@ -411,7 +410,7 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 		netdev->features &= ~NETIF_F_TSO6;
 	}
 
-	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
+	netdev_info(adapter->netdev, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->flags |= FLAG_TSO_FORCE;
 	return 0;
 }
@@ -768,9 +767,9 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
 				      (test[pat] & write));
 		val = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
 		if (val != (test[pat] & write & mask)) {
-			e_err("pattern test reg %04X failed: got 0x%08X "
-			      "expected 0x%08X\n", reg + offset, val,
-			      (test[pat] & write & mask));
+			netdev_err(adapter->netdev, "pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
+				   reg + offset, val,
+				   (test[pat] & write & mask));
 			*data = reg;
 			return 1;
 		}
@@ -785,8 +784,8 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 	__ew32(&adapter->hw, reg, write & mask);
 	val = __er32(&adapter->hw, reg);
 	if ((write & mask) != (val & mask)) {
-		e_err("set/check reg %04X test failed: got 0x%08X "
-		      "expected 0x%08X\n", reg, (val & mask), (write & mask));
+		netdev_err(adapter->netdev, "set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
+			   reg, (val & mask), (write & mask));
 		*data = reg;
 		return 1;
 	}
@@ -838,8 +837,9 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	ew32(STATUS, toggle);
 	after = er32(STATUS) & toggle;
 	if (value != after) {
-		e_err("failed STATUS register test got: 0x%08X expected: "
-		      "0x%08X\n", after, value);
+		netdev_err(adapter->netdev,
+			   "failed STATUS register test got: 0x%08X expected: 0x%08X\n",
+			   after, value);
 		*data = 1;
 		return 1;
 	}
@@ -960,7 +960,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		ret_val = -1;
 		goto out;
 	}
-	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared"));
+	netdev_info(adapter->netdev, "testing %s interrupt\n",
+		    shared_int ? "shared" : "unshared");
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1604,7 +1605,7 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	 * sessions are active
 	 */
 	if (e1000_check_reset_block(&adapter->hw)) {
-		e_err("Cannot do PHY loopback test when SoL/IDER is active.\n");
+		netdev_err(adapter->netdev, "Cannot do PHY loopback test when SoL/IDER is active\n");
 		*data = 0;
 		goto out;
 	}
@@ -1689,7 +1690,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		forced_speed_duplex = adapter->hw.mac.forced_speed_duplex;
 		autoneg = adapter->hw.mac.autoneg;
 
-		e_info("offline testing starting\n");
+		netdev_info(adapter->netdev, "offline testing starting\n");
 
 		/*
 		 * Link test performed before hardware reset so autoneg doesn't
@@ -1735,7 +1736,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		e_info("online testing starting\n");
+		netdev_info(adapter->netdev, "online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1772,8 +1773,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->supported &= ~WAKE_UCAST;
 
 		if (adapter->wol & E1000_WUFC_EX)
-			e_err("Interface does not support directed (unicast) "
-			      "frame wake-up packets\n");
+			netdev_err(adapter->netdev,
+				   "Interface does not support directed (unicast) frame wake-up packets\n");
 	}
 
 	if (adapter->wol & E1000_WUFC_EX)
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 54d03a0..d45a847 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -343,7 +343,8 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		phy->ops.read_reg  = e1000e_read_phy_reg_bm;
 		ret_val = e1000e_determine_phy_address(hw);
 		if (ret_val) {
-			e_dbg("Cannot determine PHY addr. Erroring out\n");
+			netdev_dbg(hw->adapter->netdev,
+				   "Cannot determine PHY addr.  Erroring out\n");
 			return ret_val;
 		}
 	}
@@ -411,7 +412,8 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 
 	/* Can't read flash registers if the register set isn't mapped. */
 	if (!hw->flash_address) {
-		e_dbg("ERROR: Flash registers not mapped\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "ERROR: Flash registers not mapped\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -595,7 +597,8 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_config_fc_after_link_up(hw);
 	if (ret_val)
-		e_dbg("Error configuring flow control\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Error configuring flow control\n");
 
 out:
 	return ret_val;
@@ -687,7 +690,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		e_dbg("SW/FW/HW has locked the resource for too long.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "SW/FW/HW has locked the resource for too long\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -707,7 +711,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		e_dbg("Failed to acquire the semaphore.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Failed to acquire the semaphore\n");
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
 		ret_val = -E1000_ERR_CONFIG;
@@ -1220,7 +1225,8 @@ static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw)
 	 * leave the PHY in a bad state possibly resulting in no link.
 	 */
 	if (loop == 0)
-		e_dbg("LAN_INIT_DONE not set, increase timeout\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "LAN_INIT_DONE not set, increase timeout\n");
 
 	/* Clear the Init Done bit for the next init event */
 	data = er32(STATUS);
@@ -1506,8 +1512,8 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 
 			return 0;
 		}
-		e_dbg("Unable to determine valid NVM bank via EEC - "
-		       "reading flash signature\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Unable to determine valid NVM bank via EEC - reading flash signature\n");
 		/* fall-thru */
 	default:
 		/* set bank to 0 in case flash read fails */
@@ -1536,7 +1542,8 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 			return 0;
 		}
 
-		e_dbg("ERROR: No valid NVM bank present\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "ERROR: No valid NVM bank present\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1564,7 +1571,8 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
 	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1573,7 +1581,8 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	ret_val = e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val) {
-		e_dbg("Could not detect valid bank, assuming bank 0\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Could not detect valid bank, assuming bank 0\n");
 		bank = 0;
 	}
 
@@ -1599,7 +1608,8 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 out:
 	if (ret_val)
-		e_dbg("NVM read error: %d\n", ret_val);
+		netdev_dbg(hw->adapter->netdev,
+			   "NVM read error: %d\n", ret_val);
 
 	return ret_val;
 }
@@ -1621,8 +1631,8 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 
 	/* Check if the flash descriptor is valid */
 	if (hsfsts.hsf_status.fldesvalid == 0) {
-		e_dbg("Flash descriptor invalid.  "
-			 "SW Sequencing must be used.");
+		netdev_dbg(hw->adapter->netdev,
+			   "Flash descriptor invalid.  SW Sequencing must be used\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1671,7 +1681,8 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			hsfsts.hsf_status.flcdone = 1;
 			ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		} else {
-			e_dbg("Flash controller busy, cannot get access");
+			netdev_dbg(hw->adapter->netdev,
+				   "Flash controller busy, cannot get access\n");
 		}
 	}
 
@@ -1821,8 +1832,8 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 				/* Repeat for some time before giving up. */
 				continue;
 			} else if (hsfsts.hsf_status.flcdone == 0) {
-				e_dbg("Timeout error - flash cycle "
-					 "did not complete.");
+				netdev_dbg(hw->adapter->netdev,
+					   "Timeout error - flash cycle did not complete\n");
 				break;
 			}
 		}
@@ -1849,7 +1860,7 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
 	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw->adapter->netdev, "nvm parameter(s) out of bounds\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1900,7 +1911,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val =  e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val) {
-		e_dbg("Could not detect valid bank, assuming bank 0\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Could not detect valid bank, assuming bank 0\n");
 		bank = 0;
 	}
 
@@ -1974,7 +1986,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	if (ret_val) {
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
-		e_dbg("Flash commit failed.\n");
+		netdev_dbg(hw->adapter->netdev, "Flash commit failed\n");
 		nvm->ops.release(hw);
 		goto out;
 	}
@@ -2030,7 +2042,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 out:
 	if (ret_val)
-		e_dbg("NVM update error: %d\n", ret_val);
+		netdev_dbg(hw->adapter->netdev,
+			   "NVM update error: %d\n", ret_val);
 
 	return ret_val;
 }
@@ -2180,8 +2193,8 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 			/* Repeat for some time before giving up. */
 			continue;
 		if (hsfsts.hsf_status.flcdone == 0) {
-			e_dbg("Timeout error - flash cycle "
-				 "did not complete.");
+			netdev_dbg(hw->adapter->netdev,
+				   "Timeout error - flash cycle did not complete\n");
 			break;
 		}
 	} while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
@@ -2225,7 +2238,8 @@ static s32 e1000_retry_write_flash_byte_ich8lan(struct e1000_hw *hw,
 		return ret_val;
 
 	for (program_retries = 0; program_retries < 100; program_retries++) {
-		e_dbg("Retrying Byte %2.2X at offset %u\n", byte, offset);
+		netdev_dbg(hw->adapter->netdev,
+			   "Retrying Byte %02X at offset %u\n", byte, offset);
 		udelay(100);
 		ret_val = e1000_write_flash_byte_ich8lan(hw, offset, byte);
 		if (!ret_val)
@@ -2358,7 +2372,7 @@ static s32 e1000_valid_led_default_ich8lan(struct e1000_hw *hw, u16 *data)
 
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 
@@ -2488,10 +2502,11 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
 	if (ret_val) {
-		e_dbg("PCI-E Master disable polling has failed.\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "PCI-E Master disable polling has failed\n");
 	}
 
-	e_dbg("Masking off all interrupts\n");
+	netdev_dbg(hw->adapter->netdev, "Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
 	/*
@@ -2542,7 +2557,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 		ctrl |= E1000_CTRL_PHY_RST;
 	}
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	e_dbg("Issuing a global reset to ich8lan\n");
+	netdev_dbg(hw->adapter->netdev, "Issuing a global reset to ich8lan\n");
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
 	msleep(20);
 
@@ -2566,7 +2581,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 			 * return with an error. This can happen in situations
 			 * where there is no eeprom and prevents getting link.
 			 */
-			e_dbg("Auto Read Done did not complete\n");
+			netdev_dbg(hw->adapter->netdev,
+				   "Auto Read Done did not complete\n");
 		}
 	}
 	/* Dummy read to clear the phy wakeup bit after lcd reset */
@@ -2625,14 +2641,15 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = mac->ops.id_led_init(hw);
 	if (ret_val)
-		e_dbg("Error initializing identification LED\n");
+		netdev_dbg(hw->adapter->netdev,
+			   "Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 
 	/* Setup the receive address. */
 	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
 
 	/* Zero out the Multicast HASH table */
-	e_dbg("Zeroing the MTA\n");
+	netdev_dbg(hw->adapter->netdev, "Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
 
@@ -2778,8 +2795,8 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	 */
 	hw->fc.current_mode = hw->fc.requested_mode;
 
-	e_dbg("After fix-ups FlowControl is now = %x\n",
-		hw->fc.current_mode);
+	netdev_dbg(hw->adapter->netdev, "After fix-ups FlowControl is now = %x\n",
+		   hw->fc.current_mode);
 
 	/* Continue to configure the copper link. */
 	ret_val = e1000_setup_copper_link_ich8lan(hw);
@@ -2995,7 +3012,7 @@ void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 
 	if (hw->mac.type != e1000_ich8lan) {
-		e_dbg("Workaround applies to ICH8 only.\n");
+		netdev_dbg(hw->adapter->netdev, "Workaround applies to ICH8 only\n");
 		return;
 	}
 
@@ -3274,7 +3291,8 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 		if (status & E1000_STATUS_PHYRA)
 			ew32(STATUS, status & ~E1000_STATUS_PHYRA);
 		else
-			e_dbg("PHY Reset Asserted not set - needs delay\n");
+			netdev_dbg(hw->adapter->netdev,
+				   "PHY Reset Asserted not set - needs delay\n");
 	}
 
 	e1000e_get_cfg_done(hw);
@@ -3289,7 +3307,7 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 	} else {
 		if (e1000_valid_nvm_bank_detect_ich8lan(hw, &bank)) {
 			/* Maybe we should do a basic PHY config */
-			e_dbg("EEPROM not present\n");
+			netdev_dbg(hw->adapter->netdev, "EEPROM not present\n");
 			return -E1000_ERR_CONFIG;
 		}
 	}
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 2425ed1..777d4f0 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -154,12 +154,12 @@ void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 	u8 mac_addr[ETH_ALEN] = {0};
 
 	/* Setup the receive address */
-	e_dbg("Programming MAC Address into RAR[0]\n");
+	netdev_dbg(hw->adapter->netdev, "Programming MAC Address into RAR[0]\n");
 
 	e1000e_rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	e_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	netdev_dbg(hw->adapter->netdev, "Clearing RAR[1-%u]\n", rar_count-1);
 	for (i = 1; i < rar_count; i++)
 		e1000e_rar_set(hw, mac_addr, i);
 }
@@ -186,7 +186,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 	                         &nvm_alt_mac_addr_offset);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		goto out;
 	}
 
@@ -201,7 +201,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = e1000_read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			e_dbg("NVM Read Error\n");
+			netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 			goto out;
 		}
 
@@ -211,7 +211,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 
 	/* if multicast bit is set, the alternate address will not be used */
 	if (alt_mac_addr[0] & 0x01) {
-		e_dbg("Ignoring Alternate Mac Address with MC bit set\n");
+		netdev_dbg(hw->adapter->netdev, "Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
 
@@ -484,7 +484,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_config_fc_after_link_up(hw);
 	if (ret_val) {
-		e_dbg("Error configuring flow control\n");
+		netdev_dbg(hw->adapter->netdev, "Error configuring flow control\n");
 	}
 
 	return ret_val;
@@ -524,7 +524,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 			mac->autoneg_failed = 1;
 			return 0;
 		}
-		e_dbg("NOT RXing /C/, disable AutoNeg and force link.\n");
+		netdev_dbg(hw->adapter->netdev, "NOT RXing /C/, disable AutoNeg and force link\n");
 
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (mac->txcw & ~E1000_TXCW_ANE));
@@ -537,7 +537,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 		/* Configure Flow Control after forcing link up. */
 		ret_val = e1000e_config_fc_after_link_up(hw);
 		if (ret_val) {
-			e_dbg("Error configuring flow control\n");
+			netdev_dbg(hw->adapter->netdev, "Error configuring flow control\n");
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
@@ -547,7 +547,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		e_dbg("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		netdev_dbg(hw->adapter->netdev, "RXing /C/, enable AutoNeg and stop forcing link\n");
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
@@ -589,7 +589,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 			mac->autoneg_failed = 1;
 			return 0;
 		}
-		e_dbg("NOT RXing /C/, disable AutoNeg and force link.\n");
+		netdev_dbg(hw->adapter->netdev, "NOT RXing /C/, disable AutoNeg and force link\n");
 
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (mac->txcw & ~E1000_TXCW_ANE));
@@ -602,7 +602,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 		/* Configure Flow Control after forcing link up. */
 		ret_val = e1000e_config_fc_after_link_up(hw);
 		if (ret_val) {
-			e_dbg("Error configuring flow control\n");
+			netdev_dbg(hw->adapter->netdev, "Error configuring flow control\n");
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
@@ -612,7 +612,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		e_dbg("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		netdev_dbg(hw->adapter->netdev, "RXing /C/, enable AutoNeg and stop forcing link\n");
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
@@ -629,11 +629,11 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 		if (rxcw & E1000_RXCW_SYNCH) {
 			if (!(rxcw & E1000_RXCW_IV)) {
 				mac->serdes_has_link = true;
-				e_dbg("SERDES: Link up - forced.\n");
+				netdev_dbg(hw->adapter->netdev, "SERDES: Link up - forced\n");
 			}
 		} else {
 			mac->serdes_has_link = false;
-			e_dbg("SERDES: Link down - force failed.\n");
+			netdev_dbg(hw->adapter->netdev, "SERDES: Link down - force failed\n");
 		}
 	}
 
@@ -646,20 +646,20 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 			if (rxcw & E1000_RXCW_SYNCH) {
 				if (!(rxcw & E1000_RXCW_IV)) {
 					mac->serdes_has_link = true;
-					e_dbg("SERDES: Link up - autoneg "
-					   "completed sucessfully.\n");
+					netdev_dbg(hw->adapter->netdev, "SERDES: Link up - autoneg "
+					   "completed sucessfully\n");
 				} else {
 					mac->serdes_has_link = false;
-					e_dbg("SERDES: Link down - invalid"
-					   "codewords detected in autoneg.\n");
+					netdev_dbg(hw->adapter->netdev, "SERDES: Link down - invalid"
+					   "codewords detected in autoneg\n");
 				}
 			} else {
 				mac->serdes_has_link = false;
-				e_dbg("SERDES: Link down - no sync.\n");
+				netdev_dbg(hw->adapter->netdev, "SERDES: Link down - no sync\n");
 			}
 		} else {
 			mac->serdes_has_link = false;
-			e_dbg("SERDES: Link down - autoneg failed\n");
+			netdev_dbg(hw->adapter->netdev, "SERDES: Link down - autoneg failed\n");
 		}
 	}
 
@@ -690,7 +690,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &nvm_data);
 
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 
@@ -743,7 +743,7 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	 */
 	hw->fc.current_mode = hw->fc.requested_mode;
 
-	e_dbg("After fix-ups FlowControl is now = %x\n",
+	netdev_dbg(hw->adapter->netdev, "After fix-ups FlowControl is now = %x\n",
 		hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
@@ -757,7 +757,7 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
 	 */
-	e_dbg("Initializing the Flow Control address, type and timer regs\n");
+	netdev_dbg(hw->adapter->netdev, "Initializing the Flow Control address, type and timer regs\n");
 	ew32(FCT, FLOW_CONTROL_TYPE);
 	ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
 	ew32(FCAL, FLOW_CONTROL_ADDRESS_LOW);
@@ -827,7 +827,7 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
 		break;
 	default:
-		e_dbg("Flow control param set incorrectly\n");
+		netdev_dbg(hw->adapter->netdev, "Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
 		break;
 	}
@@ -865,7 +865,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 			break;
 	}
 	if (i == FIBER_LINK_UP_LIMIT) {
-		e_dbg("Never got a valid link from auto-neg!!!\n");
+		netdev_dbg(hw->adapter->netdev, "Never got a valid link from auto-neg!!!\n");
 		mac->autoneg_failed = 1;
 		/*
 		 * AutoNeg failed to achieve a link, so we'll call
@@ -875,13 +875,13 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 		 */
 		ret_val = mac->ops.check_for_link(hw);
 		if (ret_val) {
-			e_dbg("Error while checking for link\n");
+			netdev_dbg(hw->adapter->netdev, "Error while checking for link\n");
 			return ret_val;
 		}
 		mac->autoneg_failed = 0;
 	} else {
 		mac->autoneg_failed = 0;
-		e_dbg("Valid Link Found\n");
+		netdev_dbg(hw->adapter->netdev, "Valid Link Found\n");
 	}
 
 	return 0;
@@ -917,7 +917,7 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	 * then the link-up status bit will be set and the flow control enable
 	 * bits (RFCE and TFCE) will be set according to their negotiated value.
 	 */
-	e_dbg("Auto-negotiation enabled\n");
+	netdev_dbg(hw->adapter->netdev, "Auto-negotiation enabled\n");
 
 	ew32(CTRL, ctrl);
 	e1e_flush();
@@ -932,7 +932,7 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	    (er32(CTRL) & E1000_CTRL_SWDPIN1)) {
 		ret_val = e1000_poll_fiber_serdes_link_generic(hw);
 	} else {
-		e_dbg("No signal detected\n");
+		netdev_dbg(hw->adapter->netdev, "No signal detected\n");
 	}
 
 	return 0;
@@ -1028,7 +1028,7 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and Tx flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	e_dbg("hw->fc.current_mode = %u\n", hw->fc.current_mode);
+	netdev_dbg(hw->adapter->netdev, "hw->fc.current_mode = %u\n", hw->fc.current_mode);
 
 	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
@@ -1046,7 +1046,7 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
 		break;
 	default:
-		e_dbg("Flow control param set incorrectly\n");
+		netdev_dbg(hw->adapter->netdev, "Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -1087,7 +1087,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 	}
 
 	if (ret_val) {
-		e_dbg("Error forcing flow control settings\n");
+		netdev_dbg(hw->adapter->netdev, "Error forcing flow control settings\n");
 		return ret_val;
 	}
 
@@ -1111,8 +1111,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
-			e_dbg("Copper PHY and Auto Neg "
-				 "has not completed.\n");
+			netdev_dbg(hw->adapter->netdev, "Copper PHY and Auto Neg "
+				 "has not completed\n");
 			return ret_val;
 		}
 
@@ -1175,11 +1175,10 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			if (hw->fc.requested_mode == e1000_fc_full) {
 				hw->fc.current_mode = e1000_fc_full;
-				e_dbg("Flow Control = FULL.\r\n");
+				netdev_dbg(hw->adapter->netdev, "Flow Control = FULL\n");
 			} else {
 				hw->fc.current_mode = e1000_fc_rx_pause;
-				e_dbg("Flow Control = "
-					 "RX PAUSE frames only.\r\n");
+				netdev_dbg(hw->adapter->netdev, "Flow Control = RX PAUSE frames only\n");
 			}
 		}
 		/*
@@ -1195,7 +1194,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
-			e_dbg("Flow Control = Tx PAUSE frames only.\r\n");
+			netdev_dbg(hw->adapter->netdev, "Flow Control = Tx PAUSE frames only\n");
 		}
 		/*
 		 * For transmitting PAUSE frames ONLY.
@@ -1210,14 +1209,14 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_rx_pause;
-			e_dbg("Flow Control = Rx PAUSE frames only.\r\n");
+			netdev_dbg(hw->adapter->netdev, "Flow Control = Rx PAUSE frames only\n");
 		} else {
 			/*
 			 * Per the IEEE spec, at this point flow control
 			 * should be disabled.
 			 */
 			hw->fc.current_mode = e1000_fc_none;
-			e_dbg("Flow Control = NONE.\r\n");
+			netdev_dbg(hw->adapter->netdev, "Flow Control = NONE\n");
 		}
 
 		/*
@@ -1227,7 +1226,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = mac->ops.get_link_up_info(hw, &speed, &duplex);
 		if (ret_val) {
-			e_dbg("Error getting link speed and duplex\n");
+			netdev_dbg(hw->adapter->netdev, "Error getting link speed and duplex\n");
 			return ret_val;
 		}
 
@@ -1240,7 +1239,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = e1000e_force_mac_fc(hw);
 		if (ret_val) {
-			e_dbg("Error forcing flow control settings\n");
+			netdev_dbg(hw->adapter->netdev, "Error forcing flow control settings\n");
 			return ret_val;
 		}
 	}
@@ -1264,21 +1263,21 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
 	status = er32(STATUS);
 	if (status & E1000_STATUS_SPEED_1000) {
 		*speed = SPEED_1000;
-		e_dbg("1000 Mbs, ");
+		netdev_dbg(hw->adapter->netdev, "1000 Mbs, ");
 	} else if (status & E1000_STATUS_SPEED_100) {
 		*speed = SPEED_100;
-		e_dbg("100 Mbs, ");
+		netdev_dbg(hw->adapter->netdev, "100 Mbs, ");
 	} else {
 		*speed = SPEED_10;
-		e_dbg("10 Mbs, ");
+		netdev_dbg(hw->adapter->netdev, "10 Mbs, ");
 	}
 
 	if (status & E1000_STATUS_FD) {
 		*duplex = FULL_DUPLEX;
-		e_dbg("Full Duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Full Duplex\n");
 	} else {
 		*duplex = HALF_DUPLEX;
-		e_dbg("Half Duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Half Duplex\n");
 	}
 
 	return 0;
@@ -1324,7 +1323,7 @@ s32 e1000e_get_hw_semaphore(struct e1000_hw *hw)
 	}
 
 	if (i == timeout) {
-		e_dbg("Driver can't access device - SMBI bit is set.\n");
+		netdev_dbg(hw->adapter->netdev, "Driver can't access device - SMBI bit is set\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1343,7 +1342,7 @@ s32 e1000e_get_hw_semaphore(struct e1000_hw *hw)
 	if (i == timeout) {
 		/* Release semaphores */
 		e1000e_put_hw_semaphore(hw);
-		e_dbg("Driver can't access the NVM\n");
+		netdev_dbg(hw->adapter->netdev, "Driver can't access the NVM\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -1383,7 +1382,7 @@ s32 e1000e_get_auto_rd_done(struct e1000_hw *hw)
 	}
 
 	if (i == AUTO_READ_DONE_TIMEOUT) {
-		e_dbg("Auto read by HW from NVM has not completed.\n");
+		netdev_dbg(hw->adapter->netdev, "Auto read by HW from NVM has not completed\n");
 		return -E1000_ERR_RESET;
 	}
 
@@ -1404,7 +1403,7 @@ s32 e1000e_valid_led_default(struct e1000_hw *hw, u16 *data)
 
 	ret_val = e1000_read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 
@@ -1658,7 +1657,7 @@ s32 e1000e_disable_pcie_master(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		e_dbg("Master requests are pending.\n");
+		netdev_dbg(hw->adapter->netdev, "Master requests are pending\n");
 		return -E1000_ERR_MASTER_REQUESTS_PENDING;
 	}
 
@@ -1676,7 +1675,7 @@ void e1000e_reset_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		e_dbg("Not in Adaptive IFS mode!\n");
+		netdev_dbg(hw->adapter->netdev, "Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1704,7 +1703,7 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		e_dbg("Not in Adaptive IFS mode!\n");
+		netdev_dbg(hw->adapter->netdev, "Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1896,7 +1895,7 @@ s32 e1000e_acquire_nvm(struct e1000_hw *hw)
 	if (!timeout) {
 		eecd &= ~E1000_EECD_REQ;
 		ew32(EECD, eecd);
-		e_dbg("Could not acquire NVM grant\n");
+		netdev_dbg(hw->adapter->netdev, "Could not acquire NVM grant\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -2001,7 +2000,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 		}
 
 		if (!timeout) {
-			e_dbg("SPI NVM Status error\n");
+			netdev_dbg(hw->adapter->netdev, "SPI NVM Status error\n");
 			return -E1000_ERR_NVM;
 		}
 	}
@@ -2030,7 +2029,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw->adapter->netdev, "nvm parameter(s) out of bounds\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -2073,7 +2072,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw->adapter->netdev, "nvm parameter(s) out of bounds\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -2176,14 +2175,14 @@ s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw)
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
 		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			e_dbg("NVM Read Error\n");
+			netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 			return ret_val;
 		}
 		checksum += nvm_data;
 	}
 
 	if (checksum != (u16) NVM_SUM) {
-		e_dbg("NVM Checksum Invalid\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Checksum Invalid\n");
 		return -E1000_ERR_NVM;
 	}
 
@@ -2207,7 +2206,7 @@ s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
 	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
 		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			e_dbg("NVM Read Error while updating checksum.\n");
+			netdev_dbg(hw->adapter->netdev, "NVM Read Error while updating checksum\n");
 			return ret_val;
 		}
 		checksum += nvm_data;
@@ -2215,7 +2214,7 @@ s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
 	checksum = (u16) NVM_SUM - checksum;
 	ret_val = e1000_write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
-		e_dbg("NVM Write Error while updating checksum.\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Write Error while updating checksum\n");
 
 	return ret_val;
 }
@@ -2278,7 +2277,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 	/* Check that the host interface is enabled. */
 	hicr = er32(HICR);
 	if ((hicr & E1000_HICR_EN) == 0) {
-		e_dbg("E1000_HOST_EN bit disabled.\n");
+		netdev_dbg(hw->adapter->netdev, "E1000_HOST_EN bit disabled\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 	/* check the previous command is completed */
@@ -2290,7 +2289,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 	}
 
 	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-		e_dbg("Previous command timeout failed .\n");
+		netdev_dbg(hw->adapter->netdev, "Previous command timeout failed\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 
@@ -2563,14 +2562,14 @@ s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num)
 
 	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 	*pba_num = (u32)(nvm_data << 16);
 
 	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
-		e_dbg("NVM Read Error\n");
+		netdev_dbg(hw->adapter->netdev, "NVM Read Error\n");
 		return ret_val;
 	}
 	*pba_num |= nvm_data;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..4de5064 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -404,7 +406,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_ring *rx_ring = adapter->rx_ring;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
@@ -462,7 +463,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (adapter->flags2 & FLAG2_IS_DISCARDING) {
 			/* All receives must fit into a single buffer */
-			e_dbg("Receive packet consumed multiple buffers\n");
+			netdev_dbg(adapter->netdev, "Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			if (status & E1000_RXD_STAT_EOP)
@@ -581,7 +582,7 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	pci_read_config_word(adapter->pdev, PCI_STATUS, &pci_status);
 
 	/* detected Hardware unit hang */
-	e_err("Detected Hardware Unit Hang:\n"
+	netdev_err(adapter->netdev, "Detected Hardware Unit Hang:\n"
 	      "  TDH                  <%x>\n"
 	      "  TDT                  <%x>\n"
 	      "  next_to_use          <%x>\n"
@@ -712,7 +713,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 				  int *work_done, int work_to_do)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	union e1000_rx_desc_packet_split *rx_desc, *next_rxd;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -760,7 +760,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			adapter->flags2 |= FLAG2_IS_DISCARDING;
 
 		if (adapter->flags2 & FLAG2_IS_DISCARDING) {
-			e_dbg("Packet Split buffers didn't pick up the full "
+			netdev_dbg(adapter->netdev, "Packet Split buffers didn't pick up the full "
 			      "packet\n");
 			dev_kfree_skb_irq(skb);
 			if (staterr & E1000_RXD_STAT_EOP)
@@ -776,7 +776,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		length = le16_to_cpu(rx_desc->wb.middle.length0);
 
 		if (!length) {
-			e_dbg("Last part of the packet spanning multiple "
+			netdev_dbg(adapter->netdev, "Last part of the packet spanning multiple "
 			      "descriptors\n");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
@@ -1036,7 +1036,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			e_err("pskb_may_pull failed.\n");
+			netdev_err(adapter->netdev, "pskb_may_pull failed\n");
 			dev_kfree_skb(skb);
 			goto next_desc;
 		}
@@ -1457,8 +1457,8 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 					return;
 			}
 			/* MSI-X failed, so fall through and try MSI */
-			e_err("Failed to initialize MSI-X interrupts.  "
-			      "Falling back to MSI interrupts.\n");
+			netdev_err(adapter->netdev, "Failed to initialize MSI-X interrupts.  "
+			      "Falling back to MSI interrupts\n");
 			e1000e_reset_interrupt_capability(adapter);
 		}
 		adapter->int_mode = E1000E_INT_MODE_MSI;
@@ -1468,8 +1468,8 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 			adapter->flags |= FLAG_MSI_ENABLED;
 		} else {
 			adapter->int_mode = E1000E_INT_MODE_LEGACY;
-			e_err("Failed to initialize MSI interrupts.  Falling "
-			      "back to legacy interrupts.\n");
+			netdev_err(adapter->netdev, "Failed to initialize MSI interrupts.  Falling "
+			      "back to legacy interrupts\n");
 		}
 		/* Fall through */
 	case E1000E_INT_MODE_LEGACY:
@@ -1562,7 +1562,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, e1000_intr, IRQF_SHARED,
 			  netdev->name, netdev);
 	if (err)
-		e_err("Unable to allocate interrupt, Error: %d\n", err);
+		netdev_err(adapter->netdev, "Unable to allocate interrupt, Error: %d\n", err);
 
 	return err;
 }
@@ -1716,7 +1716,7 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	return 0;
 err:
 	vfree(tx_ring->buffer_info);
-	e_err("Unable to allocate memory for the transmit descriptor ring\n");
+	netdev_err(adapter->netdev, "Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
 }
 
@@ -1770,7 +1770,7 @@ err_pages:
 	}
 err:
 	vfree(rx_ring->buffer_info);
-	e_err("Unable to allocate memory for the transmit descriptor ring\n");
+	netdev_err(adapter->netdev, "Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
 }
 
@@ -1996,7 +1996,7 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 
 	return 0;
 err:
-	e_err("Unable to allocate memory for queues\n");
+	netdev_err(adapter->netdev, "Unable to allocate memory for queues\n");
 	kfree(adapter->rx_ring);
 	kfree(adapter->tx_ring);
 	return -ENOMEM;
@@ -2789,7 +2789,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		e1e_wphy(&adapter->hw, BM_WUC, 0);
 
 	if (mac->ops.init_hw(hw))
-		e_err("Hardware Error\n");
+		netdev_err(adapter->netdev, "Hardware Error\n");
 
 	/* additional part of the flow-control workaround above */
 	if (hw->mac.type == e1000_pchlan)
@@ -2948,7 +2948,7 @@ static irqreturn_t e1000_intr_msi_test(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	e_dbg("icr is %08X\n", icr);
+	netdev_dbg(adapter->netdev, "icr is %08X\n", icr);
 	if (icr & E1000_ICR_RXSEQ) {
 		adapter->flags &= ~FLAG_MSI_TEST_FAILED;
 		wmb();
@@ -3008,7 +3008,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
 		err = -EIO;
-		e_info("MSI interrupt test failed!\n");
+		netdev_info(adapter->netdev, "MSI interrupt test failed!\n");
 	}
 
 	free_irq(adapter->pdev->irq, netdev);
@@ -3018,7 +3018,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 		goto msi_test_failed;
 
 	/* okay so the test worked, restore settings */
-	e_dbg("MSI interrupt test succeeded!\n");
+	netdev_dbg(adapter->netdev, "MSI interrupt test succeeded!\n");
 msi_test_failed:
 	e1000e_set_interrupt_capability(adapter);
 	e1000_request_irq(adapter);
@@ -3058,7 +3058,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
 		return err;
 
 	/* back to INTx mode */
-	e_warn("MSI interrupt test failed, using legacy interrupt.\n");
+	netdev_warn(adapter->netdev, "MSI interrupt test failed, using legacy interrupt\n");
 
 	e1000_free_irq(adapter);
 
@@ -3135,7 +3135,7 @@ static int e1000_open(struct net_device *netdev)
 	if (adapter->int_mode != E1000E_INT_MODE_LEGACY) {
 		err = e1000_test_msi(adapter);
 		if (err) {
-			e_err("Interrupt allocation failed\n");
+			netdev_err(adapter->netdev, "Interrupt allocation failed\n");
 			goto err_req_irq;
 		}
 	}
@@ -3429,7 +3429,7 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 		ret_val |= e1e_rphy(hw, PHY_1000T_STATUS, &phy->stat1000);
 		ret_val |= e1e_rphy(hw, PHY_EXT_STATUS, &phy->estatus);
 		if (ret_val)
-			e_warn("Error reading PHY register\n");
+			netdev_warn(adapter->netdev, "Error reading PHY register\n");
 	} else {
 		/*
 		 * Do not read PHY registers if link is not up
@@ -3504,7 +3504,7 @@ bool e1000e_has_link(struct e1000_adapter *adapter)
 	if ((ret_val == E1000_ERR_PHY) && (hw->phy.type == e1000_phy_igp_3) &&
 	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
-		e_info("Gigabit has been disabled, downgrading speed\n");
+		netdev_info(adapter->netdev, "Gigabit has been disabled, downgrading speed\n");
 	}
 
 	return link_active;
@@ -3582,10 +3582,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				e1e_rphy(hw, PHY_AUTONEG_EXP, &autoneg_exp);
 
 				if (!(autoneg_exp & NWAY_ER_LP_NWAY_CAPS))
-					e_info("Autonegotiated half duplex but"
+					netdev_info(adapter->netdev, "Autonegotiated half duplex but"
 					       " link partner cannot autoneg. "
 					       " Try forcing full duplex if "
-					       "link gets many collisions.\n");
+					       "link gets many collisions\n");
 			}
 
 			/*
@@ -3627,7 +3627,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 				switch (adapter->link_speed) {
 				case SPEED_10:
 				case SPEED_100:
-					e_info("10/100 speed: disabling TSO\n");
+					netdev_info(adapter->netdev, "10/100 speed: disabling TSO\n");
 					netdev->features &= ~NETIF_F_TSO;
 					netdev->features &= ~NETIF_F_TSO6;
 					break;
@@ -3842,7 +3842,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 		break;
 	default:
 		if (unlikely(net_ratelimit()))
-			e_warn("checksum_partial proto=%x!\n",
+			netdev_warn(adapter->netdev, "checksum_partial proto=%x!\n",
 			       be16_to_cpu(protocol));
 		break;
 	}
@@ -4157,7 +4157,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 			pull_size = min((unsigned int)4, skb->data_len);
 			if (!__pskb_pull_tail(skb, pull_size)) {
-				e_err("__pskb_pull_tail failed.\n");
+				netdev_err(adapter->netdev, "__pskb_pull_tail failed\n");
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
@@ -4278,14 +4278,14 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	/* Jumbo frame support */
 	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
 	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-		e_err("Jumbo Frames not supported.\n");
+		netdev_err(adapter->netdev, "Jumbo Frames not supported\n");
 		return -EINVAL;
 	}
 
 	/* Supported frame sizes */
 	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
 	    (max_frame > adapter->max_hw_frame_size)) {
-		e_err("Unsupported MTU setting\n");
+		netdev_err(adapter->netdev, "Unsupported MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -4293,7 +4293,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		msleep(1);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
 	adapter->max_frame_size = max_frame;
-	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+	netdev_info(adapter->netdev, "changing MTU from %d to %d\n", netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 	if (netif_running(netdev))
 		e1000e_down(adapter);
@@ -4453,20 +4453,20 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 	/* activate PHY wakeup */
 	retval = hw->phy.ops.acquire(hw);
 	if (retval) {
-		e_err("Could not acquire PHY\n");
+		netdev_err(adapter->netdev, "Could not acquire PHY\n");
 		return retval;
 	}
 	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
 	                         (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
 	retval = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
 	if (retval) {
-		e_err("Could not read PHY page 769\n");
+		netdev_err(adapter->netdev, "Could not read PHY page 769\n");
 		goto out;
 	}
 	phy_reg |= BM_WUC_ENABLE_BIT | BM_WUC_HOST_WU_BIT;
 	retval = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
 	if (retval)
-		e_err("Could not set PHY Host Wakeup bit\n");
+		netdev_err(adapter->netdev, "Could not set PHY Host Wakeup bit\n");
 out:
 	hw->phy.ops.release(hw);
 
@@ -4688,7 +4688,7 @@ static int e1000_resume(struct pci_dev *pdev)
 
 		e1e_rphy(&adapter->hw, BM_WUS, &phy_data);
 		if (phy_data) {
-			e_info("PHY Wakeup cause - %s\n",
+			netdev_info(adapter->netdev, "PHY Wakeup cause - %s\n",
 				phy_data & E1000_WUS_EX ? "Unicast Packet" :
 				phy_data & E1000_WUS_MC ? "Multicast Packet" :
 				phy_data & E1000_WUS_BC ? "Broadcast Packet" :
@@ -4700,7 +4700,7 @@ static int e1000_resume(struct pci_dev *pdev)
 	} else {
 		u32 wus = er32(WUS);
 		if (wus) {
-			e_info("MAC Wakeup cause - %s\n",
+			netdev_info(adapter->netdev, "MAC Wakeup cause - %s\n",
 				wus & E1000_WUS_EX ? "Unicast Packet" :
 				wus & E1000_WUS_MC ? "Multicast Packet" :
 				wus & E1000_WUS_BC ? "Broadcast Packet" :
@@ -4805,7 +4805,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
-			"Cannot re-enable PCI device after reset.\n");
+			"Cannot re-enable PCI device after reset\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_set_master(pdev);
@@ -4867,16 +4867,16 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	u32 pba_num;
 
 	/* print bus type/speed/width info */
-	e_info("(PCI Express:2.5GB/s:%s) %pM\n",
+	netdev_info(adapter->netdev, "(PCI Express:2.5GB/s:%s) %pM\n",
 	       /* bus width */
 	       ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 	        "Width x1"),
 	       /* MAC address */
 	       netdev->dev_addr);
-	e_info("Intel(R) PRO/%s Network Connection\n",
+	netdev_info(adapter->netdev, "Intel(R) PRO/%s Network Connection\n",
 	       (hw->phy.type == e1000_phy_ife) ? "10/100" : "1000");
 	e1000e_read_pba_num(hw, &pba_num);
-	e_info("MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
+	netdev_info(adapter->netdev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
 	       hw->mac.type, hw->phy.type, (pba_num >> 8), (pba_num & 0xff));
 }
 
@@ -5073,7 +5073,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	if (e1000_check_reset_block(&adapter->hw))
-		e_info("PHY reset is blocked due to SOL/IDER session.\n");
+		netdev_info(adapter->netdev, "PHY reset is blocked due to SOL/IDER session\n");
 
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_HW_CSUM |
@@ -5111,7 +5111,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		if (e1000_validate_nvm_checksum(&adapter->hw) >= 0)
 			break;
 		if (i == 2) {
-			e_err("The NVM Checksum Is Not Valid\n");
+			netdev_err(adapter->netdev, "The NVM Checksum Is Not Valid\n");
 			err = -EIO;
 			goto err_eeprom;
 		}
@@ -5121,13 +5121,13 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* copy the MAC address */
 	if (e1000e_read_mac_addr(&adapter->hw))
-		e_err("NVM Read Error while reading MAC address\n");
+		netdev_err(adapter->netdev, "NVM Read Error while reading MAC address\n");
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		e_err("Invalid MAC Address: %pM\n", netdev->perm_addr);
+		netdev_err(adapter->netdev, "Invalid MAC Address: %pM\n", netdev->perm_addr);
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -5403,10 +5403,9 @@ static struct pci_driver e1000_driver = {
 static int __init e1000_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
-	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999 - 2009 Intel Corporation.\n",
-	       e1000e_driver_name);
+	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
+		e1000e_driver_version);
+	pr_info("Copyright (c) 1999 - 2009 Intel Corporation\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 2e39977..a4ee418 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -191,16 +191,16 @@ static int __devinit e1000_validate_option(unsigned int *value,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			e_info("%s Enabled\n", opt->name);
+			netdev_info(adapter->netdev, "%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			e_info("%s Disabled\n", opt->name);
+			netdev_info(adapter->netdev, "%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			e_info("%s set to %i\n", opt->name, *value);
+			netdev_info(adapter->netdev, "%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -212,7 +212,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					e_info("%s\n", ent->str);
+					netdev_info(adapter->netdev, "%s\n", ent->str);
 				return 0;
 			}
 		}
@@ -222,7 +222,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 		BUG();
 	}
 
-	e_info("Invalid %s value specified (%i) %s\n", opt->name, *value,
+	netdev_info(adapter->netdev, "Invalid %s value specified (%i) %s\n", opt->name, *value,
 	       opt->err);
 	*value = opt->def;
 	return -1;
@@ -243,8 +243,8 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 	int bd = adapter->bd_number;
 
 	if (bd >= E1000_MAX_NIC) {
-		e_notice("Warning: no configuration for board #%i\n", bd);
-		e_notice("Using defaults for all values\n");
+		netdev_notice(adapter->netdev, "Warning: no configuration for board #%i\n", bd);
+		netdev_notice(adapter->netdev, "Using defaults for all values\n");
 	}
 
 	{ /* Transmit Interrupt Delay */
@@ -338,15 +338,15 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->itr = InterruptThrottleRate[bd];
 			switch (adapter->itr) {
 			case 0:
-				e_info("%s turned off\n", opt.name);
+				netdev_info(adapter->netdev, "%s turned off\n", opt.name);
 				break;
 			case 1:
-				e_info("%s set to dynamic mode\n", opt.name);
+				netdev_info(adapter->netdev, "%s set to dynamic mode\n", opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
 			case 3:
-				e_info("%s set to dynamic conservative mode\n",
+				netdev_info(adapter->netdev, "%s set to dynamic conservative mode\n",
 					opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 7f3ceb9..7f10869 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -190,7 +190,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	u32 i, mdic = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		e_dbg("PHY Address %d is out of range\n", offset);
+		netdev_dbg(hw->adapter->netdev, "PHY Address %d is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -217,11 +217,11 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		e_dbg("MDI Read did not complete\n");
+		netdev_dbg(hw->adapter->netdev, "MDI Read did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		e_dbg("MDI Error\n");
+		netdev_dbg(hw->adapter->netdev, "MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
 	*data = (u16) mdic;
@@ -243,7 +243,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	u32 i, mdic = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		e_dbg("PHY Address %d is out of range\n", offset);
+		netdev_dbg(hw->adapter->netdev, "PHY Address %d is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -271,11 +271,11 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		e_dbg("MDI Write did not complete\n");
+		netdev_dbg(hw->adapter->netdev, "MDI Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		e_dbg("MDI Error\n");
+		netdev_dbg(hw->adapter->netdev, "MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -755,7 +755,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	/* Commit the changes. */
 	ret_val = e1000e_commit_phy(hw);
 	if (ret_val) {
-		e_dbg("Error committing the PHY changes\n");
+		netdev_dbg(hw->adapter->netdev, "Error committing the PHY changes\n");
 		return ret_val;
 	}
 
@@ -792,7 +792,7 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 
 	ret_val = e1000_phy_hw_reset(hw);
 	if (ret_val) {
-		e_dbg("Error resetting the PHY.\n");
+		netdev_dbg(hw->adapter->netdev, "Error resetting the PHY\n");
 		return ret_val;
 	}
 
@@ -805,7 +805,7 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 	/* disable lplu d0 during driver init */
 	ret_val = e1000_set_d0_lplu_state(hw, false);
 	if (ret_val) {
-		e_dbg("Error Disabling LPLU D0\n");
+		netdev_dbg(hw->adapter->netdev, "Error Disabling LPLU D0\n");
 		return ret_val;
 	}
 	/* Configure mdi-mdix settings */
@@ -941,39 +941,39 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 				 NWAY_AR_10T_HD_CAPS);
 	mii_1000t_ctrl_reg &= ~(CR_1000T_HD_CAPS | CR_1000T_FD_CAPS);
 
-	e_dbg("autoneg_advertised %x\n", phy->autoneg_advertised);
+	netdev_dbg(hw->adapter->netdev, "autoneg_advertised %x\n", phy->autoneg_advertised);
 
 	/* Do we want to advertise 10 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_HALF) {
-		e_dbg("Advertise 10mb Half duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 10mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
 	}
 
 	/* Do we want to advertise 10 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_FULL) {
-		e_dbg("Advertise 10mb Full duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 10mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_HALF) {
-		e_dbg("Advertise 100mb Half duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 100mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_FULL) {
-		e_dbg("Advertise 100mb Full duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 100mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
 	}
 
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (phy->autoneg_advertised & ADVERTISE_1000_HALF)
-		e_dbg("Advertise 1000mb Half duplex request denied!\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 1000mb Half duplex request denied!\n");
 
 	/* Do we want to advertise 1000 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_1000_FULL) {
-		e_dbg("Advertise 1000mb Full duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Advertise 1000mb Full duplex\n");
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
@@ -1032,7 +1032,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	default:
-		e_dbg("Flow control param set incorrectly\n");
+		netdev_dbg(hw->adapter->netdev, "Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		return ret_val;
 	}
@@ -1041,7 +1041,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+	netdev_dbg(hw->adapter->netdev, "Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		ret_val = e1e_wphy(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
@@ -1078,13 +1078,13 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_advertised == 0)
 		phy->autoneg_advertised = phy->autoneg_mask;
 
-	e_dbg("Reconfiguring auto-neg advertisement params\n");
+	netdev_dbg(hw->adapter->netdev, "Reconfiguring auto-neg advertisement params\n");
 	ret_val = e1000_phy_setup_autoneg(hw);
 	if (ret_val) {
-		e_dbg("Error Setting up Auto-Negotiation\n");
+		netdev_dbg(hw->adapter->netdev, "Error Setting up Auto-Negotiation\n");
 		return ret_val;
 	}
-	e_dbg("Restarting Auto-Neg\n");
+	netdev_dbg(hw->adapter->netdev, "Restarting Auto-Neg\n");
 
 	/*
 	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
@@ -1106,7 +1106,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		ret_val = e1000_wait_autoneg(hw);
 		if (ret_val) {
-			e_dbg("Error while waiting for "
+			netdev_dbg(hw->adapter->netdev, "Error while waiting for "
 				 "autoneg to complete\n");
 			return ret_val;
 		}
@@ -1144,10 +1144,10 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 		 * PHY will be set to 10H, 10F, 100H or 100F
 		 * depending on user settings.
 		 */
-		e_dbg("Forcing Speed and Duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Forcing Speed and Duplex\n");
 		ret_val = e1000_phy_force_speed_duplex(hw);
 		if (ret_val) {
-			e_dbg("Error Forcing Speed and Duplex\n");
+			netdev_dbg(hw->adapter->netdev, "Error Forcing Speed and Duplex\n");
 			return ret_val;
 		}
 	}
@@ -1164,11 +1164,11 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 		return ret_val;
 
 	if (link) {
-		e_dbg("Valid link established!!!\n");
+		netdev_dbg(hw->adapter->netdev, "Valid link established!!!\n");
 		e1000e_config_collision_dist(hw);
 		ret_val = e1000e_config_fc_after_link_up(hw);
 	} else {
-		e_dbg("Unable to establish link!!!\n");
+		netdev_dbg(hw->adapter->netdev, "Unable to establish link!!!\n");
 	}
 
 	return ret_val;
@@ -1214,12 +1214,12 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e_dbg("IGP PSCR: %X\n", phy_data);
+	netdev_dbg(hw->adapter->netdev, "IGP PSCR: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
+		netdev_dbg(hw->adapter->netdev, "Waiting for forced speed/duplex link on IGP phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
 						     PHY_FORCE_LIMIT,
@@ -1229,7 +1229,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			netdev_dbg(hw->adapter->netdev, "Link taking longer than expected\n");
 
 		/* Try once more */
 		ret_val = e1000e_phy_has_link_generic(hw,
@@ -1273,7 +1273,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	e_dbg("M88E1000 PSCR: %X\n", phy_data);
+	netdev_dbg(hw->adapter->netdev, "M88E1000 PSCR: %X\n", phy_data);
 
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
@@ -1291,7 +1291,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 		return ret_val;
 
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
+		netdev_dbg(hw->adapter->netdev, "Waiting for forced speed/duplex link on M88 phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
 						     100000, &link);
@@ -1300,7 +1300,7 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 		if (!link) {
 			if (hw->phy.type != e1000_phy_m88) {
-				e_dbg("Link taking longer than expected.\n");
+				netdev_dbg(hw->adapter->netdev, "Link taking longer than expected\n");
 			} else {
 				/*
 				 * We didn't get link.
@@ -1392,12 +1392,12 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	e_dbg("IFE PMC: %X\n", data);
+	netdev_dbg(hw->adapter->netdev, "IFE PMC: %X\n", data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on IFE phy.\n");
+		netdev_dbg(hw->adapter->netdev, "Waiting for forced speed/duplex link on IFE phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
 		                                     PHY_FORCE_LIMIT,
@@ -1407,7 +1407,7 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			netdev_dbg(hw->adapter->netdev, "Link taking longer than expected\n");
 
 		/* Try once more */
 		ret_val = e1000e_phy_has_link_generic(hw,
@@ -1457,11 +1457,11 @@ void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 	if (mac->forced_speed_duplex & E1000_ALL_HALF_DUPLEX) {
 		ctrl &= ~E1000_CTRL_FD;
 		*phy_ctrl &= ~MII_CR_FULL_DUPLEX;
-		e_dbg("Half Duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Half Duplex\n");
 	} else {
 		ctrl |= E1000_CTRL_FD;
 		*phy_ctrl |= MII_CR_FULL_DUPLEX;
-		e_dbg("Full Duplex\n");
+		netdev_dbg(hw->adapter->netdev, "Full Duplex\n");
 	}
 
 	/* Forcing 10mb or 100mb? */
@@ -1469,12 +1469,12 @@ void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
 		ctrl |= E1000_CTRL_SPD_100;
 		*phy_ctrl |= MII_CR_SPEED_100;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		e_dbg("Forcing 100mb\n");
+		netdev_dbg(hw->adapter->netdev, "Forcing 100mb\n");
 	} else {
 		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		*phy_ctrl |= MII_CR_SPEED_10;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		e_dbg("Forcing 10mb\n");
+		netdev_dbg(hw->adapter->netdev, "Forcing 10mb\n");
 	}
 
 	e1000e_config_collision_dist(hw);
@@ -1909,7 +1909,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 	bool link;
 
 	if (phy->media_type != e1000_media_type_copper) {
-		e_dbg("Phy info is only valid for copper media\n");
+		netdev_dbg(hw->adapter->netdev, "Phy info is only valid for copper media\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -1918,7 +1918,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!link) {
-		e_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw->adapter->netdev, "Phy info is only valid if link is up\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -1986,7 +1986,7 @@ s32 e1000e_get_phy_info_igp(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!link) {
-		e_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw->adapter->netdev, "Phy info is only valid if link is up\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -2046,7 +2046,7 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		e_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw->adapter->netdev, "Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -2169,7 +2169,7 @@ s32 e1000e_get_cfg_done(struct e1000_hw *hw)
  **/
 s32 e1000e_phy_init_script_igp3(struct e1000_hw *hw)
 {
-	e_dbg("Running IGP 3 PHY init script\n");
+	netdev_dbg(hw->adapter->netdev, "Running IGP 3 PHY init script\n");
 
 	/* PHY init IGP 3 */
 	/* Enable rise/fall, 10-mode work in class-A */
@@ -2618,7 +2618,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	/* Gig must be disabled for MDIO accesses to page 800 */
 	if ((hw->mac.type == e1000_pchlan) &&
 	   (!(er32(PHY_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)))
-		e_dbg("Attempting to access page 800 while gig enabled.\n");
+		netdev_dbg(hw->adapter->netdev, "Attempting to access page 800 while gig enabled\n");
 
 	/* All operations in this function are phy address 1 */
 	hw->phy.addr = 1;
@@ -2629,7 +2629,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
 	if (ret_val) {
-		e_dbg("Could not read PHY page 769\n");
+		netdev_dbg(hw->adapter->netdev, "Could not read PHY page 769\n");
 		goto out;
 	}
 
@@ -2637,7 +2637,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	phy_reg &= ~(BM_WUC_HOST_WU_BIT);
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
 	if (ret_val) {
-		e_dbg("Could not clear PHY page 769 bit 4\n");
+		netdev_dbg(hw->adapter->netdev, "Could not clear PHY page 769 bit 4\n");
 		goto out;
 	}
 
@@ -2645,7 +2645,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG,
 	                                    phy_reg | BM_WUC_ENABLE_BIT);
 	if (ret_val) {
-		e_dbg("Could not write PHY page 769 bit 2\n");
+		netdev_dbg(hw->adapter->netdev, "Could not write PHY page 769 bit 2\n");
 		goto out;
 	}
 
@@ -2656,7 +2656,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	/* Write the page 800 offset value using opcode 0x11 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ADDRESS_OPCODE, reg);
 	if (ret_val) {
-		e_dbg("Could not write address opcode to page 800\n");
+		netdev_dbg(hw->adapter->netdev, "Could not write address opcode to page 800\n");
 		goto out;
 	}
 
@@ -2671,7 +2671,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	}
 
 	if (ret_val) {
-		e_dbg("Could not access data value from page 800\n");
+		netdev_dbg(hw->adapter->netdev, "Could not access data value from page 800\n");
 		goto out;
 	}
 
@@ -2685,7 +2685,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	/* Clear 769_17.2 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
 	if (ret_val) {
-		e_dbg("Could not clear PHY page 769 bit 2\n");
+		netdev_dbg(hw->adapter->netdev, "Could not clear PHY page 769 bit 2\n");
 		goto out;
 	}
 
@@ -3015,7 +3015,7 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 	/* masking with 0x3F to remove the page from offset */
 	ret_val = e1000e_write_phy_reg_mdic(hw, addr_reg, (u16)offset & 0x3F);
 	if (ret_val) {
-		e_dbg("Could not write PHY the HV address register\n");
+		netdev_dbg(hw->adapter->netdev, "Could not write PHY the HV address register\n");
 		goto out;
 	}
 
@@ -3026,7 +3026,7 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 		ret_val = e1000e_write_phy_reg_mdic(hw, data_reg, *data);
 
 	if (ret_val) {
-		e_dbg("Could not read data value from HV data register\n");
+		netdev_dbg(hw->adapter->netdev, "Could not read data value from HV data register\n");
 		goto out;
 	}
 
@@ -3152,12 +3152,12 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	e_dbg("I82577_PHY_CTRL_2: %X\n", phy_data);
+	netdev_dbg(hw->adapter->netdev, "I82577_PHY_CTRL_2: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		e_dbg("Waiting for forced speed/duplex link on 82577 phy\n");
+		netdev_dbg(hw->adapter->netdev, "Waiting for forced speed/duplex link on 82577 phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
 		                                     PHY_FORCE_LIMIT,
@@ -3167,7 +3167,7 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			e_dbg("Link taking longer than expected.\n");
+			netdev_dbg(hw->adapter->netdev, "Link taking longer than expected\n");
 
 		/* Try once more */
 		ret_val = e1000e_phy_has_link_generic(hw,
@@ -3203,7 +3203,7 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		e_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw->adapter->netdev, "Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
-- 
1.7.0.14.g7e948


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
