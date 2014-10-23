From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 5/6] ethernet: renesas: remove unnecessary
 check
Date: Thu, 23 Oct 2014 16:29:34 +0400
Message-ID: <5448F4AE.1080901@cogentembedded.com>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in> <1414029531-5067-6-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:37706 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168AbaJWM3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 08:29:37 -0400
Received: by mail-la0-f46.google.com with SMTP id gi9so733717lab.5
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 05:29:36 -0700 (PDT)
In-Reply-To: <1414029531-5067-6-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 5:58 AM, Varka Bhadram wrote:

> devm_ioremap_resource checks platform_get_resource() return value.
> We can remove the duplicate check here.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |    9 +++------
>   1 file changed, 3 insertions(+), 6 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 60e9c2c..ffb49f3 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2781,8 +2777,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   	pm_runtime_enable(&pdev->dev);
>   	pm_runtime_get_sync(&pdev->dev);
>
> -	/* The sh Ether-specific entries in the device structure. */
> -	ndev->base_addr = res->start;
>   	devno = pdev->id;
>   	if (devno < 0)
>   		devno = 0;
> @@ -2806,6 +2800,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   		goto out_release;
>   	}
>
> +	/* The sh Ether-specific entries in the device structure. */

    No need to move the comment, at least not there.

> +	ndev->base_addr = res->start;
> +
>   	spin_lock_init(&mdp->lock);
>   	mdp->pdev = pdev;

WBR, Sergei
