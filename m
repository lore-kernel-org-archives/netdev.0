From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 1/2] net: calexdaxgmac: fix printing of hardware version
Date: Sun, 10 Feb 2013 16:34:52 -0600
Message-ID: <5118208C.7010109@gmail.com>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk> <1360510721-17860-2-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:36820 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702Ab3BJWfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 17:35:07 -0500
Received: by mail-oa0-f48.google.com with SMTP id j1so5696295oag.21
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 14:34:56 -0800 (PST)
In-Reply-To: <1360510721-17860-2-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2013 09:38 AM, Ben Dooks wrote:
> The current driver attempts to print netdev_info() before registering the
> network device and allowing the name to be set. Change this print to be
> after the network deviec has been registered, and thus has been allocated

You missed the typo pointed out on the first version sent to lakml.

> a network device name.
> 
> Fix the following issue:
> 
> calxedaxgmac fff50000.ethernet (unregistered net_device): h/w version is 0x1012
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Otherwise,

Acked-by: Rob Herring <rob.herring@calxeda.com>

> ---
>  drivers/net/ethernet/calxeda/xgmac.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> index f7f0290..f91d9b2 100644
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -1715,9 +1715,6 @@ static int xgmac_probe(struct platform_device *pdev)
>  		goto err_io;
>  	}
>  
> -	uid = readl(priv->base + XGMAC_VERSION);
> -	netdev_info(ndev, "h/w version is 0x%x\n", uid);
> -
>  	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
>  	ndev->irq = platform_get_irq(pdev, 0);
>  	if (ndev->irq == -ENXIO) {
> @@ -1771,6 +1768,9 @@ static int xgmac_probe(struct platform_device *pdev)
>  	if (ret)
>  		goto err_reg;
>  
> +	uid = readl(priv->base + XGMAC_VERSION);
> +	netdev_info(ndev, "h/w version is 0x%x\n", uid);
> +
>  	return 0;
>  
>  err_reg:
> 
