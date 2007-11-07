From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/24] [IPSEC]: Use dst->header_len when resizing on output
Date: Wed, 07 Nov 2007 22:08:18 +0800
Message-ID: <E1IplZq-0001G4-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3517 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757404AbXKGOIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Use dst->header_len when resizing on output

Currently we use x->props.header_len when resizing on output.  However,
if we're resizing at all we might as well go the whole hog and do it
for the whole dst.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index f4bfd6c..58d5a74 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -19,7 +19,8 @@
 
 static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 {
-	int nhead = x->props.header_len + LL_RESERVED_SPACE(skb->dst->dev)
+	struct dst_entry *dst = skb->dst;
+	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
 		- skb_headroom(skb);
 
 	if (nhead > 0)
