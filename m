From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH V2 1/9] net/mlx5: Mellanox Connect-IB, core driver part
 1/3
Date: Wed, 03 Jul 2013 13:29:57 -0700
Message-ID: <1372883397.1886.9.camel@joe-AO722>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
	 <1372871592-32033-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372871592-32033-2-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

trivial comments:

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
[]
> +static const char *deliv_status_to_str(u8 status)
> +{
> +	switch (status) {
> +	case MLX5_CMD_DELIVERY_STAT_OK:
> +		return "no errors";
[]
> +	default:
> +		return "unknown status code\n";
> +	}
> +}

Likely unnecessary newline for default case

> +static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
> +					      gfp_t flags)
> +{
> +	struct mlx5_cmd_mailbox *mailbox;
> +
> +	mailbox = kmalloc(sizeof(*mailbox), flags);
> +	if (!mailbox) {
> +		mlx5_core_dbg(dev, "failed allocation\n");
> +		return ERR_PTR(-ENOMEM);
> +	}

unnecessary OOM message.

> +static void set_wqname(struct mlx5_core_dev *dev)
> +{
> +	struct mlx5_cmd *cmd = &dev->cmd;
> +
> +	strcpy(cmd->wq_name, "mlx5_cmd_");
> +	strcat(cmd->wq_name, dev_name(&dev->pdev->dev));

More likely snprintf might be better.

	snprintf(cmd->wq_name, sizeof(cmd->wq_name), "mlx5_cmd_%s",
		 dev_name(&dev->pdev->dev));

How big is wq_name?  Will a maximum length dev_name always fit?


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
