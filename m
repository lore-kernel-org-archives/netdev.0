From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] net/mlx4_core: destroy workqueue when driver fails to
 register
Date: Mon, 2 Dec 2013 10:12:46 +0200
Message-ID: <529C40FE.8040908@mellanox.com>
References: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Wei Yang <weiyang@linux.vnet.ibm.com>, <davem@davemloft.net>,
	<jackm@dev.mellanox.co.il>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:35163 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752366Ab3LBIMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 03:12:55 -0500
In-Reply-To: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 03:44, Wei Yang wrote:
> When driver registration fails, we need to clean up the resources allocated
> before. mlx4_core missed to destroy the workqueue allocated.
> 
> This patch destroies the workqueue when registration fails.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 5789ea2..01fc651 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2635,6 +2635,8 @@ static int __init mlx4_init(void)
>  		return -ENOMEM;
>  
>  	ret = pci_register_driver(&mlx4_driver);
> +	if (ret < 0)
> +		destroy_workqueue(mlx4_wq);
>  	return ret < 0 ? ret : 0;
>  }
>  
> 

Acked-By: Amir Vadai <amirv@mellanox.com>
