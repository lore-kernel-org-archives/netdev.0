From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use non-compound pages in frag allocator
Date: Thu, 04 Aug 2016 15:24:49 +0200
Message-ID: <1470317089.13693.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1470314858-32105-1-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32876 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757561AbcHDN0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 09:26:25 -0400
Received: by mail-io0-f193.google.com with SMTP id y195so21770231iod.0
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 06:24:53 -0700 (PDT)
In-Reply-To: <1470314858-32105-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-04 at 15:47 +0300, Ilya Lesokhin wrote:
> The code currently always references the first page in the
> frag therefore there is no need to pay the extra overhead
> of making the frag page compound
> 
> Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
> ---
>  net/core/sock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08bf97e..77432ba 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1993,7 +1993,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
>  	if (SKB_FRAG_PAGE_ORDER) {
>  		/* Avoid direct reclaim but allow kswapd to wake */
>  		pfrag->page = alloc_pages((gfp & ~__GFP_DIRECT_RECLAIM) |
> -					  __GFP_COMP | __GFP_NOWARN |
> +					  __GFP_NOWARN |
>  					  __GFP_NORETRY,
>  					  SKB_FRAG_PAGE_ORDER);
>  		if (likely(pfrag->page)) {


Looks very risky to me.

What numbers can you show us exactly ?

splice() is known to play games on pages, make sure it still works ?
