From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v3 0/3] Add support for 10G to PHY Lib
Date: Thu, 13 Oct 2011 09:37:37 -0500
Message-ID: <1318516660-25452-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:11181 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854Ab1JMOhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 10:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sequence of patches upgrades PHY Lib to support buses which
implement clause 45 of the IEEE 802.3 spec (10G MDIO).

The first two mostly just update the mdiobus API to add a new argument
(devad), which addresses the specific "device" inside the PHY.

The last patch implements a generic driver for 10G PHYs, but
currently only supports 10G Copper PHYs (that's all I have
to test with).

v3: Make patch series more coherent

Andy Fleming (3):
  phylib: Convert MDIO and PHY Lib drivers to support 10G
  phylib: Convert MDIO bitbang to new MDIO 45 format
  phylib: Add rudimentary Generic 10G support

 Documentation/networking/phy.txt                  |   15 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c         |    6 +-
 drivers/net/ethernet/adi/bfin_mac.c               |    7 +-
 drivers/net/ethernet/aeroflex/greth.c             |    5 +-
 drivers/net/ethernet/amd/au1000_eth.c             |    7 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c      |    4 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c        |    7 +-
 drivers/net/ethernet/broadcom/tg3.c               |    5 +-
 drivers/net/ethernet/cadence/macb.c               |    7 +-
 drivers/net/ethernet/dnet.c                       |    7 +-
 drivers/net/ethernet/ethoc.c                      |    5 +-
 drivers/net/ethernet/faraday/ftgmac100.c          |    5 +-
 drivers/net/ethernet/freescale/fec.c              |    7 +-
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c  |    7 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c  |    6 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c      |   13 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.h      |   11 +-
 drivers/net/ethernet/lantiq_etop.c                |    5 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |    5 +-
 drivers/net/ethernet/marvell/pxa168_eth.c         |    7 +-
 drivers/net/ethernet/rdc/r6040.c                  |    5 +-
 drivers/net/ethernet/s6gmac.c                     |    5 +-
 drivers/net/ethernet/smsc/smsc911x.c              |   22 ++-
 drivers/net/ethernet/smsc/smsc9420.c              |   10 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    9 +-
 drivers/net/ethernet/ti/cpmac.c                   |    4 +-
 drivers/net/ethernet/ti/davinci_mdio.c            |    5 +-
 drivers/net/ethernet/toshiba/tc35815.c            |    5 +-
 drivers/net/ethernet/xilinx/ll_temac_mdio.c       |    5 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |    9 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c          |    7 +-
 drivers/net/phy/fixed.c                           |    5 +-
 drivers/net/phy/icplus.c                          |   17 ++-
 drivers/net/phy/mdio-bitbang.c                    |   34 ++--
 drivers/net/phy/mdio-octeon.c                     |    5 +-
 drivers/net/phy/mdio_bus.c                        |    8 +-
 drivers/net/phy/phy.c                             |    5 +-
 drivers/net/phy/phy_device.c                      |  178 ++++++++++++++++++--
 include/linux/phy.h                               |   70 +++++++-
 net/dsa/slave.c                                   |    5 +-
 40 files changed, 401 insertions(+), 153 deletions(-)

-- 
1.7.3.4
