From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/7] xfrm: Always zero high-order sequence number bits
Date: Thu, 28 May 2015 09:28:07 +0200
Message-ID: <1432798090-20657-5-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51235 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbbE1H2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:30 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

As we're now always including the high bits of the sequence number
in the IV generation process we need to ensure that they don't
contain crap.

This patch ensures that the high sequence bits are always zeroed
so that we don't leak random data into the IV.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c | 2 ++
 1 file changed, 2 insertions(+)

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
1.9.1
