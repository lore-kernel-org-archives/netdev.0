From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 3/3] net: bcmgenet: fix bcmgenet_open()
Date: Fri, 27 Mar 2015 22:51:18 -0700 (PDT)
Message-ID: <20150328055118.C1864220209@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:33302 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbC1FvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:51:20 -0400
Received: by ierx19 with SMTP id x19so2285851ier.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:51:19 -0700 (PDT)
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
