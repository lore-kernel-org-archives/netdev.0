From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: IPv6 and encapsulation headers
Date: Sat, 10 Jul 2004 19:16:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710091630.GA16312@gondor.apana.org.au>
References: <20040710033209.GA14316@gondor.apana.org.au> <20040710.133641.132032007.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040710.133641.132032007.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 10, 2004 at 01:36:41PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Looks good.

Thanks for reviewing it.

I've got a couple of questions that you might be able to help me with.

It appears that the value of hdr_len in ah6 for transport mode is broken.
It's setting hdr_len to be skb->h.raw - skb->nh.raw.  When AH is being
applied outside an ESP tunnel, skb->h.raw will be pointing somewhere
inside the tunnel.  The end result is that leading bytes of the payload
inside the tunnel gets moved before the AH header.

So should it be changed to ip6_find_1stfragopt() as is the case with
esp6 and ipcomp6?

A second problem is that ip6_find_1stfragopt() seems to be the wrong
thing to do for ah6/esp6/ipcomp6.  RFC 2402/2406/3173 all say that
fragment headers should be placed before the encapsulation header.
So should it be changed accordingly?

Thanks again,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
