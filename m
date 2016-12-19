From: Scott Wood <oss@buserror.net>
Subject: Re: [upstream-release] [PATCH net v3 2/4] powerpc: fsl/fman: remove
 fsl, fman from of_device_ids[]
Date: Mon, 19 Dec 2016 13:46:23 -0600
Message-ID: <1482176783.32531.28.camel@buserror.net>
References: <1482164013-6111-1-git-send-email-madalin.bucur@nxp.com>
         <1482164013-6111-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: madalin.bucur@nxp.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482164013-6111-3-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-12-19 at 18:13 +0200, Madalin Bucur wrote:
> The fsl/fman drivers will use of_platform_populate() on all
> supported platforms. Call of_platform_populate() to probe the
> FMan sub-nodes.
> 
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
> ---
>  arch/powerpc/platforms/85xx/corenet_generic.c | 3 ---
>  drivers/net/ethernet/freescale/fman/fman.c    | 8 ++++++++
>  2 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/85xx/corenet_generic.c
> b/arch/powerpc/platforms/85xx/corenet_generic.c
> index 1179115..824b7f1 100644
> --- a/arch/powerpc/platforms/85xx/corenet_generic.c
> +++ b/arch/powerpc/platforms/85xx/corenet_generic.c
> @@ -117,9 +117,6 @@ static const struct of_device_id of_device_ids[] = {
>  	{
>  		.compatible	= "fsl,qe",
>  	},
> -	{
> -		.compatible    = "fsl,fman",
> -	},
>  	/* The following two are for the Freescale hypervisor */
>  	{
>  		.name		= "hypervisor",

For this part:

Acked-by: Scott Wood <oss@buserror.net>

> diff --git a/drivers/net/ethernet/freescale/fman/fman.c
> b/drivers/net/ethernet/freescale/fman/fman.c
> index dafd9e1..0b7f711 100644
> --- a/drivers/net/ethernet/freescale/fman/fman.c
> +++ b/drivers/net/ethernet/freescale/fman/fman.c
> @@ -2868,6 +2868,14 @@ static struct fman *read_dts_node(struct
> platform_device *of_dev)
>  
>  	fman->dev = &of_dev->dev;
>  
> +	/* call of_platform_populate in order to probe sub-nodes on arm64
> */
> +	err = of_platform_populate(fm_node, NULL, NULL, &of_dev->dev);
> +	if (err) {
> +		dev_err(&of_dev->dev, "%s: of_platform_populate()
> failed\n",
> +			__func__);
> +		goto fman_free;
> +	}

The "on arm64" comment is no longer accurate (and the rest of the comment
seems unnecessary).

-Scott
