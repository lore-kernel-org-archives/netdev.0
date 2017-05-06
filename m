From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/5] dsa: Microchip KSZ switches SPI devicetree
 configuration
Date: Sat, 6 May 2017 13:02:04 +0300
Message-ID: <1ade6f7e-7a28-db47-3811-d35d90f57b56@cogentembedded.com>
References: <9235D6609DB808459E95D78E17F2E43D40A5C00B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:33827 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751935AbdEFKCH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 06:02:07 -0400
Received: by mail-lf0-f44.google.com with SMTP id 99so14169224lfu.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 03:02:07 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5C00B@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 5/6/2017 2:18 AM, Woojung.Huh@microchip.com wrote:

> From: Woojung Huh <Woojung.Huh@microchip.com>
>
> A sample SPI configuration for Microchip KSZ switches.
>
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 73 +++++++++++++++++++++++
>  1 file changed, 73 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/ksz.txt
>
> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> new file mode 100644
> index 0000000..9cca7d4
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
> +				speed = <1000>;
> +				duplex-full;
> +			};
> +		};
> +
> +		spi1: spi@f8008000 {
> +		pinctrl-0 = <&pinctrl_spi_ksz>;
> +		cs-gpios = <&pioC 25 0>;
> +		id = <1>;
> +		status = "okay";

    4 lines above should be indented more to the right.

> +
> +		ksz9477: ksz9477@0 {
> +			compatible = "microchip,ksz9477";
> +			reg = <0>;
> +
> +			spi-max-frequency = <44000000>;
> +			spi-cpha;
> +			spi-cpol;
> +
> +			status = "okay";
> +			ports {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				port@0 {
> +					reg = <0>;
> +					label = "lan1";
> +				};
> +				port@1 {
> +					reg = <1>;
> +					label = "lan2";
> +				};
> +				port@2 {
> +					reg = <2>;
> +					label = "lan3";
> +				};
> +				port@3 {
> +					reg = <3>;
> +					label = "lan4";
> +				};
> +				port@4 {
> +					reg = <4>;
> +					label = "lan5";
> +				};
> +				port@5 {
> +					reg = <5>;
> +					label = "cpu";
> +					ethernet = <&macb0>;
> +					fixed-link {
> +						speed = <1000>;
> +						full-duplex;
> +					};
> +				};
> +			};
> +		};
> +		};

    Unmatched }?

MBR, Sergei
