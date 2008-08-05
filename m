From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH 2/2] Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 10:13:19 +0300
Message-ID: <200808051013.19873.joakim.koskela@hiit.fi>
References: <200808041619.42562.joakim.koskela@hiit.fi> <20080804162046.GA12969@gondor.apana.org.au>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:50171 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbYHEHOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 03:14:20 -0400
In-Reply-To: <20080804162046.GA12969@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 04 August 2008 19:20:46 Herbert Xu wrote:
> > diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> > index c6bb4c6..f09fcb9 100644
> > --- a/net/ipv6/esp6.c
> > +++ b/net/ipv6/esp6.c
> > @@ -521,6 +521,10 @@ static int esp6_init_state(struct xfrm_state *x)
> >  			      crypto_aead_ivsize(aead);
> >  	switch (x->props.mode) {
> >  	case XFRM_MODE_BEET:
> > +		x->props.header_len += IPV4_BEET_PHMAXLEN;
> > +		if (x->sel.family == AF_INET)
> > +			x->props.header_len += (sizeof(struct ipv6hdr) - sizeof(struct
> > iphdr));
>
> This is still going to break with the new any family (i.e., v4
> or v6) SA.  So perhaps that should be x->sel.family != AF_INET6.
>
> Cheers,

Hi, and thanks for checking this out. Didn't think about the any family, 
thanks for catching that. I'll resubmit this part.

br, j
