From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] fm10k: Check the host state when bringing the interface up
Date: Thu, 16 Oct 2014 02:36:24 -0700
Message-ID: <1413452187-2950-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44209 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbaJPJgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 05:36:31 -0400
In-Reply-To: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Set the flag to fetch the host state before kicking off the service task
that reads the host state when bringing the interface back up.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index e02036c..a0cb74a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1489,6 +1489,7 @@ void fm10k_up(struct fm10k_intfc *interface)
 	netif_tx_start_all_queues(interface->netdev);
 
 	/* kick off the service timer */
+	hw->mac.get_host_state = 1;
 	mod_timer(&interface->service_timer, jiffies);
 }
 
-- 
1.9.3
