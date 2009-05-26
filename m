From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Tue, 26 May 2009 13:20:06 +0200
Message-ID: <20090526112006.GH22742@pengutronix.de>
References: <200905242327.15139.arnd@arndb.de> <200905261010.31364.arnd@arndb.de> <20090526.022508.238274281.davem@davemloft.net> <200905261042.05967.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	wg@grandegger.com, devicetree-discuss@ozlabs.org,
	netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48946 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbZEZLUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 07:20:21 -0400
Content-Disposition: inline
In-Reply-To: <200905261042.05967.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2009 at 10:42:05AM +0100, Arnd Bergmann wrote:
> On Tuesday 26 May 2009, David Miller wrote:
> > It's such a baroque thing, there is no reason to set it at all if you
> > ask me.  It's only use is to allow ISA and similar primitive bus
> > devices to have their I/O ports changed via ifconfig.
> 
> My original comment was about the fact that sja1000 was doing
> dev->base_addr = (unsigned long)ioremap(phys_addr, size), I didn't
> even think about SIOCGIFMAP and command line overrides, but that
> surely makes it worse and the driver should be changed to
> store the virtual register address in its private data structure.
> 
> drivers/net/fec.c seems to have the same problem, which manifests
> in a number of ugly casts and direct pointer dereferences in places
> where it should do writel() or out_be32().

Ack. I'll prepare a patch for fec.c. Internally the driver already uses
a void __iomem * and writel/readl in -next. There is only one usage
left.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
