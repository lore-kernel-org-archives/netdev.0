From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] fix build problem with IPV6
Date: Fri, 15 Aug 2003 18:19:38 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815211938.GM1564@conectiva.com.br>
References: <20030815140740.388a79c4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030815140740.388a79c4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Aug 15, 2003 at 02:07:40PM -0700, Stephen Hemminger escreveu:
> IPV6 won't build in current 2.6.0-test3 tree unless CONFIG_XFRM is defined
> because of reference to xfrm6_fini.
> 
> The linux way to fix this would be to make the functions
> stub's in the include file, but that isn't how IPV6 does it now
> for other xfrm functions.
> 
> diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
> --- a/net/ipv6/route.c	Fri Aug 15 14:04:05 2003
> +++ b/net/ipv6/route.c	Fri Aug 15 14:04:05 2003
> @@ -2000,7 +2000,9 @@
>  	proc_net_remove("ipv6_route");
>  	proc_net_remove("rt6_stats");
>  #endif
> +#ifdef CONFIG_XFRM
>  	xfrm6_fini();
> +#endif
>  	rt6_ifdown(NULL);
>  	fib6_gc_cleanup();
>  	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);

Stephen,

	Couldn't this be ifdefed at the header that has the xfrm6_fini
prototype?

#ifndef CONFIG_XFRM
void xfrm6_fini(void) {}
#endif

	Or something like that.

- Arnaldo
