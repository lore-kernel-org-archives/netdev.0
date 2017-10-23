From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv4: esp4: use BUG_ON instead of if condition followed by
 BUG
Date: Mon, 23 Oct 2017 13:06:09 -0500
Message-ID: <20171023180608.GA25108@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ipv4/esp4.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b00e4a4..89b6c5e 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -521,8 +521,7 @@ static inline int esp_remove_trailer(struct sk_buff *skb)
 		goto out;
 	}
 
-	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2));
 
 	ret = -EINVAL;
 	padlen = nexthdr[0];
-- 
2.7.4
