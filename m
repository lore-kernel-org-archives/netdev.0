From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] net: ethernet: broadcom: Remove null check before kfree
Date: Sun, 27 Aug 2017 01:47:47 +0530
Message-ID: <1503778667-4416-1-git-send-email-himanshujha199640@gmail.com>
Cc: jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34810 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdHZUS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 16:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kfree on NULL pointer is a no-op and therefore checking is redundant.

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/ethernet/broadcom/sb1250-mac.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 16a0f19..ecdef42 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -1367,15 +1367,11 @@ static int sbmac_initctx(struct sbmac_softc *s)
 
 static void sbdma_uninitctx(struct sbmacdma *d)
 {
-	if (d->sbdma_dscrtable_unaligned) {
-		kfree(d->sbdma_dscrtable_unaligned);
-		d->sbdma_dscrtable_unaligned = d->sbdma_dscrtable = NULL;
-	}
+	kfree(d->sbdma_dscrtable_unaligned);
+	d->sbdma_dscrtable_unaligned = d->sbdma_dscrtable = NULL;
 
-	if (d->sbdma_ctxtable) {
-		kfree(d->sbdma_ctxtable);
-		d->sbdma_ctxtable = NULL;
-	}
+	kfree(d->sbdma_ctxtable);
+	d->sbdma_ctxtable = NULL;
 }
 
 
-- 
2.7.4
