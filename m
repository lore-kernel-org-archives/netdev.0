From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] [IPSEC] esp: Remove NAT-T checksum invalidation for BEET
Date: Wed, 10 Oct 2007 22:40:10 +0800
Message-ID: <E1IfcjK-00023y-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3575 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753611AbXJJOkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC] esp: Remove NAT-T checksum invalidation for BEET

I pointed this out back when this patch was first proposed but it looks like
it got lost along the way.

The checksum only needs to be ignored for NAT-T in transport mode where
we lose the original inner addresses due to NAT.  With BEET the inner
addresses will be intact so the checksum remains valid.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/esp4.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 452910d..1af332d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -261,8 +261,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 		 *    as per draft-ietf-ipsec-udp-encaps-06,
 		 *    section 3.1.2
 		 */
-		if (x->props.mode == XFRM_MODE_TRANSPORT ||
-		    x->props.mode == XFRM_MODE_BEET)
+		if (x->props.mode == XFRM_MODE_TRANSPORT)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
