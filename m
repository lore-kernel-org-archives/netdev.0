From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 06/10] net/mlx4_core: Dynamically allocate
 structs at mlx4_slave_cap
Date: Mon, 28 Nov 2016 15:28:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB022A617@AcuExch.aculab.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
 <1480261877-19720-7-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tal Alon <talal@mellanox.com>
To: 'Tariq Toukan' <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:59412 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932718AbcK1P2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:28:35 -0500
In-Reply-To: <1480261877-19720-7-git-send-email-tariqt@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan
> Sent: 27 November 2016 15:51
> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> In order to avoid temporary large structs on the stack,
> allocate them dynamically.
> 
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Tal Alon <talal@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 244 +++++++++++++++++-------------
>  1 file changed, 142 insertions(+), 102 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 4a9497e9778d..65502df9fd96 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -799,40 +799,117 @@ static void slave_adjust_steering_mode(struct mlx4_dev *dev,
...
> +static int mlx4_slave_special_qp_cap(struct mlx4_dev *dev)
> +{
> +	struct mlx4_func_cap *func_cap = NULL;
> +	int i, err = 0;
> +
> +	func_cap = kzalloc(sizeof(*func_cap), GFP_KERNEL);
> +	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports,
> +				     sizeof(u32), GFP_KERNEL);
> +	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports,
> +				       sizeof(u32), GFP_KERNEL);
> +	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports,
> +				      sizeof(u32), GFP_KERNEL);
> +	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports,
> +				       sizeof(u32), GFP_KERNEL);
> +	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports,
> +				      sizeof(u32), GFP_KERNEL);
...
It has to be better to allocate a single piece of memory.
Potentially using a structure something like:

struct fubar {
	struct mlx4_func_cap func_cap;
	struct {
		u32	qp0_qkey;
		u32	qp0_tunnel;
		u32	qp0_proxy;
		u32	qp1_tunnel;
		u32	qp1_proxy;
	} port_info[];
};

	David
