From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: clear RNBC only for 82598
Date: Mon, 29 Aug 2011 01:41:08 -0700
Message-ID: <1314607268-26958-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1H2IlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:20 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

RNBC (0x03FC0) is only for 82598 and has different meaning
on newer HW. Make sure to only clear it for 82598.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 90a04e2..91986af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -225,8 +225,9 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 	IXGBE_READ_REG(hw, IXGBE_GORCH);
 	IXGBE_READ_REG(hw, IXGBE_GOTCL);
 	IXGBE_READ_REG(hw, IXGBE_GOTCH);
-	for (i = 0; i < 8; i++)
-		IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		for (i = 0; i < 8; i++)
+			IXGBE_READ_REG(hw, IXGBE_RNBC(i));
 	IXGBE_READ_REG(hw, IXGBE_RUC);
 	IXGBE_READ_REG(hw, IXGBE_RFC);
 	IXGBE_READ_REG(hw, IXGBE_ROC);
-- 
1.7.6
