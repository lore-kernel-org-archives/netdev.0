From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 8 Sep 2004 18:46:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908084630.GA23117@gondor.apana.org.au>
References: <20040908073238.GB18285@svana.org> <E1C4xe9-0005xL-00@gondolin.me.apana.org.au> <20040908083828.GE18285@svana.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martijn van Oosterhout <kleptog@svana.org>
Content-Disposition: inline
In-Reply-To: <20040908083828.GE18285@svana.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 06:38:28PM +1000, Martijn van Oosterhout wrote:
> 
> But within a single binary, it knows how big the structure was at the
> time it was compiled and has allocated the appropriate space. It also
> was compiled with a particular version of PX_MAX_PROTO so it should
> know if it's an unknown type. Any communication with the kernel
> includes the size so there is no possibility of buffer overruns AFAICS.
> The change is backward compatable in the sense that the sa_protocol
> field determines which union member is appropriate and hence the
> expected size of the structure.

It can break because people often initialise the size of the
address by doing sizeof(struct sockaddr_pppox).  For example,
you'll see exactly this breakage in pppoe_getname in
drivers/net/pppoe.c.

Now granted you can work around this in pppoe.c and repair the
kernel ABI.  But user space has ABIs too.  Think of a library
that exports this stuff to other user space applications.  If
it does sizeof(struct sockaddr_pppox) then you're toast.

IMHO this union was a silly idea to begin with.  Let's not prolong
its life any further.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
