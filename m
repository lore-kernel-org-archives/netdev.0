From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH v2] stmmac: Don't exit mdio registration when mdio subnode
 is not found in the DTS
Date: Fri, 8 Jan 2016 16:04:58 +0800
Message-ID: <568F6DAA.9000205@electromag.com.au>
References: <1452197608-29060-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rockchip@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy3.45ru.net.au ([203.30.46.155]:47680 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751672AbcAHIFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 03:05:00 -0500
In-Reply-To: <1452197608-29060-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/01/2016 4:13 AM, Romain Perier wrote:
> Originally, most of the platforms using this driver did not define an mdio subnode
> in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio bus for stmmac driver")
> introduced a backward compatibily issue by using of_mdiobus_register explicitly
> with an mdio subnode. This patch fixes the issue by calling the function
> mdiobus_register, when mdio subnode is not found. The driver is now compatible
> with both modes.
>
> Fixes: e34d65696d2e ("stmmac: create of compatible mdio bus for stmmac driver")
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>
> Changes in v2:
> 	- Removed IS_ENABLED macro from the if statement before calling
> 	  of_mdiobus_register.
> 	- Added Fixes tag in commit message
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 16c85cc..648488d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -218,8 +218,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>   		if (mdio_node) {
>   			netdev_dbg(ndev, "FOUND MDIO subnode\n");
>   		} else {
> -			netdev_err(ndev, "NO MDIO subnode\n");
> -			return 0;
> +			netdev_warn(ndev, "No MDIO subnode found\n");
>   		}
>   	}
>
> @@ -251,7 +250,10 @@ int stmmac_mdio_register(struct net_device *ndev)
>   	new_bus->phy_mask = mdio_bus_data->phy_mask;
>   	new_bus->parent = priv->device;
>
> -	err = of_mdiobus_register(new_bus, mdio_node);
> +	if (mdio_node)
> +		err = of_mdiobus_register(new_bus, mdio_node);
> +	else
> +		err = mdiobus_register(new_bus);
>   	if (err != 0) {
>   		pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
>   		goto bus_register_fail;
>
Tested-by: Phil Reid <preid@electromag.com.au>

-- 
Regards
Phil Reid
