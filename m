From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] bnxt_en: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 15:12:26 +0200
Message-ID: <20170926131226.8423-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:50994 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967604AbdIZNM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 09:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c25f5b555adf..5ba49938ba55 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1491,7 +1491,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 				   (struct rx_tpa_end_cmp *)rxcmp,
 				   (struct rx_tpa_end_cmp_ext *)rxcmp1, event);
 
-		if (unlikely(IS_ERR(skb)))
+		if (IS_ERR(skb))
 			return -EBUSY;
 
 		rc = -ENOMEM;
-- 
2.13.0
