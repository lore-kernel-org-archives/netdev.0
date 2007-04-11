From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: disable ASF on all chip types
Date: Wed, 11 Apr 2007 14:48:00 -0700
Message-ID: <20070411214859.922360015@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34866 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161292AbXDKWao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:44 -0400
Content-Disposition: inline; filename=sky2-disable-asf.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to make sure and disable ASF on all chip types. Otherwise, there may be
random reboots.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:10:13.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:11:48.000000000 -0700
@@ -2542,16 +2542,14 @@ static void sky2_reset(struct sky2_hw *h
 	int i;
 
 	/* disable ASF */
-	if (hw->chip_id <= CHIP_ID_YUKON_EC) {
-		if (hw->chip_id == CHIP_ID_YUKON_EX) {
-			status = sky2_read16(hw, HCU_CCSR);
-			status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
-				    HCU_CCSR_UC_STATE_MSK);
-			sky2_write16(hw, HCU_CCSR, status);
-		} else
-			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
-		sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
-	}
+	if (hw->chip_id == CHIP_ID_YUKON_EX) {
+		status = sky2_read16(hw, HCU_CCSR);
+		status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
+			    HCU_CCSR_UC_STATE_MSK);
+		sky2_write16(hw, HCU_CCSR, status);
+	} else
+		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
+	sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
 
 	/* do a SW reset */
 	sky2_write8(hw, B0_CTST, CS_RST_SET);

--
Stephen Hemminger <shemminger@linux-foundation.org>

