From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 09/19] igb: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:44:01 -0500
Message-ID: <1309196641-16003-1-git-send-email-jdmason@kudzu.us>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:52919 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab1F0RoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:44:06 -0400
Received: by mail-pv0-f174.google.com with SMTP id 12so2991698pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:44:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6e67258..d6c4bd8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -6267,7 +6267,7 @@ s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 	struct igb_adapter *adapter = hw->back;
 	u16 cap_offset;
 
-	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	cap_offset = adapter->pdev->pcie_cap;
 	if (!cap_offset)
 		return -E1000_ERR_CONFIG;
 
@@ -6281,7 +6281,7 @@ s32 igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 	struct igb_adapter *adapter = hw->back;
 	u16 cap_offset;
 
-	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	cap_offset = adapter->pdev->pcie_cap;
 	if (!cap_offset)
 		return -E1000_ERR_CONFIG;
 
-- 
1.7.5.4

