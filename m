From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 15/34]bnx2x: Indirection table initialization index
Date: Wed, 14 Jan 2009 18:43:27 +0200
Message-ID: <1231951407.11301.136.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1625 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763220AbZANQoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong initialization of the multi-queue indirection table - it should be using
the function and not the port index

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 27a9be6..e7da72d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4537,7 +4537,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 
 static void bnx2x_init_ind_table(struct bnx2x *bp)
 {
-	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
 	int i;
 
 	if (!is_multi(bp))
@@ -4546,10 +4546,8 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	DP(NETIF_MSG_IFUP, "Initializing indirection table\n");
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
-			TSTORM_INDIRECTION_TABLE_OFFSET(port) + i,
-			i % bp->num_queues);
-
-	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
+			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
+			BP_CL_ID(bp) + (i % bp->num_queues));
 }
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
@@ -5253,6 +5251,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
 	/* set NIC mode */
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 	if (CHIP_IS_E1H(bp))
-- 
1.5.4.3




