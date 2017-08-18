From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/14] amd-xgbe: AMD XGBE driver updates
 2017-08-17
Date: Thu, 17 Aug 2017 19:02:01 -0500
Message-ID: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0076.outbound.protection.outlook.com ([104.47.36.76]:2099
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753375AbdHRACH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following updates are included in this driver update series:

- Set the MDIO mode to clause 45 for the 10GBase-T configuration
- Set the MII control width to 8-bits for speeds less than 1Gbps
- Fix an issue to related to module removal when the devices are up
- Fix ethtool statistics related to packet counting of TSO packets
- Add additional debugfs support
- Add support for device renaming
- Add additional dynamic debug output for the PCS window calculation
- Optimize reading of DMA channel interrupt enablement register
- Add additional dynamic debug output about the hardware features
- Add per queue Tx and Rx ethtool statistics
- Add a macro to clear ethtool_link_ksettings modes
- Convert the driver to use the ethtool_link_ksettings
- Add support for VXLAN offload capabilities
- Add additional ethtool statistics related to VXLAN

This patch series is based on net-next.

---

Tom Lendacky (14):
      amd-xgbe: Set the MDIO mode for 10000Base-T configuration
      amd-xgbe: Set the MII control width for the MAC interface
      amd-xgbe: Be sure driver shuts down cleanly on module removal
      amd-xgbe: Update TSO packet statistics accuracy
      amd-xgbe: Add additional debugfs support
      amd-xgbe: Add support to handle device renaming
      amd-xgbe: Add additional dynamic debug messages
      amd-xgbe: Optimize DMA channel interrupt enablement
      amd-xgbe: Add hardware features debug output
      amd-xgbe: Add per queue Tx and Rx statistics
      net: ethtool: Add macro to clear a link mode setting
      amd-xgbe: Convert to using the new link mode settings
      amd-xgbe: Add support for VXLAN offload capabilities
      amd-xgbe: Add additional ethtool statistics


 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |   25 +
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |  176 +++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |  198 ++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |  487 ++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   86 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   97 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |   81 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c     |    4 
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c  |   54 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c  |  439 +++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe.h         |  103 +++++
 include/linux/ethtool.h                      |   11 +
 12 files changed, 1408 insertions(+), 353 deletions(-)

-- 
Tom Lendacky
