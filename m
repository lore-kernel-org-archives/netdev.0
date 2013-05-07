From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 09/36] net: ethernet: cadence: remove unnecessary platform_set_drvdata()
Date: Tue, 7 May 2013 11:02:06 +0200
Message-ID: <5188C30E.80401@atmel.com>
References: <001901ce4ada$af3f99f0$0dbecdd0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:11436 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759083Ab3EGJCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 05:02:09 -0400
In-Reply-To: <001901ce4ada$af3f99f0$0dbecdd0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2013 06:23, Jingoo Han :
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>   drivers/net/ethernet/cadence/at91_ether.c |    1 -
>   drivers/net/ethernet/cadence/macb.c       |    2 --
>   2 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index cc9a185..3f19571 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -435,7 +435,6 @@ static int at91ether_remove(struct platform_device *pdev)
>   	unregister_netdev(dev);
>   	clk_disable(lp->pclk);
>   	free_netdev(dev);
> -	platform_set_drvdata(pdev, NULL);
>
>   	return 0;
>   }
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 6be513d..6a7bf7d 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1635,7 +1635,6 @@ err_out_put_pclk:
>   err_out_free_dev:
>   	free_netdev(dev);
>   err_out:
> -	platform_set_drvdata(pdev, NULL);
>   	return err;
>   }
>
> @@ -1661,7 +1660,6 @@ static int __exit macb_remove(struct platform_device *pdev)
>   		clk_disable_unprepare(bp->pclk);
>   		clk_put(bp->pclk);
>   		free_netdev(dev);
> -		platform_set_drvdata(pdev, NULL);
>   	}
>
>   	return 0;
>


-- 
Nicolas Ferre
