From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: sh-eth: Add flag to determine the type of TSU
 register
Date: Tue, 04 Jun 2013 02:07:41 +0400
Message-ID: <51AD13AD.9090501@cogentembedded.com>
References: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:62629 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab3FCWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 18:07:43 -0400
Received: by mail-la0-f45.google.com with SMTP id fr10so4021411lab.18
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 15:07:42 -0700 (PDT)
In-Reply-To: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/07/2013 09:08 AM, Nobuhiro Iwamatsu wrote:

> Some sh-eth devices may have two ether devices inside.
> And the function of TSU is accessed from each ether device.
> In this case, sh-eth need to remap address using devm_ioremap(),
> without using devm_ioremap_resource().
> tsu_shared_reg of sh_eth_cpu_data is used for this control.
>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[...]

> @@ -2750,7 +2754,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   			ret = -ENODEV;
>   			goto out_release;
>   		}

     This patch is not good anymore since in the meanwhile the above 
check got removed.
Iwamatsu-san, are you going to respin this patch and the next series of 
9 patches any time
soon. I need them to base my work on.

> -		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
> +
> +		if (mdp->cd->tsu_shared_reg)
> +			mdp->tsu_addr = devm_ioremap(&pdev->dev, rtsu->start,
> +					resource_size(rtsu));
> +		else
> +			mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
>

WBR, Sergei
