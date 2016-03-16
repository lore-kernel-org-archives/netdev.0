From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/1] net: stmmac: Don't search for phys if mdio node is
 defined.
Date: Wed, 16 Mar 2016 10:36:30 +0100
Message-ID: <56E9291E.6010503@st.com>
References: <1458027273-127737-1-git-send-email-preid@electromag.com.au> <1458027273-127737-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Reid <preid@electromag.com.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:42240 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964968AbcCPJgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:36:37 -0400
In-Reply-To: <1458027273-127737-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2016 8:34 AM, Phil Reid wrote:
> If a dt mdio entry has been added least assume that we wont
> search for phys attached. The DT and of_mdiobus_register already do
> this. This stops DSA phys being found and phys created for them, as
> this is handled by the DSA driver.

iiuc, this doesn't conflict with the recent rework we are doing
for the mdio/phy platform management.

> Signed-off-by: Phil Reid <preid@electromag.com.au>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 3f5512f..06704ca 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -235,6 +235,9 @@ int stmmac_mdio_register(struct net_device *ndev)
>   		goto bus_register_fail;
>   	}
>
> +	if (priv->plat->phy_node || mdio_node)
> +		goto bus_register_done;
> +
>   	found = 0;
>   	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
>   		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
> @@ -290,6 +293,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>   		return -ENODEV;
>   	}
>
> +bus_register_done:
>   	priv->mii = new_bus;
>
>   	return 0;
>
