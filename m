From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 01/10] arm64: dts: allwinner: Restore EMAC changes
Date: Sun, 10 Sep 2017 20:56:40 +0200
Message-ID: <20170910185640.GA17417@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-2-clabbe.montjoie@gmail.com>
 <20170908071954.j2bhtw4wqa27fald@flea.lan>
 <20170908073657.GA29999@Red>
 <CAGb2v64K3XTLJwZwYmq3r64=3_bHHGTeGyC0gfoJfL5+Ty53ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v64K3XTLJwZwYmq3r64=3_bHHGTeGyC0gfoJfL5+Ty53ag-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 03:39:04PM +0800, Chen-Yu Tsai wrote:
> On Fri, Sep 8, 2017 at 3:36 PM, Corentin Labbe
> <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Fri, Sep 08, 2017 at 09:19:54AM +0200, Maxime Ripard wrote:
> >> On Fri, Sep 08, 2017 at 09:11:47AM +0200, Corentin Labbe wrote:
> >> > diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> >> > index 1c2387bd5df6..968908761194 100644
> >> > --- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> >> > +++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> >> > @@ -50,6 +50,7 @@
> >> >     compatible = "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
> >> >
> >> >     aliases {
> >> > +           ethernet0 = &emac;
> >> >             serial0 = &uart0;
> >> >     };
> >> >
> >> > @@ -108,6 +109,22 @@
> >> >     status = "okay";
> >> >  };
> >> >
> >> > +&emac {
> >> > +   pinctrl-names = "default";
> >> > +   pinctrl-0 = <&emac_rgmii_pins>;
> >> > +   phy-supply = <&reg_gmac_3v3>;
> >> > +   phy-handle = <&ext_rgmii_phy>;
> >> > +   phy-mode = "rgmii";
> >> > +   status = "okay";
> >> > +};
> >> > +
> >> > +&mdio {
> >> > +   ext_rgmii_phy: ethernet-phy@7 {
> >> > +           compatible = "ethernet-phy-ieee802.3-c22";
> >> > +           reg = <7>;
> >> > +   };
> >> > +};
> >> > +
> >>
> >> This won't compile, you don't have that node in the H5 DTSI.
> >>
> >
> > Since H5 DTSI include arm/sunxi-h3-h5.dtsi it compiles.
> > Furthermore, I restested just now and confirm, it compiles fine.
> 
> The order of your patches are wrong. No individual patch should
> introduce build failures, not just the whole patch series.
> 

Yes, I just miss-understood the reason of build failure.
I will fix the order in the next serie.

Thanks
Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
