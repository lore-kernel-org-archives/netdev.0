From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 8/8] ipv6: esp6: use BUG_ON instead of if condition followed by BUG
Date: Mon, 30 Oct 2017 09:39:35 +0100
Message-ID: <1509352775-9563-9-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41274 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932220AbdJ3Ijp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:45 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>

Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1696401..4000b71 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -483,8 +483,8 @@ static inline int esp_remove_trailer(struct sk_buff *skb)
 		goto out;
 	}
 
-	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
-		BUG();
+	ret = skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2);
+	BUG_ON(ret);
 
 	ret = -EINVAL;
 	padlen = nexthdr[0];
-- 
2.7.4
