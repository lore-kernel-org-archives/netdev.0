From: Roger <roger.chen@rock-chips.com>
Subject: Re: [PATCH 3/4] GMAC: dts: add gmac info for rk3288
Date: Wed, 26 Nov 2014 10:49:17 +0800
Message-ID: <54753FAD.8040908@rock-chips.com>
References: <1416906536-26158-1-git-send-email-roger.chen@rock-chips.com> <547486EB.5080702@cogentembedded.com> <1773507.kOcjDCLbcs@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, mark.yao@rock-chips.com,
	eddie.cai@rock-chips.com
To: =?windows-1252?Q?Heiko_St=FCbner?= <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1773507.kOcjDCLbcs@diego>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2014/11/25 22:39, Heiko St=FCbner wrote:
> Am Dienstag, 25. November 2014, 16:40:59 schrieb Sergei Shtylyov:
>> Hello.
>>
>> On 11/25/2014 12:08 PM, Roger Chen wrote:
>>> add gmac info in rk3288.dtsi for GMAC driver
>>>
>>> Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
>>> ---
>>>
>>>    arch/arm/boot/dts/rk3288.dtsi |   59
>>>    +++++++++++++++++++++++++++++++++++++++++ 1 file changed, 59
>>>    insertions(+)
>>>
>>> diff --git a/arch/arm/boot/dts/rk3288.dtsi b/arch/arm/boot/dts/rk32=
88.dtsi
>>> index 0f50d5d..949675d 100644
>>> --- a/arch/arm/boot/dts/rk3288.dtsi
>>> +++ b/arch/arm/boot/dts/rk3288.dtsi
>> [...]
>>
>>> @@ -490,6 +497,25 @@
>>>
>>>    		reg =3D <0xff740000 0x1000>;
>>>    =09
>>>    	};
>>>
>>> +	gmac: eth@ff290000 {
>>      Please name the node "ethernet@ff290000" to comply with the ePA=
PR
>> standard.
>>> +		compatible =3D "rockchip,rk3288-gmac";
>>> +		reg =3D <0xff290000 0x10000>;
>>> +		interrupts =3D <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;  /*irq=3D59*/
>>> +		interrupt-names =3D "macirq";
>>> +		rockchip,grf =3D <&grf>;
>>> +		clocks =3D <&cru SCLK_MAC>, <&cru SCLK_MAC_PLL>,
>>> +			<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
>>> +			<&cru SCLK_MACREF>, <&cru SCLK_MACREF_OUT>,
>>> +			<&cru ACLK_GMAC>, <&cru PCLK_GMAC>;
>>> +		clock-names =3D "stmmaceth", "clk_mac_pll",
>>> +			"mac_clk_rx", "mac_clk_tx",
>>> +			"clk_mac_ref", "clk_mac_refout",
>>> +			"aclk_mac", "pclk_mac";
>>> +		phy-mode =3D "rgmii";
>>> +		pinctrl-names =3D "default";
>>> +		pinctrl-0 =3D <&rgmii_pin /*&rmii_pin*/>;
>>      Hm, pinctrl props in a .dtsi file? Those are usually board depe=
ndent.
> yep, especially as there is a board-dependent selection needed of wha=
t to use
> [rgmii or rmii] depending on the phy on the board.

of course pinctrl props is redefined in the rk3288-evb-rk808.dts,
IMO, pinctrl props in .dtsi is used to fit for the "phy-mode" prop as d=
efault.
if pinctrl props should be removed, how about "phy-mode" prop?

>> [...]
>>
>>> @@ -1040,5 +1066,38 @@
>>>
>>>    				rockchip,pins =3D <7 23 3 &pcfg_pull_none>;
>>>    		=09
>>>    			};
>>>    	=09
>>>    		};
>>>
>>> +
>>> +		gmac {
>>> +			rgmii_pin: rgmii-pins {
> please add the "s" to the label - "rgmii_pins"
>
>
>>> +				rockchip,pins =3D <3 30 3 &pcfg_pull_none>,
>>> +						<3 31 3 &pcfg_pull_none>,
>>> +						<3 26 3 &pcfg_pull_none>,
>>> +						<3 27 3 &pcfg_pull_none>,
>>> +						<3 28 3 &pcfg_pull_none>,
>>> +						<3 29 3 &pcfg_pull_none>,
>>> +						<3 24 3 &pcfg_pull_none>,
>>> +						<3 25 3 &pcfg_pull_none>,
>>> +						<4 0 3 &pcfg_pull_none>,
>>> +						<4 5 3 &pcfg_pull_none>,
>>> +						<4 6 3 &pcfg_pull_none>,
>>> +						<4 9 3 &pcfg_pull_none>,
>>> +						<4 4 3 &pcfg_pull_none>,
>>> +						<4 1 3 &pcfg_pull_none>,
>>> +						<4 3 3 &pcfg_pull_none>;
>>> +			};
>>> +
>>> +			rmii_pin: rmii-pins {
> same here
>
>
>>> +				rockchip,pins =3D <3 30 3 &pcfg_pull_none>,
>>> +						<3 31 3 &pcfg_pull_none>,
>>> +						<3 28 3 &pcfg_pull_none>,
>>> +						<3 29 3 &pcfg_pull_none>,
>>> +						<4 0 3 &pcfg_pull_none>,
>>> +						<4 5 3 &pcfg_pull_none>,
>>> +						<4 4 3 &pcfg_pull_none>,
>>> +						<4 1 3 &pcfg_pull_none>,
>>> +						<4 2 3 &pcfg_pull_none>,
>>> +						<4 3 3 &pcfg_pull_none>;
>>> +			};
>>> +		};
>>      These are usually define in the board .dts file...
> The pinctrl settings itself are soc-specific, i.e. the pins and their=
 settings
> to use to enable r{g}mii functionality are the same for all boards us=
ing this
> soc, so the pinctrl definitions should stay here and not be redefined=
 in each
> and every board file.
>
>
> Heiko
>
>
>
