From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/8] net/mlx4_en: Add __GFP_COLD gfp flags in
 alloc_pages
Date: Thu, 30 Oct 2014 10:15:33 -0700
Message-ID: <1414689333.9028.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	 <1414685216-28907-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:55283 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758594AbaJ3RQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 13:16:07 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so5903464pab.13
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 10:16:07 -0700 (PDT)
In-Reply-To: <1414685216-28907-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 18:06 +0200, Or Gerlitz wrote:
> From: Ido Shamay <idos@mellanox.com>
> 
> Needed in order to get cache cold pages (L3 flushed) for HW scatter.
> 
> Otherwise memory may flush those entries when the packet comes from
> PCI, causing back pressure resulting in BW decrease.
> 
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 4cb716f..9d616a8 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -54,7 +54,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
>  	dma_addr_t dma;
>  
>  	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
> -		gfp_t gfp = _gfp;
> +		gfp_t gfp = _gfp | __GFP_COLD;

This should be set by callers, to avoid extra code

GFP_ATOMIC | __GFP_COLD

or

GFP_KERNEL | __GFP_COLD

>  
>  		if (order)
>  			gfp |= __GFP_COMP | __GFP_NOWARN;
