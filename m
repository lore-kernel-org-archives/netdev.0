From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/14] amd-xgbe: AMD XGBE driver updates
 2016-06-28
Date: Wed, 28 Jun 2017 13:41:23 -0500
Message-ID: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0053.outbound.protection.outlook.com ([104.47.34.53]:21019
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751501AbdF1Sl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:41:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following updates and fixes are included in this driver update series:

- Simplify mailbox interface code
- Fix SFP supported and advertising settings
- Fix PTP initialization register usage
- Insure there is timestamp skb present before using it
- Add a timeout to timestamp register updates
- Handle return code from software reset function
- Some fixes for handling 2.5Gbps rates
- Limit I2C error messages
- Fix non-DMA interrupt handling through tasklet usage
- Add NUMA affinity support for memory allocations
- Add NUMA affinity support for interrupts
- Prepare for more fine-grained cache coherency controls
- Simplify setting the DMA burst length programming
- Performance improvements

This patch series is based on net-next.

---

Tom Lendacky (14):
      amd-xgbe: Simplify mailbox interface rate change code
      amd-xgbe: Fix SFP PHY supported/advertised settings
      amd-xgbe: Use the proper register during PTP initialization
      amd-xgbe: Add a check for an skb in the timestamp path
      amd-xgbe: Prevent looping forever if timestamp update fails
      amd-xgbe: Handle return code from software reset function
      amd-xgbe: Fixes for working with PHYs that support 2.5GbE
      amd-xgbe: Limit the I2C error messages that are output
      amd-xgbe: Re-issue interrupt if interrupt status not cleared
      amd-xgbe: Add NUMA affinity support for memory allocations
      amd-xgbe: Add NUMA affinity support for IRQ hints
      amd-xgbe: Prepare for more fine grained cache coherency controls
      amd-xgbe: Simplify the burst length settings
      amd-xgbe: Adjust register settings to improve performance


 drivers/net/ethernet/amd/xgbe/xgbe-common.h   |   53 ++---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c     |   94 +++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      |  244 ++++++++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      |  245 ++++++++++++++++---------
 drivers/net/ethernet/amd/xgbe/xgbe-i2c.c      |   30 +++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c     |   14 +
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c     |   33 +++
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c      |   14 +
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c   |  240 +++++++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |   10 -
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c      |    2 
 drivers/net/ethernet/amd/xgbe/xgbe.h          |   56 +++---
 12 files changed, 547 insertions(+), 488 deletions(-)

-- 
Tom Lendacky
