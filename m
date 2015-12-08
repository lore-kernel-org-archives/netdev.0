From: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Subject: Re: [PATCH v3 1/4] stmmac: create of compatible mdio bus for stmacc
 driver
Date: Tue, 8 Dec 2015 11:53:31 +0100
Message-ID: <20151208105331.GF22271@distanz.ch>
References: <1449551582-6599-1-git-send-email-preid@electromag.com.au>
 <1449551582-6599-2-git-send-email-preid@electromag.com.au>
 <2819989.unjINxCo2S@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	vbridger-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2819989.unjINxCo2S@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015-12-08 at 10:35:05 +0100, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Tuesday 08 December 2015 13:12:59 Phil Reid wrote:
> 
> > @@ -201,6 +201,25 @@ int stmmac_mdio_register(struct net_device *ndev)
> >  	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
> >  	int addr, found;
> >  
> > +#ifdef CONFIG_OF
> > +	struct device_node *mdio_node = NULL;
> > +	struct device_node *child_node = NULL;
> > +
> > +	for_each_child_of_node(priv->device->of_node, child_node) {
> > +		if (of_device_is_compatible(child_node, "snps,dwmac-mdio")) {
> > +			mdio_node = child_node;
> > +			break;
> > +		}
> > +	}
> 
> Can you use "if (IS_ENABLED(CONFIG_OF))" here instead of a preprocessor "#if"?
> 
> > @@ -231,7 +250,11 @@ int stmmac_mdio_register(struct net_device *ndev)
> >  	new_bus->irq = irqlist;
> >  	new_bus->phy_mask = mdio_bus_data->phy_mask;
> >  	new_bus->parent = priv->device;
> > +#ifdef CONFIG_OF
> > +	err = of_mdiobus_register(new_bus, mdio_node);
> > +#else
> >  	err = mdiobus_register(new_bus);
> > +#endif
> 
> This looks like it should be done in the header file. Can you make
> a separate patch that changes the header file declaring of_mdiobus_register
> to make it a static inline function calling mdiobus_register() if CONFIG_OF
> is disabled?

This is already the case since commit 23a456f0 ("net: mdio:
of_mdiobus_register(): fall back to mdiobus_register() for !CONFIG_OF"),
so just calling of_mdiobus_register() regardless of CONFIG_OF is
sufficient here.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
