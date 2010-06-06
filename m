From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0
 is used
Date: Mon, 07 Jun 2010 07:57:25 +1000
Message-ID: <1275861445.1931.2974.camel@pasglop>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	michal.simek@petalogix.com, john.williams@petalogix.com,
	Brian Hill <brian.hill@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59228 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754531Ab0FFV5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 17:57:40 -0400
In-Reply-To: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-26 at 11:29 -0600, John Linn wrote:
> The code is not checking the interrupt for DMA correctly so that an
> interrupt number of 0 will cause a false error.
> 
> Signed-off-by: Brian Hill <brian.hill@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>
> ---
>  drivers/net/ll_temac_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
> index fa7620e..0615737 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -950,7 +950,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
>  
>  	lp->rx_irq = irq_of_parse_and_map(np, 0);
>  	lp->tx_irq = irq_of_parse_and_map(np, 1);
> -	if (!lp->rx_irq || !lp->tx_irq) {
> +	if ((lp->rx_irq == NO_IRQ) || (lp->tx_irq == NO_IRQ)) {
>  		dev_err(&op->dev, "could not determine irqs\n");
>  		rc = -ENOMEM;
>  		goto nodev;

Hasn't NO_IRQ been deprecated ?

Linus made it clear a while back that interrupt 0 was not valid and
that's the way it should be.

We now have an interrupt remapping scheme on powerpc, so we ensure that
0 always mean no interrupt. Other archs might need some fixups. Which
are specifically needs this patch ?

Cheers,
Ben.


