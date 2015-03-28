From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 2/3] net: bcmgenet: remove __bcmgenet_fini_dma()
Date: Fri, 27 Mar 2015 22:51:06 -0700 (PDT)
Message-ID: <20150328055106.2FCEE220209@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:32819 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbC1FvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:51:07 -0400
Received: by pablj1 with SMTP id lj1so8280517pab.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:51:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_fini_dma() is the only caller of __bcmgenet_fini_dma().
Move __bcmgenet_fini_dma() code inside bcmgenet_fini_dma().

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 620021e..546d862 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2173,10 +2173,13 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 	return ret;
 }
 
-static void __bcmgenet_fini_dma(struct bcmgenet_priv *priv)
+static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
 	int i;
 
+	bcmgenet_fini_rx_napi(priv);
+	bcmgenet_fini_tx_napi(priv);
+
 	/* disable DMA */
 	bcmgenet_dma_teardown(priv);
 
@@ -2192,14 +2195,6 @@ static void __bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 	kfree(priv->tx_cbs);
 }
 
-static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
-{
-	bcmgenet_fini_rx_napi(priv);
-	bcmgenet_fini_tx_napi(priv);
-
-	__bcmgenet_fini_dma(priv);
-}
-
 /* init_edma: Initialize DMA control register */
 static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 {
-- 
2.2.0.rc0.207.ga3a616c
