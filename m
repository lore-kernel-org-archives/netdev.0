From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Tue, 15 Mar 2005 07:32:08 +1100
Message-ID: <20050314203208.GA15146@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <42357AF0.4080205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42357AF0.4080205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2005 at 12:52:16PM +0100, Patrick McHardy wrote:
> 
> >+		if (remote != fl_tunnel.fl4_dst) {
> >+			fl_tunnel.fl4_src = local;
> >+			fl_tunnel.fl4_dst = remote;
> >+			err = xfrm_dst_lookup((struct xfrm_dst **)&rt,
> >+					      &fl_tunnel, AF_INET);
> >+			if (err)
> >+				goto error;
> >+		} else
> >+			dst_hold(&rt->u.dst);
> > 	}
> >+
> > 	dst_prev->child = &rt->u.dst;
> >+	dst->path = &rt->u.dst;
> >+
> >+	*dst_p = dst;
> >+	dst = dst_prev;
> >+
> >+	dst_prev = *dst_p;
> > 	i = 0;
> >-	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = 
> >dst_prev->child) {
> >+	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
> 
> Since the tunnel dst is not necessarily the last in the bundle anymore,
> we might miss to initialize some dsts, for example with ipcomp/tunnel +
> esp/transport. If we have nested tunnels we'll fiddle with entries in
> the routing cache.

Sorry, but I don't get it :) First of all what do you mean by the
tunnel dst?

If you mean &rt->u.dst then as far as I can see it's still the last
child in the bundle.  It may also appear in ->route elements earlier
on but that does not come into play in this loop.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
