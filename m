From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] smsc911x: Change clock warning message to debug level
Date: Fri, 21 Mar 2014 15:09:36 +0300
Message-ID: <532C2C00.4080901@cogentembedded.com>
References: <1395238926-16126-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Fabio Estevam <fabio.estevam@freescale.com>,
	steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:37438 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965324AbaCULJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 07:09:47 -0400
Received: by mail-lb0-f175.google.com with SMTP id w7so1510712lbi.20
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 04:09:46 -0700 (PDT)
In-Reply-To: <1395238926-16126-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/19/2014 05:22 PM, Fabio Estevam wrote:

> Since passing the clock is not mandatory, change the warning message to debug,
> so that we avoid getting the following clock failure message on every boot:

> smsc911x: Driver version 2008-10-21
> smsc911x smsc911x (unregistered net_device): couldn't get clock -2
> libphy: smsc911x-mdio: probed

> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>   drivers/net/ethernet/smsc/smsc911x.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 6382b7c..95e2b9a 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -439,7 +439,7 @@ static int smsc911x_request_resources(struct platform_device *pdev)
>   	/* Request clock */
>   	pdata->clk = clk_get(&pdev->dev, NULL);
>   	if (IS_ERR(pdata->clk))
> -		netdev_warn(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));
> +		netdev_dbg(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));

    Looks like using netdev_dbg() is premature at  this point (see that 
"unregistered net_device"), so I'd replace netdev_*(ndev, ...) with 
dev_*(&pdev->dev, ...)

WBR, Sergei
