From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] stmmac: Enable Clause 45 PHYs in GMAC4 (eQOS)
Date: Thu, 5 Jan 2017 01:37:37 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A91819D@PGSMSX102.gar.corp.intel.com>
References: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:6307 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969994AbdAEBhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 20:37:43 -0500
In-Reply-To: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joao Pinto [mailto:Joao.Pinto@synopsys.com]
> Sent: Wednesday, January 04, 2017 10:36 PM
> To: davem@davemloft.net
> Cc: Kweh, Hock Leong <hock.leong.kweh@intel.com>; netdev@vger.kernel.org;
> Joao Pinto <Joao.Pinto@synopsys.com>
> Subject: [PATCH] stmmac: Enable Clause 45 PHYs in GMAC4 (eQOS)
> 
> The eQOS IP Core (best known in stmmac as gmac4) has a register that must be
> set if using a Clause 45 PHY. If this register is not set, the PHY won't work.
> This patch will have no impact in setups using Clause 22 PHYs.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Hi Joao,

This is not working on our environment. We are using the 4-ETH-4-MGB-101 plugin card.

Regards,
Wilson

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index b0344c2..676ae3c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -41,6 +41,7 @@
>  #define MII_GMAC4_GOC_SHIFT		2
>  #define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
>  #define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
> +#define MII_CLAUSE45_PHY		(1 << 1)
> 
>  static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int
> mii_addr)  { @@ -125,7 +126,7 @@ static int stmmac_mdio_write(struct
> mii_bus *bus, int phyaddr, int phyreg,
>  	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
>  		& priv->hw->mii.clk_csr_mask;
>  	if (priv->plat->has_gmac4)
> -		value |= MII_GMAC4_WRITE;
> +		value |= MII_GMAC4_WRITE | MII_CLAUSE45_PHY;
>  	else
>  		value |= MII_WRITE;
> 
> --
> 2.9.3
