From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/7] esp6: Use high-order sequence number bits for IV generation
Date: Thu, 28 May 2015 09:28:06 +0200
Message-ID: <1432798090-20657-4-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51229 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbbE1H2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:30 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

I noticed we were only using the low-order bits for IV generation
when ESN is enabled.  This is very bad because it means that the
IV can repeat.  We must use the full 64 bits.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 31f1b5d..7c07ce3 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -248,7 +248,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, assoclen);
 	aead_givcrypt_set_giv(req, esph->enc_data,
-			      XFRM_SKB_CB(skb)->seq.output.low);
+			      XFRM_SKB_CB(skb)->seq.output.low +
+			      ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
-- 
1.9.1
