From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Sat, 19 Feb 2005 20:23:14 +1100
Message-ID: <20050219092314.GA8153@gondor.apana.org.au>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4216D6B4.5070901@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 07:03:32AM +0100, Patrick McHardy wrote:
>
> An optional tunnel mode SA might change peer/dev/rt_gateway/rt_type if
> successfully resolved. This introduces a couple of problems:
> 
> - MTU estimatation impossible

This is OK for two reasons:

1) The application must be able to react to MTU changes anyway.
2) The most common use for optional SAs is IPCOMP which has zero overhead.

Actually, 2) gives us the real reason why we must include optional SAs.
Even though we can skip the compression of a tunnel mode IPCOMP SA, we
must perform the IPIP encapsulation.

> - netfilter LOCAL_OUT hook sees incorrect output device
> - strict source routing check done with incorrect rt_gateway

Once you take the above into account these turn out to be non-issues.
If the optional SA is transport mode, then the route is identical with
or without it.  If it's tunnel mode, then we must perform the IPIP
encapsulation regardless.

> That sounds reasonable. The selector initialized to the inner flow is
> meant for cacheing the incomplete bundle at the policy. We can have
> multiple SAs with equal family/reqid/saddr/daddr/mode/proto differing
> only be SPI and selector. If we use a selector selecting more than the
> inner flow we could create a conflict with an already existing cached
> bundle.

Agreed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
