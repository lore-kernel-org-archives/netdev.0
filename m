From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 7/7] bnxt_en: Pass in sh parameter to bnxt_set_dflt_rings().
Date: Mon, 29 May 2017 19:06:10 -0400
Message-ID: <1496099170-701-8-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:35980 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdE2XGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:55 -0400
Received: by mail-qt0-f171.google.com with SMTP id f55so58555738qta.3
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:55 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the existing code, the local variable sh is hardcoded to true to
calculate default rings for shared ring configuration.  It is better
to have the caller determine the value of sh.

Reported-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2c6af31..954758f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7567,10 +7567,9 @@ static int bnxt_get_dflt_rings(struct bnxt *bp, int *max_rx, int *max_tx,
 	return rc;
 }
 
-static int bnxt_set_dflt_rings(struct bnxt *bp)
+static int bnxt_set_dflt_rings(struct bnxt *bp, bool sh)
 {
 	int dflt_rings, max_rx_rings, max_tx_rings, rc;
-	bool sh = true;
 
 	if (sh)
 		bp->flags |= BNXT_FLAG_SHARED_RINGS;
@@ -7749,7 +7748,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	bnxt_set_max_func_irqs(bp, max_irqs);
-	rc = bnxt_set_dflt_rings(bp);
+	rc = bnxt_set_dflt_rings(bp, true);
 	if (rc) {
 		netdev_err(bp->dev, "Not enough rings available.\n");
 		rc = -ENOMEM;
-- 
1.8.3.1
