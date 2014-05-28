From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] lpc_eth: Use resource_size instead of computation
Date: Wed, 28 May 2014 09:16:56 -0700
Message-ID: <1401293816.19335.3.camel@joe-AO725>
References: <1401290047-30005-1-git-send-email-benoit.taine@lip6.fr>
	 <1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Benoit Taine <benoit.taine@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-05-28 at 17:14 +0200, Benoit Taine wrote:
> This issue was reported by coccicheck using the semantic patch 
> at scripts/coccinelle/api/resource_size.cocci

Slightly associated trivial note:

> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
[]
> @@ -1419,8 +1419,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>  
>  	netdev_dbg(ndev, "IO address start     :0x%08x\n",
>  			res->start);
> -	netdev_dbg(ndev, "IO address size      :%d\n",
> -			res->end - res->start + 1);
> +	netdev_dbg(ndev, "IO address size      :%d\n", resource_size(res));

May be better using:

	netdev_dbg(ndev, "IO                       :%pR\n", res)


