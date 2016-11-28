From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] ethernet :mellanox :mlx5: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Mon, 28 Nov 2016 22:08:32 +0300
Message-ID: <1508ea17-928d-d506-18bd-55373e89a4c6@cogentembedded.com>
References: <20161128133740.GA688@gnr743-HP-ZBook-15>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sahu.rameshwar73-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128133740.GA688@gnr743-HP-ZBook-15>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2016 04:37 PM, Souptick Joarder wrote:

> In alloc_cmd_box(), pci_pool_alloc() followed by memset will be
> replaced by pci_pool_zalloc()
>
> Signed-off-by: Souptick joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> index 1e639f8..d96ebd4 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> @@ -1063,14 +1063,13 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
>  	if (!mailbox)
>  		return ERR_PTR(-ENOMEM);
>
> -	mailbox->buf = pci_pool_alloc(dev->cmd.pool, flags,
> +	mailbox->buf = pci_pool_zalloc(dev->cmd.pool, flags,
>  				      &mailbox->dma);

    Same here, the & needs to start under 'dev' on the broken up line.

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
