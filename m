From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Tue, 22 Apr 2008 10:36:52 -0500
Message-ID: <20080422153652.GF15474@ld0162-tx32.am.freescale.net>
References: <200804161640.42693.laurentp@cse-semaphore.com> <200804221055.09038.laurentp@cse-semaphore.com> <20080422150844.GA15474@ld0162-tx32.am.freescale.net> <200804221721.51461.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:53806 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063AbYDVPhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 11:37:03 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m3MFarjM010686
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 08:36:53 -0700 (MST)
Received: from ld0162-tx32.am.freescale.net (ld0162-tx32.am.freescale.net [10.82.19.112])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3MFaqU1029401
	for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 10:36:52 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <200804221721.51461.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2008 at 05:21:49PM +0200, Laurent Pinchart wrote:
> As the openfirmware + gpio + mdio driver might benefit non-powerpc platforms, 
> I plan to create a new driver (probably drivers/net/phy/mdio-ofgpio.c) that 
> mostly ports drivers/net/fs_enet/mii-bitbang.c to the gpiolib (this replaces 
> around 90% of the code).
> 
> If both drivers/net/fs_enet/mii-bitbang.c and drivers/net/phy/mdio-ofgpio.c 
> must live together, 

The only reason I can see for that would be if the gpiolib version
doesn't work on arch/ppc -- but that's not going to be a problem for very
much longer.

> I'll have a problem in drivers/net/fs_enet/fs_enet-main.c. The net
> device probing code searches the device tree for an associated PHY, and
> creates a PHY id from the PHY node. As the id will be generated from
> different bus ids in the two mdio drivers (the bus number is the
> register address for drivers/net/fs_enet/mii-bitbang.c, and is the gpio
> index for drivers/net/phy/mdio-ofgpio.c), things will break.
> 
> Any idea regarding how to get rid of that fs_enet/mii-bitbang hardcoded 
> dependency ?

If mii-bitbang is only used on arch/ppc, then #ifdef CONFIG_PPC_MERGE
should do it.

It'd be nice to be able to give phylib an OF node rather than a string,
though...

-Scott
