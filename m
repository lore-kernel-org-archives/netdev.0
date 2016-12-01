From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] esp6: Fix integrity verification when ESN are used
Date: Thu, 1 Dec 2016 12:44:52 +0100
Message-ID: <1480592692-3653-4-git-send-email-steffen.klassert@secunet.com>
References: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50038 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcLALpD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 06:45:03 -0500
In-Reply-To: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias@strongswan.org>

When handling inbound packets, the two halves of the sequence number
stored on the skb are already in network order.

Fixes: 000ae7b2690e ("esp6: Switch to new AEAD interface")
Signed-off-by: Tobias Brunner <tobias@strongswan.org>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 060a60b..111ba55 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -418,7 +418,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		esph = (void *)skb_push(skb, 4);
 		*seqhi = esph->spi;
 		esph->spi = esph->seq_no;
-		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.input.hi);
+		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
 		aead_request_set_callback(req, 0, esp_input_done_esn, skb);
 	}
 
-- 
1.9.1
