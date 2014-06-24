From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/6] amd-xgbe: AMD 10Gb Ethernet driver updates
Date: Tue, 24 Jun 2014 16:19:00 -0500
Message-ID: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.141] ([207.46.163.141]:39024 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752593AbaFXVT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:19:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series fixes some bugs and provides new/changed support
in the driver.

- Make all the defines in the xgbe.h file unique by prefixing them with
  XGBE_ if they are not currently using the prefix.
- VLAN CTAGs are supplied in context descriptors. Tell the hardware to
  look in the Tx context descriptor, and not a register, for the VLAN CTAG
  to be inserted in the packet.
- The hardware will indicate a VLAN packet has been received even if VLAN
  CTAG stripping is currently disabled.  Only indicate that a VLAN CTAG
  has been stripped for the current packet if stripping is enabled.
- Add support for VLAN filtering
- Modify destination address filtering to use the hardware hash tables
- Eliminate a checkpatch warning by replacing sscanf with kstrtouint

This patch series is based on net-next.

---

Tom Lendacky (6):
      amd-xgbe: Make defines in xgbe.h unique
      amd-xgbe: VLAN Tx tag insertion fix
      amd-xgbe: VLAN Rx tag stripping fix
      amd-xgbe: Add support for VLAN filtering
      amd-xgbe: Change destination address filtering support
      amd-xgbe: Resolve checkpatch warning about sscanf usage


 drivers/net/ethernet/amd/Kconfig             |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |   26 +-
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    9 -
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c    |   23 +-
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |  344 ++++++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |  115 ++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   13 +
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   55 ++--
 8 files changed, 398 insertions(+), 189 deletions(-)

-- 
Tom Lendacky
