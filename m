From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: check MAC type before any REG access
Date: Tue,  7 Jan 2014 01:32:24 -0800
Message-ID: <1389087149-27962-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6793 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283AbaAGJci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 04:32:38 -0500
In-Reply-To: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

We need to check if we are dealing with the correct MAC type before we
try to read anything from the registers.

Change-Id: I3989516999d06c3009e87d6a2eafc20af305c5c2
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 02ad529..7e34de1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -180,14 +180,6 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 	i40e_status status = 0;
 	u32 reg;
 
-	hw->phy.get_link_info = true;
-
-	/* Determine port number */
-	reg = rd32(hw, I40E_PFGEN_PORTNUM);
-	reg = ((reg & I40E_PFGEN_PORTNUM_PORT_NUM_MASK) >>
-	       I40E_PFGEN_PORTNUM_PORT_NUM_SHIFT);
-	hw->port = (u8)reg;
-
 	i40e_set_mac_type(hw);
 
 	switch (hw->mac.type) {
@@ -198,6 +190,14 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 		break;
 	}
 
+	hw->phy.get_link_info = true;
+
+	/* Determine port number */
+	reg = rd32(hw, I40E_PFGEN_PORTNUM);
+	reg = ((reg & I40E_PFGEN_PORTNUM_PORT_NUM_MASK) >>
+	       I40E_PFGEN_PORTNUM_PORT_NUM_SHIFT);
+	hw->port = (u8)reg;
+
 	/* Determine the PF number based on the PCI fn */
 	reg = rd32(hw, I40E_GLPCI_CAPSUP);
 	if (reg & I40E_GLPCI_CAPSUP_ARI_EN_MASK)
-- 
1.8.3.1
