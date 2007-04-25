From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Wed, 25 Apr 2007 14:05:33 +0200
Message-ID: <20070425120533.GD1613@ff.dom.local>
References: <20070424073151.GA2333@ff.dom.local> <E1HgVf2-0001K7-00@gondolin.me.apana.org.au> <20070425082759.GA9258@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:36703 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964780AbXDYMOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 08:14:49 -0400
Content-Disposition: inline
In-Reply-To: <20070425082759.GA9258@alice>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 10:27:59AM +0200, Eric Sesterhenn / Snakebyte wrote:
> * Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > >
> > > My proposal is: maybe Eric could change this in
> > > xfrm6_tunnel_rcv() from xfrm6_tunnel.c e.g. like this:
> > > 
> > > return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
> > > 
> > > and, if no errors in testing, he could resubmit this patch? 
> > 
> > I agree, this is the right fix.
> 
> 
> The fix proposed by Jarek indeed fixes the problem, tested on two boxes,
> with an -rc5 kernel and a yesterdays git
> 
> Acked-by: Eric Sesterhenn <snakebyte@gmx.de>
> 
> --- linux-2.6/net/ipv6/xfrm6_tunnel.c.orig	2007-04-25 00:22:30.000000000 +0200
> +++ linux-2.6/net/ipv6/xfrm6_tunnel.c	2007-04-25 00:22:45.000000000 +0200
> @@ -261,7 +261,7 @@ static int xfrm6_tunnel_rcv(struct sk_bu
>  	__be32 spi;
>  
>  	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
> -	return xfrm6_rcv_spi(skb, spi);
> +	return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
>  }
>  
>  static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,

I think the main idea of fixing the problem plus testing is Eric's only
credit and I've only proposed some change in placement of cosmetic value.

So, Eric, considering all massive work you've done with rather feeble
support, please, fix the comment and sign this patch (at least I'm not
going to).

I also please Andrew to change the assignement of this patch in -mm.

Thanks & regards,
Jarek P.
