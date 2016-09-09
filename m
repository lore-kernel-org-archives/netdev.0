From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for
 Allwinner sun8i-emac
Date: Fri, 9 Sep 2016 16:04:13 +0200
Message-ID: <20160909140413.GD30871@lunn.ch>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473425117-18645-4-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +The device node referenced by "phy" or "phy-handle" should be a child node
> +of this node. See phy.txt for the generic PHY bindings.

I've not looked at the code yet, but is this really true? Generally
there is not this limitation. You can point to any Ethernet phy
anyway, so long as it is on am MDIO bus.

> +
> +Optional properties:
> +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
> +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)
> +
> +The TX/RX clock delay chain settings are board specific.
> +
> +Optional properties for "allwinner,sun8i-h3-emac":
> +- allwinner,leds-active-low: EPHY LEDs are active low
> +
> +Example:
> +
> +emac: ethernet@01c0b000 {
> +	compatible = "allwinner,sun8i-h3-emac";
> +	syscon = <&syscon>;
> +	reg = <0x01c0b000 0x104>;
> +	reg-names = "emac";
> +	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +	resets = <&ccu RST_BUS_EMAC>, <<&ccu RST_BUS_EPHY>;
> +	reset-names = "ahb", "ephy";
> +	clocks = <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
> +	clock-names = "ahb", "ephy";
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	phy = <&phy1>;

ethernet.txt say:

- phy: the same as "phy-handle" property, not recommended for new bindings.

This is a new binding, please don't support it.

> +	phy-mode = "mii";
> +	allwinner,leds-active-low;
> +
> +	phy1: ethernet-phy@1 {
> +		reg = <1>;
> +	};

It is normal to place these phy nodes inside an container node called
mdio.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
