From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] fm10k: use ether_addr_equal instead of memcmp
Date: Tue, 22 Dec 2015 06:02:06 -0800
Message-ID: <1450792932-96015-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53515 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485AbbLVODO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:14 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When comparing MAC addresses, use ether_addr_equal instead of memcmp to
ETH_ALEN length. Found and replaced using the following sed:

 sed -e 's/memcmp\x28\(.*\), ETH_ALEN\x29/!ether_addr_equal\x28\1\x29/'

Reported-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c  | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c  | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 202468f..9c6ed88 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1191,7 +1191,7 @@ static s32 fm10k_mbx_mac_addr(struct fm10k_hw *hw, u32 **results,
 
 	/* MAC was changed so we need reset */
 	if (is_valid_ether_addr(hw->mac.perm_addr) &&
-	    memcmp(hw->mac.perm_addr, hw->mac.addr, ETH_ALEN))
+	    !ether_addr_equal(hw->mac.perm_addr, hw->mac.addr))
 		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
 
 	/* VLAN override was changed, or default VLAN changed */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 808307e..7dd7ca8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1250,7 +1250,7 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 
 		/* block attempts to set MAC for a locked device */
 		if (is_valid_ether_addr(vf_info->mac) &&
-		    memcmp(mac, vf_info->mac, ETH_ALEN))
+		    !ether_addr_equal(mac, vf_info->mac))
 			return FM10K_ERR_PARAM;
 
 		set = !(vlan & FM10K_VLAN_CLEAR);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
index 95afb5c..ab01bb3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -755,7 +755,7 @@ parse_nested:
 		err = fm10k_tlv_attr_get_mac_vlan(
 					results[FM10K_TEST_MSG_MAC_ADDR],
 					result_mac, &result_vlan);
-		if (!err && memcmp(test_mac, result_mac, ETH_ALEN))
+		if (!err && !ether_addr_equal(test_mac, result_mac))
 			err = FM10K_ERR_INVALID_VALUE;
 		if (!err && test_vlan != result_vlan)
 			err = FM10K_ERR_INVALID_VALUE;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 5445c0f..f1dc6e8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -298,7 +298,7 @@ static s32 fm10k_update_uc_addr_vf(struct fm10k_hw *hw, u16 glort,
 
 	/* verify we are not locked down on the MAC address */
 	if (is_valid_ether_addr(hw->mac.perm_addr) &&
-	    memcmp(hw->mac.perm_addr, mac, ETH_ALEN))
+	    !ether_addr_equal(hw->mac.perm_addr, mac))
 		return FM10K_ERR_PARAM;
 
 	/* add bit to notify us if this is a set or clear operation */
-- 
2.5.0
