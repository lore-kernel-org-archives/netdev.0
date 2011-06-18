From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Sat, 18 Jun 2011 20:27:22 +0200
Message-ID: <201106182027.22974.arnd@arndb.de>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1308410354-21387-3-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 18 June 2011 17:19:13 Shawn Guo wrote:
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> new file mode 100644
> index 0000000..705111d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -0,0 +1,14 @@
> +* Freescale Fast Ethernet Controller (FEC)
> +
> +Required properties:
> +- compatible : should be "fsl,<soc>-fec", "fsl,fec"
> +- reg : address and length of the register set for the device
> +- interrupts : should contain fec interrupt
> +
> +Example:
> +
> +fec@83fec000 {
> +	compatible = "fsl,imx51-fec", "fsl,fec";
> +	reg = <0x83fec000 0x4000>;
> +	interrupts = <87>;
> +};

How about also adding device_type="network" as required here, so you
inherit the attributes like "local-mac-address".

I would also suggest adding a call to of_get_mac_address() so you
can read the address out of the device tree when it is not configured
in hardware. Today, the driver relies on a module parameter or
platform_data on hardware with a mac address set.

The other information that is currently encoded in platform_data
is the phy mode. How about adding a property that enables RMII mode
when present?

	Arnd
