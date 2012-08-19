From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/fsl: introduce Freescale 10G MDIO driver
Date: Sun, 19 Aug 2012 22:57:24 +0200
Message-ID: <20120819205724.GA27555@electric-eye.fr.zoreil.com>
References: <1345233792-14985-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38964 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab2HSVNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 17:13:00 -0400
Content-Disposition: inline
In-Reply-To: <1345233792-14985-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi <timur@freescale.com> :
> Similar to fsl_pq_mdio.c, this driver is for the 10G MDIO controller on
> Freescale Frame Manager Ethernet controllers.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
[...]
> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> new file mode 100644
> index 0000000..1894476
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
[...]
> +static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 value)
> +{
> +	struct tgec_mdio_controller __iomem *regs = bus->priv;
> +	uint16_t dev_addr = regnum >> 16;
> +	uint32_t status;
> +
> +	/* Setup the MII Mgmt clock speed */
> +	out_be32(&regs->mdio_stat, MDIO_STAT_CLKDIV(100));
> +
> +	/* Wait till the bus is free */
> +	status = spin_event_timeout(
> +		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
> +	if (!status) {
> +		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
> +		return -ETIMEDOUT;
> +	}

This code - comment included - is repeated several times. You may
consider factoring it out in some xgmac_mdio_free_bus_wait function.

-- 
Ueimor
