From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net 1/3] alx: fix wrong condition to free descriptor memory
Date: Tue, 24 Jan 2017 14:34:22 +0100
Message-ID: <e10a8070a2f3d029b5080d90cd38f1602a710cfa.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32925 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdAXNey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 08:34:54 -0500
Received: by mail-wm0-f68.google.com with SMTP id r144so34737108wme.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 05:34:49 -0800 (PST)
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The condition to free the descriptor memory is wrong, we want to free the
memory if it is set and not if it is unset. Invert the test to fix this
issue.

Fixes: b0999223f224b ("alx: add ability to allocate and free alx_napi structures")
Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8f525574d68..765306bd78c2 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -703,7 +703,7 @@ static void alx_free_rings(struct alx_priv *alx)
 	if (alx->qnapi[0] && alx->qnapi[0]->rxq)
 		kfree(alx->qnapi[0]->rxq->bufs);
 
-	if (!alx->descmem.virt)
+	if (alx->descmem.virt)
 		dma_free_coherent(&alx->hw.pdev->dev,
 				  alx->descmem.size,
 				  alx->descmem.virt,
-- 
2.9.3
