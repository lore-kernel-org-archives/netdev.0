From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH V2 01/12] net-next: mediatek: Document ralink/mediatek SoC
 ethernet binding
Date: Wed, 2 Mar 2016 19:49:42 +0100
Message-ID: <56D735C6.6090505@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
 <1456496504-50429-2-git-send-email-blogic@openwrt.org>
 <20160302184637.GA4042@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?RnJlZCBDaGFuZyAo5by15ZiJ5a6PKQ==?=
	<Fred.Chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	=?UTF-8?B?U3RldmVuIExpdSAo5YqJ5Lq66LGqKQ==?=
	<steven.liu-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?B?Q2FybG9zIEh1YW5nICjpu4Plo6vlvbAp?=
	<Carlos.Huang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160302184637.GA4042@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 02/03/2016 19:46, Rob Herring wrote:
> On Fri, Feb 26, 2016 at 03:21:33PM +0100, John Crispin wrote:
>> Add three files. One describes the actual frame engine, the other two
>> describe fast ethernet and gigabit switches bindings.
>>
>> Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
>> Signed-off-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
>> Signed-off-by: Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Does this reflect the order people worked on this? Your SoB typically 
> would be last.

yes it does and the series was NAK'ed so ignore this patch. i'll order
them differently in V3


> 
>> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> ---
>>  .../devicetree/bindings/net/mediatek-net-esw.txt   |   25 +++++
>>  .../devicetree/bindings/net/mediatek-net-gsw.txt   |   48 +++++++++
>>  .../devicetree/bindings/net/mediatek-net.txt       |  113 ++++++++++++++++++++
>>  3 files changed, 186 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-esw.txt
>>  create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
>>  create mode 100644 Documentation/devicetree/bindings/net/mediatek-net.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/mediatek-net-esw.txt b/Documentation/devicetree/bindings/net/mediatek-net-esw.txt
>> new file mode 100644
>> index 0000000..84c51a0
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/mediatek-net-esw.txt
>> @@ -0,0 +1,25 @@
>> +Ralink Fast Ethernet Embedded Switch
>> +====================================
>> +
>> +The ralink fast ethernet embedded switch can be found on Ralink and Mediatek
>> +SoCs (RT3x5x, RT5350, MT76x8).
>> +
>> +Required properties:
>> +- compatible: Should be "ralink,rt3050-esw"
>> +- reg: Address and length of the register set for the device
>> +- interrupts: Should contain the embedded switches interrupt
>> +
>> +Optional properties:
>> +- mediatek,led_polarity: override the active high/low settings of the leds
> 
> Don't use '_'.
> 
> This doesn't tell me what the polaritiy actually is.
> 
>> +- interrupt-parent: Should be the phandle for the interrupt controller
>> +  that services interrupts for this device
>> +
>> +Example:
>> +
>> +esw@10110000 {
>> +	compatible = "ralink,rt3050-esw";
>> +	reg = <0x10110000 8000>;
>> +
>> +	interrupt-parent = <&intc>;
>> +	interrupts = <17>;
>> +};
>> diff --git a/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt b/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
>> new file mode 100644
>> index 0000000..596b385
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
>> @@ -0,0 +1,48 @@
>> +Mediatek Gigabit Switch
>> +=======================
>> +
>> +The mediatek gigabit switch can be found on Mediatek SoCs.
>> +
>> +Required properties:
>> +- compatible: Should be "mediatek,mt7620-gsw", "mediatek,mt7621-gsw",
>> +  "mediatek,mt7623-gsw"
> 
> This is an OR condition? Formatting like this would be better:
> 
> Should be one of:
> 	"mediatek,mt7620-gsw"
> 	"mediatek,mt7621-gsw"
> 	"mediatek,mt7623-gsw"
> 
>> +- reg: Address and length of the register set for the device
>> +- interrupts: Should contain the gigabit switches interrupt
> 
> s/switches/switch's/
> 
>> +
>> +
>> +Additional required properties for ARM based SoCs:
> 
> Which ones are those? Describe in terms of compatible properties.
> 
>> +- mediatek,reset-pin: phandle describing the reset GPIO
>> +- clocks: the clocks used by the switch
>> +- clock-names: the names of the clocks listed in the clocks property
>> +  these should be "trgpll", "esw", "gp2", "gp1"
>> +- mt7530-supply: the phandle of the regulator used to power the switch
>> +- mediatek,pctl-regmap: phandle to the port control regmap. this is used to
>> +  setup the drive current
>> +
>> +
>> +Optional properties:
>> +- interrupt-parent: Should be the phandle for the interrupt controller
>> +  that services interrupts for this device
>> +
>> +Example:
>> +
>> +gsw: switch@1b100000 {
>> +	compatible = "mediatek,mt7623-gsw";
>> +	reg = <0 0x1b110000 0 0x300000>;
>> +
>> +	interrupt-parent = <&pio>;
>> +	interrupts = <168 IRQ_TYPE_EDGE_RISING>;
>> +
>> +	clocks = <&apmixedsys CLK_APMIXED_TRGPLL>,
>> +		 <&ethsys CLK_ETHSYS_ESW>,
>> +		 <&ethsys CLK_ETHSYS_GP2>,
>> +		 <&ethsys CLK_ETHSYS_GP1>;
>> +	clock-names = "trgpll", "esw", "gp2", "gp1";
>> +
>> +	mt7530-supply = <&mt6323_vpa_reg>;
>> +
>> +	mediatek,pctl-regmap = <&syscfg_pctl_a>;
>> +	mediatek,reset-pin = <&pio 15 0>;
>> +
>> +	status = "okay";
>> +};
>> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> new file mode 100644
>> index 0000000..f8c5747
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> @@ -0,0 +1,113 @@
>> +iMEdiatek Frame Engine Ethernet controller
> 
> typo?
> 
>> +=======================================
>> +
>> +The frame engine ethernet controller can be found on Ralink and Mediatek SoCs
>> +(RT288x, RT3x5x, RT366x, RT388x, rt5350, mt7620, mt7621, mt76x8).
>> +
>> +Depending on the SoC, there is a number of ports connected to the CPU port
>> +directly and/or via a (gigabit-)switch. Newer gigabit SoCs can support
>> +a dual MAC setup.
>> +
>> +* Ethernet controller node
>> +
>> +Required properties:
>> +- compatible: Should be one of "ralink,rt2880-eth", "ralink,rt3050-eth",
>> +  "ralink,rt3050-eth", "ralink,rt3883-eth", "ralink,rt5350-eth",
>> +  "mediatek,mt7620-eth", "mediatek,mt7621-eth", "mediatek,mt7623-eth"
> 
> Do one per line.
> 
>> +- reg: Address and length of the register set for the device
>> +- interrupts: Should contain the frame engines interrupt
>> +- mediatek,ethsys: phandle to the syscon node that handles the port setup
>> +
>> +Required properties for ARM based SoCs:
> 
> Which ones?
> 
>> +- clocks: the clock used by the core
>> +- clock-names: the names of the clock listed in the clocks property
>> +- power-domains: phandle the to power domain that the ethernet is part of
>> +
>> +Optional properties:
>> +- interrupt-parent: Should be the phandle for the interrupt controller
>> +  that services interrupts for this device
>> +- mediatek,switch : phandle pointing at the device node of the switch device
>> +
>> +
>> +* Ethernet port node for MT7620
>> +
>> +We need to define which physical port is wired and how it should be setup.
>> +
>> +Required properties:
>> +- compatible: Should be "mediatek,eth-port"
>> +- reg: The number of the physical port
>> +- phy-handle: reference to the node describing the phy
>> +
>> +
>> +* Ethernet MAC node - dual MAC SoCs only
>> +
>> +Required properties:
>> +- compatible: Should be "mediatek,eth-mac"
>> +- reg: The number of the MAC
>> +
>> +
>> +Example for singel MAC SoC:
> 
> s/singel/single/
> 
>> +
>> +mdio-bus {
>> +	status = "okay";
>> +
>> +	phy4: ethernet-phy@4 {
>> +		reg = <4>;
>> +		phy-mode = "rgmii";
>> +	};
>> +};
>> +
>> +eth: ethernet@10100000 {
>> +	compatible = "mediatek,mt7620-eth";
>> +	reg = <0x10100000 10000>;
>> +
>> +	#address-cells = <1>;
>> +	#size-cells = <0>;
>> +
>> +	interrupt-parent = <&cpuintc>;
>> +	interrupts = <5>;
>> +
>> +	mediatek,switch = <&gsw>;
>> +
>> +	port@4 {
>> +		status = "okay";
>> +		phy-mode = "rgmii";
>> +		phy-handle = <&phy4>;
>> +	};
>> +};
>> +
>> +
>> +Example for dual MAC SoC:
>> +
>> +eth: ethernet@1b100000 {
>> +	compatible = "mediatek,mt7623-eth";
>> +	reg = <0 0x1b100000 0 0x10000>;
>> +
>> +	clocks = <&topckgen CLK_TOP_ETHIF_SEL>;
>> +	clock-names = "ethif";
>> +
>> +	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
>> +	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
>> +
>> +	mediatek,ethsys = <&ethsys>;
>> +	mediatek,switch = <&gsw>;
>> +
>> +	#address-cells = <1>;
>> +	#size-cells = <0>;
>> +
>> +	status = "disabled";
>> +
>> +	gmac1: mac@0 {
>> +		compatible = "mediatek,eth-mac";
>> +		reg = <0>;
>> +
>> +		status = "okay";
> 
> The parent disabled and this enabled doesn't make sense. I'd just drop 
> status from examples.
> 
>> +	};
>> +
>> +	gmac2: mac@1 {
>> +		compatible = "mediatek,eth-mac";
>> +		reg = <1>;
>> +
>> +		status = "okay";
>> +	};
>> +};
>> -- 
>> 1.7.10.4
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> _______________________________________________
> Linux-mediatek mailing list
> Linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-mediatek
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
