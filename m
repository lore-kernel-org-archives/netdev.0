From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC 59/72] r6040: Move the RDC driver
Date: Sat, 25 Jun 2011 20:59:28 +0200
Message-ID: <201106252059.28085.florian@openwrt.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-60-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Sten Wang <sten.wang@rdc.com.tw>,
	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35684 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630Ab1FYS7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 14:59:35 -0400
Received: by wyg8 with SMTP id 8so416669wyg.19
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2011 11:59:34 -0700 (PDT)
In-Reply-To: <1309010363-22750-60-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff,

On Saturday 25 June 2011 15:59:10 Jeff Kirsher wrote:
> Move the RDC driver into drivers/net/ethernet/ and make the
> necessary Kconfig and Makefile changes.
> 
> CC: Sten Wang <sten.wang@rdc.com.tw>
> CC: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
> CC: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                        |    2 +-
>  drivers/net/Kconfig                |   13 -------------
>  drivers/net/Makefile               |    1 -
>  drivers/net/ethernet/Kconfig       |   14 ++++++++++++++
>  drivers/net/ethernet/Makefile      |    1 +
>  drivers/net/{ => ethernet}/r6040.c |    0
>  6 files changed, 16 insertions(+), 15 deletions(-)
>  rename drivers/net/{ => ethernet}/r6040.c (100%)

Why not move this to drivers/net/ethernet/rdc/r6040.c?

> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 9ddb715..f1f555d 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5258,7 +5258,7 @@ RDC R6040 FAST ETHERNET DRIVER
>  M:	Florian Fainelli <florian@openwrt.org>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> -F:	drivers/net/r6040.c
> +F:	drivers/net/ethernet/r6040.c
> 
>  RDS - RELIABLE DATAGRAM SOCKETS
>  M:	Andy Grover <andy.grover@oracle.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 82da415..463e4cf 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -404,19 +404,6 @@ config FEALNX
>  	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet
>  	  cards. <http://www.myson.com.tw/>
> 
> -config R6040
> -	tristate "RDC R6040 Fast Ethernet Adapter support"
> -	depends on NET_PCI && PCI
> -	select CRC32
> -	select MII
> -	select PHYLIB
> -	help
> -	  This is a driver for the R6040 Fast Ethernet MACs found in the
> -	  the RDC R-321x System-on-chips.
> -
> -	  To compile this driver as a module, choose M here: the module
> -	  will be called r6040. This is recommended.
> -
>  config NET_POCKET
>  	bool "Pocket and portable adapters"
>  	depends on PARPORT
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index b7e875a..f57a0be 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -16,7 +16,6 @@ obj-$(CONFIG_PLIP) += plip.o
> 
>  obj-$(CONFIG_ROADRUNNER) += rrunner.o
> 
> -obj-$(CONFIG_R6040) += r6040.o
>  obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
>  obj-$(CONFIG_FEALNX) += fealnx.o
>  obj-$(CONFIG_SKFP) += skfp/
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index f5eb70e..3c10879 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -98,6 +98,20 @@ config PASEMI_MAC
>  source "drivers/net/ethernet/qlogic/Kconfig"
>  source "drivers/net/ethernet/racal/Kconfig"
>  source "drivers/net/ethernet/radisys/Kconfig"
> +
> +config R6040
> +	tristate "RDC R6040 Fast Ethernet Adapter support"
> +	depends on PCI
> +	select CRC32
> +	select MII
> +	select PHYLIB
> +	---help---
> +	  This is a driver for the R6040 Fast Ethernet MACs found in the
> +	  the RDC R-321x System-on-chips.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called r6040. This is recommended.
> +
>  source "drivers/net/ethernet/realtek/Kconfig"
> 
>  config S6GMAC
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 2ccb194..537631b 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -41,6 +41,7 @@ obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
> pasemi_mac_ethtool.o obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
>  obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
>  obj-$(CONFIG_NET_VENDOR_RADISYS) += radisys/
> +obj-$(CONFIG_R6040) += r6040.o
>  obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
>  obj-$(CONFIG_S6GMAC) += s6gmac.o
>  obj-$(CONFIG_NET_VENDOR_SIS) += sis/
> diff --git a/drivers/net/r6040.c b/drivers/net/ethernet/r6040.c
> similarity index 100%
> rename from drivers/net/r6040.c
> rename to drivers/net/ethernet/r6040.c

-- 
Florian
