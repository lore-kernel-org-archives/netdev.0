From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: bcmgenet: do not set packet length for RX buffers
Date: Thu, 26 Jun 2014 10:26:22 -0700
Message-ID: <1403803582-13472-4-git-send-email-f.fainelli@gmail.com>
References: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:46911 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295AbaFZR0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:26:38 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3376919qgd.10
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:26:37 -0700 (PDT)
In-Reply-To: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware will provide this information as soon as we will start
processing incoming packets, so there is no need to set the RX buffer
length during buffer allocation.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index e51e462bc8fd..16281ad2da12 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1408,13 +1408,6 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
 		if (cb->skb)
 			continue;
 
-		/* set the DMA descriptor length once and for all
-		 * it will only change if we support dynamically sizing
-		 * priv->rx_buf_len, but we do not
-		 */
-		dmadesc_set_length_status(priv, priv->rx_bd_assign_ptr,
-				priv->rx_buf_len << DMA_BUFLENGTH_SHIFT);
-
 		ret = bcmgenet_rx_refill(priv, cb);
 		if (ret)
 			break;
-- 
1.9.1
