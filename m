From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Tue, 17 Aug 2004 15:59:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817.155942.51047516.yoshfuji@linux-ipv6.org>
References: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@redhat.com
In-Reply-To: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com> (at Tue, 17 Aug 2004 02:43:38 -0400 (EDT)), James Morris <jmorris@redhat.com> says:

It generally seems okay. Just a few things for readability.

> diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/neighbour.c linux-2.6.8.1-mm1.w/net/core/neighbour.c
> --- linux-2.6.8.1-mm1.o/net/core/neighbour.c	2004-06-16 01:18:56.000000000 -0400
> +++ linux-2.6.8.1-mm1.w/net/core/neighbour.c	2004-08-17 02:57:22.888296160 -0400
> @@ -1165,12 +1165,9 @@
>  	if (!tbl->kmem_cachep)
>  		tbl->kmem_cachep = kmem_cache_create(tbl->id,
>  						     tbl->entry_size,
> -						     0, SLAB_HWCACHE_ALIGN,
> +						     0, SLAB_HWCACHE_ALIGN|
> +						     SLAB_PANIC,

I rather prefer
						     tbl->entry_size, 0,
						     SLAB_HWCACHE_ALIGN|SLAB_PANIC,


> diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv6/route.c linux-2.6.8.1-mm1.w/net/ipv6/route.c
> --- linux-2.6.8.1-mm1.o/net/ipv6/route.c	2004-08-14 10:25:45.000000000 -0400
> +++ linux-2.6.8.1-mm1.w/net/ipv6/route.c	2004-08-17 02:44:31.302595016 -0400
> @@ -2026,11 +2026,9 @@
>  
>  	ip6_dst_ops.kmem_cachep = kmem_cache_create("ip6_dst_cache",
>  						     sizeof(struct rt6_info),
> -						     0, SLAB_HWCACHE_ALIGN,
> +						     0, SLAB_HWCACHE_ALIGN|
> +						     SLAB_PANIC,
>  						     NULL, NULL);

ditto.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
