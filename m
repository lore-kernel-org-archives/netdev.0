From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 07/11] net/mlx5_core: Implement get/set port
 status
Date: Wed, 08 Apr 2015 21:26:37 +0300
Message-ID: <552572DD.6030105@cogentembedded.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com> <1428504685-8945-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33813 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbbDHS0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 14:26:41 -0400
Received: by lbcga7 with SMTP id ga7so23992133lbc.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 11:26:40 -0700 (PDT)
In-Reply-To: <1428504685-8945-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/08/2015 05:51 PM, Amir Vadai wrote:

> From: Rana Shahout <ranas@mellanox.com>

> Signed-off-by: Rana Shahout <ranas@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/port.c | 34 ++++++++++++++++++++++++++
>   include/linux/mlx5/driver.h                    |  8 ++++++
>   2 files changed, 42 insertions(+)

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
> index 6e2d99c..7c394c0 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
> @@ -179,3 +179,37 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
>   	return err;
>   }
>   EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
> +
> +int mlx5_set_port_status(struct mlx5_core_dev *dev,
> +			 enum mlx5_port_status status)
> +{
> +	u32 in[MLX5_ST_SZ_DW(paos_reg)];
> +	u32 out[MLX5_ST_SZ_DW(paos_reg)];
> +	int err;
> +
> +	memset(in, 0, sizeof(in));
> +
> +	MLX5_SET(paos_reg, in, admin_status, status);
> +	MLX5_SET(paos_reg, in, ase, 1);
> +
> +	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
> +				   sizeof(out), MLX5_REG_PAOS, 0, 1);
> +	return err;

    Why not just direct return of the function's result?

[...]

WBR, Sergei
