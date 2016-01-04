From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 08/24] phy: Centralise print about attached
 phy
Date: Mon, 4 Jan 2016 22:16:20 +0100
Message-ID: <20160104211620.GC7485@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
 <1451929022-5580-9-git-send-email-andrew@lunn.ch>
 <568AD2F6.2090006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35212 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbcADVQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 16:16:21 -0500
Content-Disposition: inline
In-Reply-To: <568AD2F6.2090006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 12:15:50PM -0800, Florian Fainelli wrote:
> On 04/01/16 09:36, Andrew Lunn wrote:
> > Many Ethernet drivers contain the same netdev_info() print statement
> > about the attached phy. Move it into the phy device code.
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> 
> [snip]
> 
> > diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> > index 5f8a5182b8dc..4c6f7a7f9352 100644
> > --- a/drivers/net/ethernet/adi/bfin_mac.c
> > +++ b/drivers/net/ethernet/adi/bfin_mac.c
> > @@ -444,11 +444,6 @@ static int mii_probe(struct net_device *dev, int phy_mode)
> >  	lp->old_duplex = -1;
> >  	lp->phydev = phydev;
> >  
> > -	pr_info("attached PHY driver [%s] "
> > -	        "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
> > -		phydev->drv->name, phydev_name(phydev), phydev->irq,
> > -	        MDC_CLK, mdc_div, sclk/1000000);
> 
> Removing this gets rid of the bus clocking information that is displayed
> here.

Yes, but how useful is that information?

I'm unsure what to do with all these prints. How useful are they? The
information is already in /sys. Are we really interested in seeing
this at boot time?

My main issue with them is that i need to touch them all when moving
members out of phydev into the common mdio device structure. So having
it once in a central place is good.
 
> Maybe something ala
> phy_print_status() which takes variadic arguments?

O.K. that works, since in most cases it will be a call like:

phy_print_attached(phydev);

and sometimes

phy_print_attached(phydev, "mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)",
                   MDC_CLK, mdc_div, sclk/1000000);

	   Andrew
