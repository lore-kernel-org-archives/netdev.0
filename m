From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] i40e: fix null dereference
Date: Sat, 14 Dec 2013 03:26:45 -0800
Message-ID: <1387020406-7964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jeffrey.t.kirsher@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2013 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab3LNL07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Dec 2013 06:26:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the vsi->tx_rings structure is NULL we don't want to panic.

Change-Id: Ic694f043701738c434e8ebe0caf0673f4410dc10
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index be15938..12b0932 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -354,6 +354,9 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	struct rtnl_link_stats64 *vsi_stats = i40e_get_vsi_stats_struct(vsi);
 	int i;
 
+	if (!vsi->tx_rings)
+		return stats;
+
 	rcu_read_lock();
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		struct i40e_ring *tx_ring, *rx_ring;
-- 
1.8.3.1
