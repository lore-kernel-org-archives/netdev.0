From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Tue, 16 Feb 2016 23:38:46 +0200
Message-ID: <CAJ3xEMjbOAyzu_6B23HPJshY+p9Dm23P6Sr2SxA=caHz6iuk6A@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32786 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcBPVir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:38:47 -0500
Received: by mail-io0-f182.google.com with SMTP id z135so996226iof.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 13:38:47 -0800 (PST)
In-Reply-To: <1455653401-9808-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 10:09 PM, Saeed Mahameed <saeedm@mellanox.com>
> @@ -1602,7 +1622,7 @@ static int mlx5e_create_tis(struct mlx5e_priv
*priv, int tc)
>
>         memset(in, 0, sizeof(in));
>
> -       MLX5_SET(tisc, tisc, prio,  tc);
> +       MLX5_SET(tisc, tisc, prio, tc << 1);

point bug fix? or we could never hit that prior to the patch as ## TCs
was always 0?

>         MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
>
>         return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
> @@ -1618,7 +1638,7 @@ static int mlx5e_create_tises(struct mlx5e_priv *priv)
>         int err;
>         int tc;
>
> -       for (tc = 0; tc < priv->params.num_tc; tc++) {
> +       for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++) {
>                 err = mlx5e_create_tis(priv, tc);

various places in the patch use priv->params.num_tc, wasn't sure if
it's correct to hard code things here, and if it does, why not hard
code everywhere
