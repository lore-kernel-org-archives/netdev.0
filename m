From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: Re: [PATCH v2] net: axienet: add support for standard phy-mode
 binding
Date: Mon, 10 Jul 2017 11:49:11 +0200
Message-ID: <20170710094911.b5pgp4bhtsjbt3ke@collins.gmr.ssr.upm.es>
References: <20170707065015.9671-1-alvaro.gamez@hazent.com>
 <002545df-143b-9ca9-eb42-36b3c2adc0cb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <002545df-143b-9ca9-eb42-36b3c2adc0cb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2017 at 10:16:31AM -0700, Florian Fainelli wrote:
> On 07/06/2017 11:50 PM, Alvaro Gamez Machado wrote:
> > Keep supporting proprietary "xlnx,phy-type" attribute and add support for
> > MII connectivity to the PHY.
> > 
> > Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
> > ---
> > diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
> > index af27f7d1cbf3..48e939a5fa31 100644
> > --- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
> > +++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
> > @@ -389,7 +389,7 @@ struct axidma_bd {
> >   * @dma_err_tasklet: Tasklet structure to process Axi DMA errors
> >   * @tx_irq:	Axidma TX IRQ number
> >   * @rx_irq:	Axidma RX IRQ number
> > - * @phy_type:	Phy type to identify between MII/GMII/RGMII/SGMII/1000 Base-X
> > + * @phy_mode:	Phy type to identify between MII/GMII/RGMII/SGMII/1000 Base-X
> >   * @options:	AxiEthernet option word
> >   * @last_link:	Phy link state in which the PHY was negotiated earlier
> >   * @features:	Stores the extended features supported by the axienet hw
> > @@ -432,7 +432,7 @@ struct axienet_local {
> >  
> >  	int tx_irq;
> >  	int rx_irq;
> > -	u32 phy_type;
> > +	u32 phy_mode;
> 
> Can you use phy_interface_t here for storing this value?

Sure!

> 
> > @@ -1539,7 +1532,38 @@ static int axienet_probe(struct platform_device *pdev)
> >  	 * the device-tree and accordingly set flags.
> >  	 */
> >  	of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
> > -	of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
> > +
> > +	/* Start with the proprietary, and broken phy_type */
> > +	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &value);
> > +	if (!ret) {
> > +		netdev_warn(ndev, "Please upgrade your device tree binary blob to use phy-mode");
> > +		switch (value) {
> > +		case XAE_PHY_TYPE_MII:
> > +			lp->phy_mode = PHY_INTERFACE_MODE_MII;
> > +			break;
> > +		case XAE_PHY_TYPE_GMII:
> > +			lp->phy_mode = PHY_INTERFACE_MODE_GMII;
> > +			break;
> > +		case XAE_PHY_TYPE_RGMII_2_0:
> > +			lp->phy_mode = PHY_INTERFACE_MODE_RGMII;
> 
> This should be PHY_INTERFACE_MODE_RGMII_ID.

Yes, thank you, Andrew already noticed that. Sorry I didn't see it myself.

Since Andrew told me that netdev is closed for patches right now, I'll wait
until next week to send these changes.

Thanks to both of you for your assistance on this small patch!

-- 
Alvaro G. M.
