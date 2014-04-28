From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Use port VLAN in MAC/VLAN filter configuration
Date: Mon, 28 Apr 2014 06:52:27 -0700
Message-ID: <1398693158-2815-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59462 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836AbaD1Nwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:44 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The function to set the VF MAC address was not taking the port VLAN
filter into account when setting/clearing/resetting the VF's host
administered MAC address.  Be sure to use the port VLAN for VF MAC
filtering configurations.

Change-ID: I12595331981c79529738f041dcdbdb667ef8f5e6
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 982eef0..82e7abf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2049,10 +2049,11 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	}
 
 	/* delete the temporary mac address */
-	i40e_del_filter(vsi, vf->default_lan_addr.addr, 0, true, false);
+	i40e_del_filter(vsi, vf->default_lan_addr.addr, vf->port_vlan_id,
+			true, false);
 
 	/* add the new mac address */
-	f = i40e_add_filter(vsi, mac, 0, true, false);
+	f = i40e_add_filter(vsi, mac, vf->port_vlan_id, true, false);
 	if (!f) {
 		dev_err(&pf->pdev->dev,
 			"Unable to add VF ucast filter\n");
-- 
1.9.0
