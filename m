From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH v2 13/17] net: mlx4 calls skb_set_rxhash
Date: Sun, 01 Dec 2013 14:26:31 +0200
Message-ID: <529B2AF7.90309@gmail.com>
References: <alpine.DEB.2.02.1311260928050.21143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>
To: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:42109 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab3LAM0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 07:26:37 -0500
Received: by mail-bk0-f51.google.com with SMTP id 6so4891978bkj.38
        for <netdev@vger.kernel.org>; Sun, 01 Dec 2013 04:26:36 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311260928050.21143@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/11/2013 19:31, Tom Herbert wrote:
> Drivers should call skb_set_rxhash to set the rxhash and its type
> in an skbuff.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 07a1d0f..3e48c44 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -747,7 +747,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  					}
>  
>  					if (dev->features & NETIF_F_RXHASH)
> -						gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
> +						skb_set_rxhash(gro_skb, be32_to_cpu(cqe->immed_rss_invalid), RXHASH_TYPE_L3);
>  
>  					skb_record_rx_queue(gro_skb, cq->ring);
>  
> @@ -789,7 +789,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  		skb_record_rx_queue(skb, cq->ring);
>  
>  		if (dev->features & NETIF_F_RXHASH)
> -			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
> +			skb_set_rxhash(skb, be32_to_cpu(cqe->immed_rss_invalid), RXHASH_TYPE_L3);
>  
>  		if ((be32_to_cpu(cqe->vlan_my_qpn) &
>  		    MLX4_CQE_VLAN_PRESENT_MASK) &&
> 

I need to do some work in this area of code, but anyway it is not in the
scope of this patchset.

Acked-By: Amir Vadai <amirv@mellanox.com>
