From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/18] fm10k: don't store sw_vid at reset
Date: Tue, 15 Sep 2015 17:36:36 -0700
Message-ID: <1442363803-47237-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903AbbIPAgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:49 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If we store the sw_vid at reset of PF, then we accidentally prevent the
VF from receiving the message to update its default VID. This only
occurs if the VF is created before the PF has come up, which is the
standard way of creating VFs when using the module parameter.

This fixes an issue where we request the incorrect MAC/VLAN
combinations, and prevents us from accidentally reporting some frames as
VLAN tagged.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 94571e6..0e25a80 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -228,9 +228,6 @@ int fm10k_iov_resume(struct pci_dev *pdev)
 		hw->iov.ops.set_lport(hw, vf_info, i,
 				      FM10K_VF_FLAG_MULTI_CAPABLE);
 
-		/* assign our default vid to the VF following reset */
-		vf_info->sw_vid = hw->mac.default_vid;
-
 		/* mailbox is disconnected so we don't send a message */
 		hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
 
-- 
2.4.3
