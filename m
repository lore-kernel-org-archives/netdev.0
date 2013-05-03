From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] cxgb4: fix error recovery when t4_fw_hello returns a positive value
Date: Fri,  3 May 2013 15:11:04 -0300
Message-ID: <1367604664-22368-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: dm@chelsio.com, linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 636f9d371f70f22961fd598fe18380057518ca31 ("cxgb4: Add
support for T4 configuration file"), t4_fw_hello may return a positive
value instead of 0 for success. The recovery code tests only for zero
and fails recovery for any other value.

This fix tests for negative error values and fails only on those cases.
Error recovery after an error injection works after this change.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c306df7..bb4ad38 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4538,7 +4538,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 
 	if (t4_wait_dev_ready(adap) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
-	if (t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, NULL))
+	if (t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, NULL) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
 	adap->flags |= FW_OK;
 	if (adap_init1(adap, &c))
-- 
1.7.1
