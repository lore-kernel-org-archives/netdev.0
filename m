From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 22:36:54 +1100
Message-ID: <20050217113654.GA10346@gondor.apana.org.au>
References: <4214381F.5020507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4214381F.5020507@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 17, 2005 at 07:22:23AM +0100, Patrick McHardy wrote:
>
> #   Tunnel mode packets are rerouted if the tunnel destination
> #   address is different from the original destination address,
> #   otherwise the old route is used. This is inconsistent, the
> #   old route might have been selected for a given output device
> #   or using routing by tos/fwmark. Always choose a new route
> #   in tunnel mode.

I understand the inconsistency and agree that it should be fixed.
However, I think the way you did it has created a new inconsistency.

Tunnel mode SAs are not always used to carry subnets.  It can also
be used for host-to-host configurations where the aim is to protect
the IP header.  Therefore it would be inconsistent to look up a
new route for host-to-host tunnel mode SAs.

Perhaps we can simply expand the check to include local as well,
i.e.,

	if (local != fl->fl4_src || remote != fl->fl4_dst) {

What do you think?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
