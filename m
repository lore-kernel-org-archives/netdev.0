From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: set pf_id based on device and function numbers
Date: Fri,  6 Dec 2013 00:06:14 -0800
Message-ID: <1386317188-13944-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christopher Pau <christopher.pau@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab3LFIGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:33 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher Pau <christopher.pau@intel.com>

pf_id needs to be encoded for cards with ARI enabled, which
allows for larger function numbers than 8.

Commit-Id: I23fa7df9dabf3878cc08c9b2151729c8539f5f17
Signed-off-by: Christopher Pau <christopher.pau@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1e4ea13..9e868ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -297,7 +297,11 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw)
 	}
 
 	/* Determine the PF number based on the PCI fn */
-	hw->pf_id = (u8)hw->bus.func;
+	reg = rd32(hw, I40E_GLPCI_CAPSUP);
+	if (reg & I40E_GLPCI_CAPSUP_ARI_EN_MASK)
+		hw->pf_id = (u8)((hw->bus.device << 3) | hw->bus.func);
+	else
+		hw->pf_id = (u8)hw->bus.func;
 
 	/* If there was a Global Reset in progress when we got here,
 	 * we don't need to do the PF Reset
-- 
1.8.3.1
