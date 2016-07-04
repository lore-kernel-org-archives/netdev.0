From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 4 Jul 2016 14:33:49 +0300
Message-ID: <CALzJLG-BeQgXsxEWeAvROQGtsr2J2DnPFzUjLB66vL35u_VEcw@mail.gmail.com>
References: <20160704130217.79de2ba1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Daniel Jurgens <danielj@mellanox.com>,
	Gil Rockah <gilr@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:35304 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbcGDLee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 07:34:34 -0400
Received: by mail-yw0-f195.google.com with SMTP id v77so4919689ywg.2
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 04:34:08 -0700 (PDT)
In-Reply-To: <20160704130217.79de2ba1@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2016 at 6:02 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/ethernet/mellanox/mlx5/core/en.h
>
> between commit:
>
>   6cd392a082de ("net/mlx5e: Handle RQ flush in error cases")
>
> from the net tree and commit:
>
>   cb3c7fd4f839 ("net/mlx5e: Support adaptive RX coalescing")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
>
> --
> Cheers,
> Stephen Rothwell
>
> diff --cc drivers/net/ethernet/mellanox/mlx5/core/en.h
> index 943b1bd434bf,00643a116492..000000000000
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@@ -143,10 -146,32 +146,31 @@@ struct mlx5e_umr_wqe
>         struct mlx5_wqe_data_seg       data;
>   };
>
> + static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
> +       "rx_cqe_moder",
> + };
> +
> + enum mlx5e_priv_flag {
> +       MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
> + };
> +
> + #define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
> +       do {                                        \
> +               if (enable)                         \
> +                       priv->pflags |= pflag;      \
> +               else                                \
> +                       priv->pflags &= ~pflag;     \
> +       } while (0)
> +
>   #ifdef CONFIG_MLX5_CORE_EN_DCB
>   #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
>  -#define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
>   #endif
>
> + struct mlx5e_cq_moder {
> +       u16 usec;
> +       u16 pkts;
> + };
> +
>   struct mlx5e_params {
>         u8  log_sq_size;
>         u8  rq_wq_type;
> @@@ -190,7 -215,7 +214,8 @@@ struct mlx5e_tstamp
>   enum {
>         MLX5E_RQ_STATE_POST_WQES_ENABLE,
>         MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
>  +      MLX5E_RQ_STATE_FLUSH_TIMEOUT,
> +       MLX5E_RQ_STATE_AM,
>   };
>

Thanks Stephen, the fixup looks good.

I already notified Dave on those issues and how to fix, see mail
thread "Mellanox 100G mlx5 resiliency and xmit path fixes"

Thanks,
Saeed.
