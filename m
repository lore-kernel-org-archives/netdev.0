From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] e1000e: cleanup strict checkpatch MEMORY_BARRIER checks
Date: Thu, 23 Aug 2012 02:56:47 -0700
Message-ID: <1345715813-20757-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932455Ab2HWJ5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:57:00 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Add comments to memory barriers per strict checkpatch.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e7226b0..d8a65af 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3746,6 +3746,10 @@ static irqreturn_t e1000_intr_msi_test(int irq, void *data)
 	e_dbg("icr is %08X\n", icr);
 	if (icr & E1000_ICR_RXSEQ) {
 		adapter->flags &= ~FLAG_MSI_TEST_FAILED;
+		/*
+		 * Force memory writes to complete before acknowledging the
+		 * interrupt is handled.
+		 */
 		wmb();
 	}
 
@@ -3787,6 +3791,10 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 		goto msi_test_failed;
 	}
 
+	/*
+	 * Force memory writes to complete before enabling and firing an
+	 * interrupt.
+	 */
 	wmb();
 
 	e1000_irq_enable(adapter);
@@ -3798,7 +3806,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 
 	e1000_irq_disable(adapter);
 
-	rmb();
+	rmb();			/* read flags after interrupt has been fired */
 
 	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
-- 
1.7.11.4
