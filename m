From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH 21/36] net: ethernet: nxp: remove unnecessary platform_set_drvdata()
Date: Tue, 07 May 2013 18:22:59 +0200
Message-ID: <51892A63.6060309@antcom.de>
References: <002601ce4add$888a35b0$999ea110$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Wei Yongjun' <yongjun_wei@trendmicro.com.cn>,
	Eric Dumazet <edumazet@google.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:40763 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755558Ab3EGQbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 12:31:31 -0400
In-Reply-To: <002601ce4add$888a35b0$999ea110$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2013 06:44 AM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Tested-by: Roland Stigge <stigge@antcom.de>
Acked-by: Roland Stigge <stigge@antcom.de>

> ---
>  drivers/net/ethernet/nxp/lpc_eth.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> index 55a5548..a061b93 100644
> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -1483,7 +1483,6 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>  	return 0;
>  
>  err_out_unregister_netdev:
> -	platform_set_drvdata(pdev, NULL);
>  	unregister_netdev(ndev);
>  err_out_dma_unmap:
>  	if (!use_iram_for_net(&pldat->pdev->dev) ||
> @@ -1511,7 +1510,6 @@ static int lpc_eth_drv_remove(struct platform_device *pdev)
>  	struct netdata_local *pldat = netdev_priv(ndev);
>  
>  	unregister_netdev(ndev);
> -	platform_set_drvdata(pdev, NULL);
>  
>  	if (!use_iram_for_net(&pldat->pdev->dev) ||
>  	    pldat->dma_buff_size > lpc32xx_return_iram_size())
