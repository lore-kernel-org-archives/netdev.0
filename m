From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] small skbuff.[ch] tweaks
Date: Tue, 2 Sep 2003 10:58:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902105833.04778449.ak@suse.de>
References: <20030902081625.GA52298@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030902081625.GA52298@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2003 01:16:25 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> --- linux-2.6.0-test4-VIRGIN/net/core/skbuff.c	2003-08-22 13:47:28.000000000 -0700
> +++ linux-2.6.0-test4mnb1/net/core/skbuff.c	2003-09-01 14:00:37.000000000 -0700
> @@ -129,14 +129,17 @@
>  	/* Get the HEAD */
>  	skb = kmem_cache_alloc(skbuff_head_cache,
>  			       gfp_mask & ~__GFP_DMA);
> -	if (!skb)
> +	if (unlikely(!skb))
>  		goto out;
>  
>  	/* Get the DATA. Size must match skb_add_mtu(). */
>  	size = SKB_DATA_ALIGN(size);
>  	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
> -	if (!data)
> -		goto nodata;
> +	if (unlikely(!data)) {

Both unlikely(!ptr) and likely(ptr) are not needed because gcc assumes this
by default

-Andi
