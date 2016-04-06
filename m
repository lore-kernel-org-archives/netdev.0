From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Remove unused variable
Date: Tue,  5 Apr 2016 20:35:58 -0700
Message-ID: <1459913769-56510-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48525 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760048AbcDFDgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:17 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This variable is vestigial, a remnant of the primordial code from which
this driver spawned. We can safely remove it.

Change-ID: I24e0fe338e7c7c50d27dc5515564f33caefbb93a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 47b9e62..150002e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1311,8 +1311,8 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	struct i40e_pf *pf = vf->pf;
 	i40e_status aq_ret = 0;
 	struct i40e_vsi *vsi;
-	int i = 0, len = 0;
 	int num_vsis = 1;
+	int len = 0;
 	int ret;
 
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
@@ -1374,15 +1374,14 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	vfres->num_queue_pairs = vf->num_queue_pairs;
 	vfres->max_vectors = pf->hw.func_caps.num_msix_vectors_vf;
 	if (vf->lan_vsi_idx) {
-		vfres->vsi_res[i].vsi_id = vf->lan_vsi_id;
-		vfres->vsi_res[i].vsi_type = I40E_VSI_SRIOV;
-		vfres->vsi_res[i].num_queue_pairs = vsi->alloc_queue_pairs;
+		vfres->vsi_res[0].vsi_id = vf->lan_vsi_id;
+		vfres->vsi_res[0].vsi_type = I40E_VSI_SRIOV;
+		vfres->vsi_res[0].num_queue_pairs = vsi->alloc_queue_pairs;
 		/* VFs only use TC 0 */
-		vfres->vsi_res[i].qset_handle
+		vfres->vsi_res[0].qset_handle
 					  = le16_to_cpu(vsi->info.qs_handle[0]);
-		ether_addr_copy(vfres->vsi_res[i].default_mac_addr,
+		ether_addr_copy(vfres->vsi_res[0].default_mac_addr,
 				vf->default_lan_addr.addr);
-		i++;
 	}
 	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
 
-- 
2.5.5
