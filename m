From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch -next] net/mlx5_core: fix an error code
Date: Thu, 11 Jun 2015 14:28:27 +0300
Message-ID: <CAJ3xEMi4ZgFTG9OLNgN=81g56QWK-GCF790d3v=9rWHhMmqLvQ@mail.gmail.com>
References: <20150611085001.GB27393@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eli Cohen <eli@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:35232 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbFKL22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 07:28:28 -0400
In-Reply-To: <20150611085001.GB27393@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 11:50 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> We return success if mlx5e_alloc_sq_db() fails but we should return an
> error code.
>
> Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 7348c51..075e517 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -525,7 +525,8 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
>         sq->uar_map     = sq->uar.map;
>         sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
>
> -       if (mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu)))
> +       err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
> +       if (err)
>                 goto err_sq_wq_destroy;
>
>         sq->txq = netdev_get_tx_queue(priv->netdev,

Dan, nice catch, the team here just handed me the same fix, but you
submitted 1st...

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
