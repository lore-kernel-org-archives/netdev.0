From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/3] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Mon, 8 May 2006 23:47:29 +1000
Message-ID: <20060508134729.GA13089@gondor.apana.org.au>
References: <1145343829.44448f556684c@webmail.hiit.fi> <20060506112026.GA27671@gondor.apana.org.au> <20060506112123.GA27904@gondor.apana.org.au> <200605081522.14524.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15879 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751256AbWEHNrw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 09:47:52 -0400
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200605081522.14524.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo:

On Mon, May 08, 2006 at 03:22:14PM +0200, Ingo Oeser wrote:
> 
> you wrote:
> > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> > --- a/include/net/xfrm.h
> > +++ b/include/net/xfrm.h
> > @@ -204,8 +204,7 @@ struct xfrm_type;
> > ?struct xfrm_dst;
> > ?struct xfrm_policy_afinfo {
> > ????????unsigned short??????????family;
> > -???????rwlock_t????????????????lock;
> > -???????struct xfrm_type_map????*type_map;
> > +???????struct xfrm_type????????*type_map[256];
> 
> What does this magic number "256" mean? I guess we need either
> a comment or a proper constant here. I prefer the latter.

It's just moving an existing line down if you look further up in
the patch.  Of couse I would have nothing against a patch that
replaced 256 with IPPROTO_MAX or something.

However, I prefer to not mix clean-ups with substantive changes so
if you have the time please post a separate patch for this.  Otherwise
I'll do a patch when I resubmit this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
