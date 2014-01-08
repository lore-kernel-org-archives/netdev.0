From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] i40e: Stop accepting any VLAN tag on VLAN 0 filter set
Date: Tue,  7 Jan 2014 22:07:24 -0800
Message-ID: <1389161256-24599-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9942 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbaAHGIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:36 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When the 8021q driver is loaded it sets VLAN 0 filters on all devices.
This does not mean that any VLAN tagged packet should be accepted.
Instead accept only VLAN 0 tagged packets so that upper layers can
interpret the priority bits.

Change-Id: I17274a540b613749612ffe23a3aef2b8ee6ff6a4
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5ddbd54..2a42470 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1509,11 +1509,6 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				cpu_to_le16((u16)(f->vlan ==
 					    I40E_VLAN_ANY ? 0 : f->vlan));
 
-			/* vlan0 as wild card to allow packets from all vlans */
-			if (f->vlan == I40E_VLAN_ANY ||
-			    (vsi->netdev && !(vsi->netdev->features &
-					      NETIF_F_HW_VLAN_CTAG_FILTER)))
-				cmd_flags |= I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
 			cmd_flags |= I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
 			del_list[num_del].flags = cmd_flags;
 			num_del++;
@@ -1579,12 +1574,6 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			add_list[num_add].queue_number = 0;
 
 			cmd_flags |= I40E_AQC_MACVLAN_ADD_PERFECT_MATCH;
-
-			/* vlan0 as wild card to allow packets from all vlans */
-			if (f->vlan == I40E_VLAN_ANY || (vsi->netdev &&
-			    !(vsi->netdev->features &
-						 NETIF_F_HW_VLAN_CTAG_FILTER)))
-				cmd_flags |= I40E_AQC_MACVLAN_ADD_IGNORE_VLAN;
 			add_list[num_add].flags = cpu_to_le16(cmd_flags);
 			num_add++;
 
-- 
1.8.3.1
