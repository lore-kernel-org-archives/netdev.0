From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH V2 11/14] NET: MIPS: lantiq: convert etop driver to clkdev
 api
Date: Fri, 24 Feb 2012 14:55:15 +0400
Message-ID: <4F476C93.2000304@mvista.com>
References: <1330012993-13510-1-git-send-email-blogic@openwrt.org> <1330012993-13510-11-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59430 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab2BXK4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 05:56:31 -0500
Received: by bkcjm19 with SMTP id jm19so1859760bkc.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 02:56:30 -0800 (PST)
In-Reply-To: <1330012993-13510-11-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-02-2012 20:03, John Crispin wrote:

> Update from old pmu_{dis,en}able() to ckldev api.

> Signed-off-by: John Crispin<blogic@openwrt.org>
> Cc: netdev@vger.kernel.org
[...]

> diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
> index e5ec8b1..6b2e4b4 100644
> --- a/drivers/net/ethernet/lantiq_etop.c
> +++ b/drivers/net/ethernet/lantiq_etop.c
[...]
> @@ -886,6 +903,22 @@ ltq_etop_probe(struct platform_device *pdev)
>   	priv->pdev = pdev;
>   	priv->pldata = dev_get_platdata(&pdev->dev);
>   	priv->netdev = dev;
> +
> +	priv->clk_ppe = clk_get(&pdev->dev, NULL);
> +	if (!priv->clk_ppe)
> +		return -ENOENT;
> +	if (ltq_has_gbit()) {
> +		priv->clk_switch = clk_get(&pdev->dev, "switch");
> +		if (!priv->clk_switch)

    clk_get() doesn't retirn NULL, it returns error code.

> +			return -ENOENT;
> +	}
> +	if (ltq_is_ase()) {
> +		priv->clk_ephy = clk_get(&pdev->dev, "ephy");
> +		priv->clk_ephycgu = clk_get(&pdev->dev, "ephycgu");
> +		if (!priv->clk_ephy || !priv->clk_ephycgu)

    Same here.

WBR, Sergei
