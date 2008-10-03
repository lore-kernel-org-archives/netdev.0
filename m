From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,CFT] dynamic struct mii_bus allocation
Date: Fri, 3 Oct 2008 11:43:15 +0200
Message-ID: <20081003094315.GA11391@xi.wantstofly.org>
References: <20081002101508.GA31074@xi.wantstofly.org> <200810031136.13365.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Michael Chan <mchan@broadcom.com>,
	Olof Johansson <olof@lixom.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Eugene Konev <ejka@imfi.kspu.ru>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Andy Fleming <afleming@freescale.com>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:38205 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbYJCJnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 05:43:19 -0400
Content-Disposition: inline
In-Reply-To: <200810031136.13365.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2008 at 11:36:01AM +0200, Laurent Pinchart wrote:

> Hi Lennert,

Hi Laurent,


> > You're listed as maintainer of one of the network drivers in the tree
> > that use phylib.  Available at the URL below is a change to the phylib
> > API (dynamic allocation of struct mii_bus, which is needed for hooking
> > up mdio buses into the device tree) that needs corresponding mdio bus
> > driver changes.  I've patched all mdio bus drivers I could find, and
> > tried not to break anything, but it's possible I might have
> > inadvertently broken something, so I'd like you to test these changes
> > and let me know if they work for you or not:
> > 
> > 	git://git.marvell.com/phylib.git master
> > 
> > As a side-effect of the last patch, you should end up with a list of
> > mdio buses in your system in /sys/class/mdio_bus.
> > 
> > 
> > thanks,
> > Lennert
> > 
> > 
> > The following changes since commit e69c4e0f1210450841e40716894ba6a877b31d52:
> >   Vlad Yasevich (1):
> >         sctp: correctly save sctp_adaptation from parameter.
> > 
> > are available in the git repository at:
> > 
> >   git://git.marvell.com/phylib.git master
> > 
> > Lennert Buytenhek (5):
> >       phylib: phy_mii_ioctl() fixes
> >       phylib: add mdiobus_{read,write}
> >       phylib: rename mii_bus::dev to mii_bus::parent
> >       phylib: move to dynamic allocation of struct mii_bus
> >       phylib: give mdio buses a device tree presence
> > 
> >  arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
> >  arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
> >  drivers/net/au1000_eth.c                  |   43 ++++++---
> >  drivers/net/au1000_eth.h                  |    2 +-
> >  drivers/net/bfin_mac.c                    |   31 ++++---
> >  drivers/net/bfin_mac.h                    |    2 +-
> >  drivers/net/cpmac.c                       |   51 ++++++----
> >  drivers/net/fec_mpc52xx_phy.c             |    8 +-
> >  drivers/net/fs_enet/mii-bitbang.c         |    9 +-
> >  drivers/net/fs_enet/mii-fec.c             |    8 +-
> >  drivers/net/gianfar_mii.c                 |    9 +-
> >  drivers/net/macb.c                        |   49 ++++++----
> >  drivers/net/macb.h                        |    2 +-
> >  drivers/net/mv643xx_eth.c                 |   32 ++++---
> 
> Just a side note, the patch "phylib: rename mii_bus::dev to
> mii_bus::parent" seems to do a lot more than just renaming mii_bus::dev
> to mii_bus::parent in drivers/net/mv643xx_eth.c. You might have
> inadvertently committed unrelated changes.

What commit ID are you looking at?  I only see this:

	commit def8867a8d2a9f474262dd46179770845a420d51
	Author: Lennert Buytenhek <buytenh@wantstofly.org>
	Date:   Tue Sep 23 02:35:17 2008 +0200

	    phylib: rename mii_bus::dev to mii_bus::parent
	    
	    In preparation of giving mii_bus objects a device tree presence of
	    their own, rename struct mii_bus's ->dev argument to ->parent, since
	    having a 'struct device *dev' that points to our parent device
	    conflicts with introducing a 'struct device dev' representing our own
	    device.
	    
	    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
	    Acked-by: Andy Fleming <afleming@freescale.com>

	[...]

	diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
	index 372811a..6340081 100644
	--- a/drivers/net/mv643xx_eth.c
	+++ b/drivers/net/mv643xx_eth.c
	@@ -2368,7 +2368,7 @@ static int mv643xx_eth_shared_probe(struct platform_device
			msp->smi_bus.read = smi_bus_read;
			msp->smi_bus.write = smi_bus_write,
			snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
	-               msp->smi_bus.dev = &pdev->dev;
	+               msp->smi_bus.parent = &pdev->dev;
			msp->smi_bus.phy_mask = 0xffffffff;
			if (mdiobus_register(&msp->smi_bus) < 0)
				goto out_unmap;



> >  drivers/net/phy/fixed.c                   |   29 ++++--
> >  drivers/net/phy/mdio-bitbang.c            |    4 +-
> >  drivers/net/phy/mdio-ofgpio.c             |   11 +-
> 
> Works fine for me. For the mdio-ofgpio part:
> 
> Acked-by: Laurent Pinchart <laurentp@cse-semaphore.com>

Thanks!


> BTW your "phylib: move to dynamic allocation of struct mii_bus"
> patch fixes a double free in drivers/net/phy/mdio-ofgpio.c. Thanks
> for catching this.

Yeah, sorry for not reporting that separately.  (I'm not sure if it's
worth fixing separately, since deinit probably doesn't happen very
often.)


cheers,
Lennert
