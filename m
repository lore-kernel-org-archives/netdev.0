From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] DM9000: __devinit/exit annotations
Date: Fri, 18 Apr 2008 11:43:46 +0100
Message-ID: <20080418104346.GG15407@fluff.org.uk>
References: <1208512936-5897-2-git-send-email-enrico.scholz@sigma-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:63396 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750849AbYDRKnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 06:43:49 -0400
Content-Disposition: inline
In-Reply-To: <1208512936-5897-2-git-send-email-enrico.scholz@sigma-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 12:02:15PM +0200, Enrico Scholz wrote:
> There were missing __dev* annotations for the dm9000_probe() 
> and dm9000_drv_remove() functions.
> 
> Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Acked-by: Ben Dooks <ben-linux@fluff.org>

>  drivers/net/dm9000.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index e668b37..7bc16d2 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -503,7 +503,7 @@ dm9000_release_board(struct platform_device *pdev, struct board_info *db)
>  /*
>   * Search DM9000 board, allocate space and register it
>   */
> -static int
> +static int __devinit
>  dm9000_probe(struct platform_device *pdev)
>  {
>  	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
> @@ -1376,7 +1376,7 @@ dm9000_drv_resume(struct platform_device *dev)
>  	return 0;
>  }
>  
> -static int
> +static int __devexit
>  dm9000_drv_remove(struct platform_device *pdev)
>  {
>  	struct net_device *ndev = platform_get_drvdata(pdev);
> @@ -1397,7 +1397,7 @@ static struct platform_driver dm9000_driver = {
>  		.owner	 = THIS_MODULE,
>  	},
>  	.probe   = dm9000_probe,
> -	.remove  = dm9000_drv_remove,
> +	.remove  = __devexit_p(dm9000_drv_remove),
>  	.suspend = dm9000_drv_suspend,
>  	.resume  = dm9000_drv_resume,
>  };
> -- 
> 1.5.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
