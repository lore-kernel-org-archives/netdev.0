From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 21:15:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831111508.GA2327@gondor.apana.org.au>
References: <20040831101203.GA1951@gondor.apana.org.au> <Pine.LNX.4.44.0408311326540.4022-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, laforge@netfilter.org,
        netfilter-devel@lists.netfilter.org, rusty@rustcorp.com.au,
        netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408311326540.4022-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 01:54:21PM +0300, Julian Anastasov wrote:
> 
> 	Yes, 2.2 worked somehow, until some users wanted more
> control from the routing. Now ip_fw_compat_masq.c has such call,
> it can be fast in some setups with small number of IPs but may
> be now there some setups using nfmark for selecting maddr from
> ISP-specific routing tables. I'm not sure we can avoid the routing
> and the cache pollution, we have to live with the old behavoir, not
> the current one.

You're right.  However, we can still do this without performing
another routing lookup.  The information is already there in the
fib rule.  We just didn't bother writing it down in the route for
forwarded packets.

So if we add a new field for the preferred source address to
struct rtable then we can avoid the lookup.

BTW, I'd still like to know the problem with the original oif key.
It's basically saying that if you can find the correct route using
the other keys (daddr/tos/mark) then all is well, if you can't
(dev != out) then we'll use the best address on the outgoing
interface.

> 	I have some related work, you can check it for more ideas:
> 
> http://www.ssi.bg/~ja/#routes
> see dgd-usage.txt
> 
> 	In short, I use the mpath route as a nexthop selector (on
> first packet), the next packets do not hit the mpath route, they feed the 
> routing with the maddr already bound to the NAT connection. This survives
> cache expiration. May be using connmark is a better idea:
> assign nfmark to connection and route it always via same GW. But
> may be the oif key remains, I'm not sure.

Fortunately I'm one of those with lots of interfaces but only one
IP on each.  I can sympathise with your situation of many IPs but
only one interface :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
