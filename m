From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Fri, 18 Feb 2005 20:53:44 +1100
Message-ID: <20050218095344.GA19307@gondor.apana.org.au>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net> <20050217203805.GA4047@gondor.apana.org.au> <42150B36.5080609@trash.net> <20050217221031.GA4554@gondor.apana.org.au> <42152283.4030800@trash.net> <20050217151122.098c6def.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050217151122.098c6def.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 17, 2005 at 03:11:22PM -0800, David S. Miller wrote:
> 
> I have to side with Patrick on this one.

OK.

> This is one of the fundamental tunnel behavior differences between
> Transport mode and Tunnel mode SAs.

I don't see it that way.  To me IPsec is about encapsulating a packet
so that it gets to the destination securely.  It shouldn't affect the
routing of the packet on the host itself.  Of course, once the packet
leaves the host the IPsec encapsulation will certainly affect its
routing.

In this respect, the difference between transport mode SAs and tunnel
mode SAs is simply that one adds an IP header while the other doesn't.

Ideally I should be able to only look at the routing table and determine
which interface/gateway a packet is going to be sent through.  As it is
I need to look at the routing table plus the IPsec database.

Put it another way, my solution to Patrick's inconsistency would be to
always inherit the routing decision from the top to the bottom of the
bundle.  For example, suppose you had

ip ro add 192.168.0.0/16 \
	nexthop via 10.0.0.1 dev eth0 \
	nexthop via 10.0.0.2 dev eth0

Then the packets to 192.168.0.0/16 should be sent via 10.0.0.1/10.0.0.2
regardless of what IPsec protections are applied to it.

This is something that can't be done in a clean way with the
current setup.  I'd like to see that available in Linux at some
point.  It'll have to be optional of course (selectable per-policy).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
