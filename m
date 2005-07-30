From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [hipl-users] Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for	Linux
Date: Sat, 30 Jul 2005 21:15:00 +1000
Message-ID: <E1DypIy-00037K-00@gondolin.me.apana.org.au>
References: <1122651216.25842.67.camel@odysse>
Cc: herbert@gondor.apana.org.au, infrahip@HIIT.FI, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: diego.beltrami@HIIT.FI
In-Reply-To: <1122651216.25842.67.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Diego Beltrami <diego.beltrami@hiit.fi> wrote:
> 
> The modifications in the ESP functions are due to the hybrid cases when
> Inner and Outer address families are different; in those cases the
> values returned by espX functions are not coherent.

I see.  However, this is really a consequence of us not implementing
interfamily transforms for plain old tunnel mode.  Had we implemented
that, it would be a piece of cake to extend this to BEET without
touching ESP.

>> Also, if you're going to do cross-family transforms, it should be
>> done for both BEET and plain tunnel-mode.
> 
> Potentially it could be possible also for plain tunnel-mode: this will
> require further analysis.

It definitely does need further analysis even for BEET mode.  The rcv
path for interfamily transforms is straightforward since we pass through
netif_rx.  However, on the outbound path things aren't that simple.

I suggest that you remove the interfamily support for the initial merge
of the BEET implementation.  We can then readd it for both plain tunnel
and BEET mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
