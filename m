From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/7][BNX2]: Refine tx coalescing setup.
Date: Tue, 29 Jan 2008 16:19:09 -0800
Message-ID: <1201652349.19087.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1979 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286AbYA2Xj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Refine tx coalescing setup. 

Make the tx coalescing setup code independent of the MSIX vector.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 353c73f..8d0022d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4438,18 +4438,21 @@ bnx2_init_chip(struct bnx2 *bp)
 	}
 
 	if (bp->flags & BNX2_FLAG_USING_MSIX) {
+		u32 base = ((BNX2_TX_VEC - 1) * BNX2_HC_SB_CONFIG_SIZE) +
+			   BNX2_HC_SB_CONFIG_1;
+
 		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
 		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
 
-		REG_WR(bp, BNX2_HC_SB_CONFIG_1,
+		REG_WR(bp, base,
 			BNX2_HC_SB_CONFIG_1_TX_TMR_MODE |
 			BNX2_HC_SB_CONFIG_1_ONE_SHOT);
 
-		REG_WR(bp, BNX2_HC_TX_QUICK_CONS_TRIP_1,
+		REG_WR(bp, base + BNX2_HC_TX_QUICK_CONS_TRIP_OFF,
 			(bp->tx_quick_cons_trip_int << 16) |
 			 bp->tx_quick_cons_trip);
 
-		REG_WR(bp, BNX2_HC_TX_TICKS_1,
+		REG_WR(bp, base + BNX2_HC_TX_TICKS_OFF,
 			(bp->tx_ticks_int << 16) | bp->tx_ticks);
 
 		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 059e115..7a1eff4 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -5510,6 +5510,15 @@ struct l2_fhdr {
 #define BNX2_HC_PERIODIC_TICKS_8_HC_PERIODIC_TICKS	 (0xffffL<<0)
 #define BNX2_HC_PERIODIC_TICKS_8_HC_INT_PERIODIC_TICKS	 (0xffffL<<16)
 
+#define BNX2_HC_SB_CONFIG_SIZE	(BNX2_HC_SB_CONFIG_2 - BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_COMP_PROD_TRIP_OFF	(BNX2_HC_COMP_PROD_TRIP_1 -	\
+					 BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_COM_TICKS_OFF	(BNX2_HC_COM_TICKS_1 - BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_CMD_TICKS_OFF	(BNX2_HC_CMD_TICKS_1 - BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_TX_QUICK_CONS_TRIP_OFF	(BNX2_HC_TX_QUICK_CONS_TRIP_1 -	\
+					 BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_TX_TICKS_OFF	(BNX2_HC_TX_TICKS_1 - BNX2_HC_SB_CONFIG_1)
+
 
 /*
  *  txp_reg definition


