From: Amir Mellanox <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next] mlx4: change TX coalescing defaults
Date: Tue, 6 Nov 2012 10:04:46 +0200
Message-ID: <CAPcc5Piw2f4y=PXRGN+_gUA3ogO6zzbhyvNFEf717_m8dejbWQ@mail.gmail.com>
References: <1352168442.3140.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Vimalkumar <j.vimal@gmail.com>, amirv@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42343 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab2KFIEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 03:04:47 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so73923eek.19
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 00:04:46 -0800 (PST)
In-Reply-To: <1352168442.3140.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Hi,

I will check and review your patch and return to you ASAP.

Regarding BQL, the driver has it over half a year now, In commit:
5b263f5374ea70daa61ed9f5cc5d8f4ac236efbd

Amir.

On Tue, Nov 6, 2012 at 4:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> mlx4 currently uses a too high tx coalescing setting, deferring
> TX completion interrupts by up to 128 us.
>
> With the recent skb_orphan() removal in commit 8112ec3b872,
> performance of a single TCP flow is capped to ~4 Gbps, unless
> we increase tcp_limit_output_bytes.
>
> I suggest using 16 us instead of 128 us, allowing a finer control.
>
> Performance of a single TCP flow is restored to previous levels,
> while keeping TCP small queues fully enabled with default sysctl.
>
> This patch is also a BQL prereq.
>
> Reported-by: Vimalkumar <j.vimal@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> By the way, is BQL addition planned for this driver ?
>
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index edd9cb8..2b23ca2 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -870,7 +870,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
>         /* If we haven't received a specific coalescing setting
>          * (module param), we set the moderation parameters as follows:
>          * - moder_cnt is set to the number of mtu sized packets to
> -        *   satisfy our coelsing target.
> +        *   satisfy our coalescing target.
>          * - moder_time is set to a fixed value.
>          */
>         priv->rx_frames = MLX4_EN_RX_COAL_TARGET;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 9d27e42..8a5e70d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -126,7 +126,7 @@ enum {
>  #define MLX4_EN_RX_COAL_TIME   0x10
>
>  #define MLX4_EN_TX_COAL_PKTS   16
> -#define MLX4_EN_TX_COAL_TIME   0x80
> +#define MLX4_EN_TX_COAL_TIME   0x10
>
>  #define MLX4_EN_RX_RATE_LOW            400000
>  #define MLX4_EN_RX_COAL_TIME_LOW       0
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
