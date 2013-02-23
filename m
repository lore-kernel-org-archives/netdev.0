From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] mlx4_en: fix allocation of device tx_cq
Date: Sat, 23 Feb 2013 09:05:47 +0200
Message-ID: <51286A4B.4000003@mellanox.com>
References: <1361581082-5583-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:52109 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353Ab3BWHF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 02:05:58 -0500
In-Reply-To: <1361581082-5583-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/2013 02:58, Kleber Sacilotto de Souza wrote:
> The memory to hold the network device tx_cq is not being allocated with
> the correct size in mlx4_en_init_netdev(). It should use MAX_TX_RINGS
> instead of MAX_RX_RINGS. This can cause problems if the number of tx
> rings being used is greater than MAX_RX_RINGS.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 5088dc5..5944dd6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2067,7 +2067,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>  		err = -ENOMEM;
>  		goto out;
>  	}
> -	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_RX_RINGS,
> +	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_TX_RINGS,
>  			      GFP_KERNEL);
>  	if (!priv->tx_cq) {
>  		err = -ENOMEM;
> 

(sorry for double posting - tried to send from my tablet in plain text
without success).

Acked-by: Amir Vadai <amirv@mellanox.com>
