From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: Re: [PATCH v3 06/20] mlx5: Replace PCI pool old API
Date: Mon, 27 Feb 2017 12:08:36 +0100
Message-ID: <20170227110836.GA26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-7-romain.perier@collabora.com>
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
In-Reply-To: <20170226192425.13098-7-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:11PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
>  include/linux/mlx5/driver.h                   |  2 +-
>  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> index caa837e..6eef344 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> @@ -1061,7 +1061,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
>  	if (!mailbox)
>  		return ERR_PTR(-ENOMEM);
>  
> -	mailbox->buf = pci_pool_zalloc(dev->cmd.pool, flags,
> +	mailbox->buf = dma_pool_zalloc(dev->cmd.pool, flags,
>  				       &mailbox->dma);
>  	if (!mailbox->buf) {
>  		mlx5_core_dbg(dev, "failed allocation\n");
> @@ -1076,7 +1076,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
>  static void free_cmd_box(struct mlx5_core_dev *dev,
>  			 struct mlx5_cmd_mailbox *mailbox)
>  {
> -	pci_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
> +	dma_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
>  	kfree(mailbox);
>  }
>  
> @@ -1696,7 +1696,8 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
>  		return -EINVAL;
>  	}
>  
> -	cmd->pool = pci_pool_create("mlx5_cmd", dev->pdev, size, align, 0);
> +	cmd->pool = dma_pool_create("mlx5_cmd", &dev->pdev->dev, size, align,
> +				    0);
>  	if (!cmd->pool)
>  		return -ENOMEM;
>  
> @@ -1786,7 +1787,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
>  	free_cmd_page(dev, cmd);
>  
>  err_free_pool:
> -	pci_pool_destroy(cmd->pool);
> +	dma_pool_destroy(cmd->pool);
>  
>  	return err;
>  }
> @@ -1800,6 +1801,6 @@ void mlx5_cmd_cleanup(struct mlx5_core_dev *dev)
>  	destroy_workqueue(cmd->wq);
>  	destroy_msg_cache(dev);
>  	free_cmd_page(dev, cmd);
> -	pci_pool_destroy(cmd->pool);
> +	dma_pool_destroy(cmd->pool);
>  }
>  EXPORT_SYMBOL(mlx5_cmd_cleanup);
> diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
> index 2fcff6b..13a267c 100644
> --- a/include/linux/mlx5/driver.h
> +++ b/include/linux/mlx5/driver.h
> @@ -284,7 +284,7 @@ struct mlx5_cmd {
>  	struct semaphore pages_sem;
>  	int	mode;
>  	struct mlx5_cmd_work_ent *ent_arr[MLX5_MAX_COMMANDS];
> -	struct pci_pool *pool;
> +	struct dma_pool *pool;
>  	struct mlx5_cmd_debug dbg;
>  	struct cmd_msg_cache cache[MLX5_NUM_COMMAND_CACHES];
>  	int checksum_disabled;
> -- 
> 2.9.3
> 
