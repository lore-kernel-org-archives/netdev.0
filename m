From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [net-next v2 69/71] xircom: Move the Xircom driver
Date: Sun, 31 Jul 2011 10:52:55 +0200
Message-ID: <20110731085255.GA19629@comet.dominikbrodowski.net>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-70-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, psheer@icon.co.za
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:41647 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751494Ab1GaI5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 04:57:42 -0400
Content-Disposition: inline
In-Reply-To: <1312082850-24914-70-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 08:27:28PM -0700, Jeff Kirsher wrote:
> Move the Xircom driver into drivers/net/ethernet/xircom/ and
> make the necessary Kconfig and Makefile changes.
> 
> CC: <psheer@icon.co.za>
> CC: Dominik Brodowski <linux@dominikbrodowski.net>
Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>

> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/xircom/Kconfig                |   26 ++++++++++++++++++++
>  drivers/net/ethernet/xircom/Makefile               |    5 ++++
>  .../net/{pcmcia => ethernet/xircom}/xirc2ps_cs.c   |    0
>  drivers/net/pcmcia/Kconfig                         |    9 -------
>  drivers/net/pcmcia/Makefile                        |    1 -
>  7 files changed, 33 insertions(+), 10 deletions(-)
>  create mode 100644 drivers/net/ethernet/xircom/Kconfig
>  create mode 100644 drivers/net/ethernet/xircom/Makefile
>  rename drivers/net/{pcmcia => ethernet/xircom}/xirc2ps_cs.c (100%)
> 
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index df8940d..f011665 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -160,5 +160,6 @@ source "drivers/net/ethernet/toshiba/Kconfig"
>  source "drivers/net/ethernet/tundra/Kconfig"
>  source "drivers/net/ethernet/via/Kconfig"
>  source "drivers/net/ethernet/xilinx/Kconfig"
> +source "drivers/net/ethernet/xircom/Kconfig"
>  
>  endif # ETHERNET
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 09f26b6..7f3b73c 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -69,3 +69,4 @@ obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
>  obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
>  obj-$(CONFIG_NET_VENDOR_VIA) += via/
>  obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
> +obj-$(CONFIG_NET_VENDOR_XIRCOM) += xircom/
> diff --git a/drivers/net/ethernet/xircom/Kconfig b/drivers/net/ethernet/xircom/Kconfig
> new file mode 100644
> index 0000000..0e01524
> --- /dev/null
> +++ b/drivers/net/ethernet/xircom/Kconfig
> @@ -0,0 +1,26 @@
> +#
> +# Xircom network device configuration
> +#
> +
> +config NET_VENDOR_XIRCOM
> +	bool "Xircom devices"
> +	depends on PCMCIA
> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about Xircom cards. If you say Y, you will be asked for
> +	  your specific card in the following questions.
> +
> +config PCMCIA_XIRC2PS
> +	tristate "Xircom 16-bit PCMCIA support"
> +	depends on NET_VENDOR_XIRCOM && PCMCIA
> +	---help---
> +	  Say Y here if you intend to attach a Xircom 16-bit PCMCIA (PC-card)
> +	  Ethernet or Fast Ethernet card to your computer.
> +
> +	  To compile this driver as a module, choose M here: the module will be
> +	  called xirc2ps_cs.  If unsure, say N.
> diff --git a/drivers/net/ethernet/xircom/Makefile b/drivers/net/ethernet/xircom/Makefile
> new file mode 100644
> index 0000000..3b7aebd
> --- /dev/null
> +++ b/drivers/net/ethernet/xircom/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Xircom network device drivers.
> +#
> +
> +obj-$(CONFIG_PCMCIA_XIRC2PS) += xirc2ps_cs.o
> diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
> similarity index 100%
> rename from drivers/net/pcmcia/xirc2ps_cs.c
> rename to drivers/net/ethernet/xircom/xirc2ps_cs.c
> diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
> index 80d291e..12e7ae4 100644
> --- a/drivers/net/pcmcia/Kconfig
> +++ b/drivers/net/pcmcia/Kconfig
> @@ -21,15 +21,6 @@ menuconfig NET_PCMCIA
>  
>  if NET_PCMCIA && PCMCIA
>  
> -config PCMCIA_XIRC2PS
> -	tristate "Xircom 16-bit PCMCIA support"
> -	help
> -	  Say Y here if you intend to attach a Xircom 16-bit PCMCIA (PC-card)
> -	  Ethernet or Fast Ethernet card to your computer.
> -
> -	  To compile this driver as a module, choose M here: the module will be
> -	  called xirc2ps_cs.  If unsure, say N.
> -
>  config ARCNET_COM20020_CS
>  	tristate "COM20020 ARCnet PCMCIA support"
>  	depends on ARCNET_COM20020
> diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
> index ccf5535..618e816 100644
> --- a/drivers/net/pcmcia/Makefile
> +++ b/drivers/net/pcmcia/Makefile
> @@ -3,7 +3,6 @@
>  #
>  
>  # 16-bit client drivers
> -obj-$(CONFIG_PCMCIA_XIRC2PS)	+= xirc2ps_cs.o
>  obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
>  
>  obj-$(CONFIG_PCMCIA_IBMTR)	+= ibmtr_cs.o
> -- 
> 1.7.6
> 
