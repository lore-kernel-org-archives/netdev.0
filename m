From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipsec: Remove useless ret variable
Date: Wed, 24 Dec 2008 16:37:24 +1100
Message-ID: <20081224053724.GA23476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60259 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750701AbYLXFh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 00:37:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

ipsec: Remove useless ret variable

This patch removes a useless ret variable from the IPv4 ESP/UDP
decapsulation code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 390dcb1..4ec2162 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -78,7 +78,6 @@ int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 	struct udphdr *uh;
 	struct iphdr *iph;
 	int iphlen, len;
-	int ret;
 
 	__u8 *udpdata;
 	__be32 *udpdata32;
@@ -152,8 +151,7 @@ int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 	skb_reset_transport_header(skb);
 
 	/* process ESP */
-	ret = xfrm4_rcv_encap(skb, IPPROTO_ESP, 0, encap_type);
-	return ret;
+	return xfrm4_rcv_encap(skb, IPPROTO_ESP, 0, encap_type);
 
 drop:
 	kfree_skb(skb);

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
