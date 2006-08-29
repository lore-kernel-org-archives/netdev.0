From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 29 Aug 2006 18:28:28 +1000
Message-ID: <20060829082828.GA8625@gondor.apana.org.au>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:21771 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750834AbWH2I2j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 04:28:39 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20060828004906.GC20092@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 02:49:07AM +0200, cagri coltekin wrote:
> 
> Ooops, sorry for the confusion. It happens with 2.6.17 too (see
> below), cut&paste from wrong log. The rest of the data provided
> in the previous message is actually fresh.

Thanks.  Please try this patch and tell me if it prints anything out.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4fb47a2..5e2e4ea 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -508,6 +508,10 @@ static int ip6_fragment(struct sk_buff *
 	dev = rt->u.dst.dev;
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
+	if (unlikely(hlen > skb->len)) {
+		printk(KERN_CRIT "ip6_fragment: hlen = 0x%x, len = 0x%x, nexthdr=%d\n", hlen, skb->len, nexthdr);
+		BUG();
+	}
 
 	mtu = dst_mtu(&rt->u.dst);
 	if (np && np->frag_size < mtu) {
