From: divy@chelsio.com
Subject: [PATCH 2.6.21 4/4] cxgb3 - T3B2 pcie config space
Date: Sun, 18 Mar 2007 13:10:17 -0700
Message-ID: <20070318201017.16328.26563.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:30692 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145AbXCRUKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 16:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

T3B2 does not lose its pcie config space on reset.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---
---

 drivers/net/cxgb3/t3_hw.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 983ee81..791ed6d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3244,15 +3244,17 @@ void early_hw_init(struct adapter *adapt
 }
 
 /*
- * Reset the adapter.  PCIe cards lose their config space during reset, PCI-X
+ * Reset the adapter. 
+ * Older PCIe cards lose their config space during reset, PCI-X
  * ones don't.
  */
 int t3_reset_adapter(struct adapter *adapter)
 {
-	int i;
+	int i, save_and_restore_pcie = 
+	    adapter->params.rev < T3_REV_B2 && is_pcie(adapter);
 	uint16_t devid = 0;
 
-	if (is_pcie(adapter))
+	if (save_and_restore_pcie)
 		pci_save_state(adapter->pdev);
 	t3_write_reg(adapter, A_PL_RST, F_CRSTWRM | F_CRSTWRMMODE);
 
@@ -3270,7 +3272,7 @@ int t3_reset_adapter(struct adapter *ada
 	if (devid != 0x1425)
 		return -1;
 
-	if (is_pcie(adapter))
+	if (save_and_restore_pcie)
 		pci_restore_state(adapter->pdev);
 	return 0;
 }
