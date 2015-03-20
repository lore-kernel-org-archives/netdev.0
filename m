From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 0/9] amd-xgbe: AMD XGBE driver updates 2015-03-19
Date: Fri, 20 Mar 2015 11:49:36 -0500
Message-ID: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0129.outbound.protection.outlook.com ([65.55.169.129]:33024
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750997AbbCTQtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:49:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates and changes
to the driver.

- Use the phydev->advertising field instead of the phydev->supported
  field when configuring for auto-negotiation, etc.
- Use the phy_driver flags field for setting the transceiver type
  instead of hardcoding it in the ethtool support.
- Provide an auto-negotiation timeout check
- Clarify the Tx/Rx queue information messages
- Use the new DMA memory barrier operations
- Set the device DMA mask based on what the hardware reports
- Remove the software implementation of Tx coalescing
- Fix the reporting of the Rx coalescing value
- Use napi_alloc_skb when allocating an SKB in softirq

This patch series is based on net-next.

---

Changes from v2:
- Use jiffies instead of timespec for the auto-negotiation timeout check
- Remove the Rx path SKB allocation re-work patch since we should only
  inline the headers and the current code guards better against any
  hardware bugs

Changes from v1:
- Default to 32-bit DMA width (minimum supported) if hardware returns
  an unexpected DMA width value

Tom Lendacky (9):
      amd-xgbe-phy: Use phydev advertising field vs supported
      amd-xgbe-phy: Use the phy_driver flags field
      amd-xgbe-phy: Provide support for auto-negotiation timeout
      amd-xgbe: Clarify output message about queues
      amd-xgbe: Use the new DMA memory barriers where appropriate
      amd-xgbe: Set DMA mask based on hardware register value
      amd-xgbe: Remove Tx coalescing
      amd-xgbe: Fix Rx coalescing reporting
      amd-xgbe: Use napi_alloc_skb when allocating skb in softirq


 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |    2 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   28 ++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   45 ++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   19 ++---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   19 +++--
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    6 +-
 drivers/net/phy/amd-xgbe-phy.c               |   98 ++++++++++++++++----------
 7 files changed, 127 insertions(+), 90 deletions(-)

-- 
Tom Lendacky
