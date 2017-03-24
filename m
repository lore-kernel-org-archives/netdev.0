From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] Revert "e1000e: driver trying to free already-free irq"
Date: Thu, 23 Mar 2017 20:47:15 -0700
Message-ID: <20170324034715.72855-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53005 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935731AbdCXDrd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 23:47:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 7e54d9d063fa239c95c21548c5267f0ef419ff56.

After additional regression testing, several users are experiencing
kernel panics during shutdown on e1000e devices.  Reverting this
change resolves the issue.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2175cced402f..e9af89ad039c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6274,8 +6274,8 @@ static int e1000e_pm_freeze(struct device *dev)
 		/* Quiesce the device without resetting the hardware */
 		e1000e_down(adapter, false);
 		e1000_free_irq(adapter);
-		e1000e_reset_interrupt_capability(adapter);
 	}
+	e1000e_reset_interrupt_capability(adapter);
 
 	/* Allow time for pending master requests to run */
 	e1000e_disable_pcie_master(&adapter->hw);
-- 
2.12.0
