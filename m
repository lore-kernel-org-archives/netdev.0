From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] at91ether: return PTR_ERR if call to clk_get fails
Date: Thu, 20 Sep 2012 09:42:14 +0200
Message-ID: <505AC8D6.5080404@atmel.com>
References: <1348124676-6627-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Devendra Naga <devendra.aaru@gmail.com>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:35036 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074Ab2ITHma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 03:42:30 -0400
In-Reply-To: <1348124676-6627-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2012 09:04 AM, Devendra Naga :
> we are currently returning ENODEV, as the clk_get may give a exact
> error code in its returned pointer, assign it to the ret by using the
> PTR_ERR function, so that the subsequent goto label will jump to the
> error path and clean the driver and return the error correctly.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks,

> ---
>  drivers/net/ethernet/cadence/at91_ether.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index 7788419..4e980a7 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -1086,7 +1086,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
>  	/* Clock */
>  	lp->ether_clk = clk_get(&pdev->dev, "ether_clk");
>  	if (IS_ERR(lp->ether_clk)) {
> -		res = -ENODEV;
> +		res = PTR_ERR(lp->ether_clk);
>  		goto err_ioumap;
>  	}
>  	clk_enable(lp->ether_clk);
> 


-- 
Nicolas Ferre
