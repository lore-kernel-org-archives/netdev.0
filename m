From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of locked section
Date: Thu, 8 Nov 2007 08:39:03 +0800
Message-ID: <20071108003903.GA11963@gondor.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au> <200711071717.43429.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1454 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755566AbXKHAjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 19:39:20 -0500
Content-Disposition: inline
In-Reply-To: <200711071717.43429.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 05:17:42PM +0100, Ingo Oeser wrote:
> Hi Herbert,
> 
> Herbert Xu schrieb:
> > diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
> > index a7bc8c6..4a01cb3 100644
> > --- a/net/ipv6/xfrm6_mode_ro.c
> > +++ b/net/ipv6/xfrm6_mode_ro.c
> > @@ -53,7 +54,9 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
> >  	__skb_pull(skb, hdr_len);
> >  	memmove(ipv6_hdr(skb), iph, hdr_len);
> >  
> > +	spin_lock_bh(&x->lock);
> >  	x->lastused = get_seconds();
> > +	spin_unlock_bh(&x->lock);
> >  
> >  	return 0;
> >  }
> 
> Can you move the retrieval of the seconds outside the spinlock?

You certainly could.  Whether it's worth it I won't speculate :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
