From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V3 08/11] net/mlx5_core: Set/Query port MTU commands
Date: Sun, 10 May 2015 19:32:11 +0300
Message-ID: <554F880B.8060203@cogentembedded.com>
References: <1431250746-11941-1-git-send-email-amirv@mellanox.com> <1431250746-11941-9-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35336 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbEJQcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:32:15 -0400
Received: by lbbuc2 with SMTP id uc2so79948900lbb.2
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:32:13 -0700 (PDT)
In-Reply-To: <1431250746-11941-9-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/10/2015 12:39 PM, Amir Vadai wrote:

> From: Saeed Mahameed <saeedm@mellanox.com>

> Introduce set/Query low level functions to access MTU in hardware. To be
> used by the netdev.

> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/port.c | 56 ++++++++++++++++++++++++++
>   include/linux/mlx5/driver.h                    |  4 ++
>   2 files changed, 60 insertions(+)

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
> index 742a6fb..e56a0b6 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
> @@ -211,3 +211,59 @@ int mlx5_query_port_status(struct mlx5_core_dev *dev, u8 *status)
[...]
> +int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu)
> +{
> +	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
> +	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
> +	int err;
> +
> +	memset(in, 0, sizeof(in));
> +
> +	MLX5_SET(pmtu_reg, in, admin_mtu, mtu);
> +	MLX5_SET(pmtu_reg, in, local_port, 1);
> +
> +	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
> +				   sizeof(out), MLX5_REG_PMTU, 0, 1);
> +
> +	return err;

    Why not just return directly?

[...]

WBR, Sergei
