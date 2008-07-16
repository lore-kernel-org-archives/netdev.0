From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 05/10] r6040: call napi_disable when puting down the
	interface and set lp->dev accordingly.
Date: Wed, 16 Jul 2008 23:01:38 +0200
Message-ID: <20080716210138.GB27394@electric-eye.fr.zoreil.com>
References: <200807131432.46495.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53211 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755324AbYGPVCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:02:15 -0400
Content-Disposition: inline
In-Reply-To: <200807131432.46495.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
> We did not call napi_disabled when putting down the interface
> which should be done. Finally initialize lp->dev when everything
> is set.
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> ---
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 4f2ebb2..5eb057d 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
[...]
> @@ -1080,8 +1081,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
>  	}
>  	SET_NETDEV_DEV(dev, &pdev->dev);
>  	lp = netdev_priv(dev);
> -	lp->pdev = pdev;
> -	lp->dev = dev;
>  
>  	if (pci_request_regions(pdev, DRV_NAME)) {
>  		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");

Can you fix the error paths of r6040_init_one as well ?

They badly leak.

-- 
Ueimor
