From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Sun, 06 Mar 2005 21:29:34 +1100
Message-ID: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
References: <4229BB3E.8020203@trash.net>
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <4229BB3E.8020203@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
>
> @@ -97,6 +104,7 @@
>  		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
>  		if (err)
>  			goto error;
> +		rt->u.dst.flags |= DST_XFRM_TUNNEL;

This line doesn't look right.  rt is an entry in the IPv4 routing
cache, right? If so why should its flags change when some bundle is
created?

After all, it could also be used at the bottom of a transport mode bundle.

Besides, I think IPv4 routing cache entry will never show up at the top of
a bundle anyway which means that this flags value will never be read in
the find_bundle function.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
