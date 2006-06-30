From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 15:42:09 +1000
Message-ID: <20060630054209.GA28558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:57610 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751105AbWF3FnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 01:43:13 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I've added GSO for TCPv6 and updated Ananda's patch.  Please note that
the following patches have only been compile-tested.

[IPV6]: Remove redundant length check on input

We don't need to check skb->len when we're just about to call
pskb_may_pull since that checks it for us.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -84,14 +84,9 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	 */
 	IP6CB(skb)->iif = skb->dst ? ((struct rt6_info *)skb->dst)->rt6i_idev->dev->ifindex : dev->ifindex;
 
-	if (skb->len < sizeof(struct ipv6hdr))
+	if (unlikely(!pskb_may_pull(skb, sizeof(*hdr))))
 		goto err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr))) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
-		goto drop;
-	}
-
 	hdr = skb->nh.ipv6h;
 
 	if (hdr->version != 6)
