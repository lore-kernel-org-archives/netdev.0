From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] net: pass correct parameter to
 skb_headers_offset_update()
Date: Fri, 7 Jun 2013 15:47:22 +0900
Message-ID: <20130607064722.GF14972@verge.net.au>
References: <fdf66733b5575423669ab215dbb7aea13fd82aeb.1370525076.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55628 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab3FGGrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 02:47:25 -0400
Content-Disposition: inline
In-Reply-To: <fdf66733b5575423669ab215dbb7aea13fd82aeb.1370525076.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 06, 2013 at 09:27:21PM +0800, Weiping Pan wrote:
> Since commit 1a37e412a022(net: Use 16bits for *_headers fields of struct
> skbuff), skb->*_header are relative to skb->head,
> so copy_skb_header() should not call skb_headers_offset_update() now,
> and we should pass correct parameter to skb_headers_offset_update() in
> pskb_expand_head() and skb_copy_expand().
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  net/core/skbuff.c |   15 ++-------------
>  1 files changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 73f57a0..30a1b56 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -905,18 +905,8 @@ static void skb_headers_offset_update(struct sk_buff *skb, int off)
>  
>  static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  {
> -#ifndef NET_SKBUFF_DATA_USES_OFFSET
> -	/*
> -	 *	Shift between the two data areas in bytes
> -	 */
> -	unsigned long offset = new->data - old->data;
> -#endif
> -
>  	__copy_skb_header(new, old);
>  
> -#ifndef NET_SKBUFF_DATA_USES_OFFSET
> -	skb_headers_offset_update(new, offset);
> -#endif
>  	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
>  	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
>  	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
> @@ -1108,7 +1098,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  	skb->end      = skb->head + size;
>  #endif
>  	skb->tail	      += off;
> -	skb_headers_offset_update(skb, off);
> +	skb_headers_offset_update(skb, nhead);
>  	/* Only adjust this if it actually is csum_start rather than csum */
>  	if (skb->ip_summed == CHECKSUM_PARTIAL)
>  		skb->csum_start += nhead;
> @@ -1203,9 +1193,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
>  	off                  = newheadroom - oldheadroom;
>  	if (n->ip_summed == CHECKSUM_PARTIAL)
>  		n->csum_start += off;
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +
>  	skb_headers_offset_update(n, off);
> -#endif
>  
>  	return n;
>  }
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
