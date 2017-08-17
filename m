From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/3] ARM: sun8i: sunxi-h3-h5: add phy-is-integrated
 property to internal PHY
Date: Thu, 17 Aug 2017 10:10:54 -0500
Message-ID: <20170817151054.7v5pvyq4h4i2vmm4@rob-hp-laptop>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
 <20170810085129.20463-3-clabbe.montjoie@gmail.com>
 <CAGb2v64dBZgN6-8kHnnN1qiEXHnbXw_FM9WxGHPU0h-tZDbspA@mail.gmail.com>
 <20170811080543.GA25147@Red>
 <CAGb2v66wCRe8nFucJa5nAT1GhO75LmCyfNWQQbwxzh085Zwk+w@mail.gmail.com>
 <20170811081920.GB25147@Red>
 <CAGb2v66SGAKnFoHNqWR+DqS-mY3KA853NmKpdHqf8huOkisLKg@mail.gmail.com>
 <20170811132526.GD25147@Red>
 <302496B2-46F1-456D-A9A0-8257B5582695@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, mark.rutland@arm.com,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <302496B2-46F1-456D-A9A0-8257B5582695@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2017 at 08:03:29AM -0700, Florian Fainelli wrote:
> On August 11, 2017 6:25:26 AM PDT, Corentin Labbe <clabbe.montjoie@gmail.com> wrote:
> >On Fri, Aug 11, 2017 at 04:22:11PM +0800, Chen-Yu Tsai wrote:
> >> On Fri, Aug 11, 2017 at 4:19 PM, Corentin Labbe
> >> <clabbe.montjoie@gmail.com> wrote:
> >> > On Fri, Aug 11, 2017 at 04:11:13PM +0800, Chen-Yu Tsai wrote:
> >> >> On Fri, Aug 11, 2017 at 4:05 PM, Corentin Labbe
> >> >> <clabbe.montjoie@gmail.com> wrote:
> >> >> > On Fri, Aug 11, 2017 at 10:42:51AM +0800, Chen-Yu Tsai wrote:
> >> >> >> Hi,
> >> >> >>
> >> >> >> On Thu, Aug 10, 2017 at 4:51 PM, Corentin Labbe
> >> >> >> <clabbe.montjoie@gmail.com> wrote:
> >> >> >> > This patch add the new phy-is-integrated property to the
> >internal PHY
> >> >> >> > node.
> >> >> >> >
> >> >> >> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> >> >> >> > ---
> >> >> >> >  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 1 +
> >> >> >> >  1 file changed, 1 insertion(+)
> >> >> >> >
> >> >> >> > diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> >> > index 4b599b5d26f6..54fc24e4c569 100644
> >> >> >> > --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> >> > +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> >> >> >> > @@ -425,6 +425,7 @@
> >> >> >> >                                         reg = <1>;
> >> >> >> >                                         clocks = <&ccu
> >CLK_BUS_EPHY>;
> >> >> >> >                                         resets = <&ccu
> >RST_BUS_EPHY>;
> >> >> >> > +                                       phy-is-integrated;
> >> >> >>
> >> >> >> You also need to "delete" this property at the board level for
> >> >> >> any board that has the external PHY at address <1>. Otherwise
> >> >> >> they will stop working. This is due to the internal and
> >external
> >> >> >> PHYs having the same path and node name in the device tree, so
> >> >> >> they are effectively the same node.
> >> >> >>
> >> >> >> ChenYu
> >> >> >>
> >> >> >
> >> >> > They have not the same name, ext_rgmii_phy vs int_mii_phy.
> >> >>
> >> >> That is just the label. The label plays no part in device tree
> >merging. The path
> >> >>
> >> >>     /soc/ethernet@1c30000/mdio/ethernet-phy@1
> >> >>
> >> >> is the same. You can look under
> >> >>
> >> >>     /proc/device-tree/soc/ethernet@1c30000/mdio
> >> >>
> >> >> on the OrangePI Plus 2E or any other H3 board that uses an
> >> >> external PHY at address 1.
> >> >>
> >> >> ChenYu
> >> >
> >> > Since we get the phy node by phy-handle and not by path, I think
> >all should be good.
> >> 
> >> You are not getting me. The fact that the two seemingly separate
> >> nodes are merged together means, whatever properties you put in
> >> the internal PHY node, also affect the external PHY node. Once
> >> compiled, they are the SAME node.
> >
> >Hello Rob, florian, mark
> >
> >Adding a delete property on all external ethernet-phy@1 is a bit
> >overkill, and I dont like the idea that nodes are merged.
> 
> This is not exactly up to you that's just how DTC works.
> 
> >What do you think about other possible solutions:
> >- Using integrated-phy@1 for the integrated PHY node name
> 
> That might be okay although you are using now a seemingly non-standard unit name.
> 
> >- Using a fake address like 31 (see patch below)
> 
> You could also drop the address part in the unit name although we'd probably get a DTC warning for that.
> 
> I suspect both of your solutions and what I mentioned above will be producing DTC warnings to some extent... Rob what do you think?

If you have 2 devices at the same address, then there is some mux in the 
middle. Describe that and you problems should be solved. The internal 
phy is always there, so it should be able to always be in the DT.

Rob
