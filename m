From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Thu, 14 Sep 2017 20:53:01 +0200
Message-ID: <20170914185301.GB4021@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com>
 <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
 <20170908074325.GB29999@Red>
 <20170913182004.uniyo5opeilcfk7r@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170913182004.uniyo5opeilcfk7r@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 13, 2017 at 01:20:04PM -0500, Rob Herring wrote:
> On Fri, Sep 08, 2017 at 09:43:25AM +0200, Corentin Labbe wrote:
> > On Fri, Sep 08, 2017 at 09:25:38AM +0200, Maxime Ripard wrote:
> > > On Fri, Sep 08, 2017 at 09:11:51AM +0200, Corentin Labbe wrote:
> > > > This patch add documentation about the MDIO switch used on sun8i-h3-emac
> > > > for integrated PHY.
> > > > 
> > > > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > ---
> > > >  .../devicetree/bindings/net/dwmac-sun8i.txt        | 127 +++++++++++++++++++--
> > > >  1 file changed, 120 insertions(+), 7 deletions(-)
> > > > 
> > > > diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > > > index 725f3b187886..3fa0e54825ea 100644
> > > > --- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > > > +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > > > @@ -39,7 +39,7 @@ Optional properties for the following compatibles:
> > > >  - allwinner,leds-active-low: EPHY LEDs are active low
> > > >  
> > > >  Required child node of emac:
> > > > -- mdio bus node: should be named mdio
> > > > +- mdio bus node: should be labelled mdio
> > > 
> > > labels do not end up in the final DT (while the names do) so why are
> > > you making this change?
> > > 
> > 
> > I misunderstood label/name.
> > Anyway, this contrainst should leave due to "snps,dwmac-mdio MDIOs are automatically registered"
> > 
> > > >  
> > > >  Required properties of the mdio node:
> > > >  - #address-cells: shall be 1
> > > > @@ -48,14 +48,28 @@ Required properties of the mdio node:
> > > >  The device node referenced by "phy" or "phy-handle" should be a child node
> > > >  of the mdio node. See phy.txt for the generic PHY bindings.
> > > >  
> > > > -Required properties of the phy node with the following compatibles:
> > > > +The following compatibles require an mdio-mux node called "mdio-mux":
> > > > +  - "allwinner,sun8i-h3-emac"
> > > > +  - "allwinner,sun8i-v3s-emac":
> > > > +Required properties for the mdio-mux node:
> > > > +  - compatible = "mdio-mux"
> > > > +  - one child mdio for the integrated mdio
> > > > +  - one child mdio for the external mdio if present (V3s have none)
> > > > +Required properties for the mdio-mux children node:
> > > > +  - reg: 0 for internal MDIO bus, 1 for external MDIO bus
> > > > +
> > > > +The following compatibles require a PHY node representing the integrated
> > > > +PHY, under the integrated MDIO bus node if an mdio-mux node is used:
> > > >    - "allwinner,sun8i-h3-emac",
> > > >    - "allwinner,sun8i-v3s-emac":
> > > > +
> > > > +Required properties of the integrated phy node:
> > > >  - clocks: a phandle to the reference clock for the EPHY
> > > >  - resets: a phandle to the reset control for the EPHY
> > > > +- phy-is-integrated
> > > > +- Should be a child of the integrated mdio
> > > 
> > > I'm not sure what you mean by that, you ask that it should (so not
> > > required?) be a child of the integrated mdio...
> > > 
> > 
> > I will change words to "must"
> > 
> > > >  
> > > > -Example:
> > > > -
> > > > +Example with integrated PHY:
> > > >  emac: ethernet@1c0b000 {
> > > >  	compatible = "allwinner,sun8i-h3-emac";
> > > >  	syscon = <&syscon>;
> > > > @@ -72,13 +86,112 @@ emac: ethernet@1c0b000 {
> > > >  	phy-handle = <&int_mii_phy>;
> > > >  	phy-mode = "mii";
> > > >  	allwinner,leds-active-low;
> > > > +
> > > > +	mdio0: mdio {
> > > 
> > > (You don't label it mdio here, unlike what was asked before)
> > > 
> > > > +		#address-cells = <1>;
> > > > +		#size-cells = <0>;
> > > > +		compatible = "snps,dwmac-mdio";
> > > > +	};
> > > 
> > > I think Rob wanted that node gone?
> > > 
> > 
> > MDIO mux does not work without a parent MDIO, either gived by "parent-bus" or directly via mdio_mux_init() (like it is the case in dwmac-sun8i)
> 
> Is the MDIO controller "allwinner,sun8i-h3-emac" or "snps,dwmac-mdio"? 
> If the latter, then I think the node is fine, but then the mux should be 
> a child node of it. IOW, the child of an MDIO controller should either 
> be a mux node or slave devices.
> 

It will be snps,dwmac-mdio but putting mdio-mux as a child of it (the mdio node) give me:
[   18.175338] libphy: stmmac: probed
[   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
[   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
[   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
[   18.175482] mdio_bus stmmac-0: scan phy mdio-mux at address 2
[   18.175513] mdio_bus stmmac-0: scan phy mdio-mux at address 3
[   18.175544] mdio_bus stmmac-0: scan phy mdio-mux at address 4
[   18.175575] mdio_bus stmmac-0: scan phy mdio-mux at address 5
[   18.175607] mdio_bus stmmac-0: scan phy mdio-mux at address 6
[   18.175638] mdio_bus stmmac-0: scan phy mdio-mux at address 7
[   18.175669] mdio_bus stmmac-0: scan phy mdio-mux at address 8
[   18.175700] mdio_bus stmmac-0: scan phy mdio-mux at address 9
[   18.175731] mdio_bus stmmac-0: scan phy mdio-mux at address 10
[   18.175762] mdio_bus stmmac-0: scan phy mdio-mux at address 11
[   18.175795] mdio_bus stmmac-0: scan phy mdio-mux at address 12
[   18.175827] mdio_bus stmmac-0: scan phy mdio-mux at address 13
[   18.175858] mdio_bus stmmac-0: scan phy mdio-mux at address 14
[   18.175889] mdio_bus stmmac-0: scan phy mdio-mux at address 15
[   18.175919] mdio_bus stmmac-0: scan phy mdio-mux at address 16
[   18.175951] mdio_bus stmmac-0: scan phy mdio-mux at address 17
[   18.175982] mdio_bus stmmac-0: scan phy mdio-mux at address 18
[   18.176014] mdio_bus stmmac-0: scan phy mdio-mux at address 19
[   18.176045] mdio_bus stmmac-0: scan phy mdio-mux at address 20
[   18.176076] mdio_bus stmmac-0: scan phy mdio-mux at address 21
[   18.176107] mdio_bus stmmac-0: scan phy mdio-mux at address 22
[   18.176139] mdio_bus stmmac-0: scan phy mdio-mux at address 23
[   18.176170] mdio_bus stmmac-0: scan phy mdio-mux at address 24
[   18.176202] mdio_bus stmmac-0: scan phy mdio-mux at address 25
[   18.176233] mdio_bus stmmac-0: scan phy mdio-mux at address 26
[   18.176271] mdio_bus stmmac-0: scan phy mdio-mux at address 27
[   18.176320] mdio_bus stmmac-0: scan phy mdio-mux at address 28
[   18.176371] mdio_bus stmmac-0: scan phy mdio-mux at address 29
[   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
[   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31

Adding a fake <reg> to mdio-mux remove it.
Does it is acceptable ? or perhaps patching of_mdiobus_register() to not scan node with compatible "mdio-mux".

> > 
> > > > +	mdio-mux {
> > > > +		compatible = "mdio-mux";
> > > > +		#address-cells = <1>;
> > > > +		#size-cells = <0>;
> > > > +
> > > > +		int_mdio: mdio@1 {
> > > > +			reg = <0>;
> 
> unit address of 1 and reg prop of 0 don't match. Build your dtb with 
> W=2.
> 

reg are arbitrary value (like mdio-mux-mmioreg), but in our case it is easy to fix this warning.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
