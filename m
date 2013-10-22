From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/14] i40e: don't free nonexistent rings
Date: Tue, 22 Oct 2013 07:22:25 -0700
Message-ID: <1382451757-9817-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15972 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab3JVOWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:51 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Not all VSIs have rings! Check to see if rings were actually allocated before
freeing them.

This prevents a panic when tx_rings[0] is not allocated.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 69ed801..a8c18fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5160,11 +5160,12 @@ static s32 i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 {
 	int i;
 
-	for (i = 0; i < vsi->alloc_queue_pairs; i++) {
-		kfree_rcu(vsi->tx_rings[i], rcu);
-		vsi->tx_rings[i] = NULL;
-		vsi->rx_rings[i] = NULL;
-	}
+	if (vsi->tx_rings[0])
+		for (i = 0; i < vsi->alloc_queue_pairs; i++) {
+			kfree_rcu(vsi->tx_rings[i], rcu);
+			vsi->tx_rings[i] = NULL;
+			vsi->rx_rings[i] = NULL;
+		}
 
 	return 0;
 }
-- 
1.8.3.1
