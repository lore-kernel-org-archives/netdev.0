From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: Remove CS4227 diagnostic code
Date: Mon, 23 Nov 2015 11:36:12 -0800
Message-ID: <1448307376-20063-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41717 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbbKWTgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:25 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Testing has now shown that the diagnostic code used with the CS4227
is no longer needed, so remove it.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 80 ---------------------------
 1 file changed, 80 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 005f01b..bf2ae8d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -87,79 +87,6 @@ static s32 ixgbe_write_cs4227(struct ixgbe_hw *hw, u16 reg, u16 value)
 }
 
 /**
- * ixgbe_check_cs4227_reg - Perform diag on a CS4227 register
- * @hw: pointer to hardware structure
- * @reg: the register to check
- *
- * Performs a diagnostic on a register in the CS4227 chip. Returns an error
- * if it is not operating correctly.
- * This function assumes that the caller has acquired the proper semaphore.
- */
-static s32 ixgbe_check_cs4227_reg(struct ixgbe_hw *hw, u16 reg)
-{
-	s32 status;
-	u32 retry;
-	u16 reg_val;
-
-	reg_val = (IXGBE_CS4227_EDC_MODE_DIAG << 1) | 1;
-	status = ixgbe_write_cs4227(hw, reg, reg_val);
-	if (status)
-		return status;
-	for (retry = 0; retry < IXGBE_CS4227_RETRIES; retry++) {
-		msleep(IXGBE_CS4227_CHECK_DELAY);
-		reg_val = 0xFFFF;
-		ixgbe_read_cs4227(hw, reg, &reg_val);
-		if (!reg_val)
-			break;
-	}
-	if (reg_val) {
-		hw_err(hw, "CS4227 reg 0x%04X failed diagnostic\n", reg);
-		return status;
-	}
-
-	return 0;
-}
-
-/**
- * ixgbe_get_cs4227_status - Return CS4227 status
- * @hw: pointer to hardware structure
- *
- * Performs a diagnostic on the CS4227 chip. Returns an error if it is
- * not operating correctly.
- * This function assumes that the caller has acquired the proper semaphore.
- */
-static s32 ixgbe_get_cs4227_status(struct ixgbe_hw *hw)
-{
-	s32 status;
-	u16 value = 0;
-
-	/* Exit if the diagnostic has already been performed. */
-	status = ixgbe_read_cs4227(hw, IXGBE_CS4227_SCRATCH, &value);
-	if (status)
-		return status;
-	if (value == IXGBE_CS4227_RESET_COMPLETE)
-		return 0;
-
-	/* Check port 0. */
-	status = ixgbe_check_cs4227_reg(hw, IXGBE_CS4227_LINE_SPARE24_LSB);
-	if (status)
-		return status;
-
-	status = ixgbe_check_cs4227_reg(hw, IXGBE_CS4227_HOST_SPARE24_LSB);
-	if (status)
-		return status;
-
-	/* Check port 1. */
-	status = ixgbe_check_cs4227_reg(hw, IXGBE_CS4227_LINE_SPARE24_LSB +
-					(1 << 12));
-	if (status)
-		return status;
-
-	return ixgbe_check_cs4227_reg(hw, IXGBE_CS4227_HOST_SPARE24_LSB +
-				      (1 << 12));
-}
-
-/**
  * ixgbe_read_pe - Read register from port expander
  * @hw: pointer to hardware structure
  * @reg: register number to read
@@ -328,13 +255,6 @@ static void ixgbe_check_cs4227(struct ixgbe_hw *hw)
 		return;
 	}
 
-	/* Is the CS4227 working correctly? */
-	status = ixgbe_get_cs4227_status(hw);
-	if (status) {
-		hw_err(hw, "CS4227 status failed: %d", status);
-		goto out;
-	}
-
 	/* Record completion for next time. */
 	status = ixgbe_write_cs4227(hw, IXGBE_CS4227_SCRATCH,
 				    IXGBE_CS4227_RESET_COMPLETE);
-- 
2.5.0
