From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/4] net/mlx4_core: Adjust port number in qp_attach
 wrapper when detaching
Date: Thu, 01 May 2014 23:54:42 +0400
Message-ID: <5362A682.60101@cogentembedded.com>
References: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com> <1398948716-6765-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Jack Morgenstein <jackm@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:61279 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaEATyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 15:54:50 -0400
Received: by mail-lb0-f179.google.com with SMTP id c11so464482lbj.10
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 12:54:48 -0700 (PDT)
In-Reply-To: <1398948716-6765-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/01/2014 04:51 PM, Or Gerlitz wrote:

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>

> When using single ported VFs and the VF is using port 2, we need
> to adjust the port accordingly (change it from 1 to 2).

> Fixes: 449fc48 ('net/mlx4: Adapt code for N-Port VF')
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   23 ++++++++++++++++++++
>   1 files changed, 23 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index 3b5f53e..3f27cba 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -3733,6 +3733,25 @@ static int qp_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
>   	}
>   }
>
> +static int mlx4_adjust_port(struct mlx4_dev *dev, int slave,
> +			    u8 *gid, enum mlx4_protocol prot)
> +{
> +	int real_port;
> +
> +	if (prot != MLX4_PROT_ETH)
> +		return 0;
> +
> +	if (dev->caps.steering_mode == MLX4_STEERING_MODE_B0 ||
> +	    (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED)) {

    It looks a bit strange when you enclose in parens the second == but not 
the first. In fact, they're not at all necessary.

WBR, Sergei
