From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take2
Date: Tue, 3 Jul 2007 17:11:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0707031709040.8675@pademelon.sonytel.be>
References: <20070619183956.F224.MOKUNO@sm.sony.co.jp> <4688EFD1.1060805@garzik.org>
 <20070703194416.91C5.MOKUNO@sm.sony.co.jp> <468A4AED.7080907@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-584337861-129714989-1183475508=:8675"
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:36334 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756384AbXGCPL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 11:11:56 -0400
In-Reply-To: <468A4AED.7080907@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---584337861-129714989-1183475508=:8675
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jul 2007, Jeff Garzik wrote:
> Masakazu Mokuno wrote:
> > > > --- a/drivers/net/Makefile
> > > > +++ b/drivers/net/Makefile
> > > > @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
> > > >  obj-$(CONFIG_BNX2) += bnx2.o
> > > >  spidernet-y += spider_net.o spider_net_ethtool.o
> > > >  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> > > > +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> > > > +ps3_gelic-objs += gelic_net.o
> > > >  obj-$(CONFIG_TC35815) += tc35815.o
> > > >  obj-$(CONFIG_SKGE) += skge.o
> > > >  obj-$(CONFIG_SKY2) += sky2.o
> > > > --- /dev/null
> > > > +++ b/drivers/net/gelic_net.c
> > > The patch does not reflect the new name...
> > 
> > The driver's module name is 'ps3_gelic.ko' and the souce file names are
> > 'gelic_net.{c,h}'.  As Geoff Levand said in the mail dated June 16, we
> > have plan to add wireless support and its file name would be
> > gelic_wireless.c.
> > If this support added, the make file would be:
> > 
> >   obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> >   gelic-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o
> >   ps3_gelic-objs += gelic_net.o $(gelic-y)
> 
> 
> For single-file modules, the source file prefix should match the output file
> prefix.
> 
> No Linux driver does it any other way.  It leads to confusion.

Right now it's indeed a single source file module.

However, we are working on wireless support for gelic (the virtual network
device supports both wired and wireless), which will add a second source file.

So you want us to rename
  1. gelic_net.c -> ps3_gelic_net.c
  2. gelic_wireless.c -> ps3_gelic_wireless.c
while the actual kernel module will be ps3_gelic.{o,ko}, right?

With kind regards,
 
Geert Uytterhoeven
Software Architect

Sony Network and Software Technology Center Europe
The Corporate Village · Da Vincilaan 7-D1 · B-1935 Zaventem · Belgium
 
Phone:    +32 (0)2 700 8453	
Fax:      +32 (0)2 700 8622	
E-mail:   Geert.Uytterhoeven@sonycom.com	
Internet: http://www.sony-europe.com/
 	
Sony Network and Software Technology Center Europe	
A division of Sony Service Centre (Europe) N.V.	
Registered office: Technologielaan 7 · B-1840 Londerzeel · Belgium	
VAT BE 0413.825.160 · RPR Brussels	
Fortis Bank Zaventem · Swift GEBABEBB08A · IBAN BE39001382358619
---584337861-129714989-1183475508=:8675--
