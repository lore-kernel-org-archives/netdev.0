From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 23:10:54 +0400
Message-ID: <5217B3BE.8020003@cogentembedded.com>
References: <1377283987-20040-1-git-send-email-zonque@gmail.com> <1377283987-20040-3-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33480 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756392Ab3HWTKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:10:49 -0400
Received: by mail-la0-f45.google.com with SMTP id eh20so785043lab.4
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 12:10:48 -0700 (PDT)
In-Reply-To: <1377283987-20040-3-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/23/2013 10:53 PM, Daniel Mack wrote:

> At least the AM33xx SoC has a control module register to configure
> details such as the hardware ethernet interface mode.

> I'm not sure whether all SoCs which feature the cpsw block have such a
> register, so that third memory region is considered optional for now.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>   Documentation/devicetree/bindings/net/cpsw.txt | 5 ++++-
>   drivers/net/ethernet/ti/cpsw.c                 | 5 +++++
>   2 files changed, 9 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index fc3263f..4feba2f 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> @@ -1989,6 +1990,10 @@ static int cpsw_probe(struct platform_device *pdev)
>   		goto clean_runtime_disable_ret;
>   	}
>
> +	/* Don't fail hard if the optional control memory region is missing */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);

    Hm, but why now you don't fail if devm_ioremap_resource() fails?

WBR, Sergei
