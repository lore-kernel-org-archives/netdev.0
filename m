From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh-eth: Add flag to determine the type of TSU register
Date: Thu, 18 Apr 2013 18:48:16 +0400
Message-ID: <517007B0.7010807@cogentembedded.com>
References: <1366248372-28791-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:49807 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967194Ab3DROt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:49:26 -0400
Received: by mail-la0-f46.google.com with SMTP id ej20so431638lab.5
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:49:25 -0700 (PDT)
In-Reply-To: <1366248372-28791-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-04-2013 5:26, Nobuhiro Iwamatsu wrote:

> Some sh-eth devices may have two ether devices in the inside.

    s/in the//

> And the function of TSU is accessed from each ether device.
> In this case, sh-eth need to remap address using devm_ioremap(),
> without using devm_ioremap_resource().

    Do you mean TSU region is shared between Ether devices?

> acl_multi_reg

    You meant 'tsu_multi_reg'.

> of sh_eth_cpu_data is used for this control.

    So, "multi" here means "shared"?

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index a7499cb..d9458ae 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2743,7 +2747,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   			ret = -ENODEV;
>   			goto out_release;
>   		}
> -		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
> +
> +		if (mdp->cd->tsu_multi_reg)
> +			mdp->tsu_addr = devm_ioremap(&pdev->dev, rtsu->start,
> +					resource_size(rtsu));
> +		else
> +			mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
>   		if (IS_ERR(mdp->tsu_addr)) {
>   			ret = PTR_ERR(mdp->tsu_addr);
>   			goto out_release;
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index 1ddc9f2..6f9a997 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -472,6 +472,7 @@ struct sh_eth_cpu_data {
>   	unsigned tpauser:1;		/* EtherC have TPAUSER */
>   	unsigned bculr:1;		/* EtherC have BCULR */
>   	unsigned tsu:1;			/* EtherC have TSU */
> +	unsigned tsu_multi_reg:1; /* EtherC have TSU multi register */

    Please indent the comment with tab(s) like all the others.

>   	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
>   	unsigned rpadir:1;		/* E-DMAC have RPADIR */
>   	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */

WBR, Sergei
