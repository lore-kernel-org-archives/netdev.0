From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Fri, 18 Feb 2005 21:08:54 +1100
Message-ID: <20050218100854.GA19427@gondor.apana.org.au>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42152841.5000707@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 18, 2005 at 12:26:57AM +0100, Patrick McHardy wrote:
>
> Yes, this part is simple. There's one thing I think we need to do
> slightly different from what you describe. The current behaviour is
> to resolve one SA at a time, we should keep it this way because we
> may need an early SA in the bundle for a different policy to resolve
> a follow-up SA for nested tunnels with different peers where the
> second peer is only reachable through a tunnel to the first peer.

Agreed.  This doesn't stop us from creating the bundle object of course.
 
> I'm not sure yet how to deal with optional SAs. We shouldn't add
> incomplete optional tunnel mode SAs to the bundle because then we
> can't determine the output device, but if we don't nothing will
> trigger resolving of optional SAs following a non-optional SA that
> needs to be resolved.

I don't get it.  Can't you just add it into the bundle but ignore it
for dst->output and other calculations until it's either realised or
removed?

> I thought about adding the queue to the xfrm_dst and adding a dummy
> xfrm_state with a selector that matches only the current flow. This

The inner flow is probably not the best key for this.  How about
keying it using the outer remote address on the template? The SAs
have a bydst hash which makes this easy to look up.

So we would attach each packet to a queue shared by all SAs to a
specific (outer) remote address.
 
> Finding all queues affected by ADDSA/UPDATESA is not easy. A SA
> installed in response to an acquire request doesn't need to match
> the one requested, so theoretically states waiting on different
> larval states SAs might be able to use it. I don't think we have
> much choice other than looking at all incomplete bundles (or
> one per flow) on SADB changes.

If you key it on the remote address then you only have to look up
those.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
