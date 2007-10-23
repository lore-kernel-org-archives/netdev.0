From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/11] [IPSEC]: Use dst->header_len when resizing on output
Date: Wed, 24 Oct 2007 00:03:27 +0800
Message-ID: <E1IkME3-0008O2-00@gondolin.me.apana.org.au>
References: <20071023160217.GA32102@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2441 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751841AbXJWQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 12:03:32 -0400
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
