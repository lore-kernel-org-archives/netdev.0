From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 2/3] dt-binding: net: sfp binding documentation
Date: Mon, 4 Sep 2017 13:16:26 -0700
Message-ID: <5df7f2f5-04f7-85b1-4a53-935360001b7c@gmail.com>
References: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
 <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Baruch Siach <baruch@tkos.co.il>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36140 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753968AbdIDUQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 16:16:31 -0400
In-Reply-To: <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/03/17 à 05:31, Baruch Siach a écrit :
> Add device-tree binding documentation SFP transceivers. Support for SFP
> transceivers has been recently introduced (drivers/net/phy/sfp.c).
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
> v3:
>   Mention gpios phandle and specifier
>   Mention the polarity of each gpio
>   Fix example property names
> 
> v2:
>   Rename -gpio properties to -gpios
>   Rename the rate-select-gpio property to rate-select0-gpios
>   Add the rate-select1-gpios property
>   Add examples
> ---
>  Documentation/devicetree/bindings/net/sff,sfp.txt | 78 +++++++++++++++++++++++
>  1 file changed, 78 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> new file mode 100644
> index 000000000000..b98ee5945265
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> @@ -0,0 +1,78 @@
> +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> +Transceiver
> +
> +Required properties:
> +
> +- compatible : must be "sff,sfp"
> +
> +Optional Properties:
> +
> +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> +  interface
> +
> +- moddef0-gpios : GPIO phandle and a single specifier of the MOD-DEF0 (AKA
> +  Mod_ABS) module presence input gpio signal, active (module absent) high

Sorry for nitpicking on this, why are not we naming this mod-def0-gpios
which would be consistent with how other GPIOs are named?

> +
> +- los-gpios : GPIO phandle and a single specifier of the Receiver Loss of
> +  Signal Indication input gpio signal, active (signal lost) high
> +
> +- tx-fault-gpios : GPIO phandle and a single specifier of the Module
> +  Transmitter Fault input gpio signal, active (fault condition) high
> +
> +- tx-disable-gpios : GPIO phandle and a single specifier of the Transmitter
> +  Disable output gpio signal, active (Tx disable) high
> +
> +- rate-select0-gpios : GPIO phandle and a single specifier of the Rx Signaling
> +  Rate Select (AKA RS0) output gpio signal, low: low Rx rate, high: high Rx
> +  rate
> +
> +- rate-select1-gpios : GPIO phandle and a single specifier of the Tx Signaling
> +  Rate Select (AKA RS1) output gpio signal (SFP+ only), low: low Tx rate,
> +  high: high Tx rate
> +
> +Example #1: Direct serdes to SFP connection
> +
> +sfp_eth3: sfp-eth3 {
> +	compatible = "sff,sfp";
> +	i2c-bus = <&sfp_1g_i2c>;
> +	los-gpios = <&cpm_gpio2 22 GPIO_ACTIVE_HIGH>;
> +	moddef0-gpios = <&cpm_gpio2 21 GPIO_ACTIVE_LOW>;
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&cpm_sfp_1g_pins &cps_sfp_1g_pins>;
> +	tx-disable-gpios = <&cps_gpio1 24 GPIO_ACTIVE_HIGH>;
> +	tx-fault-gpios = <&cpm_gpio2 19 GPIO_ACTIVE_HIGH>;
> +};
> +
> +&cps_emac3 {
> +	phy-mode = "sgmii";
> +	phy-names = "comphy";
> +	phys = <&cps_comphy 5 COMPHY_SGMII2>;
> +	sfp = <&sfp_eth3>;
> +};
> +
> +Example #2: Serdes to PHY to SFP connection
> +
> +sfp_eth0: sfp-eth0 {
> +	compatible = "sff,sfp+";
> +	i2c-bus = <&sfpp0_i2c>;
> +	los-gpios = <&cps_gpio1 28 GPIO_ACTIVE_HIGH>;
> +	moddef0-gpios = <&cps_gpio1 27 GPIO_ACTIVE_LOW>;
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&cps_sfpp0_pins>;
> +	tx-disable-gpios = <&cps_gpio1 29 GPIO_ACTIVE_HIGH>;
> +	tx-fault-gpios  = <&cps_gpio1 26 GPIO_ACTIVE_HIGH>;
> +};
> +
> +p0_phy: ethernet-phy@0 {
> +	compatible = "ethernet-phy-ieee802.3-c45";
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&cpm_phy0_pins &cps_phy0_pins>;
> +	reg = <0>;
> +	interrupt = <&cpm_gpio2 18 IRQ_TYPE_EDGE_FALLING>;
> +	sfp = <&sfp_eth0>;
> +};
> +
> +&cpm_eth0 {
> +	phy = <&p0_phy>;
> +	phy-mode = "10gbase-kr";
> +};
> 


-- 
Florian
