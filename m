From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 8 Sep 2004 20:04:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908100422.GB23578@gondor.apana.org.au>
References: <20040908073238.GB18285@svana.org> <E1C4xe9-0005xL-00@gondolin.me.apana.org.au> <20040908083828.GE18285@svana.org> <20040908084630.GA23117@gondor.apana.org.au> <20040908090455.GF18285@svana.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martijn van Oosterhout <kleptog@svana.org>
Content-Disposition: inline
In-Reply-To: <20040908090455.GF18285@svana.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 07:04:55PM +1000, Martijn van Oosterhout wrote:
> 
> So, hypothetically, if I get passed a file descriptor through a UNIX
> domain socket and do a getname on it, there is no way to guarentee that
> it won't go past the buffer I've allocated. Who came up with this lame
> API?

Nope.  The code in net/socket.c ensures that the buffer does not overflow.

> Well, I guess I'll have to agree to that. So, lets say we create two
> new types, one for each version of the union, sockaddr_pppox_pppoe and
> sockaddr_pppox_pppol2tp. Deprecate the current sockaddr_pppox
> altogether (can't get rid of it now). Possibly create a new
> sockaddr_pppox_generic for use in the actual pppox.c file. Sprinkle
> some typecasts around to make the compiler happy and voila!

Please call them sockaddr_pppoe and sockaddr_pppol2tp.

> Then future userspace programs can use the structure appropriate for
> them. Does removing the union change the alignment on any
> architechture? Or will the dummy union have to stay in perpituity?

The union doesn't change the size or alignemnt.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
