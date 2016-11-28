From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH net-next v3 4/4] ARM64: dts: meson: odroidc2: disable
 advertisement EEE for GbE.
Date: Mon, 28 Nov 2016 13:31:46 +0100
Message-ID: <9709dd57-e536-9281-6b56-5ff5f9e8035c@suse.de>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
 <1480326409-25419-5-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480326409-25419-5-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 28.11.2016 um 10:46 schrieb Jerome Brunet:
> Signed-off-by: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> ---
>  arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
> index e6e3491d48a5..5624714d2b16 100644
> --- a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
> +++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
> @@ -46,6 +46,7 @@
>  
>  #include "meson-gxbb.dtsi"
>  #include <dt-bindings/gpio/gpio.h>
> +#include <dt-bindings/net/mdio.h>
>  
>  / {
>  	compatible = "hardkernel,odroid-c2", "amlogic,meson-gxbb";
> @@ -98,3 +99,18 @@
>  	pinctrl-0 = <&i2c_a_pins>;
>  	pinctrl-names = "default";
>  };
> +
> +&ethmac {
> +	phy-handle = <&eth_phy0>;
> +
> +	mdio {
> +		compatible = "snps,dwmac-mdio";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		eth_phy0: ethernet-phy@0 {
> +			reg = <0>;
> +			eee-broken-modes = <MDIO_EEE_1000T>;
> +		};
> +	};
> +};

I've tested this hand-applied because it applies to neither amlogic
v4.10/integ nor linux-next.git and will conflict if applied through the
net-next tree.

Note that there already is an &ethmac node that you should be extending
rather than duplicating:

&ethmac {
	status = "okay";
	pinctrl-0 = <&eth_rgmii_pins>;
	pinctrl-names = "default";
};

If you or your colleagues could please fix the sort order of the nodes
to be alphabetical again (ethmac after i2c_A here; between uart_A and ir
in-tree) this wouldn't happen so easily again.

I therefore suggest to not apply this patch 4/4 through net-next but
through the amlogic tree instead.

Thanks,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
