From: "Medve Emilian" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH 1/2] ucc_geth: split ucc_geth into two modules
Date: Fri, 21 Dec 2007 13:55:25 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E27018DF0C7@az33exm24.fsl.freescale.net>
References: <1198245443-13911-1-git-send-email-ionut.nicu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Nicu Ioan Petru" <ionut.nicu@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:50000 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbXLUUzj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 15:55:39 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id lBLKtQH0013168
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 13:55:30 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id lBLKtP6j000286
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:55:26 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <1198245443-13911-1-git-send-email-ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Emil Medve <Emilian.Medve@Freescale.com>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Nicu Ioan Petru
> Sent: Friday, December 21, 2007 7:57 AM
> To: netdev@vger.kernel.org
> Cc: Nicu Ioan Petru
> Subject: [PATCH 1/2] ucc_geth: split ucc_geth into two modules
> 
> Split ucc_geth_driver into 2 modules:
> 	- one module for the mii bus (phy devices register to this bus).
> 	- one module for the ethernet driver (uses phy_connect 
> to get a phydev from the mii bus)
> 
> Updated Makefile, Kconfig files and defconfigs (mpc836x, 
> mpc832x_mds, mpc832x_rdb).
> 
> Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
> ---
>  arch/powerpc/configs/mpc832x_mds_defconfig |    1 +
>  arch/powerpc/configs/mpc832x_rdb_defconfig |    1 +
>  arch/powerpc/configs/mpc836x_mds_defconfig |    1 +
>  drivers/net/Kconfig                        |    8 ++++++++
>  drivers/net/Makefile                       |    5 ++++-
>  drivers/net/ucc_geth.c                     |   18 +++++-------------
>  drivers/net/ucc_geth_mii.c                 |    9 +++++++++
>  7 files changed, 29 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/powerpc/configs/mpc832x_mds_defconfig 
> b/arch/powerpc/configs/mpc832x_mds_defconfig
> index 2d8951b..1c51739 100644
> --- a/arch/powerpc/configs/mpc832x_mds_defconfig
> +++ b/arch/powerpc/configs/mpc832x_mds_defconfig
> @@ -500,6 +500,7 @@ CONFIG_NETDEV_1000=y
>  # CONFIG_TIGON3 is not set
>  # CONFIG_BNX2 is not set
>  # CONFIG_GIANFAR is not set
> +CONFIG_UCC_MDIO=y
>  CONFIG_UCC_GETH=y
>  # CONFIG_UGETH_NAPI is not set
>  # CONFIG_UGETH_MAGIC_PACKET is not set
> diff --git a/arch/powerpc/configs/mpc832x_rdb_defconfig 
> b/arch/powerpc/configs/mpc832x_rdb_defconfig
> index 761718a..cb4d076 100644
> --- a/arch/powerpc/configs/mpc832x_rdb_defconfig
> +++ b/arch/powerpc/configs/mpc832x_rdb_defconfig
> @@ -503,6 +503,7 @@ CONFIG_E1000=y
>  # CONFIG_TIGON3 is not set
>  # CONFIG_BNX2 is not set
>  # CONFIG_GIANFAR is not set
> +CONFIG_UCC_MDIO=y
>  CONFIG_UCC_GETH=y
>  CONFIG_UGETH_NAPI=y
>  # CONFIG_UGETH_MAGIC_PACKET is not set
> diff --git a/arch/powerpc/configs/mpc836x_mds_defconfig 
> b/arch/powerpc/configs/mpc836x_mds_defconfig
> index c44fc56..92166e9 100644
> --- a/arch/powerpc/configs/mpc836x_mds_defconfig
> +++ b/arch/powerpc/configs/mpc836x_mds_defconfig
> @@ -499,6 +499,7 @@ CONFIG_NETDEV_1000=y
>  # CONFIG_TIGON3 is not set
>  # CONFIG_BNX2 is not set
>  # CONFIG_GIANFAR is not set
> +CONFIG_UCC_MDIO=y
>  CONFIG_UCC_GETH=y
>  # CONFIG_UGETH_NAPI is not set
>  # CONFIG_UGETH_MAGIC_PACKET is not set
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index d9107e5..7314802 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2315,9 +2315,17 @@ config GFAR_NAPI
>  	bool "Use Rx Polling (NAPI)"
>  	depends on GIANFAR
>  
> +config UCC_MDIO
> +	tristate "Freescale QE UCC MDIO Bus"
> +	depends on QUICC_ENGINE
> +	select PHYLIB
> +	help
> +	  Provides Bus interface for MII Management regs in the 
> UCC register space.
> +
>  config UCC_GETH
>  	tristate "Freescale QE Gigabit Ethernet"
>  	depends on QUICC_ENGINE
> +	select UCC_MDIO
>  	select PHYLIB
>  	help
>  	  This driver supports the Gigabit Ethernet mode of the 
> QUICC Engine,
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 0e5fde4..97843a3 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -22,8 +22,11 @@ gianfar_driver-objs := gianfar.o \
>  		gianfar_mii.o \
>  		gianfar_sysfs.o
>  
> +obj-$(CONFIG_UCC_MDIO) += ucc_geth_mdio.o
> +ucc_geth_mdio-objs := ucc_geth_mii.o
> +
>  obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
> -ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
> +ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
>  
>  #
>  # link order important here
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index c6a1902..c33a4cb 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1612,9 +1612,12 @@ static int init_phy(struct net_device *dev)
>  	priv->oldspeed = 0;
>  	priv->oldduplex = -1;
>  
> +	request_module("ucc_geth_mdio");
> +
>  	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, 
> priv->ug_info->mdio_bus,
>  			priv->ug_info->phy_address);
>  
> +
>  	phydev = phy_connect(dev, phy_id, &adjust_link, 0, 
> priv->phy_interface);
>  
>  	if (IS_ERR(phydev)) {
> @@ -4025,12 +4028,7 @@ static struct of_platform_driver 
> ucc_geth_driver = {
>  
>  static int __init ucc_geth_init(void)
>  {
> -	int i, ret;
> -
> -	ret = uec_mdio_init();
> -
> -	if (ret)
> -		return ret;
> +	int i;
>  
>  	if (netif_msg_drv(&debug))
>  		printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
> @@ -4038,18 +4036,12 @@ static int __init ucc_geth_init(void)
>  		memcpy(&(ugeth_info[i]), &ugeth_primary_info,
>  		       sizeof(ugeth_primary_info));
>  
> -	ret = of_register_platform_driver(&ucc_geth_driver);
> -
> -	if (ret)
> -		uec_mdio_exit();
> -
> -	return ret;
> +	return of_register_platform_driver(&ucc_geth_driver);
>  }
>  
>  static void __exit ucc_geth_exit(void)
>  {
>  	of_unregister_platform_driver(&ucc_geth_driver);
> -	uec_mdio_exit();
>  }
>  
>  module_init(ucc_geth_init);
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index df884f0..a3af4ea 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -17,6 +17,7 @@
>   */
>  
>  #include <linux/kernel.h>
> +#include <linux/module.h>
>  #include <linux/sched.h>
>  #include <linux/string.h>
>  #include <linux/errno.h>
> @@ -276,3 +277,11 @@ void uec_mdio_exit(void)
>  {
>  	of_unregister_platform_driver(&uec_mdio_driver);
>  }
> +
> +module_init(uec_mdio_init);
> +module_exit(uec_mdio_exit);
> +
> +MODULE_AUTHOR("Freescale Semiconductor, Inc");
> +MODULE_DESCRIPTION("QE UCC MDIO Bus Implementation");
> +MODULE_VERSION("1.0");
> +MODULE_LICENSE("GPL");
> -- 
> 1.5.4.rc0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
