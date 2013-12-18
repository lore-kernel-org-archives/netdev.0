From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: simplify error messages for dump descriptor
Date: Tue, 17 Dec 2013 22:44:31 -0800
Message-ID: <1387349082-18506-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab3LRGow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:52 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

debugfs fixes: We don't really need to give usage messages for data errors,
only for invalid command errors.

Change-Id: If3f74ac49e43c3ced7fd388323fa738ac145e055
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0ce0664..0768beb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -766,20 +766,11 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 
 	vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 	if (!vsi) {
-		dev_info(&pf->pdev->dev,
-			 "vsi %d not found\n", vsi_seid);
-		if (is_rx_ring)
-			dev_info(&pf->pdev->dev, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
-		else
-			dev_info(&pf->pdev->dev, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
+		dev_info(&pf->pdev->dev, "vsi %d not found\n", vsi_seid);
 		return;
 	}
 	if (ring_id >= vsi->num_queue_pairs || ring_id < 0) {
 		dev_info(&pf->pdev->dev, "ring %d not found\n", ring_id);
-		if (is_rx_ring)
-			dev_info(&pf->pdev->dev, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
-		else
-			dev_info(&pf->pdev->dev, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
 		return;
 	}
 	if (!vsi->tx_rings) {
@@ -836,10 +827,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 				 desc_n, ds->read.pkt_addr, ds->read.hdr_addr,
 				 ds->read.rsvd1, ds->read.rsvd2);
 	} else {
-		if (is_rx_ring)
-			dev_info(&pf->pdev->dev, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
-		else
-			dev_info(&pf->pdev->dev, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
+		dev_info(&pf->pdev->dev, "dump desc rx/tx <vsi_seid> <ring_id> [<desc_n>]\n");
 	}
 }
 
-- 
1.8.3.1
