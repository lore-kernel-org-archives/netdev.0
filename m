From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: properly spell I40E_VF_STATE_* flags
Date: Sun, 30 Apr 2017 06:24:39 -0700
Message-ID: <20170430132451.68494-2-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19886 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163243AbdD3NY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:57 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

These flags represent the state of the VF at various times. Do not
spell them as _STAT_ which can be confusing to readers who may think
these refer to statistics.

Change-ID: I6bc092cd472e8276896a1fd7498aced2084312df
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 98 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 14 ++--
 4 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 08035c4389cd..523dd81d76b7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1826,7 +1826,7 @@ static inline bool i40e_active_vfs(struct i40e_pf *pf)
 	int i;
 
 	for (i = 0; i < pf->num_alloc_vfs; i++)
-		if (test_bit(I40E_VF_STAT_ACTIVE, &vfs[i].vf_states))
+		if (test_bit(I40E_VF_STATE_ACTIVE, &vfs[i].vf_states))
 			return true;
 	return false;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c001562f19b2..8f47a31cb2c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7318,7 +7318,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 				 "Too many MDD events on VF %d, disabled\n", i);
 			dev_info(&pf->pdev->dev,
 				 "Use PF Control I/F to re-enable the VF\n");
-			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
+			set_bit(I40E_VF_STATE_DISABLED, &vf->vf_states);
 		}
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 350cba70490c..a46c07799384 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -50,8 +50,8 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 	for (i = 0; i < pf->num_alloc_vfs; i++, vf++) {
 		int abs_vf_id = vf->vf_id + (int)hw->func_caps.vf_base_id;
 		/* Not all vfs are enabled so skip the ones that are not */
-		if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
-		    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+		if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states) &&
+		    !test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states))
 			continue;
 
 		/* Ignore return value on purpose - a given VF may fail, but
@@ -137,8 +137,8 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
 		return;
 
 	/* verify if the VF is in either init or active before proceeding */
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
-	    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states) &&
+	    !test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states))
 		return;
 
 	abs_vf_id = vf->vf_id + (int)vf->pf->hw.func_caps.vf_base_id;
@@ -812,7 +812,7 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 	/* Start by disabling VF's configuration API to prevent the OS from
 	 * accessing the VF's VSI after it's freed / invalidated.
 	 */
-	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
+	clear_bit(I40E_VF_STATE_INIT, &vf->vf_states);
 
 	/* free vsi & disconnect it from the parent uplink */
 	if (vf->lan_vsi_idx) {
@@ -884,7 +884,7 @@ static int i40e_alloc_vf_res(struct i40e_vf *vf)
 	vf->num_queue_pairs = total_queue_pairs;
 
 	/* VF is now completely initialized */
-	set_bit(I40E_VF_STAT_INIT, &vf->vf_states);
+	set_bit(I40E_VF_STATE_INIT, &vf->vf_states);
 
 error_alloc:
 	if (ret)
@@ -938,7 +938,7 @@ static void i40e_trigger_vf_reset(struct i40e_vf *vf, bool flr)
 	u32 reg, reg_idx, bit_idx;
 
 	/* warn the VF */
-	clear_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
+	clear_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states);
 
 	/* Disable VF's configuration API during reset. The flag is re-enabled
 	 * in i40e_alloc_vf_res(), when it's safe again to access VF's VSI.
@@ -946,7 +946,7 @@ static void i40e_trigger_vf_reset(struct i40e_vf *vf, bool flr)
 	 * to do it earlier to give some time to finish to any VF config
 	 * functions that may still be running at this point.
 	 */
-	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
+	clear_bit(I40E_VF_STATE_INIT, &vf->vf_states);
 
 	/* In the case of a VFLR, the HW has already reset the VF and we
 	 * just need to clean up, so don't hit the VFRTRIG register.
@@ -1004,8 +1004,8 @@ static void i40e_cleanup_reset_vf(struct i40e_vf *vf)
 	if (!i40e_alloc_vf_res(vf)) {
 		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 		i40e_enable_vf_mappings(vf);
-		set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
-		clear_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
+		set_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states);
+		clear_bit(I40E_VF_STATE_DISABLED, &vf->vf_states);
 		/* Do not notify the client during VF init */
 		if (vf->pf->num_alloc_vfs)
 			i40e_notify_client_of_vf_reset(pf, abs_vf_id);
@@ -1194,7 +1194,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 
 	i40e_notify_client_of_vf_enable(pf, 0);
 	for (i = 0; i < pf->num_alloc_vfs; i++)
