From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: fix crash when injecting AER after failed reset
Date: Mon,  9 Oct 2017 11:40:00 -0700
Message-ID: <20171009184000.80053-11-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54282 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755250AbdJISkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:25 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

In case where AER recovery fails the device is left in a down state.
Consecutive AER error injection can lead to a double IRQ free.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5e2686d106db..c6f9da7990c7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -10861,6 +10861,9 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 	if (!test_bit(__IXGBE_SERVICE_INITED, &adapter->state))
 		return PCI_ERS_RESULT_DISCONNECT;
 
+	if (!netif_device_present(netdev))
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	rtnl_lock();
 	netif_device_detach(netdev);
 
-- 
2.14.2
