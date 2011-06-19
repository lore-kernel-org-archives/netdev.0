From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 7/7] davinci_emac: fix race in transmit time stamping.
Date: Sun, 19 Jun 2011 15:31:45 +0200
Message-ID: <4af078a4e715ec7f831cb6203bc7f368f3fec1fc.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60328 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab1FSNcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:32:22 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477680fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:32:21 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/davinci_emac.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index f5688ff..55c8245 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1083,6 +1083,8 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 		goto fail_tx;
 	}
 
+	skb_tx_timestamp(skb);
+
 	ret_code = cpdma_chan_submit(priv->txchan, skb, skb->data, skb->len,
 				     GFP_KERNEL);
 	if (unlikely(ret_code != 0)) {
@@ -1090,7 +1092,6 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 			dev_err(emac_dev, "DaVinci EMAC: desc submit failed");
 		goto fail_tx;
 	}
-	skb_tx_timestamp(skb);
 
 	return NETDEV_TX_OK;
 
-- 
1.7.0.4