-		if (test_bit(I40E_VF_STAT_INIT, &pf->vf[i].vf_states))
+		if (test_bit(I40E_VF_STATE_INIT, &pf->vf[i].vf_states))
 			i40e_vsi_stop_rings(pf->vsi[pf->vf[i].lan_vsi_idx]);
 
 	/* Disable IOV before freeing resources. This lets any VF drivers
@@ -1212,7 +1212,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	tmp = pf->num_alloc_vfs;
 	pf->num_alloc_vfs = 0;
 	for (i = 0; i < tmp; i++) {
-		if (test_bit(I40E_VF_STAT_INIT, &pf->vf[i].vf_states))
+		if (test_bit(I40E_VF_STATE_INIT, &pf->vf[i].vf_states))
 			i40e_free_vf_res(&pf->vf[i]);
 		/* disable qp mappings */
 		i40e_disable_vf_mappings(&pf->vf[i]);
@@ -1418,7 +1418,7 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 				"Number of invalid messages exceeded for VF %d\n",
 				vf->vf_id);
 			dev_err(&pf->pdev->dev, "Use PF Control I/F to enable the VF\n");
-			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
+			set_bit(I40E_VF_STATE_DISABLED, &vf->vf_states);
 		}
 	} else {
 		vf->num_valid_msgs++;
@@ -1493,7 +1493,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	int len = 0;
 	int ret;
 
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto err;
 	}
@@ -1522,7 +1522,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	if (i40e_vf_client_capable(pf, vf->vf_id) &&
 	    (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_IWARP)) {
 		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_IWARP;
-		set_bit(I40E_VF_STAT_IWARPENA, &vf->vf_states);
+		set_bit(I40E_VF_STATE_IWARPENA, &vf->vf_states);
 	}
 
 	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF) {
@@ -1583,7 +1583,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 		ether_addr_copy(vfres->vsi_res[0].default_mac_addr,
 				vf->default_lan_addr.addr);
 	}
-	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
+	set_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states);
 
 err:
 	/* send the response back to the VF */
@@ -1606,7 +1606,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
  **/
 static void i40e_vc_reset_vf_msg(struct i40e_vf *vf)
 {
-	if (test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+	if (test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states))
 		i40e_reset_vf(vf, false);
 }
 
@@ -1654,7 +1654,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 	int bkt;
 
 	vsi = i40e_find_vsi_from_id(pf, info->vsi_id);
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id) ||
 	    !vsi) {
 		aq_ret = I40E_ERR_PARAM;
@@ -1715,9 +1715,9 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 			 "VF %d successfully set multicast promiscuous mode\n",
 			 vf->vf_id);
 		if (allmulti)
-			set_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states);
+			set_bit(I40E_VF_STATE_MC_PROMISC, &vf->vf_states);
 		else
-			clear_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states);
+			clear_bit(I40E_VF_STATE_MC_PROMISC, &vf->vf_states);
 	}
 
 	if (info->flags & I40E_FLAG_VF_UNICAST_PROMISC)
@@ -1766,9 +1766,9 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 			 "VF %d successfully set unicast promiscuous mode\n",
 			 vf->vf_id);
 		if (alluni)
-			set_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states);
+			set_bit(I40E_VF_STATE_UC_PROMISC, &vf->vf_states);
 		else
-			clear_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states);
+			clear_bit(I40E_VF_STATE_UC_PROMISC, &vf->vf_states);
 	}
 
 error_param:
@@ -1797,7 +1797,7 @@ static int i40e_vc_config_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status aq_ret = 0;
 	int i;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -1854,7 +1854,7 @@ static int i40e_vc_config_irq_map_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	unsigned long tempmap;
 	int i;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -1914,7 +1914,7 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	u16 vsi_id = vqs->vsi_id;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -1953,7 +1953,7 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	struct i40e_pf *pf = vf->pf;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -1995,7 +1995,7 @@ static int i40e_vc_get_stats_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	memset(&stats, 0, sizeof(struct i40e_eth_stats));
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -2082,7 +2082,7 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status ret = 0;
 	int i;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2151,7 +2151,7 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status ret = 0;
 	int i;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2217,7 +2217,7 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 			"VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
 		goto error_param;
 	}
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2244,12 +2244,12 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		if (!ret)
 			vf->num_vlan++;
 
