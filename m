From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/7] xfrm: Decode sessions with output interface.
Date: Wed,  9 Oct 2013 12:59:06 +0200
Message-ID: <1381316351-14418-3-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51333 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756948Ab3JIK72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:28 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The output interface matching does not work on forward
policy lookups, the output interface of the flowi is
always 0. Fix this by setting the output interface when
we decode the session.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/xfrm6_policy.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 9a459be..ccde542 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -107,6 +107,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
+	fl4->flowi4_oif = skb_dst(skb)->dev->ifindex;
 
 	if (!ip_is_fragment(iph)) {
 		switch (iph->protocol) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 23ed03d..08ed277 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -138,6 +138,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
+	fl6->flowi6_oif = skb_dst(skb)->dev->ifindex;
 
 	fl6->daddr = reverse ? hdr->saddr : hdr->daddr;
 	fl6->saddr = reverse ? hdr->daddr : hdr->saddr;
-- 
1.7.9.5
