From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v3 net-next 3/3] arm64: dts: marvell: Add ethernet switch definition for the ESPRESSObin
Date: Wed, 21 Dec 2016 10:41:09 +0100
Message-ID: <87lgv9ipqi.fsf@free-electrons.com>
References: <20161221090045.474-1-romain.perier@free-electrons.com>
        <20161221090045.474-4-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>
To: Romain Perier <romain.perier@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:54119 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757867AbcLUJlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 04:41:25 -0500
In-Reply-To: <20161221090045.474-4-romain.perier@free-electrons.com> (Romain
        Perier's message of "Wed, 21 Dec 2016 10:00:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Romain,
 
 On mer., déc. 21 2016, Romain Perier <romain.perier@free-electrons.com> wrote:

> This defines and enables the Marvell ethernet switch MVE886341 on the
> Marvell ESPRESSObin board.

This patch looks OK now.

Applied on mvebu/dt64-4.11

So you can remove it from you next version because I don't want this
patch will be applied through the netdev branch. Indeed I expect more
changes in this file for v4.11 and it will be easier to have the change
in a single branch to avoid the merge conflict.

Thanks,

Gregory


>
> Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
> ---
>
> Changes in v3:
>  - Changed the node switch0 to be at 1
>  - Removed reg=<1> from the mdio node, finally that's not required
>
> Changes in v2:
>  - EXPRESSObin -> ESPRESSObin
>  - phy nodes definition must contain the internal bus address after the @
>
>  .../boot/dts/marvell/armada-3720-espressobin.dts   | 66 ++++++++++++++++++++++
>  1 file changed, 66 insertions(+)
>
> diff --git a/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts b/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
> index 83178d9..12d9f65 100644
> --- a/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
> +++ b/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
> @@ -80,3 +80,69 @@
>  &usb3 {
>  	status = "okay";
>  };
> +
> +&mdio {
> +	switch0: switch0@1 {
> +		compatible = "marvell,mv88e6085";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		reg = <1>;
> +
> +		dsa,member = <0 0>;
> +
> +		ports {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			port@0 {
> +				reg = <0>;
> +				label = "cpu";
> +				ethernet = <&eth0>;
> +			};
> +
> +			port@1 {
> +				reg = <1>;
> +				label = "wan";
> +				phy-handle = <&switch0phy0>;
> +			};
> +
> +			port@2 {
> +				reg = <2>;
> +				label = "lan0";
> +				phy-handle = <&switch0phy1>;
> +			};
> +
> +			port@3 {
> +				reg = <3>;
> +				label = "lan1";
> +				phy-handle = <&switch0phy2>;
> +			};
> +
> +		};
> +
> +		mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			switch0phy0: switch0phy0@11 {
> +				reg = <0x11>;
> +			};
> +			switch0phy1: switch0phy1@12 {
> +				reg = <0x12>;
> +			};
> +			switch0phy2: switch0phy2@13 {
> +				reg = <0x13>;
> +			};
> +		};
> +	};
> +};
> +
> +&eth0 {
> +	phy-mode = "rgmii-id";
> +	status = "okay";
> +
> +	fixed-link {
> +		speed = <1000>;
> +		full-duplex;
> +	};
> +};
> -- 
> 2.9.3
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
