From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/2] net: fec: use managed DMA API functions to
 allocate BD ring
Date: Wed, 22 Jul 2015 01:55:13 +0000
Message-ID: <BLUPR03MB373240F9253F98CF962AA88F5830@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1437491462-28599-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Li Frank <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"patchwork-lst@pengutronix.de" <patchwork-lst@pengutronix.de>
To: Lucas Stach <l.stach@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0133.outbound.protection.outlook.com ([157.56.111.133]:34432
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751756AbbGVBzQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 21:55:16 -0400
In-Reply-To: <1437491462-28599-1-git-send-email-l.stach@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de> Sent: Tuesday, July 21, 2015 11:11 PM
> To: David S. Miller
> Cc: Duan Fugang-B38611; Li Frank-B20596; netdev@vger.kernel.org;
> kernel@pengutronix.de; patchwork-lst@pengutronix.de
> Subject: [PATCH v2 1/2] net: fec: use managed DMA API functions to
> allocate BD ring
> 
> So it gets freed when the device is going away.
> This fixes a DMA memory leak on driver probe() fail and driver remove().
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> v2: Fix indentation of second line to fix alignment with opening bracket.
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 349365d85b92..a7f1bdf718f8 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3142,8 +3142,8 @@ static int fec_enet_init(struct net_device *ndev)
>  			fep->bufdesc_size;
> 
>  	/* Allocate memory for buffer descriptors. */
> -	cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
> -				      GFP_KERNEL);
> +	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
> +				       GFP_KERNEL);
>  	if (!cbd_base) {
>  		return -ENOMEM;
>  	}
> --

Can you also replace the below position with dma_alloc_coherent() ?
                txq->tso_hdrs = dma_alloc_coherent(NULL,
                                        txq->tx_ring_size * TSO_HEADER_SIZE,
                                        &txq->tso_hdrs_dma,
                                        GFP_KERNEL);


Regards,
Andy
