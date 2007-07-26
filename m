From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPVS]: Use skb_forward_csum
Date: Thu, 26 Jul 2007 16:59:39 +0800
Message-ID: <20070726085939.GA442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1238 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756119AbXGZI7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 04:59:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Found this while looking at 8797.  Although it's not clear
that this is the cause yet (it could only happen if a
seemingly remote TCP stream is DNATed to a local address),
we need this patch anyway to avoid clobbering incoming
traffic with CHECKSUM_PARTIAL in its ip_summed field.

[IPVS]: Use skb_forward_csum

As a path that forwards packets, IPVS should be using
skb_forward_csum instead of directly setting ip_summed
to CHECKSUM_NONE.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 900ce29..666e080 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -128,7 +128,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 #define IP_VS_XMIT(skb, rt)				\
 do {							\
 	(skb)->ipvs_property = 1;			\
-	(skb)->ip_summed = CHECKSUM_NONE;		\
+	skb_forward_csum(skb);				\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
