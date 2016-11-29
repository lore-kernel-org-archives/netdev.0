From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] ethernet :mellanox :mlx4: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Tue, 29 Nov 2016 12:28:56 +0300
Message-ID: <09fcb40b-cbca-b119-239d-215fcf8ae580@cogentembedded.com>
References: <20161129065931.GA3245@gnr743-HP-ZBook-15>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sahu.rameshwar73-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129065931.GA3245@gnr743-HP-ZBook-15>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/29/2016 9:59 AM, Souptick Joarder wrote:

> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
> replaced by pci_pool_zalloc().

    One more nit since you're going to send it again...

> Signed-off-by: Souptick joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> v2:
>   - Address comment from sergei
>     Alignment was not proper
>
>  drivers/net/ethernet/mellanox/mlx4/cmd.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index e36bebc..96cdf9a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2679,14 +2679,13 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>  	if (!mailbox)
>  		return ERR_PTR(-ENOMEM);
>
> -	mailbox->buf = pci_pool_alloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
> -				      &mailbox->dma);
> +	mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
> +				       &mailbox->dma);
>  	if (!mailbox->buf) {
>  		kfree(mailbox);
>  		return ERR_PTR(-ENOMEM);
>  	}
>
> -	memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
>

    Remove empty line here -- one is enough.

>  	return mailbox;
>  }

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
