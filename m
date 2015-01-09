From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: Re: [PATCH] net/fsl: Add mEMAC MDIO support to XGMAC MDIO
Date: Fri, 9 Jan 2015 14:11:32 -0600
Message-ID: <54B035F4.4020804@Freescale.com>
References: <1420364162-13109-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@gmail.com>,
	Shaohui Xie <Shaohui.Xie@Freescale.com>
To: <shh.xie@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0143.outbound.protection.outlook.com ([207.46.100.143]:35200
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750998AbbAIU02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 15:26:28 -0500
In-Reply-To: <1420364162-13109-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shao-Hui,


On 01/04/2015 03:36 AM, shh.xie@gmail.com wrote:
> From: Andy Fleming <afleming@gmail.com>
> 
> The Freescale mEMAC supports operating at 10/100/1000/10G, and
> its associated MDIO controller is likewise capable of operating
> both Clause 22 and Clause 45 MDIO buses. It is nearly identical
> to the MDIO controller on the XGMAC, so we just modify that
> driver.
> 
> Portions of this driver developed by:
> 
> Sandeep Singh <sandeep@freescale.com>
> Roy Zang <tie-fei.zang@freescale.com>
> 
> Signed-off-by: Andy Fleming <afleming@gmail.com>
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig      |  3 +-
>  drivers/net/ethernet/freescale/xgmac_mdio.c | 64 ++++++++++++++++++++++++-----
>  2 files changed, 55 insertions(+), 12 deletions(-)
> 
> 	...
> 
> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> index a352445..e0fc3d1 100644
> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> 
> 	...
> 
> @@ -123,21 +144,39 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 val
>  static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
>  {
>  	struct tgec_mdio_controller __iomem *regs = bus->priv;
> -	uint16_t dev_addr = regnum >> 16;
> +	uint16_t dev_addr;
> +	uint32_t mdio_stat;
>  	uint32_t mdio_ctl;
>  	uint16_t value;
>  	int ret;
>  
> +	mdio_stat = in_be32(&regs->mdio_stat);
> +	if (regnum & MII_ADDR_C45) {
> +		dev_addr = (regnum >> 16) & 0x1f;
> +		mdio_stat |= MDIO_STAT_ENC;
> +	} else {
> +		dev_addr = regnum & 0x1f;
> +		mdio_stat = ~MDIO_STAT_ENC;

Shouldn't this be 'mdio_stat &= ~MDIO_STAT_ENC'?


Cheers,
