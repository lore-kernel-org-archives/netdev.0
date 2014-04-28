From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Retain MAC filters when changing port VLAN
Date: Mon, 28 Apr 2014 06:52:25 -0700
Message-ID: <1398693158-2815-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbaD1Nwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:42 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

We were already taking care to retain the MAC filter list when deleting a
port VLAN.  Take some additional care to retain the MAC filter list when
changing a port VLAN.

Change-ID: Iacf9599ea24ecb4dca8e419aacaf4b58ca361a9c
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b27b2f5..982eef0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2128,11 +2128,15 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 
 	/* Check for condition where there was already a port VLAN ID
 	 * filter set and now it is being deleted by setting it to zero.
+	 * Additionally check for the condition where there was a port
+	 * VLAN but now there is a new and different port VLAN being set.
 	 * Before deleting all the old VLAN filters we must add new ones
 	 * with -1 (I40E_VLAN_ANY) or otherwise we're left with all our
 	 * MAC addresses deleted.
 	 */
-	if (!(vlan_id || qos) && vsi->info.pvid)
+	if ((!(vlan_id || qos) ||
+	    (vlan_id | qos) != le16_to_cpu(vsi->info.pvid)) &&
+	    vsi->info.pvid)
 		ret = i40e_vsi_add_vlan(vsi, I40E_VLAN_ANY);
 
 	if (vsi->info.pvid) {
-- 
1.9.0
