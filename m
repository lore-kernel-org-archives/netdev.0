From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 9/9] bnxt_en: Use dma_rmb() instead of rmb().
Date: Sat, 14 May 2016 20:29:48 -0400
Message-ID: <1463272188-30025-10-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34589 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbcEOAaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:06 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so54328266pfb.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:06 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the weaker but more appropriate dma_rmb() to order the reading of
the completion ring.

Suggested-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f2ac7da..643c3ec 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1433,7 +1433,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 		/* The valid test of the entry must be done first before
 		 * reading any further.
 		 */
-		rmb();
+		dma_rmb();
 		if (TX_CMP_TYPE(txcmp) == CMP_TYPE_TX_L2_CMP) {
 			tx_pkts++;
 			/* return full budget so NAPI will complete. */
-- 
1.8.3.1
