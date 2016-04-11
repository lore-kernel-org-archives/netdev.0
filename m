From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 5/5] ARM: dts: sun8i: Enable Ethernet controller on
 the Orange PI PC
Date: Mon, 11 Apr 2016 12:25:19 -0700
Message-ID: <570BFA1F.2040601@gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-6-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459786954-12649-6-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/04/16 09:22, Chen-Yu Tsai wrote:
> The Orange PI PC uses the H3's internal Ethernet PHY with the EMAC
> Ethernet controller.
> 
> Set a proper address for the PHY and enable the EMAC.
> 
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> ---
> 
> This patch depends on "ARM: dts: sun8i-h3: Add Ethernet controller device",
> which uses an binding still in development.
> 
> Do not merge.
> 
> ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
> index daf50b9a6657..f01e10df812a 100644
> --- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
> +++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
> @@ -102,6 +102,20 @@
>  	status = "okay";
>  };
>  
> +&ephy {
> +	allwinner,ephy-addr = <0x1>;
> +};
> +
> +&emac {
> +	phy = <&phy1>;
> +	phy-mode = "mii";
> +	status = "okay";
> +
> +	phy1: ethernet-phy@1 {
> +		reg = <1>;
> +	};
> +};

As commented in patch 1, the fact that you have to put the Ethernet PHY
address twice here is not really a good thing, because they cannot be
dissociated from eath other, I would rather have a standard Ethernet PHY
DT node represent the desired PHY address, and have your glue/SHIM
SUN8I_H3_EMAC driver scan the Device Tree to know what address to
program for the Ethernet PHY.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
