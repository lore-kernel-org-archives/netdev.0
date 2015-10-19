From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/17] i40evf: fix overlong BIT defines
Date: Mon, 19 Oct 2015 15:49:16 -0700
Message-ID: <1445294971-44714-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbbJSWtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:33 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The defines from the RSS enabling call were mistakenly
missed in the patches to the i40e which should have been
to i40evf as well.

This is a follow up to (commit ed921559886dd40528) "fix
32 bit build warnings".

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c |  5 -----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   | 14 +++++++-------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 7435fb3..a4c5a49 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -443,9 +443,6 @@ static i40e_status i40e_aq_get_set_rss_lut(struct i40e_hw *hw,
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT) &
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_MASK));
 
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)lut));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)lut));
-
 	status = i40evf_asq_send_command(hw, &desc, lut, lut_size, NULL);
 
 	return status;
@@ -520,8 +517,6 @@ static i40e_status i40e_aq_get_set_rss_key(struct i40e_hw *hw,
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_SHIFT) &
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_MASK));
 	cmd_resp->vsi_id |= cpu_to_le16((u16)I40E_AQC_SET_RSS_KEY_VSI_VALID);
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)key));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)key));
 
 	status = i40evf_asq_send_command(hw, &desc, key, key_size, NULL);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index c4f5a4e..03275eb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -89,16 +89,16 @@ enum i40e_dyn_idx_t {
 	BIT_ULL(I40E_FILTER_PCTYPE_L2_PAYLOAD))
 
 #define I40E_DEFAULT_RSS_HENA_EXPANDED (I40E_DEFAULT_RSS_HENA | \
-		BIT(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK) | \
-		BIT(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
-		BIT(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
-		BIT(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK) | \
-		BIT(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
-		BIT(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP))
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP))
 
 #define i40e_pf_get_default_rss_hena(pf) \
 	(((pf)->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE) ? \
-		I40E_DEFAULT_RSS_HENA_EXPANDED : I40E_DEFAULT_RSS_HENA)
+	  I40E_DEFAULT_RSS_HENA_EXPANDED : I40E_DEFAULT_RSS_HENA)
 
 /* Supported Rx Buffer Sizes */
 #define I40E_RXBUFFER_512   512    /* Used for packet split */
-- 
2.4.3
