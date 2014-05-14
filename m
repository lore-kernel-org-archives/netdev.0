From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbe: fix several concatenated strings to single line
Date: Wed, 14 May 2014 01:54:17 -0700
Message-ID: <1400057663-4578-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39254 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914AbaENIyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:38 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes various log strings that are split over multiple lines
in the ixgbe driver. This cleans up checkpatch.pl warnings, and makes it
easier to search the code for warning strings displayed to the kernel
log.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 17 ++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 25 +++++++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |  3 +--
 5 files changed, 19 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 272f2e7..bc7c924 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1285,8 +1285,7 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 		udelay(10);
 	}
 	if (i >= IXGBE_FDIRCMD_CMD_POLL) {
-		hw_dbg(hw, "Flow Director previous command isn't complete, "
-		       "aborting table re-initialization.\n");
+		hw_dbg(hw, "Flow Director previous command isn't complete, aborting table re-initialization.\n");
 		return IXGBE_ERR_FDIR_REINIT_FAILED;
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 390877f..4587bb9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -818,9 +818,8 @@ s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 			eeprom->address_bits = 16;
 		else
 			eeprom->address_bits = 8;
-		hw_dbg(hw, "Eeprom params: type = %d, size = %d, address bits: "
-			  "%d\n", eeprom->type, eeprom->word_size,
-			  eeprom->address_bits);
+		hw_dbg(hw, "Eeprom params: type = %d, size = %d, address bits: %d\n",
+		       eeprom->type, eeprom->word_size, eeprom->address_bits);
 	}
 
 	return 0;
@@ -1392,8 +1391,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 	}
 
 	if (i == timeout) {
-		hw_dbg(hw, "Driver can't access the Eeprom - SMBI Semaphore "
-		       "not granted.\n");
+		hw_dbg(hw, "Driver can't access the Eeprom - SMBI Semaphore not granted.\n");
 		/*
 		 * this release is particularly important because our attempts
 		 * above to get the semaphore may have succeeded, and if there
@@ -1438,14 +1436,12 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		 * was not granted because we don't have access to the EEPROM
 		 */
 		if (i >= timeout) {
-			hw_dbg(hw, "SWESMBI Software EEPROM semaphore "
-			       "not granted.\n");
+			hw_dbg(hw, "SWESMBI Software EEPROM semaphore not granted.\n");
 			ixgbe_release_eeprom_semaphore(hw);
 			status = IXGBE_ERR_EEPROM;
 		}
 	} else {
-		hw_dbg(hw, "Software semaphore SMBI between device drivers "
-		       "not granted.\n");
+		hw_dbg(hw, "Software semaphore SMBI between device drivers not granted.\n");
 	}
 
 	return status;
@@ -2663,8 +2659,7 @@ s32 ixgbe_disable_rx_buff_generic(struct ixgbe_hw *hw)
 
 	/* For informational purposes only */
 	if (i >= IXGBE_MAX_SECRX_POLL)
-		hw_dbg(hw, "Rx unit being enabled before security "
-		       "path fully disabled.  Continuing with init.\n");
+		hw_dbg(hw, "Rx unit being enabled before security path fully disabled. Continuing with init.\n");
 
 	return 0;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 30cab40..87e015d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1350,8 +1350,7 @@ static bool reg_pattern_test(struct ixgbe_adapter *adapter, u64 *data, int reg,
 		ixgbe_write_reg(&adapter->hw, reg, test_pattern[pat] & write);
 		val = ixgbe_read_reg(&adapter->hw, reg);
 		if (val != (test_pattern[pat] & write & mask)) {
-			e_err(drv, "pattern test reg %04X failed: got "
-			      "0x%08X expected 0x%08X\n",
+			e_err(drv, "pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
 			      reg, val, (test_pattern[pat] & write & mask));
 			*data = reg;
 			ixgbe_write_reg(&adapter->hw, reg, before);
@@ -1375,8 +1374,8 @@ static bool reg_set_and_check(struct ixgbe_adapter *adapter, u64 *data, int reg,
 	ixgbe_write_reg(&adapter->hw, reg, write & mask);
 	val = ixgbe_read_reg(&adapter->hw, reg);
 	if ((write & mask) != (val & mask)) {
-		e_err(drv, "set/check reg %04X test failed: got 0x%08X "
-		      "expected 0x%08X\n", reg, (val & mask), (write & mask));
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
+		      reg, (val & mask), (write & mask));
 		*data = reg;
 		ixgbe_write_reg(&adapter->hw, reg, before);
 		return true;
@@ -1423,8 +1422,8 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 	ixgbe_write_reg(&adapter->hw, IXGBE_STATUS, toggle);
 	after = ixgbe_read_reg(&adapter->hw, IXGBE_STATUS) & toggle;
 	if (value != after) {
-		e_err(drv, "failed STATUS register test got: 0x%08X "
-		      "expected: 0x%08X\n", after, value);
+		e_err(drv, "failed STATUS register test got: 0x%08X expected: 0x%08X\n",
+		      after, value);
 		*data = 1;
 		return 1;
 	}
@@ -1980,10 +1979,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 			int i;
 			for (i = 0; i < adapter->num_vfs; i++) {
 				if (adapter->vfinfo[i].clear_to_send) {
-					netdev_warn(netdev, "%s",
-						    "offline diagnostic is not "
-						    "supported when VFs are "
-						    "present\n");
+					netdev_warn(netdev, "offline diagnostic is not supported when VFs are present\n");
 					data[0] = 1;
 					data[1] = 1;
 					data[2] = 1;
@@ -2030,8 +2026,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		 * loopback diagnostic. */
 		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
 				      IXGBE_FLAG_VMDQ_ENABLED)) {
-			e_info(hw, "Skip MAC loopback diagnostic in VT "
-			       "mode\n");
+			e_info(hw, "Skip MAC loopback diagnostic in VT mode\n");
 			data[3] = 0;
 			goto skip_loopback;
 		}
@@ -2215,8 +2210,7 @@ static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter)
 	    adapter->rx_itr_setting > IXGBE_MIN_RSC_ITR) {
 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
 			adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
-			e_info(probe, "rx-usecs value high enough "
-				      "to re-enable RSC\n");
+			e_info(probe, "rx-usecs value high enough to re-enable RSC\n");
 			return true;
 		}
 	/* if interrupt rate is too high then disable RSC */
@@ -2780,8 +2774,7 @@ static int ixgbe_set_rss_hash_opt(struct ixgbe_adapter *adapter,
 
 		if ((flags2 & UDP_RSS_FLAGS) &&
 		    !(adapter->flags2 & UDP_RSS_FLAGS))
-			e_warn(drv, "enabling UDP RSS: fragmented packets"
-			       " may arrive out of order to the stack above\n");
+			e_warn(drv, "enabling UDP RSS: fragmented packets may arrive out of order to the stack above\n");
 
 		adapter->flags2 = flags2;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 2067d39..2d9451e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1113,8 +1113,8 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	err = pci_enable_msi(adapter->pdev);
 	if (err) {
 		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
-			     "Unable to allocate MSI interrupt, "
-			     "falling back to legacy.  Error: %d\n", err);
+			     "Unable to allocate MSI interrupt, falling back to legacy.  Error: %d\n",
+			     err);
 		return;
 	}
 	adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 5a97870..40dd798 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -712,8 +712,7 @@ static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw)
 			udelay(50);
 		}
 	} else {
-		hw_dbg(hw, "Software semaphore SMBI between device drivers "
-			   "not granted.\n");
+		hw_dbg(hw, "Software semaphore SMBI between device drivers not granted.\n");
 	}
 
 	return status;
-- 
1.9.0
