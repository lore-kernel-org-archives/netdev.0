From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 08/19] e1000e: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:43:47 -0500
Message-ID: <1309196627-15969-1-git-send-email-jdmason@kudzu.us>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:52919 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab1F0Rnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:43:53 -0400
Received: by pvg12 with SMTP id 12so2991698pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:43:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/e1000e/lib.c    |    2 +-
 drivers/net/e1000e/netdev.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index dd8ab05..bd72b81 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -56,7 +56,7 @@ s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
 	struct e1000_adapter *adapter = hw->adapter;
 	u16 pcie_link_status, cap_offset;
 
-	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	cap_offset = adapter->pdev->pcie_cap;
 	if (!cap_offset) {
 		bus->width = e1000_bus_width_unknown;
 	} else {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3bf5249..ed7a93d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5318,7 +5318,7 @@ static void e1000_complete_shutdown(struct pci_dev *pdev, bool sleep,
 	 */
 	if (adapter->flags & FLAG_IS_QUAD_PORT) {
 		struct pci_dev *us_dev = pdev->bus->self;
-		int pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
+		int pos = pci_pcie_cap(us_dev);
 		u16 devctl;
 
 		pci_read_config_word(us_dev, pos + PCI_EXP_DEVCTL, &devctl);
-- 
1.7.5.4

