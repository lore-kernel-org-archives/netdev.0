From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] igb: call igb_ptp_suspend during suspend/resume cycle
Date: Wed, 29 Jun 2016 14:32:58 -0700
Message-ID: <1467235982-55437-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52759 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Properly stop the extra workqueue items and ensure that we resume
cleanly. This is better than using igb_ptp_init and igb_ptp_stop since
these functions destroy the PHC device, which will cause other problems
if we do so. Since igb_ptp_reset now re-schedules the work-queue item we
don't need an equivalent igb_ptp_resume in the resume workflow.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 750a5d8..a15f826 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7528,6 +7528,8 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	if (netif_running(netdev))
 		__igb_close(netdev, true);
 
+	igb_ptp_suspend(adapter);
+
 	igb_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_PM
-- 
2.5.5
