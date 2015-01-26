From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm6: Fix transport header offset in _decode_session6.
Date: Mon, 26 Jan 2015 08:48:22 +0100
Message-ID: <1422258503-26978-2-git-send-email-steffen.klassert@secunet.com>
References: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34919 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbbAZHsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 02:48:35 -0500
In-Reply-To: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->transport_header might not be valid when we do a reverse
decode because the ipv6 tunnel error handlers don't update it
to the inner transport header. This leads to a wrong offset
calculation and to wrong layer 4 informations. We fix this
by using the size of the ipv6 header as the first offset.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 5f98364..aa48302 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -130,8 +130,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	struct flowi6 *fl6 = &fl->u.ip6;
 	int onlyproto = 0;
-	u16 offset = skb_network_header_len(skb);
 	const struct ipv6hdr *hdr = ipv6_hdr(skb);
+	u16 offset = sizeof(*hdr);
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
-- 
1.9.1
