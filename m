From: Kyle McMartin <kyle@redhat.com>
Subject: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:11:51 -0400
Message-ID: <20130829201151.GJ8764@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757112Ab3H2ULy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 16:11:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed while debugging another issue that DMA debug turned up, looks
like commit ef468d23 missed a case when switching to bufsz instead of
priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
suspect since we're not tracking the size, but trusting the hardware
between map and unmap...)

Signed-off-by: Kyle McMartin <kyle@redhat.com>

--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -686,7 +686,7 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 			priv->rx_skbuff[entry] = skb;
 			paddr = dma_map_single(priv->device, skb->data,
 					       bufsz, DMA_FROM_DEVICE);
-			desc_set_buf_addr(p, paddr, priv->dma_buf_sz);
+			desc_set_buf_addr(p, paddr, bufsz);
 		}
 
 		netdev_dbg(priv->dev, "rx ring: head %d, tail %d\n",
