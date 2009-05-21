From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 1/2] chelsio: Use generic XENPAK LASI register definitions
Date: Wed, 20 May 2009 18:51:36 -0700
Message-ID: <4A14B3A8.8040203@chelsio.com>
References: <1242775267.3198.8.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32652 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbZEUBvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 21:51:37 -0400
In-Reply-To: <1242775267.3198.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>   

Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
> This follows on from:
>
> commit 1c5022eb408e5d9ce48ffbd93d6e34d6f397a1e9
> Author: Ben Hutchings <bhutchings@solarflare.com>
> Date:   Fri May 15 00:47:59 2009 +0100
>
>     mdio: Add XENPAK LASI register definitions
>     
>     These registers were originally defined for XENPAK modules, but are
>     also implemented by many other 10G PHYs.
>
> Ben.
>
>  drivers/net/chelsio/mv88x201x.c |   17 +++++++++--------
>  1 files changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/chelsio/mv88x201x.c b/drivers/net/chelsio/mv88x201x.c
> index 29e0cba..d50907b 100644
> --- a/drivers/net/chelsio/mv88x201x.c
> +++ b/drivers/net/chelsio/mv88x201x.c
> @@ -86,7 +86,8 @@ static int mv88x201x_reset(struct cphy *cphy, int wait)
>  static int mv88x201x_interrupt_enable(struct cphy *cphy)
>  {
>  	/* Enable PHY LASI interrupts. */
> -	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, 0x9002, 0x1);
> +	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL,
> +			MDIO_PMA_LASI_LSALARM);
>  
>  	/* Enable Marvell interrupts through Elmer0. */
>  	if (t1_is_asic(cphy->adapter)) {
> @@ -102,7 +103,7 @@ static int mv88x201x_interrupt_enable(struct cphy *cphy)
>  static int mv88x201x_interrupt_disable(struct cphy *cphy)
>  {
>  	/* Disable PHY LASI interrupts. */
> -	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, 0x9002, 0x0);
> +	cphy_mdio_write(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL, 0x0);
>  
>  	/* Disable Marvell interrupts through Elmer0. */
>  	if (t1_is_asic(cphy->adapter)) {
> @@ -122,9 +123,9 @@ static int mv88x201x_interrupt_clear(struct cphy *cphy)
>  
>  #ifdef MV88x2010_LINK_STATUS_BUGS
>  	/* Required to read twice before clear takes affect. */
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9003, &val);
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9004, &val);
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9005, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_RXSTAT, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_TXSTAT, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT, &val);
>  
>  	/* Read this register after the others above it else
>  	 * the register doesn't clear correctly.
> @@ -135,12 +136,12 @@ static int mv88x201x_interrupt_clear(struct cphy *cphy)
>  	/* Clear link status. */
>  	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_STAT1, &val);
>  	/* Clear PHY LASI interrupts. */
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9005, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT, &val);
>  
>  #ifdef MV88x2010_LINK_STATUS_BUGS
>  	/* Do it again. */
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9003, &val);
> -	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, 0x9004, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_RXSTAT, &val);
> +	cphy_mdio_read(cphy, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_TXSTAT, &val);
>  #endif
>  
>  	/* Clear Marvell interrupts through Elmer0. */
>
>   

