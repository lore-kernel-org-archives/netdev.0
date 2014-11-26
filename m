From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH 3/4] GMAC: dts: add gmac info for rk3288
Date: Wed, 26 Nov 2014 09:47:56 +0100
Message-ID: <2888396.enB18gaD2a@diego>
References: <1416906536-26158-1-git-send-email-roger.chen@rock-chips.com> <1773507.kOcjDCLbcs@diego> <54753FAD.8040908@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, mark.yao@rock-chips.com,
	eddie.cai@rock-chips.com
To: Roger <roger.chen@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54753FAD.8040908@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 26. November 2014, 10:49:17 schrieb Roger:
> On 2014/11/25 22:39, Heiko St=FCbner wrote:
> > Am Dienstag, 25. November 2014, 16:40:59 schrieb Sergei Shtylyov:
> >> Hello.
> >>=20
> >> On 11/25/2014 12:08 PM, Roger Chen wrote:
> >>> add gmac info in rk3288.dtsi for GMAC driver
> >>>=20
> >>> Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
> >>> ---
> >>>=20
> >>>    arch/arm/boot/dts/rk3288.dtsi |   59
> >>>    +++++++++++++++++++++++++++++++++++++++++ 1 file changed, 59
> >>>    insertions(+)
> >>>=20
> >>> diff --git a/arch/arm/boot/dts/rk3288.dtsi
> >>> b/arch/arm/boot/dts/rk3288.dtsi
> >>> index 0f50d5d..949675d 100644
> >>> --- a/arch/arm/boot/dts/rk3288.dtsi
> >>> +++ b/arch/arm/boot/dts/rk3288.dtsi
> >>=20
> >> [...]
> >>=20
> >>> @@ -490,6 +497,25 @@
> >>>=20
> >>>    		reg =3D <0xff740000 0x1000>;
> >>>    =09
> >>>    	};
> >>>=20
> >>> +	gmac: eth@ff290000 {
> >>>=20
> >>      Please name the node "ethernet@ff290000" to comply with the e=
PAPR
> >>=20
> >> standard.
> >>=20
> >>> +		compatible =3D "rockchip,rk3288-gmac";
> >>> +		reg =3D <0xff290000 0x10000>;
> >>> +		interrupts =3D <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;  /*irq=3D59*/
> >>> +		interrupt-names =3D "macirq";
> >>> +		rockchip,grf =3D <&grf>;
> >>> +		clocks =3D <&cru SCLK_MAC>, <&cru SCLK_MAC_PLL>,
> >>> +			<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
> >>> +			<&cru SCLK_MACREF>, <&cru SCLK_MACREF_OUT>,
> >>> +			<&cru ACLK_GMAC>, <&cru PCLK_GMAC>;
> >>> +		clock-names =3D "stmmaceth", "clk_mac_pll",
> >>> +			"mac_clk_rx", "mac_clk_tx",
> >>> +			"clk_mac_ref", "clk_mac_refout",
> >>> +			"aclk_mac", "pclk_mac";
> >>> +		phy-mode =3D "rgmii";
> >>> +		pinctrl-names =3D "default";
> >>> +		pinctrl-0 =3D <&rgmii_pin /*&rmii_pin*/>;
> >>>=20
> >>      Hm, pinctrl props in a .dtsi file? Those are usually board
> >>      dependent.
> >=20
> > yep, especially as there is a board-dependent selection needed of w=
hat to
> > use [rgmii or rmii] depending on the phy on the board.
>=20
> of course pinctrl props is redefined in the rk3288-evb-rk808.dts,
> IMO, pinctrl props in .dtsi is used to fit for the "phy-mode" prop as
> default. if pinctrl props should be removed, how about "phy-mode" pro=
p?

yep, the phy-mode should also move to the board file - as it of course =
also=20
depends on the phy-chip used there.
