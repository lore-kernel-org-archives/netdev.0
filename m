From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] mlx4_en: fix allocation of CPU affinity reverse-map
Date: Sat, 23 Feb 2013 09:07:40 +0200
Message-ID: <51286ABC.6080802@mellanox.com>
References: <1361596492-10565-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:54178 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754125Ab3BWHHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 02:07:48 -0500
In-Reply-To: <1361596492-10565-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/2013 07:14, Kleber Sacilotto de Souza wrote:
> The mlx4_en driver allocates the number of objects for the CPU affinity
> reverse-map based on the number of rx rings of the device. However,
> mlx4_assign_eq() calls irq_cpu_rmap_add() as many times as IRQ's are
> assigned to EQ's, which can be as large as mlx4_dev->caps.comp_pool. If
> caps.comp_pool is larger than rx_ring_num we will eventually hit the
> BUG_ON() in cpu_rmap_add().
> 
> Fix this problem by allocating space for the maximum number of CPU
> affinity reverse-map objects we might want to add.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 5944dd6..5385474 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1829,7 +1829,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
>  	}
>  
>  #ifdef CONFIG_RFS_ACCEL
> -	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->rx_ring_num);
> +	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->mdev->dev->caps.comp_pool);
>  	if (!priv->dev->rx_cpu_rmap)
>  		goto err;
>  #endif
> 

Acked-by: Amir Vadai <amirv@mellanox.com>
