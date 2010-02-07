From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3]: sky2: disable ASF on Yukon Supreme
Date: Sun, 7 Feb 2010 08:24:50 -0800
Message-ID: <20100207082450.736d8170@nehalam>
References: <20100207082353.2d0c6a93@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932313Ab0BGQ30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2010 11:29:26 -0500
In-Reply-To: <20100207082353.2d0c6a93@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clone of vendor code to disable ASF on Extreme and Supreme chips.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2010-02-03 09:24:17.943679463 -0800
+++ b/drivers/net/sky2.c	2010-02-03 09:24:19.203992300 -0800
@@ -3035,11 +3035,20 @@ static void sky2_reset(struct sky2_hw *h
 	u32 hwe_mask = Y2_HWE_ALL_MASK;
 
 	/* disable ASF */
-	if (hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->chip_id == CHIP_ID_YUKON_EX
+	    || hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		sky2_write32(hw, CPU_WDOG, 0);
 		status = sky2_read16(hw, HCU_CCSR);
 		status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
 			    HCU_CCSR_UC_STATE_MSK);
+		/*
+		 * CPU clock divider shouldn't be used because
+		 * - ASF firmware may malfunction
+		 * - Yukon-Supreme: Parallel FLASH doesn't support divided clocks
+		 */
+		status &= ~HCU_CCSR_CPU_CLK_DIVIDE_MSK;
 		sky2_write16(hw, HCU_CCSR, status);
+		sky2_write32(hw, CPU_WDOG, 0);
 	} else
 		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
 	sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
