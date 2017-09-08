From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Fri, 8 Sep 2017 16:00:20 +0200
Message-ID: <20170908140020.GC25219@lunn.ch>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-11-clabbe.montjoie@gmail.com>
 <20170908130520.GA11248@lunn.ch>
 <20170908132632.GA3037@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170908132632.GA3037@Red>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > +static int mdio_mux_syscon_switch_fn(int current_child, int desired_child,
> > > +				     void *data)
> > > +{
> > > +	struct stmmac_priv *priv = data;
> > > +	struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
> > > +	u32 reg, val;
> > > +	int ret = 0;
> > > +	bool need_reset = false;
> > > +
> > > +	if (current_child ^ desired_child) {
> > > +		regmap_read(gmac->regmap, SYSCON_EMAC_REG, &reg);
> > > +		switch (desired_child) {
> > > +		case DWMAC_sUN8I_MDIO_MUX_INTERNAL_ID:
> > > +			dev_info(priv->device, "Switch mux to internal PHY");
> > > +			val = (reg & ~H3_EPHY_MUX_MASK) | H3_EPHY_SELECT;
> > > +			if (gmac->use_internal_phy)
> > > +				need_reset = true;
> > > +			break;
> > 
> > This i don't get. Why do you need use_internal_phy? Isn't that
> > implicit from DWMAC_sUN8I_MDIO_MUX_INTERNAL_ID? Is it even possible to
> > use an external PHY on the internal MDIO bus?
> > 
> 
> On my H3 box with external PHY, the MDIO mux library first select (for scan ?) the internal MDIO.
> Without use_internal_phy usage, this board will launch a reset to use the internal MDIO... and this reset timeout/fail.

Do you know why the reset times out/fails?

   Andrew

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
