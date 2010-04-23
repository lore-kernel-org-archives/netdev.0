From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 2/2] phylib: Convert MDIO bitbang to new MDIO 45 format
Date: Fri, 23 Apr 2010 11:22:08 +0100
Message-ID: <1272018128.11697.37.camel@localhost>
References: <1271997497-6896-1-git-send-email-afleming@freescale.com>
	 <1271997497-6896-2-git-send-email-afleming@freescale.com>
	 <1271997497-6896-3-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7337 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab0DWKWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 06:22:15 -0400
In-Reply-To: <1271997497-6896-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 23:38 -0500, Andy Fleming wrote:
> Now that we've added somewhat more complete MDIO 45 support to the PHY
> Lib, convert the MDIO bitbang driver to use this new infrastructure.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/phy/mdio-bitbang.c |   23 +++++++++++------------
>  1 files changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
> index 2f6f02e..4c0c89b 100644
> --- a/drivers/net/phy/mdio-bitbang.c
> +++ b/drivers/net/phy/mdio-bitbang.c
[...]
> @@ -157,9 +154,10 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
>  	struct mdiobb_ctrl *ctrl = bus->priv;
>  	int ret, i;
>  
> -	if (reg & MII_ADDR_C45) {
> -		reg = mdiobb_cmd_addr(ctrl, phy, reg);
> -		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, reg);
> +	/* Clause 22 PHYs only use devad = 0, and Clause 45 only use nonzero */
> +	if (devad) {
> +		mdiobb_cmd_addr(ctrl, phy, devad, reg);
> +		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, devad);
>  	} else
>  		mdiobb_cmd(ctrl, MDIO_READ, phy, reg);
>  
[...]

I don't believe there's any protocol requirement in clause 45 that
devad != 0 (although the address is not allocated).  In the mdio module
I played safe and defined MDIO_DEVAD_NONE == -1 to indicate a clause 22
request.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

