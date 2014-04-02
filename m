From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 2/4] e1000e/igb/ixgbe/i40e: fix message terminations
Date: Wed,  2 Apr 2014 02:52:17 +0200
Message-ID: <1396399939-18420-3-git-send-email-kubakici@wp.pl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:45296 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbaDBAxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 20:53:15 -0400
In-Reply-To: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add \n at the end of messages where missing, remove all \r.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/e1000e/netdev.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c      |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |  4 ++--
 drivers/net/ethernet/intel/igb/e1000_i210.c     |  2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c      | 13 ++++++-------
 drivers/net/ethernet/intel/igb/igb_ptp.c        |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    |  4 ++--
 10 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index dce377b..d8c2a57 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1165,7 +1165,7 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
 		adapter->tx_hwtstamp_skb = NULL;
 		adapter->tx_hwtstamp_timeouts++;
-		e_warn("clearing Tx timestamp hang");
+		e_warn("clearing Tx timestamp hang\n");
 	} else {
 		/* reschedule to check later */
 		schedule_work(&adapter->tx_hwtstamp_work);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 262bdf1..8129918 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -160,7 +160,7 @@ static i40e_status i40e_poll_sr_srctl_done_bit(struct i40e_hw *hw)
 		udelay(5);
 	}
 	if (ret_code == I40E_ERR_TIMEOUT)
-		hw_dbg(hw, "Done bit in GLNVM_SRCTL not set");
+		hw_dbg(hw, "Done bit in GLNVM_SRCTL not set\n");
 	return ret_code;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 545079c..562ed20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -240,7 +240,7 @@ static void i40e_ptp_tx_work(struct work_struct *work)
 		pf->ptp_tx_skb = NULL;
 		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 		pf->tx_hwtstamp_timeouts++;
-		dev_warn(&pf->pdev->dev, "clearing Tx timestamp hang");
+		dev_warn(&pf->pdev->dev, "clearing Tx timestamp hang\n");
 		return;
 	}
 
@@ -322,7 +322,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 		pf->last_rx_ptp_check = jiffies;
 		pf->rx_hwtstamp_cleared++;
 		dev_warn(&vsi->back->pdev->dev,
-			 "%s: clearing Rx timestamp hang",
+			 "%s: clearing Rx timestamp hang\n",
 			 __func__);
 	}
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9436527..ee669c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -418,7 +418,7 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		}
 		break;
 	default:
-		dev_info(&pf->pdev->dev, "Could not specify spec type %d",
+		dev_info(&pf->pdev->dev, "Could not specify spec type %d\n",
 			 input->flow_type);
 		ret = -EINVAL;
 	}
