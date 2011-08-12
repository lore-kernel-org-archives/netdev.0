From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net organize Ethernet drivers (5th series)
Date: Fri, 12 Aug 2011 03:52:41 -0700
Message-ID: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212Ab1HLKwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the fifth of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/
  
The following are changes since commit 4c78893b3d107e2a053c8f51c526510857c09858:
  cnic: Fix select dependencies in bnx2fc/bnx2i Kconfig.
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  sis*: Move the Silicon Integrated Systems (SiS) drivers
  cirrus: Move the Cirrus network driver
  nuvoton: Move the Nuvoton driver
  tsi108*: Move the Tundra driver
  s6gmac: Move the s6gmac drivers
  davinci*/tlan/cpmac: Move the Texas Instruments (TI) drivers
  hamachi/yellowfin: Move the packet engine drivers
  octeon: Move the Cavium driver
  jme: Move the JME driver
  xilinx/ll_temac: Move the Xilinx drivers

 MAINTAINERS                                        |   14 +-
 drivers/net/Kconfig                                |  160 --------------------
 drivers/net/Makefile                               |   19 ---
 drivers/net/arm/Kconfig                            |   17 --
 drivers/net/arm/Makefile                           |    2 -
 drivers/net/ethernet/Kconfig                       |   33 ++++
 drivers/net/ethernet/Makefile                      |   10 ++
 drivers/net/ethernet/cirrus/Kconfig                |   28 ++++
 drivers/net/ethernet/cirrus/Makefile               |    5 +
 drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c  |    0
 drivers/net/{ => ethernet}/jme.c                   |    0
 drivers/net/{ => ethernet}/jme.h                   |    0
 drivers/net/ethernet/nuvoton/Kconfig               |   29 ++++
 drivers/net/ethernet/nuvoton/Makefile              |    5 +
 .../net/{arm => ethernet/nuvoton}/w90p910_ether.c  |    0
 drivers/net/{ => ethernet}/octeon/Kconfig          |    6 +-
 drivers/net/ethernet/octeon/Makefile               |    5 +
 drivers/net/{ => ethernet}/octeon/octeon_mgmt.c    |    0
 drivers/net/ethernet/packetengines/Kconfig         |   46 ++++++
 drivers/net/ethernet/packetengines/Makefile        |    6 +
 drivers/net/{ => ethernet/packetengines}/hamachi.c |    0
 .../net/{ => ethernet/packetengines}/yellowfin.c   |    0
 drivers/net/{ => ethernet}/s6gmac.c                |    0
 drivers/net/ethernet/sis/Kconfig                   |   50 ++++++
 drivers/net/ethernet/sis/Makefile                  |    6 +
 drivers/net/{ => ethernet/sis}/sis190.c            |    0
 drivers/net/{ => ethernet/sis}/sis900.c            |    0
 drivers/net/{ => ethernet/sis}/sis900.h            |    0
 drivers/net/ethernet/ti/Kconfig                    |   76 +++++++++
 drivers/net/ethernet/ti/Makefile                   |    9 +
 drivers/net/{ => ethernet/ti}/cpmac.c              |    0
 drivers/net/{ => ethernet/ti}/davinci_cpdma.c      |    0
 drivers/net/{ => ethernet/ti}/davinci_cpdma.h      |    0
 drivers/net/{ => ethernet/ti}/davinci_emac.c       |    0
 drivers/net/{ => ethernet/ti}/davinci_mdio.c       |    0
 drivers/net/{ => ethernet/ti}/tlan.c               |    0
 drivers/net/{ => ethernet/ti}/tlan.h               |    0
 drivers/net/ethernet/tundra/Kconfig                |   28 ++++
 drivers/net/ethernet/tundra/Makefile               |    5 +
 drivers/net/{ => ethernet/tundra}/tsi108_eth.c     |    0
 drivers/net/{ => ethernet/tundra}/tsi108_eth.h     |    0
 drivers/net/ethernet/xilinx/Kconfig                |   35 +++++
 drivers/net/ethernet/xilinx/Makefile               |    7 +
 drivers/net/{ => ethernet/xilinx}/ll_temac.h       |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_main.c  |    0
 drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c  |    0
 .../net/{ => ethernet/xilinx}/xilinx_emaclite.c    |    0
 drivers/net/octeon/Makefile                        |    2 -
 48 files changed, 395 insertions(+), 208 deletions(-)
 create mode 100644 drivers/net/ethernet/cirrus/Kconfig
 create mode 100644 drivers/net/ethernet/cirrus/Makefile
 rename drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c (100%)
 rename drivers/net/{ => ethernet}/jme.c (100%)
 rename drivers/net/{ => ethernet}/jme.h (100%)
 create mode 100644 drivers/net/ethernet/nuvoton/Kconfig
 create mode 100644 drivers/net/ethernet/nuvoton/Makefile
 rename drivers/net/{arm => ethernet/nuvoton}/w90p910_ether.c (100%)
 rename drivers/net/{ => ethernet}/octeon/Kconfig (85%)
 create mode 100644 drivers/net/ethernet/octeon/Makefile
 rename drivers/net/{ => ethernet}/octeon/octeon_mgmt.c (100%)
 create mode 100644 drivers/net/ethernet/packetengines/Kconfig
 create mode 100644 drivers/net/ethernet/packetengines/Makefile
 rename drivers/net/{ => ethernet/packetengines}/hamachi.c (100%)
 rename drivers/net/{ => ethernet/packetengines}/yellowfin.c (100%)
 rename drivers/net/{ => ethernet}/s6gmac.c (100%)
 create mode 100644 drivers/net/ethernet/sis/Kconfig
 create mode 100644 drivers/net/ethernet/sis/Makefile
 rename drivers/net/{ => ethernet/sis}/sis190.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.h (100%)
 create mode 100644 drivers/net/ethernet/ti/Kconfig
 create mode 100644 drivers/net/ethernet/ti/Makefile
 rename drivers/net/{ => ethernet/ti}/cpmac.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_cpdma.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_cpdma.h (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_emac.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_mdio.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.h (100%)
 create mode 100644 drivers/net/ethernet/tundra/Kconfig
 create mode 100644 drivers/net/ethernet/tundra/Makefile
 rename drivers/net/{ => ethernet/tundra}/tsi108_eth.c (100%)
 rename drivers/net/{ => ethernet/tundra}/tsi108_eth.h (100%)
 create mode 100644 drivers/net/ethernet/xilinx/Kconfig
 create mode 100644 drivers/net/ethernet/xilinx/Makefile
 rename drivers/net/{ => ethernet/xilinx}/ll_temac.h (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_main.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/ll_temac_mdio.c (100%)
 rename drivers/net/{ => ethernet/xilinx}/xilinx_emaclite.c (100%)
 delete mode 100644 drivers/net/octeon/Makefile

-- 
1.7.6

