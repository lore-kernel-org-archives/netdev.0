From: Andrew Morton <akpm@linux-foundation.org>
Subject: fix-slab-corruption-running-ip6sic.patch
Date: Thu, 26 Apr 2007 14:11:33 -0700
Message-ID: <20070426141133.21ef2e17.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:45104 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752994AbXDZVMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:12:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have this floating about in my tree.  Is it of any interest?



From: Jarek Poplawski <jarkao2@o2.pl>

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> >
> > My proposal is: maybe Eric could change this in
> > xfrm6_tunnel_rcv() from xfrm6_tunnel.c e.g. like this:
> >
> > return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
> >
> > and, if no errors in testing, he could resubmit this patch?
>
> I agree, this is the right fix.

The fix proposed by Jarek indeed fixes the problem, tested on two boxes,
with an -rc5 kernel and a yesterdays git

Acked-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv6/xfrm6_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv6/xfrm6_tunnel.c~fix-slab-corruption-running-ip6sic net/ipv6/xfrm6_tunnel.c
--- a/net/ipv6/xfrm6_tunnel.c~fix-slab-corruption-running-ip6sic
+++ a/net/ipv6/xfrm6_tunnel.c
@@ -261,7 +261,7 @@ static int xfrm6_tunnel_rcv(struct sk_bu
 	__be32 spi;
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(skb, spi);
+	return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
_

