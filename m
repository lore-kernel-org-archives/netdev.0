From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v7 02/10] arm: dts: sunxi: Restore EMAC changes
Date: Wed, 18 Oct 2017 20:50:49 +0200
Message-ID: <20171018185049.GA24584@Red>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-3-clabbe.montjoie@gmail.com>
 <20171018164450.GE15371@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-sunxi@googlegroups.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171018164450.GE15371@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 06:44:50PM +0200, Andrew Lunn wrote:
> On Wed, Oct 18, 2017 at 01:44:50PM +0200, Corentin Labbe wrote:
> > The original dwmac-sun8i DT bindings have some issue on how to handle
> > integrated PHY and was reverted in last RC of 4.13.
> > But now we have a solution so we need to get back that was reverted.
> > 
> > This patch restore arm DT about dwmac-sun8i
> > This reverts commit fe45174b72ae ("arm: dts: sunxi: Revert EMAC changes")
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts |  9 ++++++++
> >  arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts   | 19 +++++++++++++++++
> >  arch/arm/boot/dts/sun8i-h3-nanopi-m1-plus.dts     | 19 +++++++++++++++++
> >  arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  7 ++++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  8 +++++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  8 +++++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts   |  5 +++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  8 +++++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts      | 22 +++++++++++++++++++
> >  arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts    | 16 ++++++++++++++
> >  arch/arm/boot/dts/sunxi-h3-h5.dtsi                | 26 +++++++++++++++++++++++
> >  11 files changed, 147 insertions(+)
> > 
> > diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > index b1502df7b509..6713d0f2b3f4 100644
> > --- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > +++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > @@ -56,6 +56,8 @@
> >  
> >  	aliases {
> >  		serial0 = &uart0;
> > +		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
> > +		ethernet0 = &emac;
> >  		ethernet1 = &xr819;
> >  	};
> >  
> > @@ -102,6 +104,13 @@
> >  	status = "okay";
> >  };
> >  
> > +&emac {
> > +	phy-handle = <&int_mii_phy>;
> > +	phy-mode = "mii";
> > +	allwinner,leds-active-low;
> > +	status = "okay";
> > +};
> > +
> >  &mmc0 {
> >  	pinctrl-names = "default";
> >  	pinctrl-0 = <&mmc0_pins_a>;
> > diff --git a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > index e1dba9ffa94b..f2292deaa590 100644
> > --- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > +++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > @@ -52,6 +52,7 @@
> >  	compatible = "sinovoip,bpi-m2-plus", "allwinner,sun8i-h3";
> >  
> >  	aliases {
> > +		ethernet0 = &emac;
> >  		serial0 = &uart0;
> >  		serial1 = &uart1;
> >  	};
> > @@ -111,6 +112,24 @@
> >  	status = "okay";
> >  };
> >  
> > +&emac {
> > +	pinctrl-names = "default";
> > +	pinctrl-0 = <&emac_rgmii_pins>;
> > +	phy-supply = <&reg_gmac_3v3>;
> > +	phy-handle = <&ext_rgmii_phy>;
> > +	phy-mode = "rgmii";
> > +
> > +	allwinner,leds-active-low;
> > +	status = "okay";
> > +};
> > +
> 
> 
> > +&external_mdio {
> > +	ext_rgmii_phy: ethernet-phy@1 {
> > +		compatible = "ethernet-phy-ieee802.3-c22";
> > +		reg = <0>;
> > +	};
> > +};
> > +
> 
> Hi Corentin
> 
> I'm wondering about the order of the patches. Does the external_mdio
> node actually exist at this point? Or only later when other patches
> are applied?
> 

You are right order of patch are wrong, I need to cut this one in two.
"Revert²" sunxi-h3-h5.dtsi
apply mdiomux
"Revert²" all board nodes

Regards
Corentin Labbe
