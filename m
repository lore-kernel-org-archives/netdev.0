From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: [PATCH] Fix buglets in mpc5200 FEC code that are corrupting memory.
Date: Fri, 9 Nov 2007 00:31:35 -0500
Message-ID: <9e4733910711082131v70c4b7bm2b00445b7e62c33f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "PowerPC dev list" <Linuxppc-dev@ozlabs.org>,
	"Domen Puncer" <domen.puncer@telargo.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:3162 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbXKIFbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 00:31:36 -0500
Received: by rv-out-0910.google.com with SMTP id k20so369993rvb
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2007 21:31:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the reason I couldn't get user space started or connect to my
nfs server. Patch is against current linus git.

mpc5200 fec driver is corrupting memory. This patch fixes two bugs
where the wrong skb buffer was being referenced.

Signed-off-by: Jon Smirl <jonsmirl@gmail.com>

---

 drivers/net/fec_mpc52xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index a8a0ee2..ddfcc0b 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -422,7 +422,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int
irq, void *dev_id)

 		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
 				(struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE);

 		/* Test for errors in received frame */
 		if (status & BCOM_FEC_RX_BD_ERRORS) {
@@ -467,7 +467,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int
irq, void *dev_id)
 			bcom_prepare_next_buffer(priv->rx_dmatsk);

 		bd->status = FEC_RX_BUFFER_SIZE;
-		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);

 		bcom_submit_next_buffer(priv->rx_dmatsk, skb);


-- 
Jon Smirl
jonsmirl@gmail.com
