From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v2] ipv6: esp6: use BUG_ON instead of if condition followed
 by BUG
Date: Thu, 26 Oct 2017 07:51:06 -0500
Message-ID: <20171026125106.GA13009@embeddedor.com>
References: <20171025040750.GB1999@gondor.apana.org.au>
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
In-Reply-To: <20171025040750.GB1999@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
Changes in v2:
 Update the code as suggested by Herbert Xu:

 ret = foo();
 BUG_ON(ret);

 net/ipv6/esp6.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89910e2..da1f6a6 100644
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
