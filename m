From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/21] amd-xgbe: AMD XGBE driver updates
 2016-11-01
Date: Thu, 3 Nov 2016 08:27:45 -0500
Message-ID: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0078.outbound.protection.outlook.com ([104.47.42.78]:4598
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754355AbcKCNnj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The majority of changes in this patch series is in preparation for and
adding support for a new PCI version of the hardware that has additional
features and function (Increased channels/queues, SFP+ support, re-driver
support, etc.).

The following updates and fixes are included in this driver update series:

- Fix formatting of PCS debug register dump
- Prepare for priority-based FIFO allocation
- Implement priority-based FIFO allocation
- Prepare for working with more than one type of PCS/PHY
- Prepare for the introduction of clause 37 auto-negotiation
- Add support for clause 37 auto-negotiation
- Prepare for supporting a new PCS register access method
- Add support for 64-bit management counter registers
- Update DMA channel status determination
- Prepare for supporting PCI devices in addition to platform devices
- Add a soft reset hardware workaround
- Add a Tx timestamp hardware workaround
- Add support for new PCI devices
- Allow for a greater number of Rx queues to be used
- Add support for a new DMA interrupt mode
- Add support for FIFO and descriptor cache ECC status
- Add I2C support in prep for SFP+ support
- Expose the phylib phy_aneg_done API call
- Add support for SFP+
- Add support for MDIO attached PHYs
- Add support for a KR re-driver

This patch series is based on net-next.

---

Tom Lendacky (21):
      amd-xgbe: Fix formatting of PCS register dump
      amd-xgbe: Prepare for priority-based FIFO allocation
      amd-xgbe: Perform priority-based hardware FIFO allocation
      amd-xgbe: Prepare for working with more than one type of phy
      amd-xgbe: Prepare for introduction of clause 37 autoneg
      amd-xgbe: Add support for clause 37 auto-negotiation
      amd-xgbe: Prepare for a new PCS register access method
      amd-xgbe: Support for 64-bit management counter registers
      amd-xgbe: Update how to determine DMA channel status
      amd-xgbe: Prepare for supporting PCI devices
      amd-xgbe: Guard against incorrectly generated interrupts
      amd-xgbe: Add a workaround for Tx timestamp issue
      amd-xgbe: Add PCI device support
      amd-xgbe: Allow for a greater number of Rx queues
      amd-xgbe: Add support for new DMA interrupt mode
      amd-xgbe: Add ECC status support for the device memory
      amd-xgbe: Add I2C support for determining SFP media types
      net: phy: expose phy_aneg_done API for use by drivers
      amd-xgbe: Add support for SFP+ modules
      amd-xgbe: Add support for MDIO attached PHYs
      amd-xgbe: Add support for a KR redriver


 drivers/net/ethernet/amd/Kconfig              |   10 
 drivers/net/ethernet/amd/xgbe/Makefile        |    5 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h   |  385 +++
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c  |  152 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      | 1140 +++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      |  346 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c  |   19 
 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c      |  492 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c     |  698 +-----
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c     | 1130 +++++----
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c      |  507 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c   |  845 +++++++
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c   | 3083 +++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |  642 +++++
 drivers/net/ethernet/amd/xgbe/xgbe.h          |  386 +++
 drivers/net/phy/phy.c                         |    3 
 include/linux/phy.h                           |    1 
 17 files changed, 8390 insertions(+), 1454 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-pci.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-platform.c

-- 
Tom Lendacky
