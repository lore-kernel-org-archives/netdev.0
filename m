From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 7 Mar 2005 13:57:23 +1100
Message-ID: <20050307025723.GA4818@gondor.apana.org.au>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net> <20050307014337.GA4451@gondor.apana.org.au> <422BB477.3040607@trash.net> <20050307015943.GA4533@gondor.apana.org.au> <422BBCC2.4010706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422BBCC2.4010706@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2005 at 03:30:26AM +0100, Patrick McHardy wrote:
> 
> I agree that it is more important, but I don't see any harm in fixing
> the other problem for transport mode first. Fixing the scalability
> problem requires a dynamically resized hash, anything static will
> lead to different scalability problems with a large number of policies.
> The tos/fwmark part looks comparatively small, simply reroute all
> packets based on src/dst/fwmark/predicted final tos if they differ.
> But since both of this is not done yet, I think it would be better to
> fix the smaller problem first.

The reason I'm asking is because the places where you're most likely
to use tos/fwmark is in IPsec gateways.  In other words, it isn't
very useful unless it works in tunnel mode.  This plus the fact
that the check for tunnel mode is a bit of a hack makes me think that
it's not worth it at the moment.

On the subject of fixing the scalability issue, we should just use
the flow cache directly for each bundle.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
