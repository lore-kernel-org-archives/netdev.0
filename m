From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] net: stmmac: Delete dead code for MDIO
 registration
Date: Mon, 21 Aug 2017 17:45:11 -0700
Message-ID: <6ea649a3-4418-8025-44a9-72330f632f22@gmail.com>
References: <20170821114530.13706-1-romain.perier@collabora.com>
 <20170821114530.13706-2-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821114530.13706-2-romain.perier@collabora.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/21/2017 04:45 AM, Romain Perier wrote:
> This code is no longer used, the logging function was changed by commit
> fbca164776e4 ("net: stmmac: Use the right logging functi").
> 
> Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 16 ----------------
>  1 file changed, 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 72ec711fcba2..f5f37bfa1d58 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -248,9 +248,6 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	found = 0;
>  	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
>  		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
> -		int act = 0;
> -		char irq_num[4];
> -		char *irq_str;
>  
>  		if (!phydev)
>  			continue;
> @@ -273,19 +270,6 @@ int stmmac_mdio_register(struct net_device *ndev)
>  		if (priv->plat->phy_addr == -1)
>  			priv->plat->phy_addr = addr;
>  
> -		act = (priv->plat->phy_addr == addr);
> -		switch (phydev->irq) {
> -		case PHY_POLL:
> -			irq_str = "POLL";
> -			break;
> -		case PHY_IGNORE_INTERRUPT:
> -			irq_str = "IGNORE";
> -			break;
> -		default:
> -			sprintf(irq_num, "%d", phydev->irq);
> -			irq_str = irq_num;
> -			break;
> -		}

I was actually just looking into moving these prints to
phy_attached_info(), since it is useful to know whether the interrupt is
POLL, IGNORE, or valid. Can you move that there? Then you can really
migrate over phy_attached_info() with no information loss.

Thanks!
-- 
Florian
