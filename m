From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net v2 4/6] bnx2x: Fix XMAC loopback test
Date: Wed, 7 Sep 2011 13:48:03 +0300
Message-ID: <1315392483.27750.25.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1377 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236Ab1IGQNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:13:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XMAC loopback type from CORE LOCAL to LINE LOCAL for the BCM578xx due to intermittent problem with the loopback with this configuration.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    2 +-
 drivers/net/bnx2x/bnx2x_reg.h  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index db5913d..3428075 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1720,7 +1720,7 @@ static int bnx2x_xmac_enable(struct link_params *params,
 
 	/* Check loopback mode */
 	if (lb)
-		val |= XMAC_CTRL_REG_CORE_LOCAL_LPBK;
+		val |= XMAC_CTRL_REG_LINE_LOCAL_LPBK;
 	REG_WR(bp, xmac_base + XMAC_REG_CTRL, val);
 	bnx2x_set_xumac_nig(params,
 			    ((vars->flow_ctrl & BNX2X_FLOW_CTRL_TX) != 0), 1);
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 2bfedde..687ee12 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5320,7 +5320,7 @@
 #define XCM_REG_XX_OVFL_EVNT_ID 				 0x20058
 #define XMAC_CLEAR_RX_LSS_STATUS_REG_CLEAR_LOCAL_FAULT_STATUS	 (0x1<<0)
 #define XMAC_CLEAR_RX_LSS_STATUS_REG_CLEAR_REMOTE_FAULT_STATUS	 (0x1<<1)
-#define XMAC_CTRL_REG_CORE_LOCAL_LPBK				 (0x1<<3)
+#define XMAC_CTRL_REG_LINE_LOCAL_LPBK				 (0x1<<2)
 #define XMAC_CTRL_REG_RX_EN					 (0x1<<1)
 #define XMAC_CTRL_REG_SOFT_RESET				 (0x1<<6)
 #define XMAC_CTRL_REG_TX_EN					 (0x1<<0)
-- 
1.7.1
