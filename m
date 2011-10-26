From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 1/7] bnx2x: Fix LED blink rate for 578xx
Date: Wed, 26 Oct 2011 11:40:33 +0200
Message-ID: <1319622039-10553-2-git-send-email-yanivr@broadcom.com>
References: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3049 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778Ab1JZHlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 03:41:17 -0400
In-Reply-To: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust blink rate on 578xx to fit its clock rate.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index ba15bdc..5777dcd 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -45,6 +45,9 @@
 #define MCPR_IMC_COMMAND_READ_OP	1
 #define MCPR_IMC_COMMAND_WRITE_OP	2
 
+/* LED Blink rate that will achieve ~15.9Hz */
+#define LED_BLINK_RATE_VAL_E3		354
+#define LED_BLINK_RATE_VAL_E1X_E2	480
 /***********************************************************/
 /*			Shortcut definitions		   */
 /***********************************************************/
@@ -5953,8 +5956,12 @@ int bnx2x_set_led(struct link_params *params,
 
 		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
-		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
-		       LED_BLINK_RATE_VAL);
+		if (CHIP_IS_E3(bp))
+			REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
+			       LED_BLINK_RATE_VAL_E3);
+		else
+			REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
+			       LED_BLINK_RATE_VAL_E1X_E2);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 		       port*4, 1);
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-- 
1.7.7.1
