From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Thu, 20 Sep 2007 03:26:10 -0400
Message-ID: <20070920072610.GA1521@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43490 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701AbXITH0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 03:26:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[this, sans patch which was too big for netdev, was just sent upstream.
 the patch can be recreated via 'git diff net-2.6.24..upstream']



NOTE that sky2 will also be going upstream for 2.6.23-rc, as just posted
on netdev.

Please pull from the 'upstream' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream

to receive the following changes:

Al Viro (20):
      8139cp: trivial endianness annotations
      endianness annotations drivers/net/bonding/
      fix vlan in 8139cp on big-endian
      3c59x: trivial endianness annotations, NULL noise removal
      amd8111e: trivial endianness annotations, NULL noise removal
      amd8111e big-endian fix
      arcnet endianness annotations
      tulip: endianness annotations
      typhoon: trivial endianness annotations
      pcnet32: endianness
      ixgb: endianness
      drivers/net/irda: endianness, NULL noise
      starfire: trivial endianness annotations
      r8169: endianness
      via-rhine: endianness
      pppoe: endianness
      tms380tr: trivial endianness annotations
      drivers/net/appletalk: endianness
      3c509: endianness
      cxgb3: trivial endianness annotations

Alex Landau (1):
      Blackfin EMAC driver: add function to change the MAC address

Bryan Wu (3):
      Blackfin EMAC driver: add power management interface and change the bf537mac_reset to bf537mac_disable
      Blackfin EMAC driver: Add phy abstraction layer supporting in bfin_emac driver
      Blackfin EMAC driver: add a select for the PHYLIB of this driver

David Gibson (1):
      Device tree aware EMAC driver

Dhananjay Phadke (1):
      netxen: ethtool fixes

Jeff Garzik (1):
      [netdrvr] Stop using legacy hooks ->self_test_count, ->get_stats_count

Maciej W. Rozycki (3):
      sb1250-mac.c: Fix "stats" references
      NET_SB1250_MAC: Update Kconfig entry
      NET_SB1250_MAC: Rename to SB1250_MAC

Sivakumar Subramani (4):
      S2io: Change kmalloc+memset to k[zc]alloc
      S2io: Removed unused feature - bimodal interrupts
      S2io: Added support set_mac_address driver entry point
      S2io: Updating transceiver information in ethtool function

Stephen Hemminger (3):
      sky2: fix VLAN receive processing (resend)
      sky2: ethtool speed report bug
      sky2: version 1.18

Ursula Braun (1):
      s390 networking MAINTAINERS

