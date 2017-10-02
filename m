From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: drop i40e_pf *pf from i40e_vc_disable_vf()
Date: Mon,  2 Oct 2017 12:48:45 -0700
Message-ID: <20171002194852.71970-9-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8038 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751587AbdJBTtU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:20 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It's never used, and the vf structure could get back to the PF if
necessary. Lets just drop the extra unneeded parameter.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 53ead127b293..70a79864177a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -154,12 +154,11 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
 
 /**
  * i40e_vc_disable_vf
- * @pf: pointer to the PF info
  * @vf: pointer to the VF info
  *
  * Disable the VF through a SW reset
  **/
-static inline void i40e_vc_disable_vf(struct i40e_pf *pf, struct i40e_vf *vf)
+static inline void i40e_vc_disable_vf(struct i40e_vf *vf)
 {
 	i40e_vc_notify_vf_reset(vf);
 	i40e_reset_vf(vf, false);
@@ -2918,7 +2917,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	}
 
 	/* Force the VF driver stop so it has to reload with new MAC address */
-	i40e_vc_disable_vf(pf, vf);
+	i40e_vc_disable_vf(vf);
 	dev_info(&pf->pdev->dev, "Reload the VF driver to make this change effective.\n");
 
 error_param:
@@ -3013,7 +3012,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 		 * the right thing by reconfiguring his network correctly
 		 * and then reloading the VF driver.
 		 */
-		i40e_vc_disable_vf(pf, vf);
+		i40e_vc_disable_vf(vf);
 		/* During reset the VF got a new VSI, so refresh the pointer. */
 		vsi = pf->vsi[vf->lan_vsi_idx];
 	}
-- 
2.14.2
