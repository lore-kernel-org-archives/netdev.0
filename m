From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 08 Sep 2004 18:17:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C4xe9-0005xL-00@gondolin.me.apana.org.au>
References: <20040908073238.GB18285@svana.org>
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martijn van Oosterhout <kleptog@svana.org>
In-Reply-To: <20040908073238.GB18285@svana.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martijn van Oosterhout <kleptog@svana.org> wrote:
> 
> By my calculations, 
> 
> sizeof(struct pppoe_addr) = 2 + ETH_ALEN + IFNAMSIZ = 2 + 6 + 16 = 24 bytes
> sizeof(struct pppol2tp_addr) = sizeof(int) + sizeof(sockaddr_in) + 4 * 2
>                             = 4 + 16 + 8 = 28 + possibly padding
> 
> So the answer is: I think so. However, I'm not sure why this is an
> issue. struct sockaddr is passed back and forth between userspace and
> kernelspace has many varying sizes (sockaddr_un is quite large). What
> could be affected? getsockname, connect and bind all take a length
> argument. Or are you referring to the possibility of it affecting other
> structures it's embedded in?

Any existing user-space binary that has struct sockaddr_pppox in it will
be broken by your change.

Perhaps you can create a new sockaddr type?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
