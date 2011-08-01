From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [net-next v2 42/71] cirrus: Move the Cirrus network driver
Date: Mon, 1 Aug 2011 15:23:30 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3882B82AF@AUSP01VMBX24.collaborationhost.net>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-43-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail132.messagelabs.com ([216.82.242.115]:16598 "EHLO
	mail132.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab1HAUXn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 16:23:43 -0400
In-Reply-To: <1312082850-24914-43-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, July 30, 2011 8:27 PM, Jeff Kirsher wrote:
>
> Move the Cirrus Ethernet driver into drivers/net/ethernet/cirrus/
> and make the necessary Kconfig and Makefile changes
> 
> CC: Hartley Sweeten <hsweeten@visionengravers.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I'm not sure why this is being done... Are all the Ethernet drivers being
moved into "vendor" sub-directories?

A couple comments below...

> ---
>  MAINTAINERS                                       |    2 +-
>  drivers/net/arm/Kconfig                           |    8 -------
>  drivers/net/arm/Makefile                          |    1 -
>  drivers/net/ethernet/Kconfig                      |    1 +
>  drivers/net/ethernet/Makefile                     |    1 +
>  drivers/net/ethernet/cirrus/Kconfig               |   24 +++++++++++++++++++++
>  drivers/net/ethernet/cirrus/Makefile              |    5 ++++
>  drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c |    0
>  8 files changed, 32 insertions(+), 10 deletions(-)
>  create mode 100644 drivers/net/ethernet/cirrus/Kconfig
>  create mode 100644 drivers/net/ethernet/cirrus/Makefile
>  rename drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c (100%)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 3c28188..d84f2c6 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1761,7 +1761,7 @@ CIRRUS LOGIC EP93XX ETHERNET DRIVER
>  M:	Hartley Sweeten <hsweeten@visionengravers.com>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> -F:	drivers/net/arm/ep93xx_eth.c
> +F:	drivers/net/ethernet/cirrus/ep93xx_eth.c
>  
>  CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
>  M:	Lennert Buytenhek <kernel@wantstofly.org>
> diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
> index 4f748cc..fc94b4b 100644
> --- a/drivers/net/arm/Kconfig
> +++ b/drivers/net/arm/Kconfig
> @@ -11,14 +11,6 @@ config ARM_AT91_ETHER
>  	  If you wish to compile a kernel for the AT91RM9200 and enable
>  	  ethernet support, then you should always answer Y to this.
>  
> -config EP93XX_ETH
> -	tristate "EP93xx Ethernet support"
> -	depends on ARM && ARCH_EP93XX
> -	select MII
> -	help
> -	  This is a driver for the ethernet hardware included in EP93xx CPUs.
> -	  Say Y if you are building a kernel for EP93xx based devices.
> -
>  config W90P910_ETH
>  	tristate "Nuvoton w90p910 Ethernet support"
>  	depends on ARM && ARCH_W90X900
> diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
> index 316b06c..462b3a4 100644
> --- a/drivers/net/arm/Makefile
> +++ b/drivers/net/arm/Makefile
> @@ -4,5 +4,4 @@
>  #
>  
>  obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
> -obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
>  obj-$(CONFIG_W90P910_ETH)	+= w90p910_ether.o
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index b15b1e2..ff07408 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -18,6 +18,7 @@ source "drivers/net/ethernet/atheros/Kconfig"
>  source "drivers/net/ethernet/broadcom/Kconfig"
>  source "drivers/net/ethernet/brocade/Kconfig"
>  source "drivers/net/ethernet/chelsio/Kconfig"
> +source "drivers/net/ethernet/cirrus/Kconfig"
>  source "drivers/net/ethernet/cisco/Kconfig"
>  source "drivers/net/ethernet/dec/Kconfig"
>  source "drivers/net/ethernet/dlink/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 1f45ec9..3a17413 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
>  obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
>  obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
>  obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
> +obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
>  obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
>  obj-$(CONFIG_NET_VENDOR_DEC) += dec/
>  obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
> diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
> new file mode 100644
> index 0000000..b48128b
> --- /dev/null
> +++ b/drivers/net/ethernet/cirrus/Kconfig
> @@ -0,0 +1,24 @@
> +#
> +# Cirrus network device configuration
> +#
> +
> +config NET_VENDOR_CIRRUS
> +	bool "Cirrus devices"
> +	depends on ARM && ARCH_EP93XX

I'm not sure this depends on is correct.

Cirrus also manufactures the CS8900A and CS8952 Ethernet controllers.  As far as I
can tell, these controllers are general purpose and not limited to ARM or ARCH_EP93XX.

> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about Cirrus cards. If you say Y, you will be asked
> +	  for your specific card in the following questions.
> +
> +config EP93XX_ETH
> +	tristate "EP93xx Ethernet support"
> +	depends on NET_VENDOR_CIRRUS && ARM && ARCH_EP93XX

The depends on ARM is redundant.  ARCH_EP93XX can only be selected if ARM is already
selected.

If drivers exist for the other two Cirrus controllers and are going to be moved
to this directory it might be cleaner to just block all the drivers in a

+if NET_VENDOR_CIRRUS
# add all config options for Cirrus Ethernet controllers
+endif 

> +	select MII
> +	help
> +	  This is a driver for the ethernet hardware included in EP93xx CPUs.
> +	  Say Y if you are building a kernel for EP93xx based devices.
> diff --git a/drivers/net/ethernet/cirrus/Makefile b/drivers/net/ethernet/cirrus/Makefile
> new file mode 100644
> index 0000000..9905ea2
> --- /dev/null
> +++ b/drivers/net/ethernet/cirrus/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Cirrus network device drivers.
> +#
> +
> +obj-$(CONFIG_EP93XX_ETH) += ep93xx_eth.o
> diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
> similarity index 100%
> rename from drivers/net/arm/ep93xx_eth.c
> rename to drivers/net/ethernet/cirrus/ep93xx_eth.c

Other than those comments...

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
