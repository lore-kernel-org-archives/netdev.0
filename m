From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Tue, 15 Mar 2005 17:01:53 +1100
Message-ID: <20050315060153.GA3282@gondor.apana.org.au>
References: <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net> <20050307014337.GA4451@gondor.apana.org.au> <422BB477.3040607@trash.net> <20050307015943.GA4533@gondor.apana.org.au> <422BBCC2.4010706@trash.net> <20050307025723.GA4818@gondor.apana.org.au> <422BC655.5070907@trash.net> <20050314215122.356ea961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050314215122.356ea961.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2005 at 09:51:22PM -0800, David S. Miller wrote:
> On Mon, 07 Mar 2005 04:11:17 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Herbert Xu wrote:
> > > The reason I'm asking is because the places where you're most likely
> > > to use tos/fwmark is in IPsec gateways.  In other words, it isn't
> > > very useful unless it works in tunnel mode.  This plus the fact
> > > that the check for tunnel mode is a bit of a hack makes me think that
> > > it's not worth it at the moment.
> > 
> > Ok, let's drop it for now.
> 
> Can someone send me an updated patch (with changelog msg please)?

I think the conclusion is that until we fix the bundle scalability
problem there is no point in adding tos/fwmark support here.

The reason is that if we do it now then tunnel mode SAs will potentially
be targets of DoS attacks that create a large number of bundles off
one policy.  However, tunnel mode SAs would be the main users of
this feature so if we can't do it for them then we might as well not
do it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
