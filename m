From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/9] net: mediatek: update the IRQ part of the binding
 document
Date: Mon, 11 Apr 2016 10:24:38 -0500
Message-ID: <20160411152438.GA16983@rob-hp-laptop>
References: <1460051876-53135-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Sean Wang =?utf-8?B?KOeOi+W/l+S6mCk=?= <sean.wang@mediatek.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55543 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbcDKPYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 11:24:44 -0400
Content-Disposition: inline
In-Reply-To: <1460051876-53135-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 07:57:48PM +0200, John Crispin wrote:
> The current binding document only describes a single interrupt. Update the
> document by adding the 2 other interrupts.
> 
> The driver currently only uses a single interrupt. The HW is however able
> to using IRQ grouping to split TX and RX onto separate GIC irqs.

I assume you aren't breaking existing DTs, and the driver will continue 
to work with a single irq specified?

> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Cc: devicetree@vger.kernel.org
> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index 5ca7929..2f142be 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -9,7 +9,7 @@ have dual GMAC each represented by a child node..
>  Required properties:
>  - compatible: Should be "mediatek,mt7623-eth"
>  - reg: Address and length of the register set for the device
> -- interrupts: Should contain the frame engines interrupt
> +- interrupts: Should contain the three frame engines interrupts

Need to define what each irq is and the order.

>  - clocks: the clock used by the core
>  - clock-names: the names of the clock listed in the clocks property. These are
>  	"ethif", "esw", "gp2", "gp1"
> @@ -42,7 +42,9 @@ eth: ethernet@1b100000 {
>  		 <&ethsys CLK_ETHSYS_GP2>,
>  		 <&ethsys CLK_ETHSYS_GP1>;
>  	clock-names = "ethif", "esw", "gp2", "gp1";
> -	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
> +	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW
> +		      GIC_SPI 199 IRQ_TYPE_LEVEL_LOW
> +		      GIC_SPI 198 IRQ_TYPE_LEVEL_LOW>;
>  	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
>  	resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
>  	reset-names = "eth";
> -- 
> 1.7.10.4
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
