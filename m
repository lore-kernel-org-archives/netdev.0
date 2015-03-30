From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 3/5] net: bcmgenet: fix bcmgenet_open()
Date: Mon, 30 Mar 2015 00:29:13 -0700 (PDT)
Message-ID: <20150330072913.63758220215@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:32812 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbbC3H3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:29:14 -0400
Received: by pdjg10 with SMTP id g10so3441884pdj.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:29:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bcmgenet_init_dma() fails, it cleans up after itself. Rx and Tx
DMAs are off, and NAPI instances haven't been netif_napi_add()'ed.
Therefore, we need to skip calling bcmgenet_fini_dma() on the error
handling path. bcmgenet_resume() already does this correctly.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 546d862..5238b33 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2666,7 +2666,7 @@ static int bcmgenet_open(struct net_device *dev)
 	ret = bcmgenet_init_dma(priv);
 	if (ret) {
 		netdev_err(dev, "failed to initialize DMA\n");
-		goto err_fini_dma;
+		goto err_clk_disable;
 	}
 
 	/* Always enable ring 16 - descriptor ring */
-- 
2.2.0.rc0.207.ga3a616c
