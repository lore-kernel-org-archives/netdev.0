From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text ~10k/5%
Date: Thu, 23 Jun 2016 11:09:41 +0300
Message-ID: <CALzJLG-j4Sv+oRZHaWLW6GqBP2P1+nTJJRGhcSdMhedPzGfjZA@mail.gmail.com>
References: <1466619839.13093.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466619839.13093.4.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2016 at 9:23 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
[...]
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -1557,3 +1557,37 @@ static void __exit cleanup(void)
>
>  module_init(init);
>  module_exit(cleanup);
> +
> +void mlx5_core_err(struct mlx5_core_dev *dev, const char *fmt, ...)
> +{
> +       struct va_format vaf;
> +       va_list args;
> +
> +       va_start(args, fmt);
> +
> +       vaf.fmt = fmt;
> +       vaf.va = &args;
> +
> +       dev_err(&dev->pdev->dev, "%s:%pS:(pid %d): %pV",
> +               dev->priv.name, __builtin_return_address(0), current->pid,
> +               &vaf);
> +
> +       va_end(args);
> +}
> +
> +void mlx5_core_warn(struct mlx5_core_dev *dev, const char *fmt, ...)
> +{
> +       struct va_format vaf;
> +       va_list args;
> +
> +       va_start(args, fmt);
> +
> +       vaf.fmt = fmt;
> +       vaf.va = &args;
> +
> +       dev_warn(&dev->pdev->dev, "%s:%pS:(pid %d): %pV",
> +                dev->priv.name, __builtin_return_address(0), current->pid,
> +                &vaf);
> +
> +       va_end(args);
> +}

Hi Joe,

I like to keep the file organized in a bottom-up fashion.  Those
functions need to appear as early as possible in the file, just move
them up to appear after the MACROs defines and static fields
declarations.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
