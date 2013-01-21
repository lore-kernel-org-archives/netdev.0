From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] net: fec: refactor dt probing
Date: Mon, 21 Jan 2013 19:27:00 +0100
Message-ID: <20130121182700.GD1906@pengutronix.de>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
 <1358757475-21035-2-git-send-email-s.hauer@pengutronix.de>
 <20130121174824.GA27956@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shawn.guo@linaro.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59786 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3AUS1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:27:03 -0500
Content-Disposition: inline
In-Reply-To: <20130121174824.GA27956@sapphire.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 07:48:26PM +0200, Baruch Siach wrote:
> Hi Sascha,
> 
> On Mon, Jan 21, 2013 at 09:37:54AM +0100, Sascha Hauer wrote:
> > For devicetree parsing only the fec_get_phy_mode_dt() is
> > available. Rename it to fec_probe_dt() to be able to add more devicetree
> > parsing to it.
> > 
> > Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> > ---
> 
> [...]
> 
> > -static int fec_get_phy_mode_dt(struct platform_device *pdev)
> > +static int fec_probe_dt(struct fec_enet_private *fep)
> >  {
> > -	struct device_node *np = pdev->dev.of_node;
> > +	struct device_node *np = fep->pdev->dev.of_node;
> >  
> > -	if (np)
> > -		return of_get_phy_mode(np);
> > +	if (!np)
> > +		return -ENODEV;
> > +
> > +	fep->phy_interface = of_get_phy_mode(np);
> >  
> >  	return -ENODEV;
> 
> Maybe return fep->phy_interface?

No, but indeed this should return successfully. I will rework this after
it's clear how we want to proceed with this.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
