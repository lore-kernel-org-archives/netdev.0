From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/11] amd-xgbe: AMD XGBE driver updates
 2016-11-10
Date: Thu, 10 Nov 2016 17:09:17 -0600
Message-ID: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:41183
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933993AbcKJXJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:09:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is targeted at adding support for a new PCI version
of the hardware. As part of the new PCI device, there is a new PCS/PHY
interaction, ECC support, I2C sideband communication, SFP+ support and
more.

The following updates and fixes are included in this driver update series:

- Hardware workaround for possible incorrectly generated interrupts
  during software reset
- Hardware workaround for Tx timestamp register access order
- Add support for a PCI version of the device
- Increase the Rx queue limit to take advantage of the increased number
  of DMA channels that might be available
- Add support for a new DMA channel interrupt mode
- Add ECC support for the device memory
- Add support for using the integrated I2C controller for sideband
  communication
- Expose the phylib phy_aneg_done() function so it can be called by the
  driver
- Add support for SFP+ modules
- Add support for MDIO attached PHYs
- Add support for KR re-driver between the PCS/SerDes and an external
  PHY

This patch series is based on net-next.

---

Tom Lendacky (11):
      amd-xgbe: Guard against incorrectly generated interrupts
      amd-xgbe: Add a workaround for Tx timestamp issue
      amd-xgbe: Add PCI device support
      amd-xgbe: Allow for a greater number of Rx queues
      amd-xgbe: Add support for new DMA interrupt mode
      amd-xgbe: Add ECC status support for the device memory
      amd-xgbe: Add I2C support for sideband communication
      net: phy: expose phy_aneg_done API for use by drivers
      amd-xgbe: Add support for SFP+ modules
      amd-xgbe: Add support for MDIO attached PHYs
      amd-xgbe: Add support for a KR redriver


 drivers/net/ethernet/aeroflex/greth.c         |    9 
 drivers/net/ethernet/amd/Kconfig              |   10 
 drivers/net/ethernet/amd/xgbe/Makefile        |    3 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h   |  314 +++
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c  |  152 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      |  225 ++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      |  316 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c      |  492 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c     |   48 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c     |  182 +
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c      |  529 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c   |   19 
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c   | 3083 +++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |   14 
 drivers/net/ethernet/amd/xgbe/xgbe.h          |  177 +
 drivers/net/phy/phy.c                         |    3 
 include/linux/phy.h                           |    1 
 17 files changed, 5487 insertions(+), 90 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-pci.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c

-- 
Tom Lendacky
