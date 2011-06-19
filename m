From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 5/7] stmmac: fix race in transmit time stamping.
Date: Sun, 19 Jun 2011 15:31:43 +0200
Message-ID: <77b4a5d89434ebfa0eaf5f0e18018d45b314ed8c.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60328 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab1FSNcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:32:12 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477680fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:32:11 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/stmmac/stmmac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 5b85f4c..d4adc80 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1079,10 +1079,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += skb->len;
 
-	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
-
 	skb_tx_timestamp(skb);
 
+	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

