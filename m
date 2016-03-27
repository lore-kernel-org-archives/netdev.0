From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers : Remove unnecessary void pointer conversions
Date: Sun, 27 Mar 2016 14:46:04 +0300
Message-ID: <56F7C7FC.9020001@cogentembedded.com>
References: <1459050140-14621-1-git-send-email-njupudi@ucsc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhaskar Jupudi <njupudi@ucsc.edu>, davem@davemloft.net,
	igal.liberman@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33983 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbcC0LqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 07:46:08 -0400
Received: by mail-lf0-f54.google.com with SMTP id c62so74879351lfc.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 04:46:07 -0700 (PDT)
In-Reply-To: <1459050140-14621-1-git-send-email-njupudi@ucsc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/27/2016 6:42 AM, Bhaskar Jupudi wrote:

> Explicit void pointer conversion is unnecessary
> because the conversions to and from a void pointer
> are always implicit in 'C'. Changed two instances
> of such conversions.
>
>
> Signed-off-by: Bhaskar Jupudi <njupudi@ucsc.edu>
> ---
> This patch is based on Kernel Janitors To-Do list
>
>   drivers/net/ethernet/freescale/fman/fman.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
> index 623aa1c..8719f7b 100644
> --- a/drivers/net/ethernet/freescale/fman/fman.c
> +++ b/drivers/net/ethernet/freescale/fman/fman.c
> @@ -2668,7 +2668,7 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
>
>   	fm_node = of_node_get(of_dev->dev.of_node);
>
> -	u32_prop = (const u32 *)of_get_property(fm_node, "cell-index", &lenp);
> +	u32_prop = of_get_property(fm_node, "cell-index", &lenp);

    This function returns a pointer to big-endian data, no?

>   	if (!u32_prop) {
>   		dev_err(&of_dev->dev, "%s: of_get_property(%s, cell-index) failed\n",
>   			__func__, fm_node->full_name);
> @@ -2724,7 +2724,7 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
>   	/* Rounding to MHz */
>   	fman->dts_params.clk_freq = DIV_ROUND_UP(clk_rate, 1000000);
>
> -	u32_prop = (const u32 *)of_get_property(fm_node,
> +	u32_prop = of_get_property(fm_node,

    Same here...

>   						"fsl,qman-channel-range",
>   						&lenp);

    Please re-align these continuation lines.

[...]

MBR, Sergei
