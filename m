From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] net/macb: add support for resetting PHY using GPIO
Date: Mon, 14 Dec 2015 16:56:34 -0600
Message-ID: <20151214225634.GA14163@rob-hp-laptop>
References: <1449830093-29433-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1449830093-29433-1-git-send-email-gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2015 at 11:34:53AM +0100, Gregory CLEMENT wrote:
> With device tree it is no more possible to reset the PHY at board
> level. Furthermore, doing in the driver allow to power down the PHY when
> the network interface is no more used.
> 
> This reset can't be done at the PHY driver level. The PHY must be able to
> answer the to the mii bus scan to let the kernel creating a PHY device.
> 
> The patch introduces a new optional property "phy-reset-gpios" inspired
> from the one use for the FEC.
> 
> Signed-off-by: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
> 
> Since the v1, I used the gpiod functions. It allows to simplify the
> code and to not introduce any #ifdef.
> 
> I also rename the property in phy-reset-gpios, even if actually the
> gpiod will match both phy-reset-gpios and phy-reset-gpio.
> 
> 
>  Documentation/devicetree/bindings/net/macb.txt | 3 +++
>  drivers/net/ethernet/cadence/macb.c            | 8 ++++++++
>  drivers/net/ethernet/cadence/macb.h            | 1 +
>  3 files changed, 12 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5d7976..4a7fb6c 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,9 @@ Required properties:
>  	Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
>  
> +Optional properties:
> +- phy-reset-gpios : Should specify the gpio for phy reset
> +

This alone is simple enough, but I worry that this doesn't really scale. 
What if you need to enable clocks or regulators for the same reason? The 
mmc folks did a pwrseq binding for similar reasons. I don't think I'd 
recommend that here as I think it is kind of ugly. We really need a 
pre-probe/scan hook for drivers. This is also needed for USB devices 
mounted on boards.

But I'm not going to hold up something simple to do all that, so:

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
