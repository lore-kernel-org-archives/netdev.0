From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Tue, 15 Feb 2005 20:53:46 +1100
Message-ID: <20050215095346.GA21999@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <4211AE5E.2010506@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Mika Penttil? <mika.penttila@kolumbus.fi>
Content-Disposition: inline
In-Reply-To: <4211AE5E.2010506@kolumbus.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 15, 2005 at 10:10:06AM +0200, Mika Penttil? wrote:
> 
> Shouldn't this pinning happen inside the loop for eaxh xdst, to be 
> balanced with  the dst_release(xdst->route) in xfrm_dst_destroy ?
> 
> >+	dst_hold(&rt->u.dst);
> >
> >	for (i = 0; i < nx; i++) {
> >		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
> >+		struct xfrm_dst *xdst;
> >
> >		if (unlikely(dst1 == NULL)) {
> >			err = -ENOBUFS;

There is a dst_release here.

The reference is either released here if the allocation fails, or it
is held by dst1 which is either returned or freed as part of the bundle.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
