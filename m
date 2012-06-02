From: Stephan Gatzka <stephan@gatzka.org>
Subject: [PATCH 1/1] fec_mpc52xx: fix timestamp filtering
Date: Sat,  2 Jun 2012 15:04:06 +0200
Message-ID: <1338642246-10911-1-git-send-email-stephan@gatzka.org>
Cc: Stephan Gatzka <stephan@gatzka.org>,
	stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:27924 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759572Ab2FBNEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 09:04:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_defer_rx_timestamp was called with a freshly allocated skb but must
be called with rskb instead.

Signed-off-by: Stephan Gatzka <stephan@gatzka.org>
Cc: stable <stable@vger.kernel.org>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 97f947b..2933d08 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -437,7 +437,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 		length = status & BCOM_FEC_RX_BD_LEN_MASK;
 		skb_put(rskb, length - 4);	/* length without CRC32 */
 		rskb->protocol = eth_type_trans(rskb, dev);
-		if (!skb_defer_rx_timestamp(skb))
+		if (!skb_defer_rx_timestamp(rskb))
 			netif_rx(rskb);
 
 		spin_lock(&priv->lock);
-- 
1.7.9.5
