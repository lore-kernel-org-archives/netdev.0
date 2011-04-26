From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-2.6 2/4] esp6: Fix scatterlist initialization
Date: Tue, 26 Apr 2011 07:40:23 +0200
Message-ID: <20110426054023.GG5495@secunet.com>
References: <20110426053923.GF5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58806 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657Ab1DZFjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:39:53 -0400
Content-Disposition: inline
In-Reply-To: <20110426053923.GF5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we use IPsec extended sequence numbers, we may overwrite
the last scatterlist of the associated data by the scatterlist
for the skb. This patch fixes this by placing the scatterlist
for the skb right behind the last scatterlist of the associated
data. esp4 does it already like that.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 5aa8ec8..59dccfb 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -371,7 +371,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_req(aead, iv);
 	asg = esp_req_sg(aead, req);
-	sg = asg + 1;
+	sg = asg + sglists;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-- 
1.7.0.4

