From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] i40evf: disable unused flags
Date: Wed, 31 May 2017 03:48:50 -0700
Message-ID: <20170531104856.47929-4-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdEaKtB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:01 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The i40evf hardware doesn't have any way to ever report FCoE enabled
so just force the code to always report FCoE is disabled, remove the
unused defines, and mark the OP as reserved.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c   | 3 +--
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 43f10761f4ba..6729624fda5b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -1105,8 +1105,7 @@ void i40e_vf_parse_hw_config(struct i40e_hw *hw,
 	hw->dev_caps.num_msix_vectors_vf = msg->max_vectors;
 	hw->dev_caps.dcb = msg->vf_offload_flags &
 			   I40E_VIRTCHNL_VF_OFFLOAD_L2;
-	hw->dev_caps.fcoe = (msg->vf_offload_flags &
-			     I40E_VIRTCHNL_VF_OFFLOAD_FCOE) ? 1 : 0;
+	hw->dev_caps.fcoe = 0;
 	for (i = 0; i < msg->num_vsis; i++) {
 		if (vsi_res->vsi_type == I40E_VSI_SRIOV) {
 			ether_addr_copy(hw->mac.perm_addr,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index c5ad0388c3d5..b0b8de5d6f57 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -79,7 +79,7 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_DEL_VLAN = 13,
 	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE = 14,
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
-	I40E_VIRTCHNL_OP_FCOE = 16,
+	I40E_VIRTCHNL_OP_RSVD = 16,
 	I40E_VIRTCHNL_OP_EVENT = 17, /* must ALWAYS be 17 */
 	I40E_VIRTCHNL_OP_IWARP = 20,
 	I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP = 21,
@@ -155,7 +155,6 @@ struct i40e_virtchnl_vsi_resource {
 /* VF offload flags */
 #define I40E_VIRTCHNL_VF_OFFLOAD_L2		0x00000001
 #define I40E_VIRTCHNL_VF_OFFLOAD_IWARP		0x00000002
-#define I40E_VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
 #define I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR	0x00000020
-- 
2.12.2
