From: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
Subject: Re: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Wed, 25 Apr 2007 10:27:59 +0200
Message-ID: <20070425082759.GA9258@alice>
References: <20070424073151.GA2333@ff.dom.local> <E1HgVf2-0001K7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jarek Poplawski <jarkao2@o2.pl>, davem@davemloft.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, snakebyte@gmx.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:41583 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1423291AbXDYI2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 04:28:03 -0400
Content-Disposition: inline
In-Reply-To: <E1HgVf2-0001K7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

--- linux-2.6/net/ipv6/xfrm6_tunnel.c.orig	2007-04-25 00:22:30.000000000 +0200
+++ linux-2.6/net/ipv6/xfrm6_tunnel.c	2007-04-25 00:22:45.000000000 +0200
@@ -261,7 +261,7 @@ static int xfrm6_tunnel_rcv(struct sk_bu
 	__be32 spi;
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(skb, spi);
+	return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,




