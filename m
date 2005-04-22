From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel BUG at net/ipv6/exthdrs_core.c:80!
Date: Fri, 22 Apr 2005 23:58:40 +1000
Message-ID: <E1DOyg4-0000iB-00@gondolin.me.apana.org.au>
References: <20050422.204610.96031992.yoshfuji@linux-ipv6.org>
Cc: matti.aarnio@zmailer.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20050422.204610.96031992.yoshfuji@linux-ipv6.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> 
> I assume that BUG was raised because of skb_header_pointer()'s failure;
> which means, skb_copy_bits()'s failure. Strange to me.
> 
> Do you know what caused this?
> How about disabling selinux / ip6tables?

Indeed, it's a bug in selinux.  The length should be skb->tail - skb->data,
and not skb->tail - skb->head.  In fact, we could be vulgar and write it as
skb->len :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== security/selinux/hooks.c 1.95 vs edited =====
--- 1.95/security/selinux/hooks.c	2005-04-02 07:30:16 +10:00
+++ edited/security/selinux/hooks.c	2005-04-22 23:55:19 +10:00
@@ -2853,8 +2853,7 @@
 
 	nexthdr = ip6->nexthdr;
 	offset += sizeof(_ipv6h);
-	offset = ipv6_skip_exthdr(skb, offset, &nexthdr,
-				  skb->tail - skb->head - offset);
+	offset = ipv6_skip_exthdr(skb, offset, &nexthdr, skb->len - offset);
 	if (offset < 0)
 		goto out;
 
