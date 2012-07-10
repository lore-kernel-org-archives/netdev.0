From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 09/11] sungem: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:33 -0700
Message-ID: <1341878975-10577-9-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139Ab2GJAJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:44 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:44 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set by the driver's skb alloc routine (which is
called in init and during rx).  It is already being set to the proper value when
eth_type_trans is called on packet receive, and the skb->dev is not referenced
anywhere else in the code.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/sun/sungem.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 3cf4ab7..9ae12d0 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -752,7 +752,6 @@ static __inline__ struct sk_buff *gem_alloc_skb(struct net_device *dev, int size
 	if (likely(skb)) {
 		unsigned long offset = ALIGNED_RX_SKB_ADDR(skb->data);
 		skb_reserve(skb, offset);
-		skb->dev = dev;
 	}
 	return skb;
 }
-- 
1.7.9.5
