From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: check platform data pointer
Date: Wed, 30 Oct 2013 22:55:13 +0300
Message-ID: <52716421.9080807@cogentembedded.com>
References: <201308310423.30322.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:65122 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab3J3SzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:55:16 -0400
Received: by mail-lb0-f175.google.com with SMTP id z5so1553712lbh.20
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 11:55:14 -0700 (PDT)
In-Reply-To: <201308310423.30322.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/31/2013 04:23 AM, Sergei Shtylyov wrote:

> Check the platform data pointer before dereferencing it and error out of the
> probe() method if it's NULL.

> This has additional effect of preventing kernel oops with outdated platform data
> containing zero PHY address instead (such as on SolutionEngine7710).

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
> This patch is against Dave's 'net-next.git' repo.

>   drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
>   1 file changed, 6 insertions(+)

> Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2653,6 +2653,12 @@ static int sh_eth_drv_probe(struct platf
>   	pm_runtime_enable(&pdev->dev);
>   	pm_runtime_resume(&pdev->dev);
>
> +	if (!pd) {
> +		dev_err(&pdev->dev, "no platform data\n");
> +		ret = -EINVAL;
> +		goto out_release;
> +	}
> +
>   	/* get PHY ID */
>   	mdp->phy_id = pd->phy;
>   	mdp->phy_interface = pd->phy_interface;

    David, could you please merge this patch? It has a value of its own, 
regardless of the device tree support in patch 2 (which got bloked).

WBR, Sergei
