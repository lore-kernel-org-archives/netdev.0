From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] i40evf: Use numa_mem_id() to better support memoryless node
Date: Sat,  3 Oct 2015 19:54:40 -0700
Message-ID: <1443927283-18456-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19539 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbbJDCyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 22:54:46 -0400
In-Reply-To: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiang Liu <jiang.liu@linux.intel.com>

Function i40e_clean_rx_irq() tries to reuse memory pages allocated
from the nearest node. To better support memoryless node, use
numa_mem_id() instead of numa_node_id() to get the nearest node with
memory.

This change should only affect performance.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index aaee89f..0e1a4d6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -917,7 +917,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
 	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
-	const int current_node = numa_node_id();
+	const int current_node = numa_mem_id();
 	struct i40e_vsi *vsi = rx_ring->vsi;
 	u16 i = rx_ring->next_to_clean;
 	union i40e_rx_desc *rx_desc;
-- 
2.4.3
