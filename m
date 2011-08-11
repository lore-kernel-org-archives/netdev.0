From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10] drivers/net organize Ethernet drivers (3rd series)
Date: Thu, 11 Aug 2011 16:39:48 -0700
Message-ID: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11581 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab1HKXkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 19:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third of seven 10 patch series to move the Ethernet
drivers into drivers/net/ethernet/

The following are changes since commit e7c379d2a0dcb8c30cb580184a0df11805464703:
  rtnetlink: remove initialization of dev->real_num_tx_queues
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Jeff Kirsher (10):
  pasemic_mac*: Move the PA Semi driver
  tehuti: Move the Tehuti driver
  stmmac: Move the STMicroelectronics driver
  bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) drivers
  *sonic/natsemi/ns83829: Move the National Semi-conductor drivers
  xscale: Move the Intel XScale IXP drivers
  ftgmac100/ftmac100: Move the Faraday drivers
  8139*/atp/r8169/sc92031: Move the Realtek drivers
  de6*/dl2k/sundance: Move the D-Link drivers
  atl*: Move the Atheros drivers

 MAINTAINERS                                        |   18 +-
 drivers/net/Kconfig                                |  389 --------------------
 drivers/net/Makefile                               |   33 --
 drivers/net/arm/Kconfig                            |    8 -
 drivers/net/arm/Makefile                           |    1 -
 drivers/net/ethernet/8390/Kconfig                  |    7 +-
 drivers/net/ethernet/Kconfig                       |   12 +-
 drivers/net/ethernet/Makefile                      |   10 +
 drivers/net/ethernet/apple/Kconfig                 |   96 +++++
 drivers/net/ethernet/apple/Makefile                |    9 +
 drivers/net/{ => ethernet/apple}/bmac.c            |    0
 drivers/net/{ => ethernet/apple}/bmac.h            |    0
 drivers/net/{ => ethernet/apple}/cs89x0.c          |    0
 drivers/net/{ => ethernet/apple}/cs89x0.h          |    0
 drivers/net/{ => ethernet/apple}/mac89x0.c         |    0
 drivers/net/{ => ethernet/apple}/mace.c            |    0
 drivers/net/{ => ethernet/apple}/mace.h            |    0
 drivers/net/{ => ethernet/apple}/macmace.c         |    0
 drivers/net/ethernet/atheros/Kconfig               |   65 ++++
 drivers/net/ethernet/atheros/Makefile              |    8 +
 drivers/net/{ => ethernet/atheros}/atl1c/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h   |    0
 .../{ => ethernet/atheros}/atl1c/atl1c_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_main.c  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h   |    0
 .../{ => ethernet/atheros}/atl1e/atl1e_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_main.c  |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_param.c |    0
 drivers/net/{ => ethernet/atheros}/atlx/Makefile   |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.h     |    0
 drivers/net/ethernet/dlink/Kconfig                 |   84 +++++
 drivers/net/ethernet/dlink/Makefile                |    8 +
 drivers/net/{ => ethernet/dlink}/de600.c           |    0
 drivers/net/{ => ethernet/dlink}/de600.h           |    0
 drivers/net/{ => ethernet/dlink}/de620.c           |    0
 drivers/net/{ => ethernet/dlink}/de620.h           |    0
 drivers/net/{ => ethernet/dlink}/dl2k.c            |    0
 drivers/net/{ => ethernet/dlink}/dl2k.h            |    0
 drivers/net/{ => ethernet/dlink}/sundance.c        |    0
 drivers/net/ethernet/faraday/Kconfig               |   38 ++
 drivers/net/ethernet/faraday/Makefile              |    6 +
 drivers/net/{ => ethernet/faraday}/ftgmac100.c     |    0
 drivers/net/{ => ethernet/faraday}/ftgmac100.h     |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.c      |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.h      |    0
 drivers/net/ethernet/natsemi/Kconfig               |   82 ++++
 drivers/net/ethernet/natsemi/Makefile              |   10 +
 drivers/net/{ => ethernet/natsemi}/ibmlana.c       |    0
 drivers/net/{ => ethernet/natsemi}/ibmlana.h       |    0
 drivers/net/{ => ethernet/natsemi}/jazzsonic.c     |    0
 drivers/net/{ => ethernet/natsemi}/macsonic.c      |    0
 drivers/net/{ => ethernet/natsemi}/natsemi.c       |    0
 drivers/net/{ => ethernet/natsemi}/ns83820.c       |    0
 drivers/net/{ => ethernet/natsemi}/sonic.c         |    0
 drivers/net/{ => ethernet/natsemi}/sonic.h         |    0
 drivers/net/{ => ethernet/natsemi}/xtsonic.c       |    0
 drivers/net/ethernet/pasemi/Kconfig                |   29 ++
 drivers/net/ethernet/pasemi/Makefile               |    5 +
 drivers/net/{ => ethernet/pasemi}/pasemi_mac.c     |    0
 drivers/net/{ => ethernet/pasemi}/pasemi_mac.h     |    0
 .../net/{ => ethernet/pasemi}/pasemi_mac_ethtool.c |    0
 drivers/net/{ => ethernet/realtek}/8139cp.c        |    0
 drivers/net/{ => ethernet/realtek}/8139too.c       |    0
 drivers/net/ethernet/realtek/Kconfig               |  126 +++++++
 drivers/net/ethernet/realtek/Makefile              |    9 +
 drivers/net/{ => ethernet/realtek}/atp.c           |    0
 drivers/net/{ => ethernet/realtek}/atp.h           |    0
 drivers/net/{ => ethernet/realtek}/r8169.c         |    0
 drivers/net/{ => ethernet/realtek}/sc92031.c       |    0
 drivers/net/ethernet/stmicro/Kconfig               |   22 ++
 drivers/net/ethernet/stmicro/Makefile              |    5 +
 drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig  |   14 +-
 drivers/net/{ => ethernet/stmicro}/stmmac/Makefile |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/common.h |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/descs.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac100.h   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac1000.h  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_core.c |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_core.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_dma.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c  |    0
 .../net/{ => ethernet/stmicro}/stmmac/enh_desc.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/norm_desc.c  |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_main.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_mdio.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.c   |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.h   |    0
 drivers/net/ethernet/tehuti/Kconfig                |   26 ++
 drivers/net/ethernet/tehuti/Makefile               |    5 +
 drivers/net/{ => ethernet/tehuti}/tehuti.c         |    0
 drivers/net/{ => ethernet/tehuti}/tehuti.h         |    0
 drivers/net/ethernet/xscale/Kconfig                |   31 ++
 drivers/net/ethernet/xscale/Makefile               |    6 +
 drivers/net/{ => ethernet/xscale}/ixp2000/Kconfig  |    2 +-
 drivers/net/{ => ethernet/xscale}/ixp2000/Makefile |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/caleb.c  |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/caleb.h  |    0
 .../net/{ => ethernet/xscale}/ixp2000/enp2611.c    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400-msf.c    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400-msf.h    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_rx.uc    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_rx.ucode |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_tx.uc    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_tx.ucode |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.c |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.h |    0
 .../{ => ethernet/xscale}/ixp2000/ixpdev_priv.h    |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.c |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.h |    0
 drivers/net/{arm => ethernet/xscale}/ixp4xx_eth.c  |    0
 124 files changed, 712 insertions(+), 452 deletions(-)
 create mode 100644 drivers/net/ethernet/apple/Kconfig
 create mode 100644 drivers/net/ethernet/apple/Makefile
 rename drivers/net/{ => ethernet/apple}/bmac.c (100%)
 rename drivers/net/{ => ethernet/apple}/bmac.h (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.h (100%)
 rename drivers/net/{ => ethernet/apple}/mac89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.h (100%)
 rename drivers/net/{ => ethernet/apple}/macmace.c (100%)
 create mode 100644 drivers/net/ethernet/atheros/Kconfig
 create mode 100644 drivers/net/ethernet/atheros/Makefile
 rename drivers/net/{ => ethernet/atheros}/atl1c/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_param.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.h (100%)
 create mode 100644 drivers/net/ethernet/dlink/Kconfig
 create mode 100644 drivers/net/ethernet/dlink/Makefile
 rename drivers/net/{ => ethernet/dlink}/de600.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de600.h (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.h (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.c (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.h (100%)
 rename drivers/net/{ => ethernet/dlink}/sundance.c (100%)
 create mode 100644 drivers/net/ethernet/faraday/Kconfig
 create mode 100644 drivers/net/ethernet/faraday/Makefile
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.h (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.h (100%)
 create mode 100644 drivers/net/ethernet/natsemi/Kconfig
 create mode 100644 drivers/net/ethernet/natsemi/Makefile
 rename drivers/net/{ => ethernet/natsemi}/ibmlana.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/ibmlana.h (100%)
 rename drivers/net/{ => ethernet/natsemi}/jazzsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/macsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/natsemi.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/ns83820.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.h (100%)
 rename drivers/net/{ => ethernet/natsemi}/xtsonic.c (100%)
 create mode 100644 drivers/net/ethernet/pasemi/Kconfig
 create mode 100644 drivers/net/ethernet/pasemi/Makefile
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac.c (100%)
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac.h (100%)
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac_ethtool.c (100%)
 rename drivers/net/{ => ethernet/realtek}/8139cp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/8139too.c (100%)
 create mode 100644 drivers/net/ethernet/realtek/Kconfig
 create mode 100644 drivers/net/ethernet/realtek/Makefile
 rename drivers/net/{ => ethernet/realtek}/atp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/atp.h (100%)
 rename drivers/net/{ => ethernet/realtek}/r8169.c (100%)
 rename drivers/net/{ => ethernet/realtek}/sc92031.c (100%)
 create mode 100644 drivers/net/ethernet/stmicro/Kconfig
 create mode 100644 drivers/net/ethernet/stmicro/Makefile
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig (93%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Makefile (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/common.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/descs.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/enh_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/norm_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_main.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_mdio.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.h (100%)
 create mode 100644 drivers/net/ethernet/tehuti/Kconfig
 create mode 100644 drivers/net/ethernet/tehuti/Makefile
 rename drivers/net/{ => ethernet/tehuti}/tehuti.c (100%)
 rename drivers/net/{ => ethernet/tehuti}/tehuti.h (100%)
 create mode 100644 drivers/net/ethernet/xscale/Kconfig
 create mode 100644 drivers/net/ethernet/xscale/Makefile
 rename drivers/net/{ => ethernet/xscale}/ixp2000/Kconfig (94%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/Makefile (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/caleb.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/caleb.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/enp2611.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400-msf.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400-msf.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_rx.uc (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_rx.ucode (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_tx.uc (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_tx.ucode (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev_priv.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.h (100%)
 rename drivers/net/{arm => ethernet/xscale}/ixp4xx_eth.c (100%)

-- 
1.7.6

