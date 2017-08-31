From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v4 4/5] net: stmmac: dwmac-sun8i: choose internal PHY via
 phy-is-integrated
Date: Thu, 31 Aug 2017 22:59:28 +0200
Message-ID: <20170831205928.GS22289@lunn.ch>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
 <20170826073311.25612-5-clabbe.montjoie@gmail.com>
 <20170826212051.GA10418@lunn.ch>
 <20170831201803.x6vwftfcllrfpk6q@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, icenowy-h8G6r0blFSE@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170831201803.x6vwftfcllrfpk6q@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 03:18:03PM -0500, Rob Herring wrote:
> On Sat, Aug 26, 2017 at 11:20:51PM +0200, Andrew Lunn wrote:
> > Hi Corentin
> > 
> > I think we have now all agreed this is an mdio-mux, plus it is also an
> > MII mux. We should represent that in device tree. This patchset does
> > this. However, as it is now, the mux structure in DT is ignored. All
> > it does is search for the phy-is-integrated flags and goes on that.
> > 
> > I made the comment that the device tree representation cannot be
> > implemented using an MDIO mux driver, because of driver loading
> > issues.  However, the core of the MDIO mux code is just a library,
> > symbols exported as GPL, free for anything to use.
> > 
> > What i think should happen is the mdio-mux is implemented inside the
> > MAC driver, using the mux-core as a library. The device tree structure
> > of a mix is then reflected within Linux. The mux switch callback is
> > implemented within the MAC driver. So it can reset the MAC when the
> > mux is switched. The 'phy-is-integrated' property is then no longer
> > needed.
> > 
> > I would suggest a binding something like:
> 
> This is looks better to me, but...
>  
> > emac: ethernet@1c0b000 {
> >         compatible = "allwinner,sun8i-h3-emac";
> >         syscon = <&syscon>;
> >         reg = <0x01c0b000 0x104>;
> >         interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> >         interrupt-names = "macirq";
> >         resets = <&ccu RST_BUS_EMAC>;
> >         reset-names = "stmmaceth";
> >         clocks = <&ccu CLK_BUS_EMAC>;
> >         clock-names = "stmmaceth";
> >         #address-cells = <1>;
> >         #size-cells = <0>;
> > 
> >         phy-handle = <&int_mii_phy>;
> >         phy-mode = "mii";
> >         allwinner,leds-active-low;
> > 
> >         mdio: mdio {
> >                 #address-cells = <1>;
> >                 #size-cells = <0>;
> > 	}
> 
> Why do you need this node still?

Hi Rob
 
It might not be needed, depending on how it is implemented. But:

Documentation/devicetree/bindings/net/mdio-mux.txt

It is normal for an mdio bus mux to have a phandle back to the parent
mdio bus.  Also, i think the stmmac driver will only instantiate the
mdio bus if there is a node for it in the device tree.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
