From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6]: Disable SG for GSO unless we have checksum
Date: Thu, 28 Sep 2006 10:44:23 +1000
Message-ID: <20060928004422.GA9050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14342 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1031298AbWI1AoZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 20:44:25 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV6]: Disable SG for GSO unless we have checksum

Because the system won't turn off the SG flag for us we
need to do this manually on the IPv6 path.  Otherwise we
will throw IPv6 packets with bad checksums at the hardware.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4f3bb7f..de6b919 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -123,6 +123,9 @@ static struct sk_buff *ipv6_gso_segment(
 	struct ipv6hdr *ipv6h;
 	struct inet6_protocol *ops;
 
+	if (!(features & NETIF_F_HW_CSUM))
+		features &= ~NETIF_F_SG;
+
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
