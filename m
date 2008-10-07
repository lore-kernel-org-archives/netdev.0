From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: git pull request: phylib updates
Date: Tue, 7 Oct 2008 23:07:32 +0200
Message-ID: <20081007210732.GA21587@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:53212 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbYJGVHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:07:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Available at the git url below are a couple of phylib updates: one
minor semantic fix, the addition of mdiobus_{read,write} to be able to
access mii buses directly (without having to go through the phy layer),
and dynamic allocation of struct mii_bus structures so that we can tie
them to a struct device and make them appear in the device tree.

The last change in particular is invasive since it needs a change in
all mdio bus drivers, as they will now need to call mdiobus_alloc()
and mdiobus_free() to allocate and free mii bus structures.  In
particular, embedding a struct mii_bus inside another (driver-private)
structure is now no longer allowed.

The patches were reviewed by the phylib maintainer and ACKed, and he
was OK with me sending a pull request for them.


thanks,
Lennert


The following changes since commit e69c4e0f1210450841e40716894ba6a877b31d52:
  Vlad Yasevich (1):
        sctp: correctly save sctp_adaptation from parameter.

are available in the git repository at:

  git://git.marvell.com/phylib.git master

Lennert Buytenhek (5):
      phylib: phy_mii_ioctl() fixes
      phylib: add mdiobus_{read,write}
      phylib: rename mii_bus::dev to mii_bus::parent
      phylib: move to dynamic allocation of struct mii_bus
      phylib: give mdio buses a device tree presence

 arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
 drivers/net/au1000_eth.c                  |   43 ++++++---
 drivers/net/au1000_eth.h                  |    2 +-
 drivers/net/bfin_mac.c                    |   31 ++++---
 drivers/net/bfin_mac.h                    |    2 +-
 drivers/net/cpmac.c                       |   51 ++++++----
 drivers/net/fec_mpc52xx_phy.c             |    8 +-
 drivers/net/fs_enet/mii-bitbang.c         |    9 +-
 drivers/net/fs_enet/mii-fec.c             |    8 +-
 drivers/net/gianfar_mii.c                 |    9 +-
 drivers/net/macb.c                        |   49 ++++++----
 drivers/net/macb.h                        |    2 +-
 drivers/net/mv643xx_eth.c                 |   32 ++++---
 drivers/net/phy/fixed.c                   |   33 ++++---
 drivers/net/phy/mdio-bitbang.c            |    4 +-
 drivers/net/phy/mdio-ofgpio.c             |   11 +-
 drivers/net/phy/mdio_bus.c                |  144 ++++++++++++++++++++++++++++-
 drivers/net/phy/phy.c                     |   54 +----------
 drivers/net/sb1250-mac.c                  |   36 +++++---
 drivers/net/sh_eth.c                      |    4 +-
 drivers/net/tc35815.c                     |   45 ++++++----
 drivers/net/tg3.c                         |   66 +++++++-------
 drivers/net/tg3.h                         |    2 +-
 drivers/net/ucc_geth_mii.c                |    9 +-
 include/linux/phy.h                       |   54 ++++++++++--
 26 files changed, 458 insertions(+), 258 deletions(-)
