From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 2/3] dt-binding: net: sfp binding documentation
Date: Sun, 3 Sep 2017 21:46:35 +0100
Message-ID: <20170903204634.GZ20805@n2100.armlinux.org.uk>
References: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
 <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:44978 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdICUqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 16:46:54 -0400
Content-Disposition: inline
In-Reply-To: <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 03, 2017 at 03:31:13PM +0300, Baruch Siach wrote:
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

I don't like this level of example - SGMII is Cisco SGMII which is not
the same as 1000Base-X - the two are incompatible.  Fibre SFP modules
only work with 1000Base-X.

The SFP/phylink takes care of informing the MAC which mode it should
be in, and the MAC must configure itself appropriately in response to
that, otherwise the module can't be supported.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
