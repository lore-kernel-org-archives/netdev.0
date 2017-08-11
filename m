From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/3] ARM: sun8i: sunxi-h3-h5: add phy-is-integrated property to internal PHY
Date: Fri, 11 Aug 2017 08:03:29 -0700
Message-ID: <302496B2-46F1-456D-A9A0-8257B5582695@gmail.com>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com> <20170810085129.20463-3-clabbe.montjoie@gmail.com> <CAGb2v64dBZgN6-8kHnnN1qiEXHnbXw_FM9WxGHPU0h-tZDbspA@mail.gmail.com> <20170811080543.GA25147@Red> <CAGb2v66wCRe8nFucJa5nAT1GhO75LmCyfNWQQbwxzh085Zwk+w@mail.gmail.com> <20170811081920.GB25147@Red> <CAGb2v66SGAKnFoHNqWR+DqS-mY3KA853NmKpdHqf8huOkisLKg@mail.gmail.com> <20170811132526.GD25147@Red>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        andrew@lunn.ch
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, robh+dt@kernel.org,
        mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38445 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752631AbdHKPDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 11:03:34 -0400
In-Reply-To: <20170811132526.GD25147@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On August 11, 2017 6:25:26 AM PDT, Corentin Labbe <clabbe=2Emontjoie@gmail=
=2Ecom> wrote:
>On Fri, Aug 11, 2017 at 04:22:11PM +0800, Chen-Yu Tsai wrote:
>> On Fri, Aug 11, 2017 at 4:19 PM, Corentin Labbe
>> <clabbe=2Emontjoie@gmail=2Ecom> wrote:
>> > On Fri, Aug 11, 2017 at 04:11:13PM +0800, Chen-Yu Tsai wrote:
>> >> On Fri, Aug 11, 2017 at 4:05 PM, Corentin Labbe
>> >> <clabbe=2Emontjoie@gmail=2Ecom> wrote:
>> >> > On Fri, Aug 11, 2017 at 10:42:51AM +0800, Chen-Yu Tsai wrote:
>> >> >> Hi,
>> >> >>
>> >> >> On Thu, Aug 10, 2017 at 4:51 PM, Corentin Labbe
>> >> >> <clabbe=2Emontjoie@gmail=2Ecom> wrote:
>> >> >> > This patch add the new phy-is-integrated property to the
>internal PHY
>> >> >> > node=2E
>> >> >> >
>> >> >> > Signed-off-by: Corentin Labbe <clabbe=2Emontjoie@gmail=2Ecom>
>> >> >> > ---
>> >> >> >  arch/arm/boot/dts/sunxi-h3-h5=2Edtsi | 1 +
>> >> >> >  1 file changed, 1 insertion(+)
>> >> >> >
>> >> >> > diff --git a/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>b/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>> >> >> > index 4b599b5d26f6=2E=2E54fc24e4c569 100644
>> >> >> > --- a/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>> >> >> > +++ b/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>> >> >> > @@ -425,6 +425,7 @@
>> >> >> >                                         reg =3D <1>;
>> >> >> >                                         clocks =3D <&ccu
>CLK_BUS_EPHY>;
>> >> >> >                                         resets =3D <&ccu
>RST_BUS_EPHY>;
>> >> >> > +                                       phy-is-integrated;
>> >> >>
>> >> >> You also need to "delete" this property at the board level for
>> >> >> any board that has the external PHY at address <1>=2E Otherwise
>> >> >> they will stop working=2E This is due to the internal and
>external
>> >> >> PHYs having the same path and node name in the device tree, so
>> >> >> they are effectively the same node=2E
>> >> >>
>> >> >> ChenYu
>> >> >>
>> >> >
>> >> > They have not the same name, ext_rgmii_phy vs int_mii_phy=2E
>> >>
>> >> That is just the label=2E The label plays no part in device tree
>merging=2E The path
>> >>
>> >>     /soc/ethernet@1c30000/mdio/ethernet-phy@1
>> >>
>> >> is the same=2E You can look under
>> >>
>> >>     /proc/device-tree/soc/ethernet@1c30000/mdio
>> >>
>> >> on the OrangePI Plus 2E or any other H3 board that uses an
>> >> external PHY at address 1=2E
>> >>
>> >> ChenYu
>> >
>> > Since we get the phy node by phy-handle and not by path, I think
>all should be good=2E
>>=20
>> You are not getting me=2E The fact that the two seemingly separate
>> nodes are merged together means, whatever properties you put in
>> the internal PHY node, also affect the external PHY node=2E Once
>> compiled, they are the SAME node=2E
>
>Hello Rob, florian, mark
>
>Adding a delete property on all external ethernet-phy@1 is a bit
>overkill, and I dont like the idea that nodes are merged=2E

This is not exactly up to you that's just how DTC works=2E

>What do you think about other possible solutions:
>- Using integrated-phy@1 for the integrated PHY node name

That might be okay although you are using now a seemingly non-standard uni=
t name=2E

>- Using a fake address like 31 (see patch below)

You could also drop the address part in the unit name although we'd probab=
ly get a DTC warning for that=2E

I suspect both of your solutions and what I mentioned above will be produc=
ing DTC warnings to some extent=2E=2E=2E Rob what do you think?


>
>If you have any other solution=2E=2E=2E
>
>Regards
>
>From fe39183946f7f4a6e21bce38fd8e4c1413012d68 Mon Sep 17 00:00:00 2001
>From: Corentin Labbe <clabbe=2Emontjoie@gmail=2Ecom>
>Date: Fri, 11 Aug 2017 14:49:54 +0200
>Subject: [PATCH] ARM: sun8i: sunxi-h3-h5: Prevent merge of external and
> integrated PHY
>
>Actually, some external and integrated PHY are merged due to same
>dtnode
>name "ethernet-phy@1"=2E
>
>This is problematic when we will want to use the phy-is-integrated
>property=2E (Need to delete it on all external PHY node)
>
>An easy solution is to set integrated PHY nodeaddresss at a fake one
>that would never be used=2E
>Since board makers currently only provides PHY at addresses 1 and 7,
>we will use 31=2E
>
>Signed-off-by: Corentin Labbe <clabbe=2Emontjoie@gmail=2Ecom>
>---
> arch/arm/boot/dts/sunxi-h3-h5=2Edtsi | 10 +++++++++-
> 1 file changed, 9 insertions(+), 1 deletion(-)
>
>diff --git a/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>b/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>index 54fc24e4c569=2E=2E2110b0069e33 100644
>--- a/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>+++ b/arch/arm/boot/dts/sunxi-h3-h5=2Edtsi
>@@ -420,7 +420,15 @@
> 			mdio: mdio {
> 				#address-cells =3D <1>;
> 				#size-cells =3D <0>;
>-				int_mii_phy: ethernet-phy@1 {
>+				/*
>+				 * Using 31 permits to make a separation between
>+				 * this integrated PHY and external ones=2E
>+				 * Without it, external "ethernet-phy@1" will be
>+				 * merged with it (due to same dtnode name)=2E
>+				 * Board makers currently only provides PHY at
>+				 * addresses 1 and 7=2E
>+				 */
>+				int_mii_phy: ethernet-phy@31 {
> 					compatible =3D "ethernet-phy-ieee802=2E3-c22";
> 					reg =3D <1>;
> 					clocks =3D <&ccu CLK_BUS_EPHY>;


--=20
Florian
