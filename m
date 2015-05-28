From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: Remove unnecessary pf members
Date: Thu, 28 May 2015 04:25:32 -0700
Message-ID: <1432812339-17129-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11036 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991AbbE1LZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:51 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We can use the stat index macro directly, a variable is not required.

Change-ID: I19f08ac16353dc0cd87a1a8248d714e15a54aa8a
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 --
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 10 ++++------
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0bfa5a0..aca9cef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -266,8 +266,6 @@ struct i40e_pf {
 
 	struct hlist_head fdir_filter_list;
 	u16 fdir_pf_active_filters;
-	u16 fd_sb_cnt_idx;
-	u16 fd_atr_cnt_idx;
 	unsigned long fd_flush_timestamp;
 	u32 fd_flush_cnt;
 	u32 fd_add_err;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c568c90..9a68c65 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2293,7 +2293,7 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	input->pctype = 0;
 	input->dest_vsi = vsi->id;
 	input->fd_status = I40E_FILTER_PROGRAM_DESC_FD_STATUS_FD_ID;
-	input->cnt_index  = pf->fd_sb_cnt_idx;
+	input->cnt_index  = I40E_FD_SB_STAT_IDX(pf->hw.pf_id);
 	input->flow_type = fsp->flow_type;
 	input->ip4_proto = fsp->h_u.usr_ip4_spec.proto;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e70a616..6f16f56 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1096,10 +1096,12 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 			   &osd->rx_jabber, &nsd->rx_jabber);
 
 	/* FDIR stats */
-	i40e_stat_update32(hw, I40E_GLQF_PCNT(pf->fd_atr_cnt_idx),
+	i40e_stat_update32(hw,
+			   I40E_GLQF_PCNT(I40E_FD_ATR_STAT_IDX(pf->hw.pf_id)),
 			   pf->stat_offsets_loaded,
 			   &osd->fd_atr_match, &nsd->fd_atr_match);
-	i40e_stat_update32(hw, I40E_GLQF_PCNT(pf->fd_sb_cnt_idx),
+	i40e_stat_update32(hw,
+			   I40E_GLQF_PCNT(I40E_FD_SB_STAT_IDX(pf->hw.pf_id)),
 			   pf->stat_offsets_loaded,
 			   &osd->fd_sb_match, &nsd->fd_sb_match);
 	i40e_stat_update32(hw,
@@ -7679,12 +7681,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
 		pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
 		pf->atr_sample_rate = I40E_DEFAULT_ATR_SAMPLE_RATE;
-		/* Setup a counter for fd_atr per PF */
-		pf->fd_atr_cnt_idx = I40E_FD_ATR_STAT_IDX(pf->hw.pf_id);
 		if (!(pf->flags & I40E_FLAG_MFP_ENABLED)) {
 			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
-			/* Setup a counter for fd_sb per PF */
-			pf->fd_sb_cnt_idx = I40E_FD_SB_STAT_IDX(pf->hw.pf_id);
 		} else {
 			dev_info(&pf->pdev->dev,
 				 "Flow Director Sideband mode Disabled in MFP mode\n");
-- 
2.1.0
