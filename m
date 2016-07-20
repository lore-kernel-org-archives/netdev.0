From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/20] fm10k: enable bus master after every reset
Date: Wed, 20 Jul 2016 15:23:53 -0700
Message-ID: <1469053438-85381-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44560 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755412AbcGTWYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:06 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If an FLR occurs, VF devices will be knocked out of bus master mode, and
the driver will be unable to recover from the reset properly, resulting
in malicious driver events and an infinite reset loop. In the normal
case, the bus master mode will already be enabled and this call will
essentially be a no-op. Since we're doing this every reset, it is
possible we could remove the other calls to pci_set_master() but it
seems not harmful to just leave them in place.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index b02361c..5e40460 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -174,6 +174,8 @@ static int fm10k_handle_reset(struct fm10k_intfc *interface)
 
 	rtnl_lock();
 
+	pci_set_master(interface->pdev);
+
 	/* reset and initialize the hardware so it is in a known state */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
-- 
2.5.5