-		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
+		if (test_bit(I40E_VF_STATE_UC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
 							   true,
 							   vfl->vlan_id[i],
 							   NULL);
-		if (test_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states))
+		if (test_bit(I40E_VF_STATE_MC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_mc_promisc_on_vlan(&pf->hw, vsi->seid,
 							   true,
 							   vfl->vlan_id[i],
@@ -2284,7 +2284,7 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status aq_ret = 0;
 	int i;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2307,12 +2307,12 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
 		vf->num_vlan--;
 
-		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
+		if (test_bit(I40E_VF_STATE_UC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
 							   false,
 							   vfl->vlan_id[i],
 							   NULL);
-		if (test_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states))
+		if (test_bit(I40E_VF_STATE_MC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_mc_promisc_on_vlan(&pf->hw, vsi->seid,
 							   false,
 							   vfl->vlan_id[i],
@@ -2338,8 +2338,8 @@ static int i40e_vc_iwarp_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	int abs_vf_id = vf->vf_id + pf->hw.func_caps.vf_base_id;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VF_STAT_IWARPENA, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VF_STATE_IWARPENA, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -2369,8 +2369,8 @@ static int i40e_vc_iwarp_qvmap_msg(struct i40e_vf *vf, u8 *msg, u16 msglen,
 				(struct i40e_virtchnl_iwarp_qvlist_info *)msg;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VF_STAT_IWARPENA, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VF_STATE_IWARPENA, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
@@ -2407,7 +2407,7 @@ static int i40e_vc_config_rss_key(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	u16 vsi_id = vrk->vsi_id;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id) ||
 	    (vrk->key_len != I40E_HKEY_ARRAY_SIZE)) {
 		aq_ret = I40E_ERR_PARAM;
@@ -2439,7 +2439,7 @@ static int i40e_vc_config_rss_lut(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	u16 vsi_id = vrl->vsi_id;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id) ||
 	    (vrl->lut_entries != I40E_VF_HLUT_ARRAY_SIZE)) {
 		aq_ret = I40E_ERR_PARAM;
@@ -2469,7 +2469,7 @@ static int i40e_vc_get_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status aq_ret = 0;
 	int len = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto err;
 	}
@@ -2506,7 +2506,7 @@ static int i40e_vc_set_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status aq_ret = 0;
 
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto err;
 	}
@@ -2536,7 +2536,7 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	int valid_len = 0;
 
 	/* Check if VF is disabled. */
-	if (test_bit(I40E_VF_STAT_DISABLED, &vf->vf_states))
+	if (test_bit(I40E_VF_STATE_DISABLED, &vf->vf_states))
 		return I40E_ERR_PARAM;
 
 	/* Validate message length. */
@@ -2860,7 +2860,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
 			vf_id);
 		ret = -EAGAIN;
@@ -2949,7 +2949,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev, int vf_id,
 
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
 			vf_id);
 		ret = -EAGAIN;
@@ -3081,7 +3081,7 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
 			vf_id);
 		ret = -EAGAIN;
@@ -3162,7 +3162,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 	vf = &(pf->vf[vf_id]);
 	/* first vsi is always the LAN vsi */
 	vsi = pf->vsi[vf->lan_vsi_idx];
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
 			vf_id);
 		ret = -EAGAIN;
@@ -3281,7 +3281,7 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable)
 	}
 
 	vf = &(pf->vf[vf_id]);
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+	if (!test_bit(I40E_VF_STATE_INIT, &vf->vf_states)) {
 		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
 			vf_id);
 		ret = -EAGAIN;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 9495f1422122..8c7c08489612 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -56,13 +56,13 @@ enum i40e_queue_ctrl {
 
 /* VF states */
 enum i40e_vf_states {
-	I40E_VF_STAT_INIT = 0,
-	I40E_VF_STAT_ACTIVE,
-	I40E_VF_STAT_IWARPENA,
-	I40E_VF_STAT_FCOEENA,
-	I40E_VF_STAT_DISABLED,
-	I40E_VF_STAT_MC_PROMISC,
-	I40E_VF_STAT_UC_PROMISC,
+	I40E_VF_STATE_INIT = 0,
+	I40E_VF_STATE_ACTIVE,
+	I40E_VF_STATE_IWARPENA,
+	I40E_VF_STATE_FCOEENA,
+	I40E_VF_STATE_DISABLED,
+	I40E_VF_STATE_MC_PROMISC,
+	I40E_VF_STATE_UC_PROMISC,
 };
 
 /* VF capabilities */
-- 
2.12.2
