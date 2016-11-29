From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH net 2/2] esp6: Fix integrity verification when ESN are used
Date: Tue, 29 Nov 2016 17:05:25 +0100
Message-ID: <f3c5eaa5-d1a3-cc7a-1bd8-20fa2c961770@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:42401 "EHLO
        mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcK2QMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 11:12:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling inbound packets, the two halves of the sequence number
stored on the skb are already in network order.

Fixes: 000ae7b2690e ("esp6: Switch to new AEAD interface")
Signed-off-by: Tobias Brunner <tobias@strongswan.org>
---
 net/ipv6/esp6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 060a60b2f8a6..111ba55fd512 100644
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
