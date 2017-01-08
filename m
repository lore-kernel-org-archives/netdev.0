From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] fm10k-shared: use mac-> instead of hw->mac.
Date: Sun,  8 Jan 2017 02:10:27 -0800
Message-ID: <20170108101034.119851-2-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59283 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162178AbdAHKKr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:47 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Since a pointer "mac" to fm10k_mac_info structure exists, use it to
access the contents of its members.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
index dd95ac4..62a6ad9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -506,7 +506,7 @@ s32 fm10k_get_host_state_generic(struct fm10k_hw *hw, bool *host_ready)
 		goto out;
 
 	/* if we somehow dropped the Tx enable we should reset */
-	if (hw->mac.tx_ready && !(txdctl & FM10K_TXDCTL_ENABLE)) {
+	if (mac->tx_ready && !(txdctl & FM10K_TXDCTL_ENABLE)) {
 		ret_val = FM10K_ERR_RESET_REQUESTED;
 		goto out;
 	}
@@ -523,8 +523,8 @@ s32 fm10k_get_host_state_generic(struct fm10k_hw *hw, bool *host_ready)
 
 	/* interface cannot receive traffic without logical ports */
 	if (mac->dglort_map == FM10K_DGLORTMAP_NONE) {
-		if (hw->mac.ops.request_lport_map)
-			ret_val = hw->mac.ops.request_lport_map(hw);
+		if (mac->ops.request_lport_map)
+			ret_val = mac->ops.request_lport_map(hw);
 
 		goto out;
 	}
-- 
2.9.3
