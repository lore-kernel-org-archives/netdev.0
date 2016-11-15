From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 8/9] alx: enable msi-x interrupts by default
Date: Tue, 15 Nov 2016 12:43:15 +0100
Message-ID: <e336185c36d5a96120b57ff3460977b85d28e365.1479208630.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34940 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753239AbcKOLnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:41 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so24981301wme.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:40 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the module parameter to enable msi-x support and enable msi-x
interrupts unconditionally by default. This is a preparatory step to enable
multi queue support by default, because this is only working with msi-x
interrupts.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 0e773a2ca6a0..91c9149ab3f2 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -51,10 +51,6 @@
 
 const char alx_drv_name[] = "alx";
 
-static bool msix = false;
-module_param(msix, bool, 0);
-MODULE_PARM_DESC(msix, "Enable msi-x interrupt support");
-
 static void alx_free_txbuf(struct alx_tx_queue *txq, int entry)
 {
 	struct alx_buffer *txb = &txq->bufs[entry];
@@ -1226,7 +1222,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 {
 	int err;
 
-	alx_init_intr(alx, msix);
+	alx_init_intr(alx, true);
 
 	if (!resume)
 		netif_carrier_off(alx->dev);
-- 
2.7.4
