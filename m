From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v6 06/11] ARM: dts: sunxi: h3/h5: represent the mdio
 switch used by sun8i-h3-emac
Date: Wed, 27 Sep 2017 15:47:09 +0200
Message-ID: <20170927134709.GA14370@Red>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
 <20170927073414.17361-7-clabbe.montjoie@gmail.com>
 <20170927101622.v7odmreccwh7ldg2@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-sunxi@googlegroups.com
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36479 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753072AbdI0NrS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 09:47:18 -0400
Content-Disposition: inline
In-Reply-To: <20170927101622.v7odmreccwh7ldg2@flea>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 12:16:22PM +0200, Maxime Ripard wrote:
> On Wed, Sep 27, 2017 at 07:34:09AM +0000, Corentin Labbe wrote:
> > Since dwmac-sun8i could use either an integrated PHY or an external PHY
> > (which could be at same MDIO address), we need to represent this selection
> > by a MDIO switch.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 31 +++++++++++++++++++++++++------
> >  1 file changed, 25 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> > index 3b7d953429a6..a8e9b8f378ba 100644
> > --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> > +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> > @@ -422,14 +422,33 @@
> >  			#size-cells = <0>;
> >  			status = "disabled";
> >  
> > -			mdio: mdio {
> > +			mdio0: mdio {
> >  				#address-cells = <1>;
> >  				#size-cells = <0>;
> > -				int_mii_phy: ethernet-phy@1 {
> > -					compatible = "ethernet-phy-ieee802.3-c22";
> > -					reg = <1>;
> > -					clocks = <&ccu CLK_BUS_EPHY>;
> > -					resets = <&ccu RST_BUS_EPHY>;
> > +				compatible = "snps,dwmac-mdio";
> > +
> > +				mdio-mux {
> > +					compatible = "mdio-mux";
> > +					#address-cells = <1>;
> > +					#size-cells = <0>;
> 
> Newline
> 
> > +					/* Only one MDIO is usable at the time */
> > +					internal_mdio: mdio@1 {
> > +						reg = <1>;
> > +						#address-cells = <1>;
> > +						#size-cells = <0>;
> 
> Newline
> 
> > +						int_mii_phy: ethernet-phy@1 {
> > +							compatible = "ethernet-phy-ieee802.3-c22";
> > +							reg = <1>;
> > +							clocks = <&ccu CLK_BUS_EPHY>;
> > +							resets = <&ccu RST_BUS_EPHY>;
> > +							phy-is-integrated;
> > +						};
> > +					};
> 
> Newline
> 
> > +					mdio: mdio@2 {
> 
> This is quite confusing. Why not call the label external_mdio?
> 

I will do it. (at origin I was not changing it for limiting changes on board with external PHY, but now all DT are reverted, it will be easy)

Regards
