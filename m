From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [PATCH,CFT] dynamic struct mii_bus allocation
Date: Sat, 4 Oct 2008 00:57:20 +0400
Message-ID: <20081003205720.GA31330@server.dev.rtsoft.ru>
References: <20081002101508.GA31074@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Olof Johansson <olof@lixom.net>,
	Kumar Gala <galak@kernel.crashing.org>,
	Eugene Konev <ejka@imfi.kspu.ru>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Andy Fleming <afleming@freescale.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:56184 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752094AbYJCVEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 17:04:04 -0400
Content-Disposition: inline
In-Reply-To: <20081002101508.GA31074@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 12:15 +0200, Lennert Buytenhek wrote:
> Hi *,
> 
> You're listed as maintainer of one of the network drivers in the tree
> that use phylib.  Available at the URL below is a change to the phylib
> API (dynamic allocation of struct mii_bus, which is needed for hooking
> up mdio buses into the device tree) that needs corresponding mdio bus
> driver changes.  I've patched all mdio bus drivers I could find, and
> tried not to break anything, but it's possible I might have
> inadvertently broken something, so I'd like you to test these changes
> and let me know if they work for you or not:
> 
> 	git://git.marvell.com/phylib.git master
> 
> As a side-effect of the last patch, you should end up with a list of
> mdio buses in your system in /sys/class/mdio_bus.
> 
> 
> thanks,
> Lennert
> 
> 
> The following changes since commit e69c4e0f1210450841e40716894ba6a877b31d52:
>   Vlad Yasevich (1):
>         sctp: correctly save sctp_adaptation from parameter.
> 
> are available in the git repository at:
> 
>   git://git.marvell.com/phylib.git master
> 
> Lennert Buytenhek (5):
>       phylib: phy_mii_ioctl() fixes
>       phylib: add mdiobus_{read,write}
>       phylib: rename mii_bus::dev to mii_bus::parent
>       phylib: move to dynamic allocation of struct mii_bus
>       phylib: give mdio buses a device tree presence

looks good, thanks!

Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>

> 
>  arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
>  arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
>  drivers/net/au1000_eth.c                  |   43 ++++++---
>  drivers/net/au1000_eth.h                  |    2 +-
>  drivers/net/bfin_mac.c                    |   31 ++++---
>  drivers/net/bfin_mac.h                    |    2 +-
>  drivers/net/cpmac.c                       |   51 ++++++----
>  drivers/net/fec_mpc52xx_phy.c             |    8 +-
>  drivers/net/fs_enet/mii-bitbang.c         |    9 +-
>  drivers/net/fs_enet/mii-fec.c             |    8 +-
>  drivers/net/gianfar_mii.c                 |    9 +-
>  drivers/net/macb.c                        |   49 ++++++----
>  drivers/net/macb.h                        |    2 +-
>  drivers/net/mv643xx_eth.c                 |   32 ++++---
>  drivers/net/phy/fixed.c                   |   29 ++++--
>  drivers/net/phy/mdio-bitbang.c            |    4 +-
>  drivers/net/phy/mdio-ofgpio.c             |   11 +-
>  drivers/net/phy/mdio_bus.c                |  144 ++++++++++++++++++++++++++++-
>  drivers/net/phy/phy.c                     |   54 +----------
>  drivers/net/sb1250-mac.c                  |   36 +++++---
>  drivers/net/sh_eth.c                      |    4 +-
>  drivers/net/tc35815.c                     |   45 ++++++----
>  drivers/net/tg3.c                         |   66 +++++++-------
>  drivers/net/tg3.h                         |    2 +-
>  drivers/net/ucc_geth_mii.c                |    9 +-
>  include/linux/phy.h                       |   54 ++++++++++--
>  26 files changed, 456 insertions(+), 256 deletions(-)
