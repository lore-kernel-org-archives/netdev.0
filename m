From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 4/5] dsa: Add spi support to Microchip KSZ
 switches
Date: Fri, 19 May 2017 17:05:43 -0700
Message-ID: <6806543e-c495-e389-7a75-41de389a9e84@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40A7C042@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36738 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdETAFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 20:05:50 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so19645422wmh.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 17:05:50 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A7C042@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 03:57 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> A sample SPI configuration for Microchip KSZ switches.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Subject should be something like:

dt-bindings: net: dsa: Add Microchip KSZ switches binding

With that fixed and the nits below:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 73 +++++++++++++++++++++++
>  1 file changed, 73 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/ksz.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> new file mode 100644
> index 0000000..8a13966
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> @@ -0,0 +1,73 @@
> +Microchip KSZ Series Ethernet switches
> +==================================
> +
> +Required properties:
> +
> +- compatible: For external switch chips, compatible string must be exactly one
> +  of: "microchip,ksz9477"
> +
> +See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
> +required and optional properties.
> +
> +Examples:
> +
> +Ethernet switch connected via SPI to the host, CPU port wired to eth0:
> +
> +		eth0: ethernet@10001000 {
> +			fixed-link {
> +				reg = <7>

There is a missing semicolon, and for a fixed-link, there is no "reg"
property.

> +				speed = <1000>;
> +				duplex-full;

Actually the correct property is named "full-duplex" (like you put it
for the switch)

> +			};
> +		};
> +
> +		spi1: spi@f8008000 {
> +			pinctrl-0 = <&pinctrl_spi_ksz>;
> +			cs-gpios = <&pioC 25 0>;
> +			id = <1>;
> +			status = "okay";
> +
> +			ksz9477: ksz9477@0 {
> +				compatible = "microchip,ksz9477";
> +				reg = <0>;
> +
> +				spi-max-frequency = <44000000>;
> +				spi-cpha;
> +				spi-cpol;
> +
> +				status = "okay";
> +				ports {
> +					#address-cells = <1>;
> +					#size-cells = <0>;
> +					port@0 {
> +						reg = <0>;
> +						label = "lan1";
> +					};
> +					port@1 {
> +						reg = <1>;
> +						label = "lan2";
> +					};
> +					port@2 {
> +						reg = <2>;
> +						label = "lan3";
> +					};
> +					port@3 {
> +						reg = <3>;
> +						label = "lan4";
> +					};
> +					port@4 {
> +						reg = <4>;
> +						label = "lan5";
> +					};
> +					port@5 {
> +						reg = <5>;
> +						label = "cpu";
> +						ethernet = <&eth0>;
> +						fixed-link {
> +							speed = <1000>;
> +							full-duplex;
> +						};
> +					};
> +				};
> +			};
> +		};
> 


-- 
Florian
