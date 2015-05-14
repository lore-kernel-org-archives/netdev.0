From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 0/7] amd-xgbe: AMD XGBE driver updates 2015-05-12
Date: Thu, 14 May 2015 11:43:51 -0500
Message-ID: <20150514164351.10220.89584.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0143.outbound.protection.outlook.com ([157.56.110.143]:30720
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932807AbbENQn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 12:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates and changes
to the driver.

- Add additional statistics to be collected and reported
- Use the netif_* functions for issuing some debug and informational
  driver messages
- Rx path SKB allocation cleanup/simplification
- Remove stand-alone phylib driver and incorporate function into the nic
  driver
- Simplify device tree support while maintaining backwards compatibility
- Fix the flow control negotiation logic to properly configure flow
  control
- Remove the checking and setting of the device dma_mask field

This patch series is based on net-next.

---
Changes in v2:
- Change from using the netif_msg_*/netdev_* combination for issuing
  messages to the more concise netif_*

Tom Lendacky (7):
      amd-xgbe: Add additional stats to be reported via ethtool
      amd-xgbe: Add netif_* message support to the driver
      amd-xgbe: Rework the Rx path SKB allocation
      amd-xgbe: Move the PHY support into amd-xgbe
      amd-xgbe: Support defining PHY resources in ETH device node
      amd-xgbe: Fix flow control setting logic
      amd-xgbe: Remove manual check and set of dma_mask pointer


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   48 -
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   40 
 MAINTAINERS                                        |    1 
 drivers/net/ethernet/amd/Kconfig                   |    4 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        |  155 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c           |   17 
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |   35 
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |   99 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  339 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   79 +
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  384 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c          | 1237 ++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h               |  236 ++-
 drivers/net/phy/Kconfig                            |    7 
 drivers/net/phy/Makefile                           |    1 
 drivers/net/phy/amd-xgbe-phy.c                     | 1862 --------------------
 16 files changed, 2092 insertions(+), 2452 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
 delete mode 100644 drivers/net/phy/amd-xgbe-phy.c

-- 
Tom Lendacky
