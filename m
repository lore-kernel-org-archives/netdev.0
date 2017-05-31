From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] net: fec: add post PHY reset delay DT property
Date: Wed, 31 May 2017 11:44:16 -0500
Message-ID: <20170531164416.ka3hk6a2lybrlngd@rob-hp-laptop>
References: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan-3arQi8VN3Tc@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170523094808.11102-1-quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 11:48:08AM +0200, Quentin Schulz wrote:
> Some PHY require to wait for a bit after the reset GPIO has been
> toggled. This adds support for the DT property `phy-reset-post-delay`
> which gives the delay in milliseconds to wait after reset.
> 
> If the DT property is not given, no delay is observed. Post reset delay
> greater than 1000ms are invalid.
> 
> Signed-off-by: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
> 
> v2:
>   - return -EINVAL when phy-reset-post-delay is greater than 1000ms
>   instead of defaulting to 1ms,
>   - remove `default to 1ms` when phy-reset-post-delay > 1000Ms from DT
>   binding doc and commit log,
>   - move phy-reset-post-delay property reading before
>   devm_gpio_request_one(),
> 
>  Documentation/devicetree/bindings/net/fsl-fec.txt |  4 ++++
>  drivers/net/ethernet/freescale/fec_main.c         | 16 +++++++++++++++-
>  2 files changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index a1e3693cca16..6f55bdd52f8a 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -15,6 +15,10 @@ Optional properties:
>  - phy-reset-active-high : If present then the reset sequence using the GPIO
>    specified in the "phy-reset-gpios" property is reversed (H=reset state,
>    L=operation state).
> +- phy-reset-post-delay : Post reset delay in milliseconds. If present then

This needs unit suffix minimally. It should also have a vendor prefix or 
be made generic.

But really, this is a property of the phy and should be in the phy node 
as should phy-reset-gpios, phy-reset-active-high, phy-supply, etc.

> +  a delay of phy-reset-post-delay milliseconds will be observed after the
> +  phy-reset-gpios has been toggled. Can be omitted thus no delay is
> +  observed. Delay is in range of 1ms to 1000ms. Other delays are invalid.
>  - phy-supply : regulator that powers the Ethernet PHY.
>  - phy-handle : phandle to the PHY device connected to this device.
>  - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
