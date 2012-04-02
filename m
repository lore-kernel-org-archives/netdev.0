From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 5/7] i2c: Add device tree support to i2c-pnx.c
Date: Mon, 2 Apr 2012 13:17:23 +0000
Message-ID: <201204021317.23393.arnd@arndb.de>
References: <1333371364-21347-1-git-send-email-stigge@antcom.de> <1333371364-21347-6-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org
To: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1333371364-21347-6-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 02 April 2012, Roland Stigge wrote:

> --- /dev/null
> +++ linux-2.6/Documentation/devicetree/bindings/i2c/pnx.txt
> @@ -0,0 +1,36 @@
> +* NXP PNX I2C Controller
> +
> +Required properties:
> +
> + - reg: Offset and length of the register set for the device
> + - compatible: should be "nxp,pnx-i2c"
> + - interrupts: <a b> where a is the interrupt number and b is a
> +   field that represents an encoding of the sense and level
> +   information for the interrupt

The encoding of the interrupt is specific to the controller and does
not belong here. Just write that there is one interrupt line to be
configure.

> + - interrupt-parent: the phandle for the interrupt controller that
> +   services interrupts for this device.

interrupt-parent should be optional, it can be set in the (grand-)parent
device on systems where all devices use the same controller.

You should also require

#address-cells = <1>;
#size-cells = <0>;

To create an address space for i2c slave device numbers.
> +Examples:
> +
> +	i2c1: i2c@400A0000 {
> +		compatible = "nxp,pnx-i2c";
> +		reg = <0x400A0000 0x100>;
> +		interrupt-parent = <&mic>;
> +		interrupts = <51 0>;
> +	};
> +
> +	i2c2: i2c@400A8000 {
> +		compatible = "nxp,pnx-i2c";
> +		reg = <0x400A8000 0x100>;

Best use all lowercase letters in the addresses.

> +		interrupt-parent = <&mic>;
> +		interrupts = <50 0>;
> +		clock-frequency = <0x186a0>;
> +		pnx,timeout = <0x64>;
> +		slave-addr = <0x11>;
> +	};

>  static struct platform_driver i2c_pnx_driver = {
>  	.driver = {
>  		.name = "pnx-i2c",
>  		.owner = THIS_MODULE,
> +#ifdef CONFIG_OF
> +		.of_match_table = i2c_pnx_of_match,
> +#endif
>  	},
>  	.probe = i2c_pnx_probe,
>  	.remove = __devexit_p(i2c_pnx_remove),

of_match_ptr() instead of this #ifdef, please.

	Arnd
