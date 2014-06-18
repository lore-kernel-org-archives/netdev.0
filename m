From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH net-next v2 3/3] devicetree: add devicetree bindings for
 cc2520 driver
Date: Wed, 18 Jun 2014 10:05:00 +0100
Message-ID: <20140618090500.GA26461@leverpostej>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
 <1403068565-32224-4-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403068565-32224-4-git-send-email-varkab@cdac.in>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2014 at 06:16:05AM +0100, Varka Bhadram wrote:
> devicetree bindings for cc2520 radio driver.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  .../devicetree/bindings/net/ieee802154/cc2520.txt  |   26 ++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
> new file mode 100644
> index 0000000..f0a749d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
> @@ -0,0 +1,26 @@
> +CC2520 IEEE 802.15.4 Compatible Radio
> +
> +Required properties:
> +	- compatible:		should be "ti,cc2520"
> +	- spi-max-frequency:	maximal bus speed (8000000), should be set to 4000000 depends
> +				sync or async operation mode
> +	- reg:			the chipselect index
> +	- mode:			SPI mode

What exactly is this property? It doesn't seem to be used by the driver,
the example is opaque, and this doesn't seem to match any existing
bindings (a grep for "mode" in Documentation/devicetree/bindings/spi
only found me a string "mode" property).

The example has several properties (the GPIOs and pinctrl) not listed
here...

Mark.

> +Example:
> +
> +	cc2520@0 {
> +		compatible = "ti,cc2520";
> +		reg = <0>;
> +		spi-max-frequency = <4000000>;
> +		mode = <1>;
> +
> +		pinctrl-names = "default";
> +		pinctrl-0 = <&cc2520_cape_pins>;	/*GPIO pin muxing details*/
> +
> +		fifo-gpio = <&gpio1 18 0>;
> +		fifop-gpio = <&gpio1 19 0>;
> +		sfd-gpio = <&gpio1 13 0>;
> +		cca-gpio = <&gpio1 16 0>;
> +		vreg-gpio = <&gpio0 31 0>;
> +		reset-gpio = <&gpio1 12 0>;
> +	};
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
