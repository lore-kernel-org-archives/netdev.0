From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 2/2] net: fec: Improve logging
Date: Sun, 17 Feb 2013 19:55:57 +0800
Message-ID: <20130217115555.GA6782@S2101-09.ap.freescale.net>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
 <1361055207-22870-2-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <s.hauer@pengutronix.de>, <marex@denx.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:53800
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755614Ab3BQMK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 07:10:59 -0500
Content-Disposition: inline
In-Reply-To: <1361055207-22870-2-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 16, 2013 at 08:53:27PM -0200, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> In case the request of the GPIO reset fails it is interesting to log
> such error even if DEBUG is not enabled, so promote the message to dev_err. 
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 5864a67..29d82cf 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1695,7 +1695,7 @@ static void fec_reset_phy(struct platform_device *pdev)
>  	err = devm_gpio_request_one(&pdev->dev, phy_reset,
>  				    GPIOF_OUT_INIT_LOW, "phy-reset");
>  	if (err) {
> -		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
> +		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);

Shouldn't dev_dbg be more like a equivalent of pr_debug?  The reason
why it's taken as a debug message rather than an error is that some
board design may not have reset line for phy.

Shawn

>  		return;
>  	}
>  	msleep(msec);
> -- 
> 1.7.9.5
> 
