From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 5/9] bnx2x: Initialization structure
Date: Mon, 25 Aug 2008 17:24:49 +0300
Message-ID: <1219674289.19456.31.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3952 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535AbYHYO0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:26:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialization structure
The TPA initialization is part of the FW internal memory initialization
and so it is moved to the appropriate function

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index cb91802..398daeb 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4606,6 +4606,17 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 {
 	int i;
 
+	if (bp->flags & TPA_ENABLE_FLAG) {
+		struct tstorm_eth_tpa_exist tpa = {0};
+
+		tpa.tpa_exist = 1;
+
+		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET,
+		       ((u32 *)&tpa)[0]);
+		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET + 4,
+		       ((u32 *)&tpa)[1]);
+	}
+
 	/* Zero this manually as its initialization is
 	   currently missing in the initTool */
 	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
@@ -5365,17 +5376,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 
 	enable_blocks_attention(bp);
 
-	if (bp->flags & TPA_ENABLE_FLAG) {
-		struct tstorm_eth_tpa_exist tmp = {0};
-
-		tmp.tpa_exist = 1;
-
-		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET,
-		       ((u32 *)&tmp)[0]);
-		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET + 4,
-		       ((u32 *)&tmp)[1]);
-	}
-
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
 		bnx2x_common_init_phy(bp, bp->common.shmem_base);
-- 
1.5.3.2




