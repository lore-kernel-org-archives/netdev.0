From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Mon, 2 Aug 2004 17:41:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802074147.GA16381@gondor.apana.org.au>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20040730171205.114f22ba.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2004 at 05:12:05PM +0900, Kazunori Miyazawa wrote:
> 
> This patch separates xfrm_lookup from ip6_dst_lookup
> to support srcrt correctly. ip6_dst_lookup should be
> called with next hop. however xfrm_lookup should be
> called with final destination. It fixes them.

Thanks for the patch.

This raises an interesting question.  Is it really correct to look at
the first hop address when doing the route lookup?

The problem is that if we use the first-hop address as the dst when
doing the route lookup then we may end up with incorrect MTU information.
This is because the MTU to the final destination may well be smaller than
the MTU to the first hop.

It seems that Alexey thought about this six years ago according to
the rthdr comment in icmpv6_rcv().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
