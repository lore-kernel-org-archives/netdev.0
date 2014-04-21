From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: bcmgenet: do not set RX buffer length
Date: Mon, 21 Apr 2014 08:45:24 -0700
Message-ID: <1398095124-5411-5-git-send-email-f.fainelli@gmail.com>
References: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:45079 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaDUPqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 11:46:12 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so3865420pab.39
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 08:46:11 -0700 (PDT)
In-Reply-To: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to set the buffer length during RX buffer allocation
since the hardware will fill that information when the packet is
received, so we are basically forcing a value that will get overwritten.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 4922958ec4aa..e15411431c9b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1479,13 +1479,6 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
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
