From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH 2/3] ARM: sun8i: sunxi-h3-h5: add phy-is-integrated
 property to internal PHY
Date: Fri, 11 Aug 2017 16:22:11 +0800
Message-ID: <CAGb2v66SGAKnFoHNqWR+DqS-mY3KA853NmKpdHqf8huOkisLKg@mail.gmail.com>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
 <20170810085129.20463-3-clabbe.montjoie@gmail.com> <CAGb2v64dBZgN6-8kHnnN1qiEXHnbXw_FM9WxGHPU0h-tZDbspA@mail.gmail.com>
 <20170811080543.GA25147@Red> <CAGb2v66wCRe8nFucJa5nAT1GhO75LmCyfNWQQbwxzh085Zwk+w@mail.gmail.com>
 <20170811081920.GB25147@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170811081920.GB25147@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2017 at 4:19 PM, Corentin Labbe
<clabbe.montjoie@gmail.com> wrote:
> On Fri, Aug 11, 2017 at 04:11:13PM +0800, Chen-Yu Tsai wrote:
>> On Fri, Aug 11, 2017 at 4:05 PM, Corentin Labbe
>> <clabbe.montjoie@gmail.com> wrote:
>> > On Fri, Aug 11, 2017 at 10:42:51AM +0800, Chen-Yu Tsai wrote:
>> >> Hi,
>> >>
>> >> On Thu, Aug 10, 2017 at 4:51 PM, Corentin Labbe
>> >> <clabbe.montjoie@gmail.com> wrote:
>> >> > This patch add the new phy-is-integrated property to the internal PHY
>> >> > node.
>> >> >
>> >> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
>> >> > ---
>> >> >  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 1 +
>> >> >  1 file changed, 1 insertion(+)
>> >> >
>> >> > diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> >> > index 4b599b5d26f6..54fc24e4c569 100644
>> >> > --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> >> > +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> >> > @@ -425,6 +425,7 @@
>> >> >                                         reg = <1>;
>> >> >                                         clocks = <&ccu CLK_BUS_EPHY>;
>> >> >                                         resets = <&ccu RST_BUS_EPHY>;
>> >> > +                                       phy-is-integrated;
>> >>
>> >> You also need to "delete" this property at the board level for
>> >> any board that has the external PHY at address <1>. Otherwise
>> >> they will stop working. This is due to the internal and external
>> >> PHYs having the same path and node name in the device tree, so
>> >> they are effectively the same node.
>> >>
>> >> ChenYu
>> >>
>> >
>> > They have not the same name, ext_rgmii_phy vs int_mii_phy.
>>
>> That is just the label. The label plays no part in device tree merging. The path
>>
>>     /soc/ethernet@1c30000/mdio/ethernet-phy@1
>>
>> is the same. You can look under
>>
>>     /proc/device-tree/soc/ethernet@1c30000/mdio
>>
>> on the OrangePI Plus 2E or any other H3 board that uses an
>> external PHY at address 1.
>>
>> ChenYu
>
> Since we get the phy node by phy-handle and not by path, I think all should be good.

You are not getting me. The fact that the two seemingly separate
nodes are merged together means, whatever properties you put in
the internal PHY node, also affect the external PHY node. Once
compiled, they are the SAME node.
