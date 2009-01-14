From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 18/34]bnx2x: Reset HW before use
Date: Wed, 14 Jan 2009 18:43:36 +0200
Message-ID: <1231951416.11301.139.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1625 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763563AbZANQo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid complications, make sure that the HW is in reset (as it should be)
before trying to take it out of reset. In normal flows, the HW is indeed in rest
so this should have no effect

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c416772..f17a238 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -5150,12 +5150,21 @@ static void enable_blocks_attention(struct bnx2x *bp)
 }
 
 
+static void bnx2x_reset_common(struct bnx2x *bp)
+{
+	/* reset_common */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+	       0xd3ffff7f);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR, 0x1403);
+}
+
 static int bnx2x_init_common(struct bnx2x *bp)
 {
 	u32 val, i;
 
 	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
 
+	bnx2x_reset_common(bp);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0xffffffff);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, 0xfffc);
 
@@ -6642,14 +6651,6 @@ static void bnx2x_reset_port(struct bnx2x *bp)
 	/* TODO: Close Doorbell port? */
 }
 
-static void bnx2x_reset_common(struct bnx2x *bp)
-{
-	/* reset_common */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-	       0xd3ffff7f);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR, 0x1403);
-}
-
 static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 {
 	DP(BNX2X_MSG_MCP, "function %d  reset_code %x\n",
-- 
1.5.4.3