Vitaly Bordug (2):
      FS_ENET: TX stuff should use fep->tx_lock, instead of fep->lock.
      FS_ENET: Add polling support

 Documentation/powerpc/booting-without-of.txt |  156 +
 MAINTAINERS                                  |   12 
 arch/mips/configs/bigsur_defconfig           |    2 
 arch/mips/configs/sb1250-swarm_defconfig     |    2 
 arch/powerpc/platforms/44x/Kconfig           |    3 
 arch/powerpc/platforms/cell/Kconfig          |    4 
 drivers/net/3c509.c                          |    4 
 drivers/net/3c59x.c                          |   39 
 drivers/net/8139cp.c                         |   59 
 drivers/net/8139too.c                        |   11 
 drivers/net/Kconfig                          |   89 
 drivers/net/Makefile                         |    3 
 drivers/net/amd8111e.c                       |    9 
 drivers/net/amd8111e.h                       |   24 
 drivers/net/appletalk/ipddp.c                |    2 
 drivers/net/appletalk/ipddp.h                |    2 
 drivers/net/arcnet/rfc1051.c                 |    4 
 drivers/net/arcnet/rfc1201.c                 |    6 
 drivers/net/atl1/atl1_ethtool.c              |   11 
 drivers/net/b44.c                            |   11 
 drivers/net/bfin_mac.c                       |  347 ++-
 drivers/net/bfin_mac.h                       |   53 
 drivers/net/bnx2.c                           |   20 
 drivers/net/bonding/bond_3ad.c               |   42 
 drivers/net/bonding/bond_3ad.h               |   20 
 drivers/net/bonding/bond_alb.c               |   19 
 drivers/net/bonding/bond_alb.h               |    4 
 drivers/net/bonding/bond_main.c              |   22 
 drivers/net/bonding/bond_sysfs.c             |    8 
 drivers/net/bonding/bonding.h                |    6 
 drivers/net/cassini.c                        |   11 
 drivers/net/chelsio/cxgb2.c                  |   11 
 drivers/net/cxgb3/common.h                   |    4 
 drivers/net/cxgb3/cxgb3_main.c               |   11 
 drivers/net/cxgb3/sge.c                      |    6 
 drivers/net/e100.c                           |   19 
 drivers/net/e1000/e1000_ethtool.c            |   22 
 drivers/net/e1000e/ethtool.c                 |   21 
 drivers/net/ehea/ehea_ethtool.c              |   13 
 drivers/net/forcedeth.c                      |   45 
 drivers/net/fs_enet/fs_enet-main.c           |   77 
 drivers/net/fs_enet/mac-fcc.c                |   12 
 drivers/net/fs_enet/mac-fec.c                |   30 
 drivers/net/fs_enet/mac-scc.c                |   20 
 drivers/net/fs_enet/mii-bitbang.c            |   10 
 drivers/net/gianfar_ethtool.c                |   20 
 drivers/net/ibm_emac/Kconfig                 |   70 
 drivers/net/ibm_emac/ibm_emac_core.c         |   12 
 drivers/net/ibm_newemac/Kconfig              |   63 
 drivers/net/ibm_newemac/Makefile             |   11 
 drivers/net/ibm_newemac/core.c               | 2907 +++++++++++++++++++++++++++
 drivers/net/ibm_newemac/core.h               |  355 +++
 drivers/net/ibm_newemac/debug.c              |  238 ++
 drivers/net/ibm_newemac/debug.h              |   78 
 drivers/net/ibm_newemac/emac.h               |  268 ++
 drivers/net/ibm_newemac/mal.c                |  728 ++++++
 drivers/net/ibm_newemac/mal.h                |  276 ++
 drivers/net/ibm_newemac/phy.c                |  373 +++
 drivers/net/ibm_newemac/phy.h                |   80 
 drivers/net/ibm_newemac/rgmii.c              |  323 +++
 drivers/net/ibm_newemac/rgmii.h              |   76 
 drivers/net/ibm_newemac/tah.c                |  173 +
 drivers/net/ibm_newemac/tah.h                |   90 
 drivers/net/ibm_newemac/zmii.c               |  322 ++
 drivers/net/ibm_newemac/zmii.h               |   73 
 drivers/net/ibmveth.c                        |   11 
 drivers/net/irda/mcs7780.c                   |    2 
 drivers/net/irda/sir_dev.c                   |    2 
 drivers/net/irda/stir4200.c                  |    2 
 drivers/net/irda/vlsi_ir.h                   |    6 
 drivers/net/ixgb/ixgb_ee.c                   |   16 
 drivers/net/ixgb/ixgb_ee.h                   |   28 
 drivers/net/ixgb/ixgb_ethtool.c              |   15 
 drivers/net/ixgb/ixgb_hw.h                   |    4 
 drivers/net/ixgbe/ixgbe_ethtool.c            |   11 
 drivers/net/mv643xx_eth.c                    |   12 
 drivers/net/myri10ge/myri10ge.c              |   11 
 drivers/net/netxen/netxen_nic.h              |    2 
 drivers/net/netxen/netxen_nic_ethtool.c      |   48 
 drivers/net/netxen/netxen_nic_init.c         |    7 
 drivers/net/netxen/netxen_nic_main.c         |    1 
 drivers/net/pcnet32.c                        |  109 -
 drivers/net/pppoe.c                          |   18 
 drivers/net/qla3xxx.c                        |    2 
 drivers/net/r8169.c                          |   37 
 drivers/net/s2io.c                           |  404 +--
 drivers/net/s2io.h                           |    3 
 drivers/net/sb1250-mac.c                     |    2 
 drivers/net/sc92031.c                        |   11 
 drivers/net/skge.c                           |   11 
 drivers/net/sky2.c                           |   34 
 drivers/net/sky2.h                           |    2 
 drivers/net/spider_net_ethtool.c             |   11 
 drivers/net/starfire.c                       |   88 
 drivers/net/tc35815.c                        |   12 
 drivers/net/tg3.c                            |   19 
 drivers/net/tokenring/tms380tr.c             |    4 
 drivers/net/tokenring/tms380tr.h             |   18 
 drivers/net/tulip/de2104x.c                  |   12 
 drivers/net/tulip/de4x5.c                    |   10 
 drivers/net/tulip/tulip.h                    |   16 
 drivers/net/tulip/tulip_core.c               |   10 
 drivers/net/tulip/uli526x.c                  |    6 
 drivers/net/tulip/winbond-840.c              |    2 
 drivers/net/typhoon.c                        |   36 
 drivers/net/typhoon.h                        |  190 -
 drivers/net/ucc_geth_ethtool.c               |   26 
 drivers/net/veth.c                           |   11 
 drivers/net/via-rhine.c                      |   16 
 drivers/net/wireless/libertas/ethtool.c      |   72 
 include/linux/arcdevice.h                    |    4 
 include/linux/if_arcnet.h                    |    2 
 include/linux/if_pppox.h                     |   12 
 113 files changed, 7993 insertions(+), 1237 deletions(-)

