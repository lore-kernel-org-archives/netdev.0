From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Subject: Re: [PATCH]: ps3: gigabit ethernet driver for PS3
Date: Wed, 13 Jun 2007 17:48:44 +0900
Message-ID: <20070613160848.71DE.MOKUNO@sm.sony.co.jp>
References: <20070613154156.71DB.MOKUNO@sm.sony.co.jp> <20070613.000359.112622353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	geoffrey.levand@am.sony.com, Geert.Uytterhoeven@sonycom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:48395 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbXFMIs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 04:48:56 -0400
In-Reply-To: <20070613.000359.112622353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, 13 Jun 2007 00:03:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
> Date: Wed, 13 Jun 2007 15:58:01 +0900
> 
> > --- a/drivers/net/Makefile
> > +++ b/drivers/net/Makefile
> > @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
> >  obj-$(CONFIG_BNX2) += bnx2.o
> >  spidernet-y += spider_net.o spider_net_ethtool.o
> >  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> > +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> > +ps3_gelic-objs += gelic_net.o
> >  obj-$(CONFIG_TC35815) += tc35815.o
> >  obj-$(CONFIG_SKGE) += skge.o
> >  obj-$(CONFIG_SKY2) += sky2.o
> 
> Please just name the driver ps3_galic.c and use a single
> 
> obj-$(CONFIG_GELIC_NET) += ps3_galic.o


I have plan to add wireless support as I sent to this ML before as RFC,
like:

> +config GELIC_WIRELESS
> +	bool "Gelic net Wireless Extension"
> +	depends on GELIC_NET
> +	select WIRELESS_EXT
> +	help
> +	  Wireless Extension support for Gelic Gigabit Ethernet driver
> +
>  config GIANFAR
>  	tristate "Gianfar Ethernet"
>  	depends on 85xx || 83xx || PPC_86xx
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -61,7 +61,8 @@ obj-$(CONFIG_BNX2) += bnx2.o
>  spidernet-y += spider_net.o spider_net_ethtool.o
>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
>  obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> -ps3_gelic-objs += gelic_net.o
> +gelic-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o
> +ps3_gelic-objs += gelic_net.o $(gelic-y)
>  obj-$(CONFIG_TC35815) += tc35815.o
>  obj-$(CONFIG_SKGE) += skge.o
>  obj-$(CONFIG_SKY2) += sky2.o

That 'ps3_gelic' line change was made so that module file names can keep
consistent after the patch above applied.

Any ideas appreciated.

--
Masakazu MOKUNO

