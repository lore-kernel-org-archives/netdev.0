From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH 10/36] net: ethernet: calxeda: remove unnecessary platform_set_drvdata()
Date: Tue, 07 May 2013 09:49:50 -0500
Message-ID: <5189148E.3040603@calxeda.com>
References: <001a01ce4ada$e498ace0$adca06a0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:44151 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847Ab3EGO6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:58:42 -0400
In-Reply-To: <001a01ce4ada$e498ace0$adca06a0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2013 11:25 PM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

netdev is closed during the merge window except for fixes, so you will
have to resubmit this. But when you do:

Acked-by: Rob Herring <rob.herring@calxeda.com>

> ---
>  drivers/net/ethernet/calxeda/xgmac.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> index 4a1f2fa..7cb148c 100644
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -1790,7 +1790,6 @@ err_io:
>  	free_netdev(ndev);
>  err_alloc:
>  	release_mem_region(res->start, resource_size(res));
> -	platform_set_drvdata(pdev, NULL);
>  	return ret;
>  }
>  
> @@ -1813,7 +1812,6 @@ static int xgmac_remove(struct platform_device *pdev)
>  	free_irq(ndev->irq, ndev);
>  	free_irq(priv->pmt_irq, ndev);
>  
> -	platform_set_drvdata(pdev, NULL);
>  	unregister_netdev(ndev);
>  	netif_napi_del(&priv->napi);
>  
> 
