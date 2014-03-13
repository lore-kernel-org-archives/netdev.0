From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/10] ixgbevf: delete unneeded call to pci_set_power_state
Date: Wed, 12 Mar 2014 19:31:30 -0700
Message-ID: <1394677890-11043-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33591 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbaCMCb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:57 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

This driver does not need to adjust the power state on suspend, so the
call to pci_set_power_state in the resume function is a no-op.  Drop it,
to make the code more understandable.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6ac5da2..475341d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3280,7 +3280,6 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	u32 err;
 
-	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	/*
 	 * pci_restore_state clears dev->state_saved so call
-- 
1.8.3.1
