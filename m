From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Don't fallback to INTA on VF.
Date: Mon, 25 Apr 2016 02:30:49 -0400
Message-ID: <1461565851-32524-2-git-send-email-michael.chan@broadcom.com>
References: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:31633 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbcDYGaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 02:30:52 -0400
In-Reply-To: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only MSI-X can be used on a VF.  The driver should fail initialization
if it cannot successfully enable MSI-X.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 12a009d..e787deb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4309,7 +4309,7 @@ static int bnxt_setup_int_mode(struct bnxt *bp)
 	if (bp->flags & BNXT_FLAG_MSIX_CAP)
 		rc = bnxt_setup_msix(bp);
 
-	if (!(bp->flags & BNXT_FLAG_USING_MSIX)) {
+	if (!(bp->flags & BNXT_FLAG_USING_MSIX) && BNXT_PF(bp)) {
 		/* fallback to INTA */
 		rc = bnxt_setup_inta(bp);
 	}
-- 
1.8.3.1
