From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 18:59:39 +0400
Message-ID: <521778DB.7040402@cogentembedded.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-3-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1377267365-24057-3-git-send-email-zonque@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23-08-2013 18:16, Daniel Mack wrote:

> At least the AM33xx SoC has a control module register to configure
> details such as the hardware ethernet interface mode.

> I'm not sure whether all SoCs which feature the cpsw block have such a
> register, so that third memory region is considered optional for now.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
[...]

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 849af52..7a25ff4 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> @@ -1999,6 +2000,21 @@ static int cpsw_probe(struct platform_device *pdev)
>   		goto clean_runtime_disable_ret;
>   	}
>
> +	/* If the control memory region is unspecified, continue without it.
> +	 * If it is specified, but we're unable to reserve it, bail.
> +	 */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +	if (!res) {
> +		dev_info(priv->dev, "error getting control i/o resource\n");
> +		goto no_gmii_sel;
> +	}
> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(priv->gmii_sel_reg)) {
> +		dev_err(priv->dev, "unable to map control i/o region\n");

    You didn't actually seem to heed my words about error message. And don't 
you want to do:

	res = PTR_ERR(priv->gmii_sel_reg);

> +		goto clean_runtime_disable_ret;
> +	}
> +
> +no_gmii_sel:
>   	memset(&dma_params, 0, sizeof(dma_params));
>   	memset(&ale_params, 0, sizeof(ale_params));

WBR, Sergei


