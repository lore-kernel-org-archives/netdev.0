From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 3/4] bnx2x: Change coalescing granularity to 4us
Date: Mon, 9 Nov 2009 18:09:35 +0200
Message-ID: <1257782975.4101.42.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2789 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756481AbZKIQNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 11:13:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |   13 +++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index c3b32f7..928942b 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1191,7 +1191,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define MAX_SP_DESC_CNT			(SP_DESC_CNT - 1)
 
 
-#define BNX2X_BTR			3
+#define BNX2X_BTR			1
 #define MAX_SPQ_PENDING			8
 
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a8ebd46..ab552d3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4920,21 +4920,21 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
 			CSTORM_SB_HC_TIMEOUT_U_OFFSET(port, sb_id,
 						      U_SB_ETH_RX_CQ_INDEX),
-			bp->rx_ticks/12);
+			bp->rx_ticks/(4 * BNX2X_BTR));
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
 			 CSTORM_SB_HC_DISABLE_U_OFFSET(port, sb_id,
 						       U_SB_ETH_RX_CQ_INDEX),
-			 (bp->rx_ticks/12) ? 0 : 1);
+			 (bp->rx_ticks/(4 * BNX2X_BTR)) ? 0 : 1);
 
 		/* HC_INDEX_C_ETH_TX_CQ_CONS */
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
 			CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, sb_id,
 						      C_SB_ETH_TX_CQ_INDEX),
-			bp->tx_ticks/12);
+			bp->tx_ticks/(4 * BNX2X_BTR));
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
 			 CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id,
 						       C_SB_ETH_TX_CQ_INDEX),
-			 (bp->tx_ticks/12) ? 0 : 1);
+			 (bp->tx_ticks/(4 * BNX2X_BTR)) ? 0 : 1);
 	}
 }
 
@@ -9008,8 +9008,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->rx_csum = 1;
 
-	bp->tx_ticks = 50;
-	bp->rx_ticks = 25;
+	/* make sure that the numbers are in the right granularity */
+	bp->tx_ticks = (50 / (4 * BNX2X_BTR)) * (4 * BNX2X_BTR);
+	bp->rx_ticks = (25 / (4 * BNX2X_BTR)) * (4 * BNX2X_BTR);
 
 	timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
 	bp->current_interval = (poll ? poll : timer_interval);
-- 
1.5.4.3




