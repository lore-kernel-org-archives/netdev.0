From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 18:20:21 +1000
Message-ID: <20050524082021.GA31446@gondor.apana.org.au>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 03:49:19AM +0000, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> diff -ruN linux-2.6.12-rc4-git7/net/ipv4/xfrm4_policy.c linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv4/xfrm4_policy.c
> --- linux-2.6.12-rc4-git7/net/ipv4/xfrm4_policy.c	2005-05-24 00:15:27.000000000 +0900
> +++ linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv4/xfrm4_policy.c	2005-05-24 00:20:29.000000000 +0900
> @@ -95,6 +95,7 @@
> 
>  		xdst = (struct xfrm_dst *)dst1;
>  		xdst->route = &rt->u.dst;
> +		xdst->route_cookie = 0;
> 
>  		dst1->next = dst_prev;
>  		dst_prev = dst1;
> @@ -119,6 +120,7 @@
> 
>  	dst_prev->child = &rt->u.dst;
>  	dst->path = &rt->u.dst;
> +	((struct xfrm_dst*)dst)->path_cookie = 0;

This isn't necessary since dst_alloc zeros the entire xfrm_dst entry.

>  	dst_prev->child = &rt->u.dst;
>  	dst->path = &rt->u.dst;
> +	((struct xfrm_dst*)dst)->path_cookie = rt->rt6i_node->fn_sernum;

Please add a space between xfrm_dst and the asterisk, i.e.

(struct xfrm_dst *)dst

Also, can rt6i_node be NULL?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
