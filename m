From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/6] mv643xx.c: Add basic device tree support.
Date: Tue, 31 Jul 2012 21:24:58 +0200
Message-ID: <20120731192458.GE28852@lunn.ch>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
 <1343749529-17571-4-git-send-email-ian.molton@codethink.co.uk>
 <201207311823.54857.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Molton <ian.molton@codethink.co.uk>,
	linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:43083 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661Ab2GaTZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 15:25:08 -0400
Content-Disposition: inline
In-Reply-To: <201207311823.54857.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 31, 2012 at 06:23:54PM +0000, Arnd Bergmann wrote:
> On Tuesday 31 July 2012, Ian Molton wrote:
> > @@ -33,6 +34,10 @@ struct of_dev_auxdata kirkwood_auxdata_lookup[] __initdata = {
> >  	OF_DEV_AUXDATA("marvell,orion-wdt", 0xf1020300, "orion_wdt", NULL),
> >  	OF_DEV_AUXDATA("marvell,orion-sata", 0xf1080000, "sata_mv.0", NULL),
> >  	OF_DEV_AUXDATA("marvell,orion-nand", 0xf4000000, "orion_nand", NULL),
> > +	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1072000, MV643XX_ETH_NAME ".0",
> > +			NULL),
> > +	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1076000, MV643XX_ETH_NAME ".1",
> > +			NULL),
> >  	{},
> >  };
> 
> Please don't do string concatenation like this, it just makes it harder to grep for the
> strings.

Hi Arnd

This pattern is used in other places, e.g. when creating the
clocks. The macro MV643XX_ETH_NAME is also used when creating the
platform data, and in the driver itself. 

Are you suggested we replace this with "mv643xx_eth.0"? Or is adding
the macro

#define MV643XX_ETH_NAME0 "mv643xx_eth.0" 

in include/linux/mv643xx_eth.h O.K, since grep will find it, and
induce the grep'er to perform a second grep on the macro?

     Andrew
