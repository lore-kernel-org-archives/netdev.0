From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH/RFC 2/3] ethernet: add a PHY reset GPIO DT binding to sh_eth
Date: Sat, 26 Jan 2013 02:04:13 +0100
Message-ID: <3496361.USCGuib0gY@avalon>
References: <1359043653-11374-1-git-send-email-g.liakhovetski@gmx.de> <7921225.sfO3PIeLVS@avalon> <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guennadi,

On Friday 25 January 2013 11:34:55 Guennadi Liakhovetski wrote:
> On Fri, 25 Jan 2013, Laurent Pinchart wrote:
> > On Thursday 24 January 2013 17:07:32 Guennadi Liakhovetski wrote:
> > > If an ethernet PHY can be reset by a GPIO, it can be specified in DT.
> > > Add a binding and code to parse it, request the GPIO and take the PHY
> > > out of reset.
> > > 
> > > Signed-off-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
> > > Cc: devicetree-discuss@lists.ozlabs.org
> > > Cc: netdev@vger.kernel.org
> > > ---
> > > 
> > >  Documentation/devicetree/bindings/net/sh_ether.txt |    2 ++
> > >  drivers/net/ethernet/renesas/sh_eth.c              |    9 ++++++++-
> > >  2 files changed, 10 insertions(+), 1 deletions(-)

[snip]

> > > diff --git a/drivers/net/ethernet/renesas/sh_eth.c
> > > b/drivers/net/ethernet/renesas/sh_eth.c index 1f64848..06035a2 100644
> > > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > > +++ b/drivers/net/ethernet/renesas/sh_eth.c

[snip]

> > > @@ -2420,6 +2423,10 @@ sh_eth_parse_dt(struct device *dev, struct
> > > net_device *ndev) else
> > > 
> > >  		pdata->needs_init = 0;
> > > 
> > > +	gpio = of_get_named_gpio_flags(np, "phy-reset-gpios", 0, &flags);
> > > +	if (gpio_is_valid(gpio) && !devm_gpio_request(dev, gpio, NULL))
> > > +		gpio_direction_output(gpio, !!(flags & OF_GPIO_ACTIVE_LOW));
> > 
> > You could use devm_gpio_request_one() here.
> 
> Yes, but then the flag would look uglier, something like
> 
> 		devm_gpio_request_one(dev, gpio, flags &
> 			OF_GPIO_ACTIVE_LOW ? GPIOF_OUT_INIT_HIGH :
> 			GPIOF_OUT_INIT_LOW);
> 
> Does it really look like an improvement? :)

It's one less function call, so to me it does :-) Feel free to ignore that 
though.

-- 
Regards,

Laurent Pinchart

