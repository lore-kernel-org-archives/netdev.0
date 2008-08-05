From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 15:22:49 +0800
Message-ID: <20080805072249.GA20340@gondor.apana.org.au>
References: <200808041619.42562.joakim.koskela@hiit.fi> <20080804162046.GA12969@gondor.apana.org.au> <200808051013.19873.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56356 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754429AbYHEHWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 03:22:52 -0400
Content-Disposition: inline
In-Reply-To: <200808051013.19873.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 10:13:19AM +0300, Joakim Koskela wrote:
> > > diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> > > index c6bb4c6..f09fcb9 100644
> > > --- a/net/ipv6/esp6.c
> > > +++ b/net/ipv6/esp6.c
> > > @@ -521,6 +521,10 @@ static int esp6_init_state(struct xfrm_state *x)
> > >  			      crypto_aead_ivsize(aead);
> > >  	switch (x->props.mode) {
> > >  	case XFRM_MODE_BEET:
> > > +		x->props.header_len += IPV4_BEET_PHMAXLEN;
> > > +		if (x->sel.family == AF_INET)
> > > +			x->props.header_len += (sizeof(struct ipv6hdr) - sizeof(struct
> > > iphdr));

Also could we avoid the IPV4_BEET_PHMAXLEN part if the inner family
is IPv6?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
