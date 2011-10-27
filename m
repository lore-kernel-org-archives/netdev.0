From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net v2 1/7] bnx2x: Fix LED blink rate for 578xx
Date: Thu, 27 Oct 2011 17:09:45 +0200
Message-ID: <1319728191-24938-2-git-send-email-yanivr@broadcom.com>
References: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1461 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab1J0NKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 09:10:03 -0400
In-Reply-To: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust blink rate on 578xx to fit its clock rate.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 818723c..edc9259 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -45,6 +45,9 @@
 #define MCPR_IMC_COMMAND_READ_OP	1
 #define MCPR_IMC_COMMAND_WRITE_OP	2
 
+/* LED Blink rate that will achieve ~15.9Hz */
+#define LED_BLINK_RATE_VAL_E3		354
+#define LED_BLINK_RATE_VAL_E1X_E2	480
 /***********************************************************/
 /*			Shortcut definitions		   */
 /***********************************************************/
@@ -5954,8 +5957,12 @@ int bnx2x_set_led(struct link_params *params,
 
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
1.7.2.2
