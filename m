From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH][v2] phylib: add module owner to the mii_bus structure
Date: Mon, 14 Jan 2008 12:56:23 -0600
Message-ID: <CFE6E252-4CB9-4F91-ABE6-330798408E50@freescale.com>
References: <20071221153713.641f010e@deepthought> <78b2dab672856274c518f4c523f6f63f59f06dd1.1198861866.git.ionut.nicu@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Ionut Nicu <ionut.nicu@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:52561 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbYANS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:56:41 -0500
In-Reply-To: <78b2dab672856274c518f4c523f6f63f59f06dd1.1198861866.git.ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 28, 2007, at 11:31, Ionut Nicu wrote:

> Prevent unloading mii bus driver module when other modules have  
> references to some
> phydevs on that bus. Added a new member (module owner) to struct  
> mii_bus and added
> code to increment the mii bus owner module usage count on  
> phy_connect and decrement
> it on phy_disconnect
>
> Set the module owner in the ucc_geth_mdio driver.
>
> Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
> Tested-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
>  drivers/net/phy/phy_device.c |    9 ++++++++-
>  drivers/net/ucc_geth_mii.c   |    3 +++


> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index a3af4ea..84c7295 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -217,6 +217,9 @@ static int uec_mdio_probe(struct of_device  
> *ofdev, const struct of_device_id *ma
>  		}
>  	}
>
> +	/* register ourselves as the owner of this bus */
> +	new_bus->owner = THIS_MODULE;
> +
>  	err = mdiobus_register(new_bus);
>  	if (0 != err) {
>  		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",


Any reason you didn't update the other drivers?

 > git grep mdiobus_register drivers/net/          // duplicates and  
mdio_bus.c edited out
drivers/net/au1000_eth.c:       mdiobus_register(&aup->mii_bus);
drivers/net/bfin_mac.c: mdiobus_register(&lp->mii_bus);
drivers/net/cpmac.c:    res = mdiobus_register(&cpmac_mii);
drivers/net/fec_mpc52xx_phy.c:  err = mdiobus_register(bus);
drivers/net/fs_enet/mii-bitbang.c:      ret = mdiobus_register(new_bus);
drivers/net/fs_enet/mii-fec.c:  ret = mdiobus_register(new_bus);
drivers/net/gianfar_mii.c:      err = mdiobus_register(new_bus);
drivers/net/macb.c:     if (mdiobus_register(&bp->mii_bus))
drivers/net/sb1250-mac.c:       err = mdiobus_register(&sc->mii_bus);
drivers/net/ucc_geth_mii.c:     err = mdiobus_register(new_bus);

I'm guessing this was only tested on the UEC, because unless I  
misunderstand the code, any other driver would now crash when you try  
to get the owner.

Andy
