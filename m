From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2 0/2] phylib: Add support for MDIO clause 45
Date: Fri, 21 May 2010 13:31:49 -0500
Message-ID: <1274466711-24962-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:32894 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757610Ab0EUSbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 14:31:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO Clause 45 adds a new argument for accessing PHY registers, so
that you need the PHY address, the "device" address, and the register
address (which can now be up to 65,535).  It's best if, moving forward
we add this new device address argument to the MDIO read/write functions,
which means all of the current bus drivers need to be modified.

I opted not to modify the phy read/write functions mostly because all of the
existing code which calls those functions is correct as-is, and any code which
accesses the new 10G PHYs must do so in a fashion quite distinct from that
of accessing older PHYs (the registers are layed out differently, and the
initialization sequences are also quite different).

However, the MDIO buses are technically allowed to use both access mechanisms
on the same bus, so there's an advantage to adding support to all of the
current implementations.

Changes in v2:
Instead of using device address "0" to indicate a Clause 22 transaction, we
use Ben's suggestion of using MDIO_DEVAD_NONE.  Also, modify the PHY
identification code to allow Clauses 22 and 45 to coexist on the same bus.

Andy Fleming (2):
  phylib: Convert MDIO and PHY Lib drivers to support 10G
  phylib: Convert MDIO bitbang to new MDIO 45 format

 Documentation/networking/phy.txt          |   13 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
 drivers/net/arm/ixp4xx_eth.c              |    7 +-
 drivers/net/au1000_eth.c                  |    7 +-
 drivers/net/bcm63xx_enet.c                |    4 +-
 drivers/net/bfin_mac.c                    |    7 +-
 drivers/net/cpmac.c                       |    4 +-
 drivers/net/davinci_emac.c                |    5 +-
 drivers/net/dnet.c                        |    7 +-
 drivers/net/ethoc.c                       |    5 +-
 drivers/net/fec.c                         |    7 +-
 drivers/net/fec_mpc52xx_phy.c             |    7 +-
 drivers/net/fs_enet/mii-fec.c             |    6 +-
 drivers/net/fsl_pq_mdio.c                 |   13 +-
 drivers/net/fsl_pq_mdio.h                 |   11 +-
 drivers/net/greth.c                       |    5 +-
 drivers/net/ll_temac_mdio.c               |    5 +-
 drivers/net/macb.c                        |    7 +-
 drivers/net/mv643xx_eth.c                 |    5 +-
 drivers/net/phy/fixed.c                   |    5 +-
 drivers/net/phy/icplus.c                  |   15 ++-
 drivers/net/phy/mdio-bitbang.c            |   34 +++---
 drivers/net/phy/mdio-octeon.c             |    5 +-
 drivers/net/phy/mdio_bus.c                |    8 +-
 drivers/net/phy/phy_device.c              |  170 ++++++++++++++++++++++++++---
 drivers/net/s6gmac.c                      |    5 +-
 drivers/net/sb1250-mac.c                  |   14 ++-
 drivers/net/smsc911x.c                    |   19 ++--
 drivers/net/smsc9420.c                    |    9 +-
 drivers/net/stmmac/stmmac_mdio.c          |    9 +-
 drivers/net/tc35815.c                     |    5 +-
 drivers/net/tg3.c                         |    5 +-
 drivers/net/xilinx_emaclite.c             |    9 +-
 include/linux/phy.h                       |   57 ++++++++--
 34 files changed, 358 insertions(+), 142 deletions(-)

