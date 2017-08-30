From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Wed, 30 Aug 2017 14:04:11 +0300
Message-ID: <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On 8/30/2017 12:51 PM, Baruch Siach wrote:

> Add device-tree binding documentation SFP transceivers. Support for SFP
> transceivers has been recently introduced (drivers/net/phy/sfp.c).
> 
> Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> ---
> v2:
>    Rename -gpio properties to -gpios
>    Rename the rate-select-gpio property to rate-select0-gpios
>    Add the rate-select1-gpios property
>    Add examples
> ---
>   Documentation/devicetree/bindings/net/sff,sfp.txt | 74 +++++++++++++++++++++++
>   1 file changed, 74 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> new file mode 100644
> index 000000000000..1d9c786d6287
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> @@ -0,0 +1,74 @@
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
> +- moddef0-gpios : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
> +  gpio signal

    Your example shows there's GPIO phandle *and* specifier.

 > +
> +- los-gpios : phandle of the Receiver Loss of Signal Indication input gpio
> +  signal

    Ditto.

> +
> +- tx-fault-gpios : phandle of the Module Transmitter Fault input gpio signal

    Ditto.

> +
> +- tx-disable-gpios : phandle of the Transmitter Disable output gpio signal

    Ditto.

> +
> +- rate-select0-gpios : phandle of the Rx Signaling Rate Select (AKA RS0) output
> +  gpio
> +
> +- rate-select1-gpios : phandle of the Tx Signaling Rate Select (AKA RS1) output
> +  gpio (SFP+ only)
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
[...]
> +Example #2: Serdes to PHY to SFP connection
> +
> +sfp_eth0: sfp-eth0 {
> +	compatible = "sff,sfp+";
> +	i2c-bus = <&sfpp0_i2c>;
> +	los-gpio = <&cps_gpio1 28 GPIO_ACTIVE_HIGH>;

    You describe "los-gpios" above , not "los-gpio" (which is a deprecated form).

> +	moddef0-gpio = <&cps_gpio1 27 GPIO_ACTIVE_LOW>;

    Ditto.

> +	pinctrl-names = "default";
> +	pinctrl-0 = <&cps_sfpp0_pins>;
> +	tx-disable-gpio = <&cps_gpio1 29 GPIO_ACTIVE_HIGH>;

    Ditto.

> +	tx-fault-gpio  = <&cps_gpio1 26 GPIO_ACTIVE_HIGH>;

    Ditto.

[...]

MBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
