From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers: net: ethernet: broadcom: bcm63xx: use devm_ioremap_resource()
Date: Sun, 12 May 2013 22:38:37 +0400
Message-ID: <518FE1AD.3090602@cogentembedded.com>
References: <1368374165-3228-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, cernekee@gmail.com, jogo@openwrt.org,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:37204 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3ELSil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 14:38:41 -0400
Received: by mail-lb0-f173.google.com with SMTP id t10so1658865lbi.32
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 11:38:40 -0700 (PDT)
In-Reply-To: <1368374165-3228-1-git-send-email-laurent.navet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/12/2013 07:56 PM, Laurent Navet wrote:

> Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
>
> Found with coccicheck and this semantic patch:
>   scripts/coccinelle/api/devm_ioremap_resource.cocci
>
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/bcm63xx_enet.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index 0b3e23e..9de4217 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -1641,9 +1641,9 @@ static int bcm_enet_probe(struct platform_device *pdev)
>   	if (ret)
>   		goto out;
>   
> -	priv->base = devm_request_and_ioremap(&pdev->dev, res_mem);
> -	if (priv->base == NULL) {
> -		ret = -ENOMEM;
> +	priv->base = devm_ioremap_resource(&pdev->dev, res_mem);
> +	if (IS_ERR(priv->base)) {
> +		ret = PTR_ERR(priv->base);
>   		goto out;
>   	}
>

    You may as well delete a check for 'res_mem' being NULL above 
alloc_etherdev()
call since devm_ioremap_resource() checks for that too.

WBR, Sergei
