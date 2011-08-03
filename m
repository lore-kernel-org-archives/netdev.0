From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 01/10] bnx2x: Fix missing pause on for 578xx
Date: Wed, 3 Aug 2011 11:59:10 +0300
Message-ID: <1312361950.21665.91.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab1HCI7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 04:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When link speed is 1G and below, pause weren't sent due to missing pause setting in the UMAC.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    6 ++++++
 drivers/net/bnx2x/bnx2x_reg.h  |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index bcd8f00..aa9958e 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1546,6 +1546,12 @@ static void bnx2x_umac_enable(struct link_params *params,
 			       vars->line_speed);
 		break;
 	}
+	if (!(vars->flow_ctrl & BNX2X_FLOW_CTRL_TX))
+		val |= UMAC_COMMAND_CONFIG_REG_IGNORE_TX_PAUSE;
+
+	if (!(vars->flow_ctrl & BNX2X_FLOW_CTRL_RX))
+		val |= UMAC_COMMAND_CONFIG_REG_PAUSE_IGNORE;
+
 	REG_WR(bp, umac_base + UMAC_REG_COMMAND_CONFIG, val);
 	udelay(50);
 
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 02461fe..d84642a 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -4771,9 +4771,11 @@
    The fields are: [4:0] - tail pointer; 10:5] - Link List size; 15:11] -
    header pointer. */
 #define UCM_REG_XX_TABLE					 0xe0300
+#define UMAC_COMMAND_CONFIG_REG_IGNORE_TX_PAUSE			 (0x1<<28)
 #define UMAC_COMMAND_CONFIG_REG_LOOP_ENA			 (0x1<<15)
 #define UMAC_COMMAND_CONFIG_REG_NO_LGTH_CHECK			 (0x1<<24)
 #define UMAC_COMMAND_CONFIG_REG_PAD_EN				 (0x1<<5)
+#define UMAC_COMMAND_CONFIG_REG_PAUSE_IGNORE			 (0x1<<8)
 #define UMAC_COMMAND_CONFIG_REG_PROMIS_EN			 (0x1<<4)
 #define UMAC_COMMAND_CONFIG_REG_RX_ENA				 (0x1<<1)
 #define UMAC_COMMAND_CONFIG_REG_SW_RESET			 (0x1<<13)
-- 
1.7.1








