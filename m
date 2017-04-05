From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: trust shinfo->gso_segs
Date: Wed, 5 Apr 2017 11:58:41 -0400
Message-ID: <CALzJLG9S2dRpBOVzc0LQAiOXJZNT+4h25_j7_GWTTHY9dUii=w@mail.gmail.com>
References: <1491407342.10124.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35046 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932092AbdDEP7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 11:59:08 -0400
Received: by mail-qk0-f195.google.com with SMTP id k139so2244769qke.2
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 08:59:03 -0700 (PDT)
In-Reply-To: <1491407342.10124.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 5, 2017 at 11:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> mlx4 is the only driver in the tree making a point to recompute
> shinfo->gso_segs.
>
> Lets remove superfluous code.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index e0c5ffb3e3a6607456e1f191b0b8c8becfc71219..3ba89bc43d74d8c023776079bcd0bbadd70fb5c6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -978,8 +978,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>
>                 ring->tso_packets++;
>
> -               i = ((skb->len - lso_header_size) / shinfo->gso_size) +
> -                       !!((skb->len - lso_header_size) % shinfo->gso_size);
> +               i = shinfo->gso_segs;
>                 tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
>                 ring->packets += i;
>         } else {
>
>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
