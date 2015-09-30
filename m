From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e: Fix a port VLAN configuration bug
Date: Wed, 30 Sep 2015 05:52:28 -0700
Message-ID: <1443617561-40490-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48753 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406AbbI3Mwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:44 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If a port VLAN is set for a given virtual function (VF) before the VF
driver is loaded then a configuration error results in which the port
VLAN is ignored when the VF driver is subsequently loaded.  This causes
the VF's MAC/VLAN filters to not use the correct VLAN filter.  This
patch ensures that the port VLAN filter is considered at the right time
during configuration of the VF's MAC/VLAN filters.

Change-ID: I28f404cbc21a4c6d70a7980b87c77f13f06685a4
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 613da51..dce7d85 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1269,7 +1269,7 @@ bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi)
 	 * so we have to go through all the list in order to make sure
 	 */
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		if (f->vlan >= 0)
+		if (f->vlan >= 0 || vsi->info.pvid)
 			return true;
 	}
 
-- 
2.4.3
