From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 14:41:54 +0800
Message-ID: <20071114064154.GA11367@gondor.apana.org.au>
References: <20071114062834.GB11173@gondor.apana.org.au> <20071113.223356.216207937.davem@davemloft.net> <20071114063657.GA11293@gondor.apana.org.au> <20071113.223803.40309642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2896 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760441AbXKNGl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:41:57 -0500
Content-Disposition: inline
In-Reply-To: <20071113.223803.40309642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 10:38:03PM -0800, David Miller wrote:
> 
> We need to fix something else up first :-)
> 
> net/ipv4/xfrm4_input.c: In function 'xfrm4_transport_finish':
> net/ipv4/xfrm4_input.c:65: error: implicit declaration of function 'xfrm4_rcv_encap_finish'
> net/ipv4/xfrm4_input.c:67: error: 'nexthdr' undeclared (first use in this function)
> net/ipv4/xfrm4_input.c:67: error: (Each undeclared identifier is reported only once
> net/ipv4/xfrm4_input.c:67: error: for each function it appears in.)
> make[2]: *** [net/ipv4/xfrm4_input.o] Error 1
> make[1]: *** [net/ipv4] Error 2
> make: *** [net] Error 2

No netfilter, surely not :)

Does this patch help?

[IPSEC]: Fix build problem with netfilter off

The function xfrm4_rcv_encap_finish is now used even with NETFILTER
off.  So we need to remove the ifdefs around i.t

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index cd25351..7795938 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -21,7 +21,6 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm4_extract_header(skb);
 }
 
-#ifdef CONFIG_NETFILTER
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
 	if (skb->dst == NULL) {
@@ -36,7 +35,6 @@ drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
-#endif
 
 int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
