From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/12] amd-xgbe: AMD XGBE driver updates
 2014-11-04
Date: Tue, 4 Nov 2014 16:06:20 -0600
Message-ID: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0134.outbound.protection.outlook.com ([157.56.110.134]:35698
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751129AbaKDWG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates to the
driver as well as some trivial changes for function renaming and
spelling fixes.

- Move channel and ring structure allocation into the device open path
- Rename the pre_xmit function to dev_xmit
- Explicitly use the u32 data type for the device descriptors
- Use page allocation for the receive buffers
- Add support for split header/payload receive
- Add support for per DMA channel interrupts
- Add support for receive side scaling (RSS)
- Add support for ethtool receive side scaling commands
- Fix the spelling of descriptors
- After a PCS reset, sync the PCS and PHY modes
- Add dependency on HAS_IOMEM to both the amd-xgbe and amd-xgbe-phy
  drivers

This patch series is based on net-next.

---

Tom Lendacky (12):
      amd-xgbe: Move ring allocation to device open
      amd-xgbe: Rename pre_xmit function to dev_xmit
      amd-xgbe: Use the u32 data type for descriptors
      amd-xgbe: Use page allocations for Rx buffers
      amd-xgbe: Implement split header receive support
      amd-xgbe: Add support for per DMA channel interrupts
      amd-xgbe: Provide support for receive side scaling
      amd-xgbe: Add receive side scaling ethtool support
      amd-xgbe: Fix a spelling error
      amd-xgbe-phy: Sync PCS and PHY modes after reset
      amd-xgbe: Let AMD_XGBE depend on HAS_IOMEM
      amd-xgbe-phy: Let AMD_XGBE_PHY depend on HAS_IOMEM


 Documentation/devicetree/bindings/net/amd-xgbe.txt |   12 -
 drivers/net/ethernet/amd/Kconfig                   |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        |   42 ++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  193 +++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |  288 ++++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  445 ++++++++++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   82 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |   86 +---
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   77 +++
 drivers/net/phy/Kconfig                            |    2 
 drivers/net/phy/amd-xgbe-phy.c                     |    3 
 11 files changed, 955 insertions(+), 277 deletions(-)

-- 
Tom Lendacky
