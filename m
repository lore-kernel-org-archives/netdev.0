From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 21:29:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C26pV-0000fW-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.61.0408311145580.12063@filer.marasystems.com>
Cc: laforge@netfilter.org, davem@davemloft.net, netdev@oss.sgi.com,
        rusty@rustcorp.com.au, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hno@marasystems.com (Henrik Nordstrom)
In-Reply-To: <Pine.LNX.4.61.0408311145580.12063@filer.marasystems.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Henrik Nordstrom <hno@marasystems.com> wrote:
> 
> Should only happen if the routing is screwed up, in principle..

If only that were the case :)
 
> I think it would for most make more sense that the source IP assignment is 
> based on routing using the original source address as key.

Doesn't work because we're trying to get the correct source address from
the routing lookup.

> What I don't get is why MASQUERADE needs to do a route lookup at all. 
> Isn't the traffic already routed at this point, and shouldn't it simply 
> use the source IP of the current selected route or the interface primary 
> IP of no source IP set in the route?

The problem is that we don't record the preferred source in struct rtable.
It is available in the original FIB rule.  So by adding a new field in
struct rtable we should be able to avoid this lookup.

>> That is the presumption I am about to challenge.  Is the 'original'
>> interface really the one we want in this case?
> 
> If there is policy routing saying that packets with a given source 
> should go out another interface my opinion is that they should.

Absolutely.

> I have been using SNAT in quite many complex routing setups and so far has 
> not run into any situation where routing gets wrong in an unmanageable and 
> unintuitive manner due to SNAT. MASQUERADE should not be more complex.

Well I took that advice and ended up with tons of broken systems because
SNAT is totally broken when your IP address is dynamic.  MASQUERADE
flushes the conntrack rules automatically.  SNAT does not.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
