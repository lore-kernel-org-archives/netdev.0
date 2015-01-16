From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/12] amd-xgbe: AMD XGBE driver updates
 2015-01-16
Date: Fri, 16 Jan 2015 12:46:18 -0600
Message-ID: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44028 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756798AbbAPSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates to the
driver as well as some trivial changes.

- Fix checks/warnings from checkpatch in the amd-xgbe driver
- Fix checks/warnings from checkpatch in the amd-xgbe-phy driver
- Add a check to be sure that the amd-xgbe driver is using the
  amd-xgbe-phy driver
- Use a saved control register value when bringing the PCS out of
  suspend
- Clear all device state during a device restart
- Simplify the Rx descriptor ring tracking
- Remove the need for Tx path spinlocks
- Update the auto-negotiation logic to make use of the auto-negotiation
  interrupt
- Properly support/advertise the FEC capability of the device
- Use the proper page registers during auto-negotiation extended next
  page exchange
- Add ACPI support to the amd-xgbe and amd-xgbe-phy drivers
- Allow platform specific phy settings to be supplied by UEFI
  
This patch series is based on net-next.

---

Tom Lendacky (12):
      amd-xgbe: Checkpatch fixes
      amd-xgbe-phy: Checkpatch fixes
      amd-xgbe: Add check to be sure amd-xgbe-phy driver is used
      amd-xgbe-phy: On suspend, save CTRL1 reg for use on resume
      amd-xgbe: Clear all state during a device restart
      amd-xgbe: Simplify the Rx desciptor ring tracking
      amd-xgbe: Remove need for Tx path spinlock
      amd-xgbe-phy: Change auto-negotiation logic
      amd-xgbe-phy: Properly support the FEC auto-negotiation
      amd-xgbe-phy: Use the proper auto-negotiation XNP registers
      amd-xgbe: Add ACPI support
      amd-xgbe-phy: Allow certain PHY settings to be set by UEFI


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   21 
 drivers/net/ethernet/amd/Kconfig                   |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c       |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |   32 -
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |   66 +
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |   59 +
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  203 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c          |   29 -
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c           |    4 
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   29 -
 drivers/net/phy/Kconfig                            |    2 
 drivers/net/phy/amd-xgbe-phy.c                     |  981 +++++++++++++-------
 12 files changed, 932 insertions(+), 498 deletions(-)

-- 
Tom Lendacky
