From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take2
Date: Tue, 03 Jul 2007 21:01:55 +0900
Message-ID: <20070703194416.91C5.MOKUNO@sm.sony.co.jp>
References: <20070619183956.F224.MOKUNO@sm.sony.co.jp> <4688EFD1.1060805@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:44069 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486AbXGCMCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 08:02:05 -0400
In-Reply-To: <4688EFD1.1060805@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 02 Jul 2007 08:30:09 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2264,6 +2264,16 @@ config TSI108_ETH
> >  	     To compile this driver as a module, choose M here: the module
> >  	     will be called tsi108_eth.
> >  
> > +config GELIC_NET
> > +	tristate "PS3 Gigabit Ethernet driver"
> > +	depends on PPC_PS3
> > +	help
> > +	  This driver supports the network device on the PS3 game
> > +	  console.  This driver has built-in support for Ethernet.
> > +
> > +	  To compile this driver as a module, choose M here: the
> > +	  module will be called ps3_gelic.
> > +
> >  config GIANFAR
> >  	tristate "Gianfar Ethernet"
> >  	depends on 85xx || 83xx || PPC_86xx
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
> > --- /dev/null
> > +++ b/drivers/net/gelic_net.c
> 
> The patch does not reflect the new name...

The driver's module name is 'ps3_gelic.ko' and the souce file names are
'gelic_net.{c,h}'.  As Geoff Levand said in the mail dated June 16, we
have plan to add wireless support and its file name would be gelic_wireless.c.
If this support added, the make file would be:

  obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
  gelic-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o
  ps3_gelic-objs += gelic_net.o $(gelic-y)

To avoid from changing the module name after adding wireless support, I
submitted with that name.


If the make file were like:

  obj-$(CONFIG_GELIC_NET) += gelic_net.o
  obj-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o

then we would get two modules gelic_net.ko and gelic_wireless.ko, which
we don't want.

--
Masakazu MOKUNO

