From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear
 WNR854T
Date: Sun, 17 Jul 2016 15:51:24 -0500
Message-ID: <20160717205124.GA18838@rob-hp-laptop>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jamie Lentin <jm@lentin.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33092 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcGQUv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 16:51:28 -0400
Content-Disposition: inline
In-Reply-To: <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 16, 2016 at 03:29:04PM +0100, Jamie Lentin wrote:
> This is a router based on the mv88f5181 chipset.
> 
> http://www.netgear.com/support/product/WNR854T.aspx
> http://wiki.openwrt.org/toh/netgear/wnr854t
> 
> Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
> ---
>  .../bindings/arm/marvell/marvell,orion5x.txt       |   1 +
>  arch/arm/boot/dts/Makefile                         |   1 +
>  arch/arm/boot/dts/orion5x-netgear-wnr854t.dts      | 200 +++++++++++++++++++++
>  arch/arm/mach-orion5x/Kconfig                      |   6 +
>  arch/arm/mach-orion5x/Makefile                     |   1 +
>  arch/arm/mach-orion5x/board-wnr854t.c              |  78 ++++++++
>  6 files changed, 287 insertions(+)
>  create mode 100644 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
>  create mode 100644 arch/arm/mach-orion5x/board-wnr854t.c
> 
> diff --git a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> index ff3c120..748a8f2 100644
> --- a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> +++ b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
> @@ -22,3 +22,4 @@ board. Currently known boards are:
>  "lacie,d2-network"
>  "marvell,rd-88f5182-nas"
>  "maxtor,shared-storage-2"
> +"netgear,wnr854t"
> diff --git a/arch/arm/boot/dts/Makefile b/arch/arm/boot/dts/Makefile
> index 95c1923..63b9202 100644
> --- a/arch/arm/boot/dts/Makefile
> +++ b/arch/arm/boot/dts/Makefile
> @@ -535,6 +535,7 @@ dtb-$(CONFIG_ARCH_ORION5X) += \
>  	orion5x-linkstation-lswtgl.dtb \
>  	orion5x-lswsgl.dtb \
>  	orion5x-maxtor-shared-storage-2.dtb \
> +	orion5x-netgear-wnr854t.dtb \
>  	orion5x-rd88f5182-nas.dtb
>  dtb-$(CONFIG_ARCH_PRIMA2) += \
>  	prima2-evb.dtb
> diff --git a/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
> new file mode 100644
> index 0000000..a8e89d8
> --- /dev/null
> +++ b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
> @@ -0,0 +1,200 @@
> +/*
> + * Copyright (C) 2014 Jamie Lentin <jm@lentin.co.uk>

It's 2016 now.

> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +/dts-v1/;
> +
> +#include <dt-bindings/gpio/gpio.h>
> +#include <dt-bindings/input/input.h>
> +#include "orion5x-mv88f5181.dtsi"
> +
> +/ {
> +	model = "Netgear WNR854-t";
> +	compatible = "netgear,wnr854t", "marvell,orion5x-88f5181",
> +			"marvell,orion5x";
> +
> +	memory {
> +		reg = <0x00000000 0x2000000>; /* 32 MB */
> +	};
> +
> +	chosen {
> +		bootargs = "console=ttyS0,115200n8 earlyprintk";
> +		linux,stdout-path = &uart0;

As kind of mentioned, drop the linux prefix here.

> +	};
> +
> +	soc {
> +		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000>,
> +			<MBUS_ID(0x09, 0x00) 0 0xf2200000 0x800>,
> +			<MBUS_ID(0x01, 0x0f) 0 0xf4000000 0x800000>;
> +	};
> +
> +	gpio-keys {
> +		compatible = "gpio-keys";
> +		pinctrl-0 = <&pmx_reset_switch>;
> +		pinctrl-names = "default";
> +
> +		reset {
> +			label = "Reset Button";
> +			linux,code = <KEY_RESTART>;
> +			gpios = <&gpio0 1 GPIO_ACTIVE_LOW>;
> +		};
> +	};
> +
> +	gpio-leds {
> +		compatible = "gpio-leds";
> +		pinctrl-0 = <&pmx_power_led &pmx_power_led_blink &pmx_wan_led>;
> +		pinctrl-names = "default";
> +
> +		led@0 {
> +			label = "power:green";
> +			gpios = <&gpio0 0 GPIO_ACTIVE_LOW>;
> +		};
> +
> +		led@1 {
> +			label = "power:blink";
> +			gpios = <&gpio0 2 GPIO_ACTIVE_LOW>;
> +		};
> +
> +		led@2 {
> +			label = "wan:green";
> +			gpios = <&gpio0 3 GPIO_ACTIVE_LOW>;
> +		};
> +	};
> +
> +	dsa@0 {
> +		compatible = "marvell,dsa";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		dsa,ethernet = <&ethport>;
> +		dsa,mii-bus = <&mdio>;
> +
> +		switch@0 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
> +
> +			port@0 {
> +				reg = <0>;
> +				label = "lan3";
> +			};
> +
> +			port@1 {
> +				reg = <1>;
> +				label = "lan4";
> +			};
> +
> +			port@2 {
> +				reg = <2>;
> +				label = "wan";
> +			};
> +
> +			port@3 {
> +				reg = <3>;
> +				label = "cpu";
> +			};
> +
> +			port@5 {
> +				reg = <5>;
> +				label = "lan1";
> +			};
> +
> +			port@7 {
> +				reg = <7>;
> +				label = "lan2";
> +			};
> +		};
> +	};
> +};
> +
> +&devbus_bootcs {
> +	status = "okay";
> +
> +	devbus,keep-config;
> +
> +	flash@0 {
> +		compatible = "cfi-flash";
> +		reg = <0 0x800000>;
> +		bank-width = <1>;
> +		#address-cells = <1>;
> +		#size-cells = <1>;
> +
> +		partition@0 {

The new recommended style adds a level here with a partitions node and 
the type of partitioning.

> +			label = "kernel";
> +			reg = <0x0 0x100000>;
> +		};
> +
> +		partition@100000 {
> +			label = "rootfs";
> +			reg = <0x100000 0x660000>;
> +		};
> +
> +		partition@760000 {
> +			label = "uboot_env";
> +			reg = <0x760000 0x20000>;
> +		};
> +
> +		partition@780000 {
> +			label = "uboot";
> +			reg = <0x780000 0x80000>;
> +			read-only;
> +		};
> +	};
> +};
> +
> +&mdio {
> +	status = "okay";
> +};
> +
> +&eth {
> +	status = "okay";
> +	ethernet-port@0 {
> +		speed = <1000>;
> +		duplex = <1>;
> +	};
> +};
> +
> +&pinctrl {
> +	pinctrl-0 = <&pmx_pci_gpios &pmx_ge>;
> +	pinctrl-names = "default";
> +
> +	pmx_power_led: pmx-power-led {
> +		marvell,pins = "mpp0";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_reset_switch: pmx-reset-switch {
> +		marvell,pins = "mpp1";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_power_led_blink: pmx-power-led-blink {
> +		marvell,pins = "mpp2";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_wan_led: pmx-wan-led {
> +		marvell,pins = "mpp3";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_pci_gpios: pmx-pci-gpios {
> +		marvell,pins = "mpp4";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_ge: pmx-ge {
> +		marvell,pins = "mpp9", "mpp12",	"mpp13", "mpp14", "mpp15",
> +				"mpp16", "mpp17", "mpp18", "mpp19";
> +		marvell,function = "ge";
> +	};
> +};
> +
> +&uart0 {
> +	/* Pin 1: Tx, Pin 7: Rx, Pin 8: Gnd */
> +	status = "okay";
> +};
> diff --git a/arch/arm/mach-orion5x/Kconfig b/arch/arm/mach-orion5x/Kconfig
> index a2af158..1fdb95d 100644
> --- a/arch/arm/mach-orion5x/Kconfig
> +++ b/arch/arm/mach-orion5x/Kconfig
> @@ -151,6 +151,12 @@ config MACH_MSS2_DT
>  	  Say 'Y' here if you want your kernel to support the
>  	  Maxtor Shared Storage II platform.
>  
> +config MACH_WNR854T_DT

There should only be at most 1 kconfig entry for all orion5x DT based 
platforms.

> +	bool "Netgear WNR854T (Flattened Device Tree)"
> +	help
> +	  Say 'Y' here if you want your kernel to support the
> +	  Netgear WNR854T platform.
> +
>  config MACH_WNR854T
>  	bool "Netgear WNR854T"
>  	help
