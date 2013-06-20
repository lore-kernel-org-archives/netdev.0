From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/11] net/mlx4_en: Suppress page allocation
 failure warnings
Date: Thu, 20 Jun 2013 14:28:09 -0700
Message-ID: <1371763689.3252.419.camel@edumazet-glaptop>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	 <1371757222-21412-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:55138 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965555Ab3FTV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 17:28:16 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so4167439eae.38
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 14:28:15 -0700 (PDT)
In-Reply-To: <1371757222-21412-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 22:40 +0300, Amir Vadai wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.com>
> 
> When system is low on resources, those warnings hang the host.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 9c57581..2b564ac 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -57,8 +57,8 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
>  	for (i = 0; i < priv->num_frags; i++) {
>  		frag_info = &priv->frag_info[i];
>  		if (ring_alloc[i].offset == frag_info->last_offset) {
> -			page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
> -					MLX4_EN_ALLOC_ORDER);
> +			page = alloc_pages(GFP_ATOMIC | __GFP_COMP |
> +					   __GFP_NOWARN, MLX4_EN_ALLOC_ORDER);
>  			if (!page)
>  				goto out;
>  			dma = dma_map_page(priv->ddev, page, 0,


Thats IMHO a lazy patch...

What about mlx4_en_init_allocator() ?

I think I did a patch doing fallback to order-1 and order-0 allocations
