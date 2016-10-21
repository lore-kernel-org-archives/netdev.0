From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 8/9] alx: enable msi-x interrupts by default
Date: Fri, 21 Oct 2016 12:49:51 +0200
Message-ID: <a8474e07dde004fc1f8645abd767c520f0c6272b.1477044921.git.tobias.regnery@gmail.com>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36357 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755181AbcJUKuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:50:40 -0400
Received: by mail-lf0-f66.google.com with SMTP id b75so5243559lfg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 03:50:40 -0700 (PDT)
In-Reply-To: <cover.1477044917.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1477044917.git.tobias.regnery@gmail.com>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
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
index 39f6247cbbd0..3b832090ad2e 100644
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
