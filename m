From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 22:54:08 +1000
Message-ID: <20050524125408.GA27317@gondor.apana.org.au>
References: <E1DaTeW-00085B-00@gondolin.me.apana.org.au> <4292E53D.7030805@miyazawa.org> <20050524.174234.00553944.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050524.174234.00553944.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 05:42:34PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> Probably, it should be better to introduce some upper limit of number of 
> recreation.

Yep, that's why a simple packet blackhole bug became a kernel hang.

In fact, we don't need to retry at all.  If the policy goes dead on us
or if the route becomes invalid after we passed the check in xfrm_lookup,
the packet is dropped anyway.  There is no point in retrying the lookup
here since that only covers the cases where we detect the problem before
the bundle is inserted into the list.

So we should simply return an error instead of retrying.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
