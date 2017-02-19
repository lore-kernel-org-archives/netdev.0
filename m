From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e: properly convert le16 value to CPU format
Date: Sat, 18 Feb 2017 22:33:37 -0800
Message-ID: <20170219063341.8039-10-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdBSGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:13 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This ensures that the pvid which is stored in __le16 format is converted
to the CPU format. This will fix comparison issues on Big Endian
platforms.

Change-ID: I92c80d1315dc2a0f9f095d5a0c48d461beb052ed
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a6dca5822cff..df78271bdce5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1254,6 +1254,7 @@ static int i40e_correct_mac_vlan_filters(struct i40e_vsi *vsi,
 					 struct hlist_head *tmp_del_list,
 					 int vlan_filters)
 {
+	s16 pvid = le16_to_cpu(vsi->info.pvid);
 	struct i40e_mac_filter *f, *add_head;
 	struct i40e_new_mac_filter *new;
 	struct hlist_node *h;
@@ -1275,8 +1276,8 @@ static int i40e_correct_mac_vlan_filters(struct i40e_vsi *vsi,
 
 	/* Update the filters about to be added in place */
 	hlist_for_each_entry(new, tmp_add_list, hlist) {
-		if (vsi->info.pvid && new->f->vlan != vsi->info.pvid)
-			new->f->vlan = vsi->info.pvid;
+		if (pvid && new->f->vlan != pvid)
+			new->f->vlan = pvid;
 		else if (vlan_filters && new->f->vlan == I40E_VLAN_ANY)
 			new->f->vlan = 0;
 		else if (!vlan_filters && new->f->vlan == 0)
@@ -1290,12 +1291,12 @@ static int i40e_correct_mac_vlan_filters(struct i40e_vsi *vsi,
 		 * order to avoid duplicating code for adding the new filter
 		 * then deleting the old filter.
 		 */
-		if ((vsi->info.pvid && f->vlan != vsi->info.pvid) ||
+		if ((pvid && f->vlan != pvid) ||
 		    (vlan_filters && f->vlan == I40E_VLAN_ANY) ||
 		    (!vlan_filters && f->vlan == 0)) {
 			/* Determine the new vlan we will be adding */
-			if (vsi->info.pvid)
-				new_vlan = vsi->info.pvid;
+			if (pvid)
+				new_vlan = pvid;
 			else if (vlan_filters)
 				new_vlan = 0;
 			else
-- 
2.11.0
