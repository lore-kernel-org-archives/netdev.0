From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/2] ixgbe: use correct mask when enabling sriov
Date: Mon, 16 May 2016 19:25:23 -0700
Message-ID: <1463451924-96911-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463451924-96911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2862 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124AbcEQCZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 22:25:26 -0400
In-Reply-To: <1463451924-96911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Swap the parameters in GENMASK in order to generate the correct mask.

This change fixes Tx hangs when enabling SRIOV.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d08fbcf..7bbf9b1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3767,9 +3767,9 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	reg_offset = (VMDQ_P(0) >= 32) ? 1 : 0;
 
 	/* Enable only the PF's pool for Tx/Rx */
-	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), GENMASK(vf_shift, 31));
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), GENMASK(31, vf_shift));
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), reg_offset - 1);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), GENMASK(vf_shift, 31));
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), GENMASK(31, vf_shift));
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), reg_offset - 1);
 	if (adapter->bridge_mode == BRIDGE_MODE_VEB)
 		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-- 
2.5.5
