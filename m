From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC 56/72] macb: Move the Atmel driver
Date: Mon, 27 Jun 2011 09:46:58 +0200
Message-ID: <4E083572.6050302@atmel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-57-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamie Iles <jamie@jamieiles.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:15302 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232Ab1F0HrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 03:47:25 -0400
In-Reply-To: <1309010363-22750-57-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le 25/06/2011 15:59, Jeff Kirsher :
> Move the Atmel driver into drivers/net/ethernet/atmel/ and

I am not sure that "atmel" is the proper name for a directory containing
the macb.c driver. This controller has not been made by atmel and will
be shared with others soon (Cf. paches by Jamie Iles).

So two questions remains:
- will we need to have a directory for this driver?
- what will be the name of this directory?

Best regards,

> make the necessary Kconfig and Makefile changes.
> 
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                             |    2 +-
>  drivers/net/Kconfig                     |   14 -------------
>  drivers/net/Makefile                    |    1 -
>  drivers/net/ethernet/Kconfig            |    1 +
>  drivers/net/ethernet/Makefile           |    1 +
>  drivers/net/ethernet/atmel/Kconfig      |   32 +++++++++++++++++++++++++++++++
>  drivers/net/ethernet/atmel/Makefile     |    5 ++++
>  drivers/net/{ => ethernet/atmel}/macb.c |    0
>  drivers/net/{ => ethernet/atmel}/macb.h |    0
>  9 files changed, 40 insertions(+), 16 deletions(-)
>  create mode 100644 drivers/net/ethernet/atmel/Kconfig
>  create mode 100644 drivers/net/ethernet/atmel/Makefile
>  rename drivers/net/{ => ethernet/atmel}/macb.c (100%)
>  rename drivers/net/{ => ethernet/atmel}/macb.h (100%)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 506d4d0..9ddb715 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1303,7 +1303,7 @@ F:	include/video/atmel_lcdc.h
>  ATMEL MACB ETHERNET DRIVER
>  M:	Nicolas Ferre <nicolas.ferre@atmel.com>
>  S:	Supported
> -F:	drivers/net/macb.*
> +F:	drivers/net/ethernet/atmel/
>  
>  ATMEL SPI DRIVER
>  M:	Nicolas Ferre <nicolas.ferre@atmel.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 9709106..7063b9c 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2,9 +2,6 @@
>  # Network device configuration
>  #
>  
> -config HAVE_NET_MACB
> -	bool
> -
>  menuconfig NETDEVICES
>  	default y if UML
>  	depends on NET
> @@ -224,17 +221,6 @@ menuconfig NET_ETHERNET
>  
>  if NET_ETHERNET
>  
> -config MACB
> -	tristate "Atmel MACB support"
> -	depends on HAVE_NET_MACB
> -	select PHYLIB
> -	help
> -	  The Atmel MACB ethernet interface is found on many AT32 and AT91
> -	  parts. Say Y to include support for the MACB chip.
> -
> -	  To compile this driver as a module, choose M here: the module
> -	  will be called macb.
> -
>  config SH_ETH
>  	tristate "Renesas SuperH Ethernet support"
>  	depends on SUPERH && \
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 5c189ab..a2a1e0a 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -68,7 +68,6 @@ obj-$(CONFIG_ETHOC) += ethoc.o
>  obj-$(CONFIG_GRETH) += greth.o
>  
>  obj-$(CONFIG_DNET) += dnet.o
> -obj-$(CONFIG_MACB) += macb.o
>  
>  obj-$(CONFIG_DEV_APPLETALK) += appletalk/
>  obj-$(CONFIG_ETHERNET) += ethernet/
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index fede911..e7c5f0b 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -39,6 +39,7 @@ config ARIADNE
>  
>  source "drivers/net/ethernet/arm/Kconfig"
>  source "drivers/net/ethernet/atheros/Kconfig"
> +source "drivers/net/ethernet/atmel/Kconfig"
>  source "drivers/net/ethernet/blackfin/Kconfig"
>  source "drivers/net/ethernet/broadcom/Kconfig"
>  source "drivers/net/ethernet/brocade/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index b8cc6ef..6c69e98 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
>  obj-$(CONFIG_ARIADNE) += ariadne.o
>  obj-$(CONFIG_NET_ARM) += arm/
>  obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
> +obj-$(CONFIG_NET_ATMEL) += atmel/
>  obj-$(CONFIG_NET_BFIN) += blackfin/
>  obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
>  obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
> diff --git a/drivers/net/ethernet/atmel/Kconfig b/drivers/net/ethernet/atmel/Kconfig
> new file mode 100644
> index 0000000..a8c11ea
> --- /dev/null
> +++ b/drivers/net/ethernet/atmel/Kconfig
> @@ -0,0 +1,32 @@
> +#
> +# Atmel device configuration
> +#
> +
> +config HAVE_NET_MACB
> +	bool
> +
> +config NET_ATMEL
> +	bool "Atmel devices"
> +	depends on HAVE_NET_MACB
> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say Y.
> +	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
> +	  available from <http://www.tldp.org/docs.html#howto>.
> +
> +	  If unsure, say Y.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the remaining Atmel network card questions. If you say Y, you will be
> +	  asked for your specific card in the following questions.
> +
> +config MACB
> +	tristate "Atmel MACB support"
> +	depends on NET_ATMEL && HAVE_NET_MACB
> +	select PHYLIB
> +	---help---
> +	  The Atmel MACB ethernet interface is found on many AT32 and AT91
> +	  parts. Say Y to include support for the MACB chip.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called macb.
> diff --git a/drivers/net/ethernet/atmel/Makefile b/drivers/net/ethernet/atmel/Makefile
> new file mode 100644
> index 0000000..91f79b1
> --- /dev/null
> +++ b/drivers/net/ethernet/atmel/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Atmel network device drivers.
> +#
> +
> +obj-$(CONFIG_MACB) += macb.o
> diff --git a/drivers/net/macb.c b/drivers/net/ethernet/atmel/macb.c
> similarity index 100%
> rename from drivers/net/macb.c
> rename to drivers/net/ethernet/atmel/macb.c
> diff --git a/drivers/net/macb.h b/drivers/net/ethernet/atmel/macb.h
> similarity index 100%
> rename from drivers/net/macb.h
> rename to drivers/net/ethernet/atmel/macb.h


-- 
Nicolas Ferre

