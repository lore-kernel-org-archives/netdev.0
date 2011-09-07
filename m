From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net v2 5/6] bnx2x: Fix 578xx link LED
Date: Wed, 7 Sep 2011 13:48:06 +0300
Message-ID: <1315392487.27750.26.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4053 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab1IGQTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 1G link LED for the BCM578xx-SFI/KR.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 3428075..ba15bdc 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -5924,7 +5924,7 @@ int bnx2x_set_led(struct link_params *params,
 					(tmp | EMAC_LED_OVERRIDE));
 				/*
 				 * return here without enabling traffic
-				 * LED blink andsetting rate in ON mode.
+				 * LED blink and setting rate in ON mode.
 				 * In oper mode, enabling LED blink
 				 * and setting rate is needed.
 				 */
@@ -5936,7 +5936,11 @@ int bnx2x_set_led(struct link_params *params,
 			 * This is a work-around for HW issue found when link
 			 * is up in CL73
 			 */
-			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
+			if ((!CHIP_IS_E3(bp)) ||
+			    (CHIP_IS_E3(bp) &&
+			     mode == LED_MODE_ON))
+				REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
+
 			if (CHIP_IS_E1x(bp) ||
 			    CHIP_IS_E2(bp) ||
 			    (mode == LED_MODE_ON))
-- 
1.7.1
