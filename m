From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG 2.6.12-rc4] IPv6 xfrm tunnel oops with large packets
Date: Sun, 22 May 2005 17:34:35 +1000
Message-ID: <20050522073435.GA15867@gondor.apana.org.au>
References: <1116702611.14509.10.camel@leto.cs.pocnet.net> <20050521194932.GA10959@gondor.apana.org.au> <20050522.051817.122678688.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christophe@saout.de, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	davem@davemloft.net
Return-path: <linux-net-owner@vger.kernel.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050522.051817.122678688.yoshfuji@linux-ipv6.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 22, 2005 at 05:18:17AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> > BTW, icmpv6_send seems to ignore its dev argument altogether.
> > Any reason why we can't just use it instead of skb->dev?
> 
> (After looking into icmpv6_send() usages,)
> I don't know the reason why we needed the last argument "dev".
> It seems that we already had it at the time of 2.2.16.
> Probably, we can remove it.

In a number of places (I've just created another one with my patch :)
we are setting skb->dev specifically for icmpv6_send.  If we make
icmpv6_send use its dev argument instead of skb->dev then we can
avoid those settings.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
