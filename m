From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/25] fm10k: only increment tx_timeout_count in Tx hang path
Date: Tue, 14 Apr 2015 16:50:58 -0700
Message-ID: <1429055471-401-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbbDNXvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:24 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were incrementing the tx_timeout_count for both the Tx hang
and then for all reset flows.  Instead, we should only increment
tx_timeout_count in the Tx hang path, so that our Tx hang counter
does not increment when it was not caused by a Tx hang.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 879124b..64ea734 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -191,7 +191,6 @@ static void fm10k_reset_subtask(struct fm10k_intfc *interface)
 	interface->flags &= ~FM10K_FLAG_RESET_REQUESTED;
 
 	netdev_err(interface->netdev, "Reset interface\n");
-	interface->tx_timeout_count++;
 
 	fm10k_reinit(interface);
 }
-- 
1.9.3
