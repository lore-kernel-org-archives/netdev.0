From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 21:40:30 +1000
Message-ID: <20050518114030.GA16993@gondor.apana.org.au>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch> <20050518011632.GA27813@gondor.apana.org.au> <20050518013712.GH13748@postel.suug.ch> <20050518015213.GB28070@gondor.apana.org.au> <20050518113030.GA15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050518113030.GA15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2005 at 01:30:30PM +0200, Thomas Graf wrote:
>
> > I think it's big enough.  If it isn't it means that somebody
> > has reordered the packets by 30000 which I find hard to
> > believe :)
> 
> I was thinking about some kind of nfs server with huge recv
> buffers and increased limits receiving at 50kpps experiencing
> a delayed fragment once in a while. Definitely a rare case
> but not impossible ;->

The worst that can happen if 30000 is too low is that we drop
a packet when we shouldn't.  IMHO if a single host sends us an
incomplete packet, followed by 30000 unrelated fragments, and
finally a fragment of the original packet, then it is only
fair for us to drop that packet.

OTOH if you're arguing that 30000 is too high then you might have
a point.  However, in that respect it cannot be any worse than
what we have now which is essentially unlimited.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
