From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [RFC 05/19] mlx4: Replace PCI pool old API
Date: Wed, 8 Feb 2017 19:24:51 +0100
Message-ID: <20170208182451.GE16878@collabora.com>
References: <20170208163457.28853-1-romain.perier@collabora.com>
 <20170208163457.28853-6-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170208163457.28853-6-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 05:34:43PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.

Tested by compilation only.

Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c  | 10 +++++-----
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index a49072b4..d400cde 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2515,8 +2515,8 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
>  	}
>  
>  	if (!priv->cmd.pool) {
> -		priv->cmd.pool = pci_pool_create("mlx4_cmd",
> -						 dev->persist->pdev,
> +		priv->cmd.pool = dma_pool_create("mlx4_cmd",
> +						 &dev->persist->pdev->dev,
>  						 MLX4_MAILBOX_SIZE,
>  						 MLX4_MAILBOX_SIZE, 0);
>  		if (!priv->cmd.pool)
> @@ -2587,7 +2587,7 @@ void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask)
>  	struct mlx4_priv *priv = mlx4_priv(dev);
>  
>  	if (priv->cmd.pool && (cleanup_mask & MLX4_CMD_CLEANUP_POOL)) {
> -		pci_pool_destroy(priv->cmd.pool);
> +		dma_pool_destroy(priv->cmd.pool);
>  		priv->cmd.pool = NULL;
>  	}
>  
> @@ -2679,7 +2679,7 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>  	if (!mailbox)
>  		return ERR_PTR(-ENOMEM);
>  
> -	mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
> +	mailbox->buf = dma_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
>  				       &mailbox->dma);
>  	if (!mailbox->buf) {
>  		kfree(mailbox);
> @@ -2696,7 +2696,7 @@ void mlx4_free_cmd_mailbox(struct mlx4_dev *dev,
>  	if (!mailbox)
>  		return;
>  
> -	pci_pool_free(mlx4_priv(dev)->cmd.pool, mailbox->buf, mailbox->dma);
> +	dma_pool_free(mlx4_priv(dev)->cmd.pool, mailbox->buf, mailbox->dma);
>  	kfree(mailbox);
>  }
>  EXPORT_SYMBOL_GPL(mlx4_free_cmd_mailbox);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> index b4f1bc5..69c8764 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> @@ -628,7 +628,7 @@ struct mlx4_mgm {
>  };
>  
>  struct mlx4_cmd {
> -	struct pci_pool	       *pool;
> +	struct dma_pool	       *pool;
>  	void __iomem	       *hcr;
>  	struct mutex		slave_cmd_mutex;
>  	struct semaphore	poll_sem;
> -- 
> 2.9.3
> 
