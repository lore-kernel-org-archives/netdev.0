From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 2/2] sh_eth: Do not print an error message for probe deferral
Date: Thu, 18 May 2017 16:08:37 +0300
Message-ID: <1794135.XeGx5bmIYM@avalon>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be> <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S . Miller" <davem@davemloft.net>,
        Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galahad.ideasonboard.com ([185.26.127.97]:54126 "EHLO
        galahad.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756125AbdERNI2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:08:28 -0400
In-Reply-To: <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

Thank you for the patch.

On Thursday 18 May 2017 15:01:35 Geert Uytterhoeven wrote:
> EPROBE_DEFER is not an error, hence printing an error message like
> 
>     sh-eth ee700000.ethernet: failed to initialise MDIO
> 
> may confuse the user.
> 
> To fix this, suppress the error message in case of probe deferral.
> While at it, shorten the message, and add the actual error code.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
> b/drivers/net/ethernet/renesas/sh_eth.c index
> c85222b02754f5a7..2d686ccf971b1b65 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -3220,7 +3220,8 @@ static int sh_eth_drv_probe(struct platform_device
> *pdev) /* MDIO bus init */
>  	ret = sh_mdio_init(mdp, pd);
>  	if (ret) {
> -		dev_err(&pdev->dev, "failed to initialise MDIO\n");
> +		if (ret != -EPROBE_DEFER)
> +			dev_err(&pdev->dev, "MDIO init failed: %d\n", ret);
>  		goto out_release;
>  	}

-- 
Regards,

Laurent Pinchart
