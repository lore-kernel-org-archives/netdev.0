From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 11:48:12 -0700
Message-ID: <8e4aa981-7f41-047d-2101-370118b4f2c0@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Tristram.Ha@microchip.com, andrew@lunn.ch, muvarov@gmail.com,
        pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2017 02:11 PM, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Add other KSZ switches support so that patch check does not complain.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 117 ++++++++++++----------
>  1 file changed, 62 insertions(+), 55 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> index 0ab8b39..34af0e0 100644
> --- a/Documentation/devicetree/bindings/net/dsa/ksz.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> @@ -3,8 +3,15 @@ Microchip KSZ Series Ethernet switches
>  
>  Required properties:
>  
> -- compatible: For external switch chips, compatible string must be exactly one
> -  of: "microchip,ksz9477"
> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
> +	      "microchip,ksz8795" for KSZ8795 chip,
> +	      "microchip,ksz8794" for KSZ8794 chip,
> +	      "microchip,ksz8765" for KSZ8765 chip,
> +	      "microchip,ksz8895" for KSZ8895 chip,
> +	      "microchip,ksz8864" for KSZ8864 chip,
> +	      "microchip,ksz8873" for KSZ8873 chip,
> +	      "microchip,ksz8863" for KSZ8863 chip,
> +	      "microchip,ksz8463" for KSZ8463 chip

It becomes pretty obvious there is a 1 to 1 mapping between the
compatible name and what you should be using it for so specifying
ksz8795 for KSZ8795 chip is really redundant.

You could just list all compatible strings that you support and change
the verbiage to be:

compatible: Should be one of:
		"microchip,ksz9477"
		...
		"microchip,ksz8463"
>  
>  See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional  required and optional properties.
> @@ -13,60 +20,60 @@ Examples:
>  
>  Ethernet switch connected via SPI to the host, CPU port wired to eth0:
>  
> -                             eth0: ethernet@10001000 {
> -                                             fixed-link {
> -                                                             speed = <1000>;
> -                                                             full-duplex;
> -                                             };
> -                             };
> +	eth0: ethernet@10001000 {
> +		fixed-link {
> +			speed = <1000>;
> +			full-duplex;
> +		};
> +	};

This is a good clean up, but it would probably belong in a separate
patch that you would do before adding compatible strings for instance.

>  
> -                             spi1: spi@f8008000 {
> -                                             pinctrl-0 = <&pinctrl_spi_ksz>;
> -                                             cs-gpios = <&pioC 25 0>;
> -                                             id = <1>;
> -                                             status = "okay";
> +	spi1: spi@f8008000 {
> +		cs-gpios = <&pioC 25 0>;
> +		id = <1>;
> +		status = "okay";
>  
> -                                             ksz9477: ksz9477@0 {
> -                                                             compatible = "microchip,ksz9477";
> -                                                             reg = <0>;
> +		ksz9477: ksz9477@0 {
> +			compatible = "microchip,ksz9477";
> +			reg = <0>;
>  
> -                                                             spi-max-frequency = <44000000>;
> -                                                             spi-cpha;
> -                                                             spi-cpol;
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
> +					ethernet = <&eth0>;
> +					fixed-link {
> +						speed = <1000>;
> +						full-duplex;
> +					};
> +				};
> +			};
> +		};
> +	};
>  
> -                                                             status = "okay";
> -                                                             ports {
> -                                                                             #address-cells = <1>;
> -                                                                             #size-cells = <0>;
> -                                                                             port@0 {
> -                                                                                             reg = <0>;
> -                                                                                             label = "lan1";
> -                                                                             };
> -                                                                             port@1 {
> -                                                                                             reg = <1>;
> -                                                                                             label = "lan2";
> -                                                                             };
> -                                                                             port@2 {
> -                                                                                             reg = <2>;
> -                                                                                             label = "lan3";
> -                                                                             };
> -                                                                             port@3 {
> -                                                                                             reg = <3>;
> -                                                                                             label = "lan4";
> -                                                                             };
> -                                                                             port@4 {
> -                                                                                             reg = <4>;
> -                                                                                             label = "lan5";
> -                                                                             };
> -                                                                             port@5 {
> -                                                                                             reg = <5>;
> -                                                                                             label = "cpu";
> -                                                                                             ethernet = <&eth0>;
> -                                                                                             fixed-link {
> -                                                                                                             speed = <1000>;
> -                                                                                                             full-duplex;
> -                                                                                             };
> -                                                                             };
> -                                                             };
> -                                             };
> -                             };
> 


-- 
Florian
