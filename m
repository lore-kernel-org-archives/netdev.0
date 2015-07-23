From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH v2 1/2] net: fec: use managed DMA API functions to
 allocate BD ring
Date: Thu, 23 Jul 2015 12:24:05 +0200
Message-ID: <1437647045.3071.36.camel@pengutronix.de>
References: <1437491462-28599-1-git-send-email-l.stach@pengutronix.de>
	 <BLUPR03MB373240F9253F98CF962AA88F5830@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Li Frank <Frank.Li@freescale.com>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"patchwork-lst@pengutronix.de" <patchwork-lst@pengutronix.de>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54391 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbbGWKYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:24:09 -0400
In-Reply-To: <BLUPR03MB373240F9253F98CF962AA88F5830@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, den 22.07.2015, 01:55 +0000 schrieb Duan Andy:
> From: Lucas Stach <l.stach@pengutronix.de> Sent: Tuesday, July 21, 2015 11:11 PM
> > To: David S. Miller
> > Cc: Duan Fugang-B38611; Li Frank-B20596; netdev@vger.kernel.org;
> > kernel@pengutronix.de; patchwork-lst@pengutronix.de
> > Subject: [PATCH v2 1/2] net: fec: use managed DMA API functions to
> > allocate BD ring
> > 
> > So it gets freed when the device is going away.
> > This fixes a DMA memory leak on driver probe() fail and driver remove().
> > 
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > ---
> > v2: Fix indentation of second line to fix alignment with opening bracket.
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 349365d85b92..a7f1bdf718f8 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -3142,8 +3142,8 @@ static int fec_enet_init(struct net_device *ndev)
> >  			fep->bufdesc_size;
> > 
> >  	/* Allocate memory for buffer descriptors. */
> > -	cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
> > -				      GFP_KERNEL);
> > +	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
> > +				       GFP_KERNEL);
> >  	if (!cbd_base) {
> >  		return -ENOMEM;
> >  	}
> > --
> 
> Can you also replace the below position with dma_alloc_coherent() ?
>                 txq->tso_hdrs = dma_alloc_coherent(NULL,
>                                         txq->tx_ring_size * TSO_HEADER_SIZE,
>                                         &txq->tso_hdrs_dma,
>                                         GFP_KERNEL);
> 
> 
No, that one has an explicit free functions.
So using managed function would result in a double free in paths. We
might want to move those over to devm eventually to make the error
handling more robust, but that's clearly out of the scope of this patch.

Regards,
Lucas

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
