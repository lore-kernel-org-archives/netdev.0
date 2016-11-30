From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v3] ethernet :mellanox :mlx4: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Wed, 30 Nov 2016 10:44:20 +0200
Message-ID: <1aa0ef57-02ac-3e2f-9f23-0e16a9d1597b@gmail.com>
References: <20161129194611.GA4088@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        sahu.rameshwar73@gmail.com
To: Souptick Joarder <jrdr.linux@gmail.com>,
        sergei.shtylyov@cogentembedded.com, yishaih@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:35900 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbcK3IoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 03:44:24 -0500
In-Reply-To: <20161129194611.GA4088@jordon-HP-15-Notebook-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Souptic,

Thanks for your patch.

On 29/11/2016 9:46 PM, Souptick Joarder wrote:
> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
> replaced by pci_pool_zalloc()
>
> Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>
> ---
> v3:
>    - Fixed alignment issues
As mentioned already, you mean 'Remove empty line'.
>
> v2:
>    - Address comment from sergei
>      Alignment was not proper
>
>   drivers/net/ethernet/mellanox/mlx4/cmd.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index e36bebc..a49072b4 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2679,15 +2679,13 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>   	if (!mailbox)
>   		return ERR_PTR(-ENOMEM);
>
> -	mailbox->buf = pci_pool_alloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
> -				      &mailbox->dma);
> +	mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
> +				       &mailbox->dma);
>   	if (!mailbox->buf) {
>   		kfree(mailbox);
>   		return ERR_PTR(-ENOMEM);
>   	}
>
> -	memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
> -
>   	return mailbox;
>   }
>   EXPORT_SYMBOL_GPL(mlx4_alloc_cmd_mailbox);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Thanks,
Tariq
