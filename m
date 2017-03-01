From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: xgene: Fix crash on DT systems
Date: Tue, 28 Feb 2017 16:58:06 -0800
Message-ID: <CAKh23FkT2nbABCxt9ic1WRR37-PkYO95naC21dNeoWtSoc1RNw@mail.gmail.com>
References: <20170228170855.8123-1-alban.bedel@avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Keyur Chudgar <kchudgar@apm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alban Bedel <alban.bedel@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:36846 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdCABF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 20:05:26 -0500
Received: by mail-ua0-f176.google.com with SMTP id 72so32165156uaf.3
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 17:04:49 -0800 (PST)
In-Reply-To: <20170228170855.8123-1-alban.bedel@avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 9:08 AM, Alban Bedel
<alban.bedel@avionic-design.de> wrote:
> On DT systems the driver require a clock, but the probe just print a
> warning and continue, leading to a crash when resetting the device.
> To fix this crash and properly handle probe deferals only ignore the
> missing clock if DT isn't used or if the clock doesn't exist.
>
> Signed-off-by: Alban Bedel <alban.bedel@avionic-design.de>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index d0d0d12b531f..68b48edc5921 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -1756,6 +1756,12 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>
>         pdata->clk = devm_clk_get(&pdev->dev, NULL);
>         if (IS_ERR(pdata->clk)) {
> +               /* Abort if the clock is defined but couldn't be retrived.
> +                * Always abort if the clock is missing on DT system as
> +                * the driver can't cope with this case.
> +                */
> +               if (PTR_ERR(pdata->clk) != -ENOENT || dev->of_node)
> +                       return PTR_ERR(pdata->clk);
>                 /* Firmware may have set up the clock already. */
>                 dev_info(dev, "clocks have been setup already\n");
>         }
> --
> 2.11.0
>

Thanks, Alban.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
