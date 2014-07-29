From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] net/fsl: Add format length modifier to avoid negative
 values
Date: Tue, 29 Jul 2014 13:29:29 -0700
Message-ID: <53D80429.8070800@infradead.org>
References: <1406663583-8824-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shruti Kanetkar <Shruti@Freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39254 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaG2U3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 16:29:34 -0400
In-Reply-To: <1406663583-8824-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/14 12:53, Shruti Kanetkar wrote:
> Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
> ---
>  drivers/net/ethernet/freescale/xgmac_mdio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> index 8173407..6e7db66 100644
> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> @@ -163,7 +163,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
>  	/* Return all Fs if nothing was there */
>  	if (in_be32(&regs->mdio_stat) & MDIO_STAT_RD_ER) {
>  		dev_err(&bus->dev,
> -			"Error while reading PHY%d reg at %d.%d\n",
> +			"Error while reading PHY%d reg at %d.%hhu\n",

I don't get it.  Please explain better.

regnum is not an unsigned char, but that is what %hhu indicates, isn't it?

>  			phy_id, dev_addr, regnum);

Earlier in the code, dev_addr is set to:
	uint16_t dev_addr = regnum >> 16;

and then we see that the register address is the low 16 bits of regnum:
	/* Set the register address */
	out_be32(&regs->mdio_addr, regnum & 0xffff);

so maybe this printk (dev_err) should just use regnum & 0xffff and %u format?

I'm certainly not sure about that suggestion, but the patch didn't make sense to me.

Thanks.

>  		return 0xffff;
>  	}
> 


-- 
~Randy
