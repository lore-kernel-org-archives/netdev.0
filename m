From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e: chomp the BIT(_ULL)
Date: Sat, 12 Dec 2015 00:33:23 -0800
Message-ID: <1449909213-33795-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52824 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbbLLIdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:39 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

BIT_ULL was used on a u32 or less where it can simply be BIT. This
fixes some trivial static analyzer warnings. Chomp, chomp.

Tested with objdump of binary before and after, no changes to code.

Change-ID: I6245e9abd447192dbde1669c747aeb2878126c7d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 30 ++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2b1b655..3373b75 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1531,7 +1531,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	if (enabled_tc && (vsi->back->flags & I40E_FLAG_DCB_ENABLED)) {
 		/* Find numtc from enabled TC bitmap */
 		for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-			if (enabled_tc & BIT_ULL(i)) /* TC is enabled */
+			if (enabled_tc & BIT(i)) /* TC is enabled */
 				numtc++;
 		}
 		if (!numtc) {
@@ -1560,7 +1560,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	/* Setup queue offset/count for all TCs for given VSI */
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
 		/* See if the given TC is enabled for the given VSI */
-		if (vsi->tc_config.enabled_tc & BIT_ULL(i)) {
+		if (vsi->tc_config.enabled_tc & BIT(i)) {
 			/* TC is enabled */
 			int pow, num_qps;
 
@@ -4433,7 +4433,7 @@ static u8 i40e_get_iscsi_tc_map(struct i40e_pf *pf)
 		if (app.selector == I40E_APP_SEL_TCPIP &&
 		    app.protocolid == I40E_APP_PROTOID_ISCSI) {
 			tc = dcbcfg->etscfg.prioritytable[app.priority];
-			enabled_tc |= BIT_ULL(tc);
+			enabled_tc |= BIT(tc);
 			break;
 		}
 	}
@@ -4517,7 +4517,7 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 	/* At least have TC0 */
 	enabled_tc = (enabled_tc ? enabled_tc : 0x1);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		if (enabled_tc & BIT_ULL(i))
+		if (enabled_tc & BIT(i))
 			num_tc++;
 	}
 	return num_tc;
@@ -4539,7 +4539,7 @@ static u8 i40e_pf_get_default_tc(struct i40e_pf *pf)
 
 	/* Find the first enabled TC */
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		if (enabled_tc & BIT_ULL(i))
+		if (enabled_tc & BIT(i))
 			break;
 	}
 
@@ -4699,7 +4699,7 @@ static void i40e_vsi_config_netdev_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 		 * will set the numtc for netdev as 2 that will be
 		 * referenced by the netdev layer as TC 0 and 1.
 		 */
-		if (vsi->tc_config.enabled_tc & BIT_ULL(i))
+		if (vsi->tc_config.enabled_tc & BIT(i))
 			netdev_set_tc_queue(netdev,
 					vsi->tc_config.tc_info[i].netdev_tc,
 					vsi->tc_config.tc_info[i].qcount,
@@ -4761,7 +4761,7 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 
 	/* Enable ETS TCs with equal BW Share for now across all VSIs */
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		if (enabled_tc & BIT_ULL(i))
+		if (enabled_tc & BIT(i))
 			bw_share[i] = 1;
 	}
 
@@ -4835,7 +4835,7 @@ int i40e_veb_config_tc(struct i40e_veb *veb, u8 enabled_tc)
 
 	/* Enable ETS TCs with equal BW Share for now */
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		if (enabled_tc & BIT_ULL(i))
+		if (enabled_tc & BIT(i))
 			bw_data.tc_bw_share_credits[i] = 1;
 	}
 
@@ -5232,7 +5232,7 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 
 	/* Generate TC map for number of tc requested */
 	for (i = 0; i < tc; i++)
-		enabled_tc |= BIT_ULL(i);
+		enabled_tc |= BIT(i);
 
 	/* Requesting same TC configuration as already enabled */
 	if (enabled_tc == vsi->tc_config.enabled_tc)
@@ -6096,23 +6096,23 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 
 	rtnl_lock();
 	if (test_bit(__I40E_REINIT_REQUESTED, &pf->state)) {
-		reset_flags |= BIT_ULL(__I40E_REINIT_REQUESTED);
+		reset_flags |= BIT(__I40E_REINIT_REQUESTED);
 		clear_bit(__I40E_REINIT_REQUESTED, &pf->state);
 	}
 	if (test_bit(__I40E_PF_RESET_REQUESTED, &pf->state)) {
-		reset_flags |= BIT_ULL(__I40E_PF_RESET_REQUESTED);
+		reset_flags |= BIT(__I40E_PF_RESET_REQUESTED);
 		clear_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 	}
 	if (test_bit(__I40E_CORE_RESET_REQUESTED, &pf->state)) {
-		reset_flags |= BIT_ULL(__I40E_CORE_RESET_REQUESTED);
+		reset_flags |= BIT(__I40E_CORE_RESET_REQUESTED);
 		clear_bit(__I40E_CORE_RESET_REQUESTED, &pf->state);
 	}
 	if (test_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state)) {
-		reset_flags |= BIT_ULL(__I40E_GLOBAL_RESET_REQUESTED);
+		reset_flags |= BIT(__I40E_GLOBAL_RESET_REQUESTED);
 		clear_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state);
 	}
 	if (test_bit(__I40E_DOWN_REQUESTED, &pf->state)) {
-		reset_flags |= BIT_ULL(__I40E_DOWN_REQUESTED);
+		reset_flags |= BIT(__I40E_DOWN_REQUESTED);
 		clear_bit(__I40E_DOWN_REQUESTED, &pf->state);
 	}
 
@@ -10567,7 +10567,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* NVM bit on means WoL disabled for the port */
 	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
-	if ((1 << hw->port) & wol_nvm_bits || hw->partition_id != 1)
+	if (BIT (hw->port) & wol_nvm_bits || hw->partition_id != 1)
 		pf->wol_en = false;
 	else
 		pf->wol_en = true;
-- 
2.5.0
