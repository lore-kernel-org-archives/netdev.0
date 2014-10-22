From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 5/6] ethernet: renesas: remove unnecessary check
Date: Wed, 22 Oct 2014 15:47:43 +0400
Message-ID: <5447995F.5080602@cogentembedded.com>
References: <N> <1413951386-29645-1-git-send-email-varkab@cdac.in> <1413951386-29645-6-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:40456 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932764AbaJVLrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 07:47:45 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so2765215lam.18
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 04:47:44 -0700 (PDT)
In-Reply-To: <1413951386-29645-6-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 8:16 AM, Varka Bhadram wrote:

> devm_ioremap_resource checks platform_get_resource() return value.
> We can remove the duplicate check here.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |    4 ----
>   1 file changed, 4 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 60e9c2c..d824ba5 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2769,10 +2769,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>
>   	/* get base addr */
>   	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (unlikely(res == NULL)) {
> -		dev_err(&pdev->dev, "invalid resource\n");
> -		return -EINVAL;
> -	}

    The driver dereferences 'res' further on, so you can't remove this check.

WBR, Sergei
