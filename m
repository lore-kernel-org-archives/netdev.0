From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv6: esp6: use BUG_ON instead of if condition followed by
 BUG
Date: Tue, 24 Oct 2017 11:28:26 -0500
Message-ID: <20171024162826.GA29550@embeddedor.com>
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
 net/ipv6/esp6.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89910e2..603ff06 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -483,8 +483,7 @@ static inline int esp_remove_trailer(struct sk_buff *skb)
 		goto out;
 	}
 
-	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2));
 
 	ret = -EINVAL;
 	padlen = nexthdr[0];
-- 
2.7.4
