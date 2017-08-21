From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Mon, 21 Aug 2017 12:41:43 -0700
Message-ID: <20170821194143.27885-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, woojung.huh@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34822 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753747AbdHUTlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 15:41:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id p8so16598385wrf.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 12:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_put_padto() already frees the passed sk_buff reference upon error,
so calling kfree_skb() on it again is not necessary.

Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")

Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_ksz.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..107172c82107 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -60,10 +60,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 					 skb_transport_header(skb) - skb->head);
 		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
 
-		if (skb_put_padto(nskb, nskb->len + padlen)) {
-			kfree_skb(nskb);
+		if (skb_put_padto(nskb, nskb->len + padlen))
 			return NULL;
-		}
 
 		kfree_skb(skb);
 	}
-- 
2.9.3
