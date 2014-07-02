From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver updates
Date: Wed, 2 Jul 2014 13:04:22 -0500
Message-ID: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0145.outbound.protection.outlook.com ([207.46.163.145]:51678
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757278AbaGBSE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series fixes some bugs and provides new/changed support
in the driver.

- Fix a debugfs backward compatibility issue introduced by a previous patch
- Write to the interrupt enablement register, not the status register when
  setting MTL interrupts
- Call netif_napi_del whenever the ndo_stop operation is called (to match
  the call to netif_napi_add on ndo_open)
- Peformance enhancements:
  - Adjusted default coalescing settings
  - AXI DMA changes (burst length size and cache settings)
  - ioread/iowrite reduction during interrupt
  - Napi poll updates
- AXI DMA settings based on device tree property to account for a change in
  the ARM64 default cache operations assignment

This patch series is based on net-next.

---

Tom Lendacky (5):
      amd-xgbe: Fix debugfs compatibility change with kstrtouint
      amd-xgbe: Clear the proper MTL interrupt register
      amd-xgbe: Call netif_napi_del on ndo_stop operation
      amd-xgbe: Performance enhancements
      amd-xgbe: Base AXI DMA cache settings on device tree


 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |    2 +
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    4 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |  103 ++++++++++++--------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |  100 ++++++++++++++++---------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   10 +++
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   27 +++++--
 6 files changed, 145 insertions(+), 101 deletions(-)

-- 
Tom Lendacky
