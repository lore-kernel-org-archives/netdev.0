From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 18:27:49 -0200
Message-ID: <4197BFC5.5080800@conectiva.com.br>
References: <20041114121837.X2357@build.pdx.osdl.net> <20041114122400.D2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041114122400.D2357@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris,

	I think somebody proposed this in the past and it was refused
because we better get rid of the panics and return an error, propagate
it and refuse to load the module, better have the machine still alive
but without networking than panic it.

- Arnaldo

Chris Wright wrote:
> Use SLAB_PANIC when creating a critical slab cache.
> 
> Signed-off-by: Chris Wright <chrisw@osdl.org>
> 
> ===== net/ipv6/ip6_fib.c 1.33 vs edited =====
> --- 1.33/net/ipv6/ip6_fib.c	2004-11-09 22:57:03 -08:00
> +++ edited/net/ipv6/ip6_fib.c	2004-11-14 11:56:01 -08:00
> @@ -1242,10 +1242,8 @@ void __init fib6_init(void)
>  {
>  	fib6_node_kmem = kmem_cache_create("fib6_nodes",
>  					   sizeof(struct fib6_node),
> -					   0, SLAB_HWCACHE_ALIGN,
> +					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>  					   NULL, NULL);
> -	if (!fib6_node_kmem)
> -		panic("cannot create fib6_nodes cache");
>  }
>  
>  void __exit fib6_gc_cleanup(void)
> 
> 
