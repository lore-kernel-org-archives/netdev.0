From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net] bnx2x: remove redundant warning log
Date: Thu, 22 Nov 2012 19:16:17 +0200
Message-ID: <1353604577-1272-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1118 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945Ab2KVSrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:47:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix bug where a register which was only meant to be read in 578xx/57712
devices causes a bogus error message to be logged when read from other
devices.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index bd1fd3d..01611b3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9545,10 +9545,13 @@ static int __devinit bnx2x_prev_unload_common(struct bnx2x *bp)
  */
 static void __devinit bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
 {
-	u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
-	if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
-		BNX2X_ERR("was error bit was found to be set in pglueb upon startup. Clearing");
-		REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR, 1 << BP_FUNC(bp));
+	if (!CHIP_IS_E1x(bp)) {
+		u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
+			BNX2X_ERR("was error bit was found to be set in pglueb upon startup. Clearing");
+			REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR,
+			       1 << BP_FUNC(bp));
+		}
 	}
 }
 
-- 
1.7.9.GIT
