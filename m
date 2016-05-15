From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: don't add broadcast filter for VFs
Date: Sat, 14 May 2016 21:57:33 -0700
Message-ID: <1463288255-1654-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbcEOE5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:42 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Now that all VSIs are configured to receive broadcasts as default, we
don't need to add a filter. This eliminates an annoying but harmless
error message each time VFs are created or reset.

Change-ID: I4cd6339684df45b0d2722133eeb84c14fa93ea19
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9473429..1fcafcf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -665,8 +665,6 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		goto error_alloc_vsi_res;
 	}
 	if (type == I40E_VSI_SRIOV) {
-		u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-
 		vf->lan_vsi_idx = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
 		/* If the port VLAN has been configured and then the
@@ -688,12 +686,6 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 					 "Could not add MAC filter %pM for VF %d\n",
 					vf->default_lan_addr.addr, vf->vf_id);
 		}
-		f = i40e_add_filter(vsi, brdcast,
-				    vf->port_vlan_id ? vf->port_vlan_id : -1,
-				    true, false);
-		if (!f)
-			dev_info(&pf->pdev->dev,
-				 "Could not allocate VF broadcast filter\n");
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
 	}
 
-- 
2.5.5
