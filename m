From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/4] arm64: dts: renesas: salvator-common: Add EthernetAVB
 PHY reset
Date: Thu, 28 Sep 2017 10:20:57 -0700
Message-ID: <947b19ea-a295-26ef-9606-729fd2694b6b@gmail.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-4-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas-1zkq55x86MTxsAP9Fp7wbw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506614014-4398-4-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 08:53 AM, Geert Uytterhoeven wrote:
> Describe the GPIO used to reset the Ethernet PHY for EthernetAVB.
> This allows the driver to reset the PHY during probe and after system
> resume.
> 
> This fixes Ethernet operation after resume from s2ram on Salvator-XS,
> where the enable pin of the regulator providing PHY power is connected
> to PRESETn, and PSCI powers down the SoC during system suspend.
> 
> On Salvator-X, the enable pin is always pulled high, but the driver may
> still need to reset the PHY if this wasn't done by the bootloader
> before.
> 
> Inspired by patches in the BSP for the individual Salvator-X/XS boards
> by Kazuya Mizuguchi.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
> ---
> For proper PHY reset operation during system resume, this depends on
> "ravb: Add missing PHY reset during system resume".
> However, this patch can be applied independently.
> ---
>  arch/arm64/boot/dts/renesas/salvator-common.dtsi | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/boot/dts/renesas/salvator-common.dtsi b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
> index ed4a8dfead3c2e58..db00e7c484f76eac 100644
> --- a/arch/arm64/boot/dts/renesas/salvator-common.dtsi
> +++ b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
> @@ -296,6 +296,7 @@
>  	pinctrl-names = "default";
>  	renesas,no-ether-link;
>  	phy-handle = <&phy0>;
> +	reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
>  	status = "okay";
>  
>  	phy0: ethernet-phy@0 {

This should be a PHY node property, unless this GPIO pin really is
global to the MDIO bus itself.
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
