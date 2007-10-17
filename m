From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/11] [IPSEC]: Fix pure tunnel modes involving IPv6
Date: Wed, 17 Oct 2007 22:34:08 +0800
Message-ID: <E1Ii9yK-0006Ga-00@gondolin.me.apana.org.au>
References: <20071017142940.GA23879@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1083 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756265AbXJQOeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:34:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Fix pure tunnel modes involving IPv6

I noticed that my recent patch broke 6-on-4 pure IPsec tunnels (the ones
that are only used for incompressible IPsec packets).  Subsequent reviews
show that I broke 6-on-6 pure tunnels more than three years ago and nobody
ever noticed. I suppose every must be testing 6-on-6 IPComp with large
pings which are very compressible :)

This patch fixes both cases.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_tunnel.c |    2 +-
 net/ipv6/xfrm6_tunnel.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 1312417..83e9580 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -18,7 +18,7 @@ static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int ipip_xfrm_rcv(struct xfrm_state *x, struct sk_buff *skb)
 {
-	return IPPROTO_IP;
+	return ip_hdr(skb)->protocol;
 }
 
 static int ipip_init_state(struct xfrm_state *x)
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 3f8a3ab..6c67ac1 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -248,7 +248,7 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	return 0;
+	return skb_network_header(skb)[IP6CB(skb)->nhoff];
 }
 
 static int xfrm6_tunnel_rcv(struct sk_buff *skb)
