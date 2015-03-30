From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 2/5] net: bcmgenet: remove __bcmgenet_fini_dma()
Date: Mon, 30 Mar 2015 00:29:01 -0700 (PDT)
Message-ID: <20150330072901.35457220215@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33326 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbC3H3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:29:03 -0400
Received: by obbnt9 with SMTP id nt9so9447582obb.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:29:02 -0700 (PDT)
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
