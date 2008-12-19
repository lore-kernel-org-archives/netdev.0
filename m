From: David Miller <davem@davemloft.net>
Subject: Re: smsc911x unloading crash
Date: Thu, 18 Dec 2008 22:55:15 -0800 (PST)
Message-ID: <20081218.225515.12838744.davem@davemloft.net>
References: <494AD3BA.9030602@telus.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: dfoley@telus.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbYLSHDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 02:03:55 -0500
In-Reply-To: <494AD3BA.9030602@telus.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dfoley <dfoley@telus.net>
Date: Thu, 18 Dec 2008 14:50:34 -0800

> I am testing out the new smsc911x driver that is in the linux-next tree.
> I get a crash when unloading the module. I've got this patch to fix it. I noticed that the dev_set_drvdata is clobbering the data when
> the driver's ..._remove function calls dev = platform_get_drvdata(pdev);
> I've back ported this to run on 2.6.27, so this patch may or
> may not be needed. Sorry if it's a matter of not having the latest version.

Steve, please take a look at this.

dfoley, even if your patch is correct your email client has severely
corrupted the patch (changing tab characters into spaces, etc.) so if
this patch is still needed you'll need to resubmit with your email
client fixed to not corrupt the patch with formatting changes.

> diff -purN a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> --- a/drivers/net/smsc911x.c    2008-12-18 10:03:27.000000000 -0800
> +++ b/drivers/net/smsc911x.c    2008-12-18 12:03:52.000000000 -0800
> @@ -822,7 +822,6 @@ static int __devinit smsc911x_mii_init(s
>                  pdata->mii_bus->irq[i] = PHY_POLL;
> 
>          pdata->mii_bus->parent = &pdev->dev;
> -       dev_set_drvdata(&pdev->dev, &pdata->mii_bus);
> 
>          pdata->using_extphy = 0;
> 
> @@ -1872,7 +1871,7 @@ static int __devexit smsc911x_drv_remove
>          res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
>                                             "smsc911x-memory");
>          if (!res)
> -               platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +               res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> 
>          release_mem_region(res->start, res->end - res->start);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
