From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 01/10] arm64: dts: allwinner: Restore EMAC changes
Date: Fri, 8 Sep 2017 09:36:57 +0200
Message-ID: <20170908073657.GA29999@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-2-clabbe.montjoie@gmail.com>
 <20170908071954.j2bhtw4wqa27fald@flea.lan>
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
In-Reply-To: <20170908071954.j2bhtw4wqa27fald-ZC1Zs529Oq4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 09:19:54AM +0200, Maxime Ripard wrote:
> On Fri, Sep 08, 2017 at 09:11:47AM +0200, Corentin Labbe wrote:
> > diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> > index 1c2387bd5df6..968908761194 100644
> > --- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> > +++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> > @@ -50,6 +50,7 @@
> >  	compatible = "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
> >  
> >  	aliases {
> > +		ethernet0 = &emac;
> >  		serial0 = &uart0;
> >  	};
> >  
> > @@ -108,6 +109,22 @@
> >  	status = "okay";
> >  };
> >  
> > +&emac {
> > +	pinctrl-names = "default";
> > +	pinctrl-0 = <&emac_rgmii_pins>;
> > +	phy-supply = <&reg_gmac_3v3>;
> > +	phy-handle = <&ext_rgmii_phy>;
> > +	phy-mode = "rgmii";
> > +	status = "okay";
> > +};
> > +
> > +&mdio {
> > +	ext_rgmii_phy: ethernet-phy@7 {
> > +		compatible = "ethernet-phy-ieee802.3-c22";
> > +		reg = <7>;
> > +	};
> > +};
> > +
> 
> This won't compile, you don't have that node in the H5 DTSI.
> 

Since H5 DTSI include arm/sunxi-h3-h5.dtsi it compiles.
Furthermore, I restested just now and confirm, it compiles fine.

Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
