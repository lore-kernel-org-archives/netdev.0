From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 2/2] phylib: Convert MDIO bitbang to new MDIO 45
 format
Date: Fri, 21 May 2010 19:55:59 +0100
Message-ID: <1274468159.2089.5.camel@achroite.uk.solarflarecom.com>
References: <1274466711-24962-1-git-send-email-afleming@freescale.com>
	 <1274466711-24962-2-git-send-email-afleming@freescale.com>
	 <1274466711-24962-3-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54742 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157Ab0EUS4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 14:56:03 -0400
In-Reply-To: <1274466711-24962-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-21 at 13:31 -0500, Andy Fleming wrote:
> Now that we've added somewhat more complete MDIO 45 support to the PHY
> Lib, convert the MDIO bitbang driver to use this new infrastructure.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/phy/mdio-bitbang.c |   29 +++++++++++++++--------------
>  1 files changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
> index 2f6f02e..be7ae74 100644
> --- a/drivers/net/phy/mdio-bitbang.c
> +++ b/drivers/net/phy/mdio-bitbang.c
[...]
> @@ -157,11 +154,13 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
>  	struct mdiobb_ctrl *ctrl = bus->priv;
>  	int ret, i;
>  
> -	if (reg & MII_ADDR_C45) {
> -		reg = mdiobb_cmd_addr(ctrl, phy, reg);
> -		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, reg);
> -	} else
> +	/* Clause 22 PHYs only use devad = 0, and Clause 45 only use nonzero */
> +	if (devad == MDIO_DEVAD_NONE)
>  		mdiobb_cmd(ctrl, MDIO_READ, phy, reg);
> +	else {
> +		mdiobb_cmd_addr(ctrl, phy, devad, reg);
> +		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, devad);
> +	}
[...]

This comment is now wrong.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

