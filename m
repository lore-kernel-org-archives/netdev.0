From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/15] i40e: move PF ID init from PF reset to SC init
Date: Tue,  7 Jan 2014 22:07:30 -0800
Message-ID: <1389161256-24599-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23587 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146AbaAHGIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:39 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Move PF ID initialization code from PF reset routine to earlier driver
initialization function.  There are a few operations which need the
PF ID before the first PF reset is called.

Change-Id: I7e971f7556b46a837149850ec05ce115c35db575
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 96c8f15..02ad529 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -198,6 +198,13 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 		break;
 	}
 
+	/* Determine the PF number based on the PCI fn */
+	reg = rd32(hw, I40E_GLPCI_CAPSUP);
+	if (reg & I40E_GLPCI_CAPSUP_ARI_EN_MASK)
+		hw->pf_id = (u8)((hw->bus.device << 3) | hw->bus.func);
+	else
+		hw->pf_id = (u8)hw->bus.func;
+
 	status = i40e_init_nvm(hw);
 	return status;
 }
@@ -375,13 +382,6 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw)
 		return I40E_ERR_RESET_FAILED;
 	}
 
-	/* Determine the PF number based on the PCI fn */
-	reg = rd32(hw, I40E_GLPCI_CAPSUP);
-	if (reg & I40E_GLPCI_CAPSUP_ARI_EN_MASK)
-		hw->pf_id = (u8)((hw->bus.device << 3) | hw->bus.func);
-	else
-		hw->pf_id = (u8)hw->bus.func;
-
 	/* If there was a Global Reset in progress when we got here,
 	 * we don't need to do the PF Reset
 	 */
-- 
1.8.3.1
