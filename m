From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 04/11] lantiq_etop: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:28 -0700
Message-ID: <1341878975-10577-4-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:43517 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab2GJAJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:19 -0400
Received: by ghrr11 with SMTP id r11so10734572ghr.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:19 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set before calling eth_type_trans.
eth_type_trans already sets skb->dev to the proper value, thus making this
unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/lantiq_etop.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 5dc9cbd..9fa39eb 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -149,7 +149,6 @@ ltq_etop_hw_receive(struct ltq_etop_chan *ch)
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	skb_put(skb, len);
-	skb->dev = ch->netdev;
 	skb->protocol = eth_type_trans(skb, ch->netdev);
 	netif_receive_skb(skb);
 }
-- 
1.7.9.5
