From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take2
Date: Mon, 02 Jul 2007 08:30:09 -0400
Message-ID: <4688EFD1.1060805@garzik.org>
References: <20070619183956.F224.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51034 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758256AbXGBMaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:30:15 -0400
In-Reply-To: <20070619183956.F224.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MOKUNO Masakazu wrote:
> Hi,
> 
> This is the second submission of the network driver for PS3.
> This version have been updated to address issues raised in the review. 
> Please apply for 2.6.23.
> 
> From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> 
> Add Gigabit Ethernet support for the PS3 game console.  The module will
> be called ps3_gelic.
> 
> CC: Geoff Levand <geoffrey.levand@am.sony.com>
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  MAINTAINERS             |    6 
>  drivers/net/Kconfig     |   10 
>  drivers/net/Makefile    |    2 
>  drivers/net/gelic_net.c | 1578 ++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/gelic_net.h |  241 +++++++
>  5 files changed, 1837 insertions(+)
> 
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2920,6 +2920,12 @@ M:	mikpe@it.uu.se
>  L:	linux-ide@vger.kernel.org
>  S:	Maintained
>  
> +PS3 NETWORK SUPPORT
> +P:	Masakazu Mokuno
> +M:	mokuno@sm.sony.co.jp
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +
>  PS3 PLATFORM SUPPORT
>  P:	Geoff Levand
>  M:	geoffrey.levand@am.sony.com
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2264,6 +2264,16 @@ config TSI108_ETH
>  	     To compile this driver as a module, choose M here: the module
>  	     will be called tsi108_eth.
>  
> +config GELIC_NET
> +	tristate "PS3 Gigabit Ethernet driver"
> +	depends on PPC_PS3
> +	help
> +	  This driver supports the network device on the PS3 game
> +	  console.  This driver has built-in support for Ethernet.
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called ps3_gelic.
> +
>  config GIANFAR
>  	tristate "Gianfar Ethernet"
>  	depends on 85xx || 83xx || PPC_86xx
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
>  obj-$(CONFIG_BNX2) += bnx2.o
>  spidernet-y += spider_net.o spider_net_ethtool.o
>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> +ps3_gelic-objs += gelic_net.o
>  obj-$(CONFIG_TC35815) += tc35815.o
>  obj-$(CONFIG_SKGE) += skge.o
>  obj-$(CONFIG_SKY2) += sky2.o
> --- /dev/null
> +++ b/drivers/net/gelic_net.c

The patch does not reflect the new name...


