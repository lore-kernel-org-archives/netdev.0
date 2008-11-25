From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] DCB: fix kconfig option
Date: Mon, 24 Nov 2008 17:07:07 -0800
Message-ID: <492B4FBB.6040100@oracle.com>
References: <20081124234627.24425.44782.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55443 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbYKYBHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 20:07:24 -0500
In-Reply-To: <20081124234627.24425.44782.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> Since the netlink option for DCB is necessary to actually be useful,
> simplified the Kconfig option.  In addition, added useful help text for the
> Kconfig option.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/Kconfig            |    4 ++--
>  drivers/net/ixgbe/Makefile     |    2 +-
>  drivers/net/ixgbe/ixgbe.h      |    2 +-
>  drivers/net/ixgbe/ixgbe_main.c |   10 +++++-----
>  include/linux/netdevice.h      |    4 ++--
>  net/Makefile                   |    4 ++--
>  net/dcb/Kconfig                |   24 +++++++++++++++++-------
>  net/dcb/dcbnl.c                |    2 +-
>  8 files changed, 31 insertions(+), 21 deletions(-)

> diff --git a/net/Makefile b/net/Makefile
> index e5af3dc..4ccc0c7 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -56,8 +56,8 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
>  obj-$(CONFIG_IUCV)		+= iucv/
>  obj-$(CONFIG_RFKILL)		+= rfkill/
>  obj-$(CONFIG_NET_9P)		+= 9p/
> -ifeq ($(CONFIG_DCBNL),y)
> -obj-$(CONFIG_DCB)		+= dcb/
> +ifeq ($(CONFIG_DCB),)

ifeq {empty/nothing} ?  or ifeq y ?

> +obj-y				+= dcb/
>  endif
>  
>  ifeq ($(CONFIG_NET),y)
> diff --git a/net/dcb/Kconfig b/net/dcb/Kconfig
> index bdf3880..a250498 100644
> --- a/net/dcb/Kconfig
> +++ b/net/dcb/Kconfig
> @@ -1,12 +1,22 @@
>  config DCB
> -        tristate "Data Center Bridging support"
> -
> -config DCBNL
> -	bool "Data Center Bridging netlink interface support"
> -	depends on DCB
> +        bool "Data Center Bridging support"

Accidental conversion of tab to spaces.

>  	default n
>  	---help---
> -	  This option turns on the netlink interface
> -	  (dcbnl) for Data Center Bridging capable devices.
> +	  This enables support for configuring Data Center Bridging (DCB)
> +	  features on DCB capable Ethernet adapters via rtnetlink.  Say 'Y'
> +	  if you have a DCB capable Ethernet adapter which supports this
> +	  interface and you are connected to a DCB capable switch.
> +
> +	  DCB is a collection of Ethernet enhancements which allow DCB capable
> +	  NICs and switches to support network traffic with differing
> +	  requirements (highly reliable, no drops vs. best effort vs. low
> +	  latency) to co-exist on Ethernet.
> +
> +	  DCB features include:
> +	    Enhanced Transmission Selection (aka Priority Grouping) - provides a
> +	      framework for assigning bandwidth guarantees to traffic classes.
> +	    Priority-based Flow Control (PFC) - a MAC control pause frame which
> +	      works at the granularity of the 802.1p priority instead of the
> +	      link (802.3x).
>  
>  	  If unsure, say N.


-- 
~Randy
