From: maximilian attems <max@stro.at>
Subject: Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()
Date: Mon, 21 Jun 2004 22:04:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621200420.GI1545@sputnik.stro.at>
References: <20040621171832.GE1545@sputnik.stro.at> <20040622.032138.58652005.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, janitor@sternwelten.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040622.032138.58652005.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:

> In article <20040621171832.GE1545@sputnik.stro.at> (at Mon, 21 Jun 2004 19:18:32 +0200), maximilian attems <janitor@sternwelten.at> says:
> 
> > From: Francois Romieu <romieu@fr.zoreil.com>
> > 
> > kmem_cache_create leak.
> > 
> > Note: fib_hash_init() can be called many times.
> > 
> > Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> 
> Please tell us what kind of leakage do you see?
> Is it just enough to return NULL if kmem_cache_create() fails
> like this?
> 
> --- a/net/ipv4/fib_hash.c	10 Nov 2003 23:40:57 -0000	1.1.1.13
> +++ b/net/ipv4/fib_hash.c	21 Jun 2004 18:19:16 -0000
> @@ -871,12 +871,14 @@
>  {
>  	struct fib_table *tb;
>  
> -	if (fn_hash_kmem == NULL)
> +	if (fn_hash_kmem == NULL) {
>  		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
>  						 sizeof(struct fib_node),
>  						 0, SLAB_HWCACHE_ALIGN,
>  						 NULL, NULL);
> -
> +		if (fn_hash_kmem == NULL)
> +			return NULL;
> +	}
>  	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
>  	if (tb == NULL)
>  		return NULL;

doesn't seem to be enough,
because if (tb == NULL) fn_hash_kmem won't be freed, 
or am i overseeing something?

a++ maks
