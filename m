From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 17/17] i40e: report VF MAC addresses correctly
Date: Fri,  3 Jan 2014 21:56:45 -0800
Message-ID: <1388815005-23166-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51754 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753AbaADF5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:57:16 -0500
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the user does not assign a VF MAC address, then just report it as
zero.  Attempting to guess the correct primary MAC address of the VF is a
futile and heartbreaking endeavour.

Change-Id: I2673577a160afb6fc55094c890467b44e60c7584
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1dd13f4..cc4ebf5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2005,7 +2005,6 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 			   int vf_id, struct ifla_vf_info *ivi)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_mac_filter *f, *ftmp;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_vf *vf;
@@ -2029,11 +2028,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 	ivi->vf = vf_id;
 
-	/* first entry of the list is the default ethernet address */
-	list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list, list) {
-		memcpy(&ivi->mac, f->macaddr, I40E_ETH_LENGTH_OF_ADDRESS);
-		break;
-	}
+	memcpy(&ivi->mac, vf->default_lan_addr.addr, ETH_ALEN);
 
 	ivi->tx_rate = 0;
 	ivi->vlan = le16_to_cpu(vsi->info.pvid) & I40E_VLAN_MASK;
-- 
1.8.3.1
