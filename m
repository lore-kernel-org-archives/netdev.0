From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 5/9] ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
Date: Wed, 14 Sep 2016 10:54:38 +0200
Message-ID: <20160914085438.GA9672@Red>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-6-git-send-email-clabbe.montjoie@gmail.com>
 <20160912072933.GC9449@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160912072933.GC9449@lukather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 09:29:33AM +0200, Maxime Ripard wrote:
> On Fri, Sep 09, 2016 at 02:45:13PM +0200, Corentin Labbe wrote:
> > The sun8i-emac is an ethernet MAC hardware that support 10/100/1000
> > speed.
> > 
> > This patch enable the sun8i-emac on the Allwinner H3 SoC Device-tree.
> > The SoC H3 have an internal PHY, so optionals syscon and ephy are set.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  arch/arm/boot/dts/sun8i-h3.dtsi | 19 +++++++++++++++++++
> >  1 file changed, 19 insertions(+)
> > 
> > diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
> > index a39da6f..a3ac476 100644
> > --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> > +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> > @@ -50,6 +50,10 @@
> >  / {
> >  	interrupt-parent = <&gic>;
> >  
> > +	aliases {
> > +		ethernet0 = &emac;
> > +	};
> > +
> 
> This needs to be done at the board level.
> 

ok

> >  	cpus {
> >  		#address-cells = <1>;
> >  		#size-cells = <0>;
> > @@ -446,6 +450,21 @@
> >  			status = "disabled";
> >  		};
> >  
> > +		emac: ethernet@1c30000 {
> > +			compatible = "allwinner,sun8i-h3-emac";
> > +			syscon = <&syscon>;
> > +			reg = <0x01c30000 0x104>;
> > +			reg-names = "emac";
> 
> You don't need reg-names anymore.
> 

ok

> > +			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> > +			resets = <&ccu RST_BUS_EMAC>, <&ccu RST_BUS_EPHY>;
> > +			reset-names = "ahb", "ephy";
> > +			clocks = <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
> > +			clock-names = "ahb", "ephy";
> 
> I still believe that having the same node for both the PHY and the MAC
> is wrong.
> 

Ok I have moved clock/reset of ephy in its node.

Thanks

Regards

Corentin Labbe
