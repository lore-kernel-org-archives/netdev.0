From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Fri, 18 Feb 2005 07:38:05 +1100
Message-ID: <20050217203805.GA4047@gondor.apana.org.au>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4214DF5B.3010608@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 17, 2005 at 07:15:55PM +0100, Patrick McHardy wrote:
>
> >Perhaps we can simply expand the check to include local as well,
> >i.e.,
> >
> >	if (local != fl->fl4_src || remote != fl->fl4_dst) {
> >
> >What do you think?
> 
> I don't think this solves the inconsistency. By reuseing routes in tunnel
> mode we allow routing by different criteria when the inner packet is headed
> for the remote gateway. Your suggestion limits this a bit further, but we
> can still have a situation where all packets going through a tunnel take
> one path, except when the inner packet is heading for the remote gateway
> itself.

That's right.  However, you should also look at it this way.  We start
with a policy with a transport mode SA.  In order to protect the IP
header we change it to use a tunnel mode SA with a host-to-host selector.
With your patch this will change the route that the packet uses.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
