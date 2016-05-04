From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Reset encapsulation field of the skb before transformation
Date: Wed, 4 May 2016 07:40:53 +0200
Message-ID: <1462340454-27922-3-git-send-email-steffen.klassert@secunet.com>
References: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56683 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbcEDFlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 01:41:05 -0400
In-Reply-To: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inner headers are invalid after a xfrm transformation.
So reset the skb encapsulation field to ensure nobody tries
to access the inner headers.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_output.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index ff4a91f..637387b 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -99,6 +99,9 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		skb_dst_force(skb);
 
+		/* Inner headers are invalid now. */
+		skb->encapsulation = 0;
+
 		err = x->type->output(x, skb);
 		if (err == -EINPROGRESS)
 			goto out;
-- 
1.9.1
