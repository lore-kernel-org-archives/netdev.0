From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Fri, 8 Sep 2017 09:43:25 +0200
Message-ID: <20170908074325.GB29999@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com>
 <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170908072538.rqsp6dobwsqmzrsr-ZC1Zs529Oq4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 09:25:38AM +0200, Maxime Ripard wrote:
> On Fri, Sep 08, 2017 at 09:11:51AM +0200, Corentin Labbe wrote:
> > This patch add documentation about the MDIO switch used on sun8i-h3-emac
> > for integrated PHY.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  .../devicetree/bindings/net/dwmac-sun8i.txt        | 127 +++++++++++++++++++--
> >  1 file changed, 120 insertions(+), 7 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > index 725f3b187886..3fa0e54825ea 100644
> > --- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > @@ -39,7 +39,7 @@ Optional properties for the following compatibles:
> >  - allwinner,leds-active-low: EPHY LEDs are active low
> >  
> >  Required child node of emac:
> > -- mdio bus node: should be named mdio
> > +- mdio bus node: should be labelled mdio
> 
> labels do not end up in the final DT (while the names do) so why are
> you making this change?
> 

I misunderstood label/name.
Anyway, this contrainst should leave due to "snps,dwmac-mdio MDIOs are automatically registered"

> >  
> >  Required properties of the mdio node:
> >  - #address-cells: shall be 1
> > @@ -48,14 +48,28 @@ Required properties of the mdio node:
> >  The device node referenced by "phy" or "phy-handle" should be a child node
> >  of the mdio node. See phy.txt for the generic PHY bindings.
> >  
> > -Required properties of the phy node with the following compatibles:
> > +The following compatibles require an mdio-mux node called "mdio-mux":
> > +  - "allwinner,sun8i-h3-emac"
> > +  - "allwinner,sun8i-v3s-emac":
> > +Required properties for the mdio-mux node:
> > +  - compatible = "mdio-mux"
> > +  - one child mdio for the integrated mdio
> > +  - one child mdio for the external mdio if present (V3s have none)
> > +Required properties for the mdio-mux children node:
> > +  - reg: 0 for internal MDIO bus, 1 for external MDIO bus
> > +
> > +The following compatibles require a PHY node representing the integrated
> > +PHY, under the integrated MDIO bus node if an mdio-mux node is used:
> >    - "allwinner,sun8i-h3-emac",
> >    - "allwinner,sun8i-v3s-emac":
> > +
> > +Required properties of the integrated phy node:
> >  - clocks: a phandle to the reference clock for the EPHY
> >  - resets: a phandle to the reset control for the EPHY
> > +- phy-is-integrated
> > +- Should be a child of the integrated mdio
> 
> I'm not sure what you mean by that, you ask that it should (so not
> required?) be a child of the integrated mdio...
> 

I will change words to "must"

> >  
> > -Example:
> > -
> > +Example with integrated PHY:
> >  emac: ethernet@1c0b000 {
> >  	compatible = "allwinner,sun8i-h3-emac";
> >  	syscon = <&syscon>;
> > @@ -72,13 +86,112 @@ emac: ethernet@1c0b000 {
> >  	phy-handle = <&int_mii_phy>;
> >  	phy-mode = "mii";
> >  	allwinner,leds-active-low;
> > +
> > +	mdio0: mdio {
> 
> (You don't label it mdio here, unlike what was asked before)
> 
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		compatible = "snps,dwmac-mdio";
> > +	};
> 
> I think Rob wanted that node gone?
> 

MDIO mux does not work without a parent MDIO, either gived by "parent-bus" or directly via mdio_mux_init() (like it is the case in dwmac-sun8i)

> > +	mdio-mux {
> > +		compatible = "mdio-mux";
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +
> > +		int_mdio: mdio@1 {
> > +			reg = <0>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +			int_mii_phy: ethernet-phy@1 {
> > +				reg = <1>;
> > +				clocks = <&ccu CLK_BUS_EPHY>;
> > +				resets = <&ccu RST_BUS_EPHY>;
> > +				phy-is-integrated
> > +			};
> > +		};
> 
> ... And in your example it's a child of the mdio mux?
> 

So I confirm, integrated PHY must be a child of integrated MDIO (that must be a child of mdio-mux).
The example is good.

> > +		ext_mdio: mdio@0 {
> > +			reg = <1>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +		};
> > +	};
> > +};
> > +
> > +Example with external PHY:
> > +emac: ethernet@1c0b000 {
> > +	compatible = "allwinner,sun8i-h3-emac";
> > +	syscon = <&syscon>;
> > +	reg = <0x01c0b000 0x104>;
> > +	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> > +	interrupt-names = "macirq";
> > +	resets = <&ccu RST_BUS_EMAC>;
> > +	reset-names = "stmmaceth";
> > +	clocks = <&ccu CLK_BUS_EMAC>;
> > +	clock-names = "stmmaceth";
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +
> > +	phy-handle = <&ext_rgmii_phy>;
> > +	phy-mode = "rgmii";
> > +	allwinner,leds-active-low;
> > +
> > +	mdio0: mdio {
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		compatible = "snps,dwmac-mdio";
> > +	};
> > +
> > +	mdio-mux {
> > +		compatible = "mdio-mux";
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +
> > +		int_mdio: mdio@1 {
> > +			reg = <0>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +			int_mii_phy: ethernet-phy@1 {
> > +				reg = <1>;
> > +				clocks = <&ccu CLK_BUS_EPHY>;
> > +				resets = <&ccu RST_BUS_EPHY>;
> > +				phy-is-integrated
> > +			};
> > +		};
> > +		ext_mdio: mdio@0 {
> > +			reg = <1>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +			ext_rgmii_phy: ethernet-phy@1 {
> > +				reg = <1>;
> > +			};
> > +		};
> > +	};
> > +};
> > +
> > +Example with SoC without integrated PHY
> > +
> > +emac: ethernet@1c0b000 {
> > +	compatible = "allwinner,sun8i-a83t-emac";
> > +	syscon = <&syscon>;
> > +	reg = <0x01c0b000 0x104>;
> > +	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> > +	interrupt-names = "macirq";
> > +	resets = <&ccu RST_BUS_EMAC>;
> > +	reset-names = "stmmaceth";
> > +	clocks = <&ccu CLK_BUS_EMAC>;
> > +	clock-names = "stmmaceth";
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +
> > +	phy-handle = <&ext_rgmii_phy>;
> > +	phy-mode = "rgmii";
> > +
> >  	mdio: mdio {
> > +		compatible = "snps,dwmac-mdio";
> >  		#address-cells = <1>;
> >  		#size-cells = <0>;
> > -		int_mii_phy: ethernet-phy@1 {
> > +		ext_rgmii_phy: ethernet-phy@1 {
> >  			reg = <1>;
> > -			clocks = <&ccu CLK_BUS_EPHY>;
> > -			resets = <&ccu RST_BUS_EPHY>;
> >  		};
> >  	};
> >  };
> > -- 
> > 2.13.5
> > 
> 
> -- 
> Maxime Ripard, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com

Thanks for the review, I will fix all reported problem in next version.

Regards
Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
