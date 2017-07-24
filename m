From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] dt-bindings: add device tree binding for
 Allwinner XR819 SDIO Wi-Fi
Date: Mon, 24 Jul 2017 12:54:40 -0500
Message-ID: <20170724175440.s7f6lk77wv2vpszz@rob-hp-laptop>
References: <20170718072940.17872-1-icenowy@aosc.io>
Reply-To: robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Return-path: <linux-sunxi+bncBDJIP47K7MERBYXI3DFQKGQEIOXTF6Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170718072940.17872-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2017 at 03:29:40PM +0800, Icenowy Zheng wrote:
> Allwinner XR819 is a SDIO Wi-Fi chip, which has the functionality to use
> an out-of-band interrupt pin instead of SDIO in-band interrupt.
> 
> Add the device tree binding of this chip, in order to make it possible
> to add this interrupt pin to device trees.
> 
> Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
> ---
>  .../bindings/net/wireless/allwinner,xr819.txt      | 37 ++++++++++++++++++++++
>  1 file changed, 37 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> new file mode 100644
> index 000000000000..64dd9c1c0584
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> @@ -0,0 +1,37 @@
> +Allwinner XRadio wireless SDIO devices
> +
> +This node provides properties for controlling the XRadio wireless device. The
> +node is expected to be specified as a child node to the SDIO controller that
> +connects the device to the system.
> +
> +Required properties:
> +
> + - compatible : Should be "allwinner,xr819".

reg is also required.

> +
> +Optional properties:
> + - interrupt-parent : the phandle for the interrupt controller to which the
> +	device interrupts are connected.
> + - interrupts : specifies attributes for the out-of-band interrupt (host-wake).
> +	When not specified the device will use in-band SDIO interrupts.
> +
> +Example:
> +
> +mmc1: mmc@01c10000 {
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&mmc1_pins_a>;
> +	vmmc-supply = <&reg_vcc_wifi>;
> +	mmc-pwrseq = <&wifi_pwrseq>;
> +	bus-width = <4>;
> +	non-removable;
> +	status = "okay";

Don't show status in examples.

> +
> +	xr819: sdio_wifi@1 {

wifi@1

> +		reg = <1>;
> +		compatible = "allwinner,xr819";
> +		interrupt-parent = <&pio>;
> +		interrupts = <6 10 IRQ_TYPE_EDGE_RISING>;
> +	};
> +};
> -- 
> 2.13.0
> 
