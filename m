From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/at91_ether: avoid NULL pointer dereference
Date: Mon, 7 Apr 2014 09:06:54 +0200
Message-ID: <53424E8E.6030908@atmel.com>
References: <1396809464-22471-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:11229 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbaDGHG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 03:06:57 -0400
In-Reply-To: <1396809464-22471-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2014 20:37, Gilles Chanteperdrix :
> The at91_ether driver calls macb_mii_init passing a 'struct macb'
> structure whose tx_clk member is initialized to 0. However,
> macb_handle_link_change() expects tx_clk to be the result of
> a call to clk_get, and so IS_ERR(tx_clk) to be true if the clock
> is invalid. This causes an oops when booting Linux 3.14 on the
> csb637 board. The following changes avoids this.
> 
> Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks for this fix. Bye,

> ---
>  drivers/net/ethernet/cadence/at91_ether.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index ce75de9..4a79eda 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -342,6 +342,9 @@ static int __init at91ether_probe(struct platform_device *pdev)
>  	}
>  	clk_enable(lp->pclk);
>  
> +	lp->hclk = ERR_PTR(-ENOENT);
> +	lp->tx_clk = ERR_PTR(-ENOENT);
> +
>  	/* Install the interrupt handler */
>  	dev->irq = platform_get_irq(pdev, 0);
>  	res = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt, 0, dev->name, dev);
> 


-- 
Nicolas Ferre