@@ -478,7 +478,7 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 				pf->flags |= I40E_FLAG_FDIR_REQUIRES_REINIT;
 			}
 		} else {
-			dev_info(&pdev->dev, "FD filter programming error");
+			dev_info(&pdev->dev, "FD filter programming error\n");
 		}
 	} else if (error ==
 			  (0x1 << I40E_RX_PROG_STATUS_DESC_NO_FD_ENTRY_SHIFT)) {
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index db96339..f67f8a1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -365,7 +365,7 @@ static s32 igb_read_invm_word_i210(struct e1000_hw *hw, u8 address, u16 *data)
 			word_address = INVM_DWORD_TO_WORD_ADDRESS(invm_dword);
 			if (word_address == address) {
 				*data = INVM_DWORD_TO_WORD_DATA(invm_dword);
-				hw_dbg("Read INVM Word 0x%02x = %x",
+				hw_dbg("Read INVM Word 0x%02x = %x\n",
 					  address, *data);
 				status = E1000_SUCCESS;
 				break;
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 5910a93..1e0c404 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -929,11 +929,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			if (hw->fc.requested_mode == e1000_fc_full) {
 				hw->fc.current_mode = e1000_fc_full;
-				hw_dbg("Flow Control = FULL.\r\n");
+				hw_dbg("Flow Control = FULL.\n");
 			} else {
 				hw->fc.current_mode = e1000_fc_rx_pause;
-				hw_dbg("Flow Control = "
-				       "RX PAUSE frames only.\r\n");
+				hw_dbg("Flow Control = RX PAUSE frames only.\n");
 			}
 		}
 		/* For receiving PAUSE frames ONLY.
@@ -948,7 +947,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
-			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = TX PAUSE frames only.\n");
 		}
 		/* For transmitting PAUSE frames ONLY.
 		 *
@@ -962,7 +961,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_rx_pause;
-			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\n");
 		}
 		/* Per the IEEE spec, at this point flow control should be
 		 * disabled.  However, we want to consider that we could
@@ -988,10 +987,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 (hw->fc.requested_mode == e1000_fc_tx_pause) ||
 			 (hw->fc.strict_ieee)) {
 			hw->fc.current_mode = e1000_fc_none;
-			hw_dbg("Flow Control = NONE.\r\n");
+			hw_dbg("Flow Control = NONE.\n");
 		} else {
 			hw->fc.current_mode = e1000_fc_rx_pause;
-			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\n");
 		}
 
 		/* Now we need to do one last check...  If we auto-
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 2cca8fd..bc33c4c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -389,7 +389,7 @@ static void igb_ptp_tx_work(struct work_struct *work)
 		adapter->ptp_tx_skb = NULL;
 		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 		adapter->tx_hwtstamp_timeouts++;
-		dev_warn(&adapter->pdev->dev, "clearing Tx timestamp hang");
+		dev_warn(&adapter->pdev->dev, "clearing Tx timestamp hang\n");
 		return;
 	}
 
@@ -456,7 +456,7 @@ void igb_ptp_rx_hang(struct igb_adapter *adapter)
 		rd32(E1000_RXSTMPH);
 		adapter->last_rx_ptp_check = jiffies;
 		adapter->rx_hwtstamp_cleared++;
-		dev_warn(&adapter->pdev->dev, "clearing Rx timestamp hang");
+		dev_warn(&adapter->pdev->dev, "clearing Rx timestamp hang\n");
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 24fba39..981b8a7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1195,7 +1195,7 @@ static s32 ixgbe_detect_eeprom_page_size_generic(struct ixgbe_hw *hw,
 	 */
 	hw->eeprom.word_page_size = IXGBE_EEPROM_PAGE_SIZE_MAX - data[0];
 
-	hw_dbg(hw, "Detected EEPROM page size = %d words.",
+	hw_dbg(hw, "Detected EEPROM page size = %d words.\n",
 	       hw->eeprom.word_page_size);
 out:
 	return status;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 23f7652..a76af8e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -536,7 +536,7 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 
 	if (time_out == max_time_out) {
 		status = IXGBE_ERR_LINK_SETUP;
-		hw_dbg(hw, "ixgbe_setup_phy_link_generic: time out");
+		hw_dbg(hw, "ixgbe_setup_phy_link_generic: time out\n");
 	}
 
 	return status;
@@ -745,7 +745,7 @@ s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
 
 	if (time_out == max_time_out) {
 		status = IXGBE_ERR_LINK_SETUP;
-		hw_dbg(hw, "ixgbe_setup_phy_link_tnx: time out");
+		hw_dbg(hw, "ixgbe_setup_phy_link_tnx: time out\n");
 	}
 
 	return status;
@@ -1175,7 +1175,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				status = 0;
 			} else {
 				if (hw->allow_unsupported_sfp) {
-					e_warn(drv, "WARNING: Intel (R) Network Connections are quality tested using Intel (R) Ethernet Optics.  Using untested modules is not supported and may cause unstable operation or damage to the module or the adapter.  Intel Corporation is not responsible for any harm caused by using untested modules.");
+					e_warn(drv, "WARNING: Intel (R) Network Connections are quality tested using Intel (R) Ethernet Optics.  Using untested modules is not supported and may cause unstable operation or damage to the module or the adapter.  Intel Corporation is not responsible for any harm caused by using untested modules.\n");
 					status = 0;
 				} else {
 					hw_dbg(hw,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 63515a6..6fef807 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -461,7 +461,7 @@ void ixgbe_ptp_rx_hang(struct ixgbe_adapter *adapter)
 		IXGBE_READ_REG(hw, IXGBE_RXSTMPH);
 		adapter->last_rx_ptp_check = jiffies;
 
-		e_warn(drv, "clearing RX Timestamp hang");
+		e_warn(drv, "clearing RX Timestamp hang\n");
 	}
 }
 
@@ -517,7 +517,7 @@ static void ixgbe_ptp_tx_hwtstamp_work(struct work_struct *work)
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
 		clear_bit_unlock(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state);
-		e_warn(drv, "clearing Tx Timestamp hang");
+		e_warn(drv, "clearing Tx Timestamp hang\n");
 		return;
 	}
 
-- 
1.9.0
