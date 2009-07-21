From: Ben Dooks <ben@simtec.co.uk>
Subject: Re: [PATCH] dm9000: switch to dev_pm_ops
Date: Tue, 21 Jul 2009 16:04:06 +0100
Message-ID: <4A65D8E6.5010005@simtec.co.uk>
References: <1248184837-22350-1-git-send-email-mike@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:35923 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753257AbZGUPEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 11:04:42 -0400
In-Reply-To: <1248184837-22350-1-git-send-email-mike@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <mike@compulab.co.il>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> ---
>  drivers/net/dm9000.c |   18 ++++++++++++------
>  1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index dd771de..7b639cd 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -1410,9 +1410,10 @@ out:
>  }
>  
>  static int
> -dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
> +dm9000_drv_suspend(struct device *dev)
>  {
> -	struct net_device *ndev = platform_get_drvdata(dev);
> +	struct platform_device *pdev = to_platform_device(dev);
> +	struct net_device *ndev = platform_get_drvdata(pdev);
>  	board_info_t *db;
>  
>  	if (ndev) {
> @@ -1428,9 +1429,10 @@ dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
>  }
>  
>  static int
> -dm9000_drv_resume(struct platform_device *dev)
> +dm9000_drv_resume(struct device *dev)
>  {
> -	struct net_device *ndev = platform_get_drvdata(dev);
> +	struct platform_device *pdev = to_platform_device(dev);
> +	struct net_device *ndev = platform_get_drvdata(pdev);
>  	board_info_t *db = netdev_priv(ndev);
>  
>  	if (ndev) {
> @@ -1447,6 +1449,11 @@ dm9000_drv_resume(struct platform_device *dev)
>  	return 0;
>  }
>  
> +static struct dev_pm_ops dm9000_drv_pm_ops = {
> +	.suspend	= dm9000_drv_suspend,
> +	.resume		= dm9000_drv_resume,
> +};
> +
>  static int __devexit
>  dm9000_drv_remove(struct platform_device *pdev)
>  {
> @@ -1466,11 +1473,10 @@ static struct platform_driver dm9000_driver = {
>  	.driver	= {
>  		.name    = "dm9000",
>  		.owner	 = THIS_MODULE,
> +		.pm	 = &dm9000_drv_pm_ops,
>  	},
>  	.probe   = dm9000_probe,
>  	.remove  = __devexit_p(dm9000_drv_remove),
> -	.suspend = dm9000_drv_suspend,
> -	.resume  = dm9000_drv_resume,
>  };
>  
>  static int __init


-- 
Ben Dooks, Software Engineer, Simtec Electronics

http://www.simtec.co.uk/
