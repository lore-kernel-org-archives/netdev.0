From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/7] net: pch_gbe: Pull PHY GPIO handling out of
 Minnow code
Date: Mon, 5 Jun 2017 20:43:55 +0200
Message-ID: <20170605184355.GD5235@lunn.ch>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170602234042.22782-3-paul.burton@imgtec.com>
 <20170603175200.GC17099@lunn.ch>
 <4378321.AjzBvRIWiG@np-p-burton>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, linux-mips@linux-mips.org,
        Eric Dumazet <edumazet@google.com>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36907 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751225AbdFESoA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 14:44:00 -0400
Content-Disposition: inline
In-Reply-To: <4378321.AjzBvRIWiG@np-p-burton>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 10:21:50AM -0700, Paul Burton wrote:
> Hi Andrew,
> 
> On Saturday, 3 June 2017 10:52:00 PDT Andrew Lunn wrote:
> > > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > > b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c index
> > > d38198718005..cb9b904786e4 100644
> > > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > > @@ -360,6 +360,16 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw
> > > *hw, u8 * addr, u32 index)> 
> > >  	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
> > >  
> > >  }
> > > 
> > > +static void pch_gbe_phy_set_reset(struct pch_gbe_hw *hw, int value)
> > > +{
> > > +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
> > > +
> > > +	if (!adapter->pdata || !adapter->pdata->phy_reset_gpio)
> > > +		return;
> > > +
> > > +	gpiod_set_value(adapter->pdata->phy_reset_gpio, value);
> > 
> > Hi Paul
> > 
> > Since you are using the gpiod_ API, the core will take notice of the
> > active low/active high flag when performing this set.
> 
> Correct, and as desired.
> 
> > >  	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
> > >  	
> > >  				    "minnow_phy_reset");
> > > 
> > > -	if (ret) {
> > > +	if (!ret)
> > > +		pdata->phy_reset_gpio = gpio_to_desc(gpio);
> > 
> > Here however, you are using the gpio_ API, which ignores the active
> > high/low flag in device tree. And in your binding patch, you give the
> > example:
> > 
> > +               phy-reset-gpios = <&eg20t_gpio 6
> > +                                  GPIO_ACTIVE_LOW>;
> > 
> > This active low is totally ignored.
> 
> First of all, this path is for the existing Minnow platform, which doesn't use 
> the device tree. That is, this code is the non-DT path so looking at what 
> happens to flags in the device tree here makes no sense.

Thanks for the explanation. Now it makes sense.

       Andrew
