From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix PHY Lib support for gianfar and ucc_geth
Date: Wed, 06 Feb 2008 06:44:17 -0500
Message-ID: <47A99D91.9000102@garzik.org>
References: <12022509302322-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40821 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759891AbYBFLoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:44:20 -0500
In-Reply-To: <12022509302322-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> The PHY Lib now uses mutexes instead of spin_locks.  ucc_geth
> and gianfar both grab the locks in their mdio_reset functions,
> so they need to use mutex_(un)lock instead.  This was not caught
> until someone tested it on an SMP system.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar_mii.c  |    4 ++--
>  drivers/net/ucc_geth_mii.c |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
> index 100bf41..6a647d9 100644
> --- a/drivers/net/gianfar_mii.c
> +++ b/drivers/net/gianfar_mii.c
> @@ -127,7 +127,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
>  	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
>  	unsigned int timeout = PHY_INIT_TIMEOUT;
>  
> -	spin_lock_bh(&bus->mdio_lock);
> +	mutex_lock(&bus->mdio_lock);
>  
>  	/* Reset the management interface */
>  	gfar_write(&regs->miimcfg, MIIMCFG_RESET);
> @@ -140,7 +140,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
>  			timeout--)
>  		cpu_relax();
>  
> -	spin_unlock_bh(&bus->mdio_lock);
> +	mutex_unlock(&bus->mdio_lock);
>  
>  	if(timeout <= 0) {
>  		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index e3ba14a..c69e654 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -109,7 +109,7 @@ int uec_mdio_reset(struct mii_bus *bus)
>  	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
>  	unsigned int timeout = PHY_INIT_TIMEOUT;
>  
> -	spin_lock_bh(&bus->mdio_lock);
> +	mutex_lock(&bus->mdio_lock);
>  
>  	/* Reset the management interface */
>  	out_be32(&regs->miimcfg, MIIMCFG_RESET_MANAGEMENT);
> @@ -121,7 +121,7 @@ int uec_mdio_reset(struct mii_bus *bus)
>  	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
>  		cpu_relax();
>  
> -	spin_unlock_bh(&bus->mdio_lock);
> +	mutex_unlock(&bus->mdio_lock);
>  

applied


