From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 00/21] NET: use unique MDIO bus names
Date: Tue, 10 Jan 2012 10:59:06 +0100
Message-ID: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59556 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab2AJJ7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:59:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While troubleshooting an issue with an user of the RDC r6040 driver
having compiled support for the fixed MDIO bus, I noticed that quite
some network drivers will have a MDIO bus named "0" most of the time.

Some network drivers already try to provide an unique MDIO bus name
using their PCI slot and function, this is okay.

Some other network drivers will format the name using their platform_device
id, which will usually result in a collision with the fixed MDIO bus
name ("0"), these drivers are fixed to use the following pattern instead:

<platform_device name>-<platform device id> which is unique

Finally the MDIO bus drivers themselves are patched to use an unique name
as well.

There is a potential to break user-space applications assuming there is a
specific MDIO bus named "0", "1" or other non-explanatory names like this.

Note that I compile tested most of the drivers on x86 and MIPS, ARM and Blackfin
drivers have not been compile tested.

Florian Fainelli (21):
  ax88796: use an unique MDIO bus name.
  bfin_mac: use an unique MDIO bus name.
  au1000-eth: use an unique MDIO bus name.
  sb1250: use an unique MDIO bus name.
  macb: use an unique MDIO bus name.
  dnet: use an unique MDIO bus name.
  fec: use an unique MDIO bus name.
  lantiq_etop: use an unique MDIO bus name.
  mv643xx-eth: use an unique MDIO bus name.
  pxa168-eth: use an unique MDIO bus name.
  sh-eth: use an unique MDIO bus name.
  s6gmac: use an unique MDIO bus name.
  smsc911x: use an unique MDIO bus name.
  stmmac: use an unique MDIO bus name.
  cpmac: use an unique MDIO bus name.
  davinci_emac: use an unique MDIO bus name.
  ixp4xx-eth: use an unique MDIO bus name.
  bcm63xx_enet: use an unique MDIO bus name.
  phy/fixed: use an unique MDIO bus name.
  mdio-gpio: use an unique MDIO bus name.
  mdio-octeon: use an unique MDIO bus name.

 drivers/net/ethernet/8390/ax88796.c               |    3 ++-
 drivers/net/ethernet/adi/bfin_mac.c               |    3 ++-
 drivers/net/ethernet/amd/au1000_eth.c             |    3 ++-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c      |    2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c        |    3 ++-
 drivers/net/ethernet/cadence/macb.c               |    3 ++-
 drivers/net/ethernet/dnet.c                       |    3 ++-
 drivers/net/ethernet/freescale/fec.c              |    3 ++-
 drivers/net/ethernet/lantiq_etop.c                |    5 ++++-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |    3 ++-
 drivers/net/ethernet/marvell/pxa168_eth.c         |    3 ++-
 drivers/net/ethernet/renesas/sh_eth.c             |    3 ++-
 drivers/net/ethernet/s6gmac.c                     |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    3 ++-
 drivers/net/ethernet/ti/cpmac.c                   |    2 +-
 drivers/net/ethernet/ti/davinci_mdio.c            |    3 ++-
 drivers/net/ethernet/xscale/ixp4xx_eth.c          |    2 +-
 drivers/net/phy/fixed.c                           |    2 +-
 drivers/net/phy/mdio-gpio.c                       |    2 +-
 drivers/net/phy/mdio-octeon.c                     |    3 ++-
 22 files changed, 39 insertions(+), 22 deletions(-)

-- 
1.7.5.4
