From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] i40evf: Allocate Rx buffers properly
Date: Fri,  6 May 2016 00:03:45 -0700
Message-ID: <1462518228-30527-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40897 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbcEFHGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:33 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Allocate the correct number of RX buffers, and don't fiddle with
next_to_use. The common RX code handles all of this. This fixes a memory
leak of one page each time the driver is opened.

Change-Id: Id06eca353086e084921f047acad28c14745684ee
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 870bad8..b548dbe 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -990,9 +990,7 @@ static void i40evf_configure(struct i40evf_adapter *adapter)
 	for (i = 0; i < adapter->num_active_queues; i++) {
 		struct i40e_ring *ring = &adapter->rx_rings[i];
 
-		i40evf_alloc_rx_buffers(ring, ring->count);
-		ring->next_to_use = ring->count - 1;
-		writel(ring->next_to_use, ring->tail);
+		i40evf_alloc_rx_buffers(ring, I40E_DESC_UNUSED(ring));
 	}
 }
 
@@ -2768,7 +2766,6 @@ static void i40evf_remove(struct pci_dev *pdev)
 
 	iounmap(hw->hw_addr);
 	pci_release_regions(pdev);
-
 	i40evf_free_all_tx_resources(adapter);
 	i40evf_free_all_rx_resources(adapter);
 	i40evf_free_queues(adapter);
-- 
2.5.5
