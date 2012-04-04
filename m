From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Wed, 04 Apr 2012 08:59:49 +0200
Message-ID: <4F7BF165.6060106@st.com>
References: <1333475057-3752-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rayagond@vayavyalabs.com, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:53072 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751659Ab2DDHBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 03:01:12 -0400
In-Reply-To: <1333475057-3752-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2012 7:44 PM, Marc Kleine-Budde wrote:
> In commit (bfab27a stmmac: add the experimental PCI support) the

I get another patch associated to this commit:

git show db8857b
commit db8857bf5bd888d763e1984f9449d0b824b39ee1
Author: Florian Fainelli <florian@openwrt.org>
Date:   Mon Jan 9 23:59:20 2012 +0000

    stmmac: use an unique MDIO bus name.

    Signed-off-by: Florian Fainelli <florian@openwrt.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


maybe, the commit should be:

git-show bfab27a14
commit bfab27a146ed4d722c6d399f844f955f29cd2b81
Author: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date:   Wed Dec 21 03:58:19 2011 +0000

    stmmac: add the experimental PCI support


> IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup()
> function. This patch re-adds the flag.

Yes this flag was removed by this PCI patch.
So it makes sense to re-add it!

> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
> 
> Just compile time tested, since I don't have the hardware.
> Applies to net-next/master (and v3.3).
> 
> regards, Marc
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index e85ffbd..07e0c78 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1737,9 +1737,10 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>  	struct mac_device_info *mac;
>  
>  	/* Identify the MAC HW device */
> -	if (priv->plat->has_gmac)
> +	if (priv->plat->has_gmac) {
> +		priv->dev->priv_flags |= IFF_UNICAST_FLT;
>  		mac = dwmac1000_setup(priv->ioaddr);
> -	else
> +	} else
>  		mac = dwmac100_setup(priv->ioaddr);
>  	if (!mac)
>  		return -ENOMEM;
