From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] fm10k: remove is_slot_appropriate
Date: Tue, 15 Sep 2015 17:36:37 -0700
Message-ID: <1442363803-47237-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58335 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbbIPAgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:50 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This function is no longer used now that we have updated fm10k_slot_warn
functionality.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 14 --------------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h |  1 -
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c   | 14 --------------
 3 files changed, 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 3ca0233..241b969 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -185,19 +185,6 @@ static s32 fm10k_init_hw_pf(struct fm10k_hw *hw)
 }
 
 /**
- *  fm10k_is_slot_appropriate_pf - Indicate appropriate slot for this SKU
- *  @hw: pointer to hardware structure
- *
- *  Looks at the PCIe bus info to confirm whether or not this slot can support
- *  the necessary bandwidth for this device.
- **/
-static bool fm10k_is_slot_appropriate_pf(struct fm10k_hw *hw)
-{
-	return (hw->bus.speed == hw->bus_caps.speed) &&
-	       (hw->bus.width == hw->bus_caps.width);
-}
-
-/**
  *  fm10k_update_vlan_pf - Update status of VLAN ID in VLAN filter table
  *  @hw: pointer to hardware structure
  *  @vid: VLAN ID to add to table
@@ -1849,7 +1836,6 @@ static struct fm10k_mac_ops mac_ops_pf = {
 	.init_hw		= &fm10k_init_hw_pf,
 	.start_hw		= &fm10k_start_hw_generic,
 	.stop_hw		= &fm10k_stop_hw_generic,
-	.is_slot_appropriate	= &fm10k_is_slot_appropriate_pf,
 	.update_vlan		= &fm10k_update_vlan_pf,
 	.read_mac_addr		= &fm10k_read_mac_addr_pf,
 	.update_uc_addr		= &fm10k_update_uc_addr_pf,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 2a17d82..bac8d48 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -521,7 +521,6 @@ struct fm10k_mac_ops {
 	s32 (*stop_hw)(struct fm10k_hw *);
 	s32 (*get_bus_info)(struct fm10k_hw *);
 	s32 (*get_host_state)(struct fm10k_hw *, bool *);
-	bool (*is_slot_appropriate)(struct fm10k_hw *);
 	s32 (*update_vlan)(struct fm10k_hw *, u32, u8, bool);
 	s32 (*read_mac_addr)(struct fm10k_hw *);
 	s32 (*update_uc_addr)(struct fm10k_hw *, u16, const u8 *,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 94f0f6a..36c8b0a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -131,19 +131,6 @@ static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
 	return 0;
 }
 
-/**
- *  fm10k_is_slot_appropriate_vf - Indicate appropriate slot for this SKU
- *  @hw: pointer to hardware structure
- *
- *  Looks at the PCIe bus info to confirm whether or not this slot can support
- *  the necessary bandwidth for this device. Since the VF has no control over
- *  the "slot" it is in, always indicate that the slot is appropriate.
- **/
-static bool fm10k_is_slot_appropriate_vf(struct fm10k_hw *hw)
-{
-	return true;
-}
-
 /* This structure defines the attibutes to be parsed below */
 const struct fm10k_tlv_attr fm10k_mac_vlan_msg_attr[] = {
 	FM10K_TLV_ATTR_U32(FM10K_MAC_VLAN_MSG_VLAN),
@@ -552,7 +539,6 @@ static struct fm10k_mac_ops mac_ops_vf = {
 	.init_hw		= &fm10k_init_hw_vf,
 	.start_hw		= &fm10k_start_hw_generic,
 	.stop_hw		= &fm10k_stop_hw_vf,
-	.is_slot_appropriate	= &fm10k_is_slot_appropriate_vf,
 	.update_vlan		= &fm10k_update_vlan_vf,
 	.read_mac_addr		= &fm10k_read_mac_addr_vf,
 	.update_uc_addr		= &fm10k_update_uc_addr_vf,
-- 
2.4.3
