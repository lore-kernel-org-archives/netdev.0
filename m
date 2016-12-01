From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: add missing checks for status bits
Date: Thu, 1 Dec 2016 09:52:24 +0100
Message-ID: <20161201085223.GD18042@verge.net.au>
References: <20161130200148.9011-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43986 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757171AbcLAIw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 03:52:29 -0500
Content-Disposition: inline
In-Reply-To: <20161130200148.9011-1-chris.brandt@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 03:01:48PM -0500, Chris Brandt wrote:
> When streaming a lot of data and the RZ can't keep up, some status bits
> will get set that are not being checked or cleared which cause the
> following messages and the Ethernet driver to stop working. This
> patch fixes that issue.
> 
> irq 21: nobody cared (try booting with the "irqpoll" option)
> handlers:
> [<c036b71c>] sh_eth_interrupt
> Disabling IRQ #21
> 
> Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>

Hi Chris,

I am wondering if the EESR_FRC but should also be checked.

> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 05b0dc5..079f10e 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -523,7 +523,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
>  	.tx_check	= EESR_TC1 | EESR_FTC,
>  	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
>  			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
> -			  EESR_TDE | EESR_ECI,
> +			  EESR_TDE | EESR_ECI | EESR_TUC | EESR_ROC,
>  	.fdr_value	= 0x0000070f,
>  
>  	.no_psr		= 1,
> -- 
> 2.10.1
> 
> 
