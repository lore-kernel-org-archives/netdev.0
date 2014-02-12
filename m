From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/9] bnx2x: Remove unnecessary internal mem config
Date: Wed, 12 Feb 2014 18:19:51 +0200
Message-ID: <1392221997-25525-4-git-send-email-yuvalmin@broadcom.com>
References: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:2686 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbaBLQUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:20:16 -0500
In-Reply-To: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Latest FW performs this autonomously, makes this code surplus.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 12 ------------
 2 files changed, 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 84aecdf..95dc365 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -87,7 +87,6 @@
 	(IRO[156].base + ((vfId) * IRO[156].m1))
 #define CSTORM_VF_TO_PF_OFFSET(funcId) \
 	(IRO[150].base + ((funcId) * IRO[150].m1))
-#define TSTORM_ACCEPT_CLASSIFY_FAILED_OFFSET (IRO[204].base)
 #define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(pfId) \
 	(IRO[203].base + ((pfId) * IRO[203].m1))
 #define TSTORM_ASSERT_LIST_INDEX_OFFSET	(IRO[102].base)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 72ff5d2..383b025 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6005,18 +6005,6 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 {
 	int i;
 
-	if (IS_MF_SI(bp))
-		/*
-		 * In switch independent mode, the TSTORM needs to accept
-		 * packets that failed classification, since approximate match
-		 * mac addresses aren't written to NIG LLH
-		 */
-		REG_WR8(bp, BAR_TSTRORM_INTMEM +
-			    TSTORM_ACCEPT_CLASSIFY_FAILED_OFFSET, 2);
-	else if (!CHIP_IS_E1(bp)) /* 57710 doesn't support MF */
-		REG_WR8(bp, BAR_TSTRORM_INTMEM +
-			    TSTORM_ACCEPT_CLASSIFY_FAILED_OFFSET, 0);
-
 	/* Zero this manually as its initialization is
 	   currently missing in the initTool */
 	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
-- 
1.8.1.227.g44fe835
