From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: fec: add post PHY reset delay DT property
Date: Mon, 22 May 2017 15:57:05 +0200
Message-ID: <20170522135705.GB29447@lunn.ch>
References: <20170522091517.6857-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan-3arQi8VN3Tc@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170522091517.6857-1-quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 11:15:17AM +0200, Quentin Schulz wrote:
> Some PHY require to wait for a bit after the reset GPIO has been
> toggled. This adds support for the DT property `phy-reset-post-delay`
> which gives the delay in milliseconds to wait after reset.
> 
> If the DT property is not given, no delay is observed. Post reset delay
> greater than 1000ms are invalid and are default to 1ms.

Hi Quentin

If it is invalid, please return -EINVAL.

> Signed-off-by: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt |  5 +++++
>  drivers/net/ethernet/freescale/fec_main.c         | 17 +++++++++++++++--
>  2 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index a1e3693cca16..8795e8ca5793 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -15,6 +15,11 @@ Optional properties:
>  - phy-reset-active-high : If present then the reset sequence using the GPIO
>    specified in the "phy-reset-gpios" property is reversed (H=reset state,
>    L=operation state).
> +- phy-reset-post-delay : Post reset delay in milliseconds. If present then
> +  a delay of phy-reset-post-delay milliseconds will be observed after the
> +  phy-reset-gpios has been toggled. Can be omitted thus no delay is
> +  observed. Delay is in range of 1ms to 1000ms. If given delay is higher
> +  than 1000ms, 1ms delay is done instead.
>  - phy-supply : regulator that powers the Ethernet PHY.
>  - phy-handle : phandle to the PHY device connected to this device.
>  - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 56a563f90b0b..00a7fd0bcd59 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3192,7 +3192,7 @@ static int fec_reset_phy(struct platform_device *pdev)
>  {
>  	int err, phy_reset;
>  	bool active_high = false;
> -	int msec = 1;
> +	int msec = 1, phy_post_delay = 0;
>  	struct device_node *np = pdev->dev.of_node;
>  
>  	if (!np)
> @@ -3210,7 +3210,6 @@ static int fec_reset_phy(struct platform_device *pdev)
>  		return 0;
>  
>  	active_high = of_property_read_bool(np, "phy-reset-active-high");
> -
>  	err = devm_gpio_request_one(&pdev->dev, phy_reset,
>  			active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
>  			"phy-reset");

No white space changes please.

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
