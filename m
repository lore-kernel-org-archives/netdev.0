From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates 2014-08-29
Date: Fri, 29 Aug 2014 10:21:48 -0500
Message-ID: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0187.outbound.protection.outlook.com ([207.46.163.187]:46211
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753580AbaH2PV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 11:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe-phy phylib driver support is integral to the amd-xgbe
driver and isn't meant to be used by other devices.  For this reason
it is being removed from the driver/net/phy directory and integrated
into the amd-xgbe driver.

The following series of patches accomplishes this as well as providing
some updates to parallel detection during auto-negotiation.

- Move phylib driver into network driver
- Update device tree bindings to move the phy device resources and
  properties into the network device while maintaining backwards
  compatibility
- Update parallel detection logic to support KR mode

This patch series is based on net-next.

---

Tom Lendacky (3):
      amd-xgbe: Move phy driver support into the network driver
      amd-xgbe: Move the phy device resources into network device
      amd-xgbe: Enhance auto-negotiation parallel detection


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   23 
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   18 
 drivers/net/ethernet/amd/Kconfig                   |    1 
 drivers/net/ethernet/amd/xgbe/Makefile             |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |   16 
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   10 
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  165 ++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c          |   39 -
 drivers/net/ethernet/amd/xgbe/xgbe-phy.c           | 1145 ++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   67 +
 drivers/net/phy/Kconfig                            |    6 
 drivers/net/phy/Makefile                           |    1 
 drivers/net/phy/amd-xgbe-phy.c                     | 1457 --------------------
 13 files changed, 1385 insertions(+), 1565 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-phy.c
 delete mode 100644 drivers/net/phy/amd-xgbe-phy.c

-- 
Tom Lendacky
