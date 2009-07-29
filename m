From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 3/4] bnx2x: WoL only with current MAC address
Date: Wed, 29 Jul 2009 13:20:10 +0300
Message-ID: <1248862810.27379.17.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3701 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbZG2KUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 06:20:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases with 57711E, depending on the functions unload sequence, other
functions MAC address could have been used to wake the system as well. Make sure
to block all but the current function if WoL is required by changing the mode
to single function WoL.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b47b531..4245412 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7354,17 +7354,17 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 		for (i = 0; i < MC_HASH_SIZE; i++)
 			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
+
+		REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
 	}
 
 	if (unload_mode == UNLOAD_NORMAL)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
-	else if (bp->flags & NO_WOL_FLAG) {
+	else if (bp->flags & NO_WOL_FLAG)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
-		if (CHIP_IS_E1H(bp))
-			REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
 
-	} else if (bp->wol) {
+	else if (bp->wol) {
 		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr = bp->dev->dev_addr;
 		u32 val;
-- 
1.5.4.3




