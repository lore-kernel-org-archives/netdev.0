From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: xfrm: Always zero high-order sequence number bits
Date: Thu, 21 May 2015 00:38:12 +0800
Message-ID: <20150520163810.GA13992@gondor.apana.org.au>
References: <20150513072610.GA27424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49904 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbbETQiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 12:38:22 -0400
Content-Disposition: inline
In-Reply-To: <20150513072610.GA27424@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we're now always including the high bits of the sequence number
in the IV generation process we need to ensure that they don't
contain crap.

This patch ensures that the high sequence bits are always zeroed
so that we don't leak random data into the IV.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index dab57da..4fd725a 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -99,6 +99,7 @@ static int xfrm_replay_overflow(struct xfrm_state *x, struct sk_buff *skb)
 
 	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 		XFRM_SKB_CB(skb)->seq.output.low = ++x->replay.oseq;
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
 		if (unlikely(x->replay.oseq == 0)) {
 			x->replay.oseq--;
 			xfrm_audit_state_replay_overflow(x, skb);
@@ -177,6 +178,7 @@ static int xfrm_replay_overflow_bmp(struct xfrm_state *x, struct sk_buff *skb)
 
 	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 		XFRM_SKB_CB(skb)->seq.output.low = ++replay_esn->oseq;
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
 		if (unlikely(replay_esn->oseq == 0)) {
 			replay_esn->oseq--;
 			xfrm_audit_state_replay_overflow(x, skb);

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
