From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/4] net/mlx4_core: Fix QUERY FUNC CAP flags
Date: Thu, 7 Jul 2016 22:26:08 +0300
Message-ID: <CAJ3xEMhgDG4iWL+ZD07R-ynCXqfY0RARuP5oCFsjXLS1H3uA5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34122 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcGGT0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 15:26:09 -0400
Received: by mail-oi0-f66.google.com with SMTP id s17so3982443oih.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 12:26:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 3:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Moshe Shemesh <moshe@mellanox.com>
>
> Separate QUERY_FUNC_CAP flags0 from QUERY_FUNC_CAP flags.
> Remove QUERY_FUNC_CAP port_flags field which was not in use.

The patch title says "Fix ..." but the change log doesn't say if this
is fixing real bug, or cleaning up dead code, nor you point to the
commit you are fixing, please add that, I guess it is something we do
wrong w.r.t the PHV bit but I am not clear what.


> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
> index f4497cf..355f05e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/fw.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
> @@ -612,8 +612,7 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
>                 MLX4_GET(func_cap->phys_port_id, outbox,
>                          QUERY_FUNC_CAP_PHYS_PORT_ID);
>
> -       MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS0_OFFSET);
> -       func_cap->flags |= (field & QUERY_FUNC_CAP_PHV_BIT);
> +       MLX4_GET(func_cap->flags0, outbox, QUERY_FUNC_CAP_FLAGS0_OFFSET);
>
>         /* All other resources are allocated by the master, but we still report
>          * 'num' and 'reserved' capabilities as follows:
> @@ -2874,7 +2873,7 @@ int get_phv_bit(struct mlx4_dev *dev, u8 port, int *phv)
>         memset(&func_cap, 0, sizeof(func_cap));
>         err = mlx4_QUERY_FUNC_CAP(dev, port, &func_cap);
>         if (!err)
> -               *phv = func_cap.flags & QUERY_FUNC_CAP_PHV_BIT;
> +               *phv = func_cap.flags0 & QUERY_FUNC_CAP_PHV_BIT;
>         return err;
>  }
>  EXPORT_SYMBOL(get_phv_bit);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
> index cdbd76f..f11614f 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/fw.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
> @@ -152,7 +152,7 @@ struct mlx4_func_cap {
>         u32     qp1_proxy_qpn;
>         u32     reserved_lkey;
>         u8      physical_port;
> -       u8      port_flags;
> +       u8      flags0;
>         u8      flags1;
>         u64     phys_port_id;
>         u32     extra_flags;
