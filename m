From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix mdio section mismatch warning
Date: Tue, 17 Nov 2009 04:06:08 -0800 (PST)
Message-ID: <20091117.040608.76998645.davem@davemloft.net>
References: <20091117194733.bd2308a8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laurentp@cse-semaphore.com,
	paulius.zaleckas@teltonika.lt, mware@elphinstone.net
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755574AbZKQMFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:05:51 -0500
In-Reply-To: <20091117194733.bd2308a8.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 17 Nov 2009 19:47:33 +1100

> This fixes the following warning:
> 
> WARNING: drivers/net/phy/built-in.o(.devexit.text+0x70): Section mismatch in reference from the function .mdio_gpio_bus_destroy() to the function .devinit.text:.mdio_gpio_bus_deinit()
> The function __devexit .mdio_gpio_bus_destroy() references
> a function __devinit .mdio_gpio_bus_deinit().
> This is often seen when error handling in the exit function
> uses functionality in the init path.
> The fix is often to remove the __devinit annotation of
> .mdio_gpio_bus_deinit() so it may be used outside an init section.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied to net-2.6, thanks Stephen.

I wish there was a better way to handle this kind of situation as it's
a quite common pattern (exit cleanup function used by device init
functions) because currently we end up not being able to put such
things into either init or exit sections.
