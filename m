From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Tue, 3 Aug 2004 20:55:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803105520.GA29077@gondor.apana.org.au>
References: <20040730171205.114f22ba.kazunori@miyazawa.org> <20040802074147.GA16381@gondor.apana.org.au> <20040802190914.303ccfbe.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040802190914.303ccfbe.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 02, 2004 at 07:09:14PM -0700, David S. Miller wrote:
> 
> An intesting solution would be to use stacked destinations, which
> do no actual encapsulation (or perhaps do the routing header work)
> and merely represent the hop-by-hop path.  Then the PMTU propagation
> machinery can be used, and route lookups will go through a slower path
> to find these special stacked hop-by-hop routes.

Yes that's brilliant.

We can replace the current rt dst with an rthdr dst + an rt dst.
The rt dst will be the same one pointing to the first hop.  The
rthdr will contain MTU information for that exact path.

This will work since any ICMP messages we receive due to MTU
issues must carry the entire IP header including the rthdr
(or in the case of IPv4 the ?SR option).  We can then attribute
that MTU to the rthdr dst.

The rthdr can even add the option/extension header as a transform.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
