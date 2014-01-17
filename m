From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 4/9] i40e: rename defines
Date: Fri, 17 Jan 2014 15:36:34 -0800
Message-ID: <1390001799-19425-5-git-send-email-aaron.f.brown@intel.com>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55439 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544AbaAQXhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:37:04 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The FLAG_FDIR_* defines can be renamed to be more descriptive.
This patch is in preparation for the following where the fdir
code is refactored.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 56 +++++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    |  2 +-
 4 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 6d0a702..a47f310 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -240,8 +240,8 @@ struct i40e_pf {
 #define I40E_FLAG_PROCESS_VFLR_EVENT           (u64)(1 << 18)
 #define I40E_FLAG_SRIOV_ENABLED                (u64)(1 << 19)
 #define I40E_FLAG_DCB_ENABLED                  (u64)(1 << 20)
-#define I40E_FLAG_FDIR_ENABLED                 (u64)(1 << 21)
-#define I40E_FLAG_FDIR_ATR_ENABLED             (u64)(1 << 22)
+#define I40E_FLAG_FD_SB_ENABLED                (u64)(1 << 21)
+#define I40E_FLAG_FD_ATR_ENABLED               (u64)(1 << 22)
 #define I40E_FLAG_PTP                          (u64)(1 << 25)
 #define I40E_FLAG_MFP_ENABLED                  (u64)(1 << 26)
 #ifdef CONFIG_I40E_VXLAN
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 151f9ff..ba1ea9f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1615,7 +1615,7 @@ static void i40e_get_channels(struct net_device *dev,
 	ch->max_combined = i40e_max_channels(vsi);
 
 	/* report info for other vector */
-	ch->other_count = (pf->flags & I40E_FLAG_FDIR_ENABLED) ? 1 : 0;
+	ch->other_count = (pf->flags & I40E_FLAG_FD_SB_ENABLED) ? 1 : 0;
 	ch->max_other = ch->other_count;
 
 	/* Note: This code assumes DCB is disabled for now. */
@@ -1648,7 +1648,7 @@ static int i40e_set_channels(struct net_device *dev,
 		return -EINVAL;
 
 	/* verify other_count has not changed */
-	if (ch->other_count != ((pf->flags & I40E_FLAG_FDIR_ENABLED) ? 1 : 0))
+	if (ch->other_count != ((pf->flags & I40E_FLAG_FD_SB_ENABLED) ? 1 : 0))
 		return -EINVAL;
 
 	/* verify the number of channels does not exceed hardware limits */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index adebf73..0ca9877 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2152,7 +2152,7 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 	u32 qtx_ctl = 0;
 
 	/* some ATR related tx ring init */
-	if (vsi->back->flags & I40E_FLAG_FDIR_ATR_ENABLED) {
+	if (vsi->back->flags & I40E_FLAG_FD_ATR_ENABLED) {
 		ring->atr_sample_rate = vsi->back->atr_sample_rate;
 		ring->atr_count = 0;
 	} else {
@@ -2172,8 +2172,8 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 	tx_ctx.new_context = 1;
 	tx_ctx.base = (ring->dma / 128);
 	tx_ctx.qlen = ring->count;
-	tx_ctx.fd_ena = !!(vsi->back->flags & (I40E_FLAG_FDIR_ENABLED |
-					       I40E_FLAG_FDIR_ATR_ENABLED));
+	tx_ctx.fd_ena = !!(vsi->back->flags & (I40E_FLAG_FD_SB_ENABLED |
+					       I40E_FLAG_FD_ATR_ENABLED));
 	tx_ctx.timesync_ena = !!(vsi->back->flags & I40E_FLAG_PTP);
 
 	/* As part of VSI creation/update, FW allocates certain
@@ -4740,8 +4740,8 @@ static void i40e_fdir_setup(struct i40e_pf *pf)
 	bool new_vsi = false;
 	int err, i;
 
-	if (!(pf->flags & (I40E_FLAG_FDIR_ENABLED |
-			   I40E_FLAG_FDIR_ATR_ENABLED)))
+	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED |
+			   I40E_FLAG_FD_ATR_ENABLED)))
 		return;
 
 	pf->atr_sample_rate = I40E_DEFAULT_ATR_SAMPLE_RATE;
@@ -4755,7 +4755,7 @@ static void i40e_fdir_setup(struct i40e_pf *pf)
 		vsi = i40e_vsi_setup(pf, I40E_VSI_FDIR, pf->mac_seid, 0);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "Couldn't create FDir VSI\n");
-			pf->flags &= ~I40E_FLAG_FDIR_ENABLED;
+			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 			return;
 		}
 		new_vsi = true;
@@ -5543,7 +5543,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	pf->num_vmdq_msix = pf->num_vmdq_qps;
 	v_budget = 1 + pf->num_lan_msix;
 	v_budget += (pf->num_vmdq_vsis * pf->num_vmdq_msix);
-	if (pf->flags & I40E_FLAG_FDIR_ENABLED)
+	if (pf->flags & I40E_FLAG_FD_SB_ENABLED)
 		v_budget++;
 
 	/* Scale down if necessary, and the rings will share vectors */
@@ -5679,13 +5679,13 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
 		err = i40e_init_msix(pf);
 		if (err) {
-			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	   |
-					I40E_FLAG_RSS_ENABLED	   |
-					I40E_FLAG_DCB_ENABLED	   |
-					I40E_FLAG_SRIOV_ENABLED	   |
-					I40E_FLAG_FDIR_ENABLED	   |
-					I40E_FLAG_FDIR_ATR_ENABLED |
-					I40E_FLAG_VMDQ_ENABLED);
+			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	|
+				       I40E_FLAG_RSS_ENABLED	|
+				       I40E_FLAG_DCB_ENABLED	|
+				       I40E_FLAG_SRIOV_ENABLED	|
+				       I40E_FLAG_FD_SB_ENABLED	|
+				       I40E_FLAG_FD_ATR_ENABLED	|
+				       I40E_FLAG_VMDQ_ENABLED);
 
 			/* rework the queue expectations without MSIX */
 			i40e_determine_queue_usage(pf);
@@ -5884,10 +5884,10 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		/* FW/NVM is not yet fixed in this regard */
 		if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
 		    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
-			pf->flags |= I40E_FLAG_FDIR_ATR_ENABLED;
+			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
 			dev_info(&pf->pdev->dev,
 				 "Flow Director ATR mode Enabled\n");
-			pf->flags |= I40E_FLAG_FDIR_ENABLED;
+			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
 			dev_info(&pf->pdev->dev,
 				 "Flow Director Side Band mode Enabled\n");
 			pf->fdir_pf_filter_count =
@@ -7383,7 +7383,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 
 	if   (!(pf->flags & I40E_FLAG_MSIX_ENABLED) ||
 		!(pf->flags & (I40E_FLAG_RSS_ENABLED |
-		I40E_FLAG_FDIR_ENABLED | I40E_FLAG_DCB_ENABLED)) ||
+		I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_DCB_ENABLED)) ||
 		(queues_left == 1)) {
 
 		/* one qp for PF, no queues for anything else */
@@ -7391,15 +7391,9 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		pf->rss_size = pf->num_lan_qps = 1;
 
 		/* make sure all the fancies are disabled */
-		pf->flags &= ~(I40E_FLAG_RSS_ENABLED       |
-				I40E_FLAG_FDIR_ENABLED	   |
-				I40E_FLAG_FDIR_ATR_ENABLED |
-				I40E_FLAG_DCB_ENABLED	   |
-				I40E_FLAG_SRIOV_ENABLED	   |
-				I40E_FLAG_VMDQ_ENABLED);
 
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
-		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
+		   !(pf->flags & I40E_FLAG_FD_SB_ENABLED)  &&
 		   !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
 
 		pf->rss_size = i40e_set_rss_size(pf, queues_left);
@@ -7408,7 +7402,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		pf->num_lan_qps = pf->rss_size_max;
 
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
-		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
+		   !(pf->flags & I40E_FLAG_FD_SB_ENABLED)  &&
 		   (pf->flags & I40E_FLAG_DCB_ENABLED)) {
 
 		/* save num_tc_qps queues for TCs 1 thru 7 and the rest
@@ -7427,7 +7421,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		pf->num_lan_qps = pf->rss_size_max + accum_tc_size;
 
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
-		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
+		  (pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
 		  !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
 
 		queues_left -= 1; /* save 1 queue for FD */
@@ -7443,7 +7437,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		pf->num_lan_qps = pf->rss_size_max;
 
 	} else if (pf->flags & I40E_FLAG_RSS_ENABLED   &&
-		  (pf->flags & I40E_FLAG_FDIR_ENABLED) &&
+		  (pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
 		  (pf->flags & I40E_FLAG_DCB_ENABLED)) {
 
 		/* save 1 queue for TCs 1 thru 7,
@@ -7462,6 +7456,12 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 
 		pf->num_lan_qps = pf->rss_size_max + accum_tc_size;
 
+		pf->flags &= ~(I40E_FLAG_RSS_ENABLED	|
+			       I40E_FLAG_FD_SB_ENABLED	|
+			       I40E_FLAG_FD_ATR_ENABLED	|
+			       I40E_FLAG_DCB_ENABLED	|
+			       I40E_FLAG_SRIOV_ENABLED	|
+			       I40E_FLAG_VMDQ_ENABLED);
 	} else {
 		dev_info(&pf->pdev->dev,
 			 "Invalid configuration, flags=0x%08llx\n", pf->flags);
@@ -7504,7 +7504,7 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf)
 	settings->hash_lut_size = I40E_HASH_LUT_SIZE_128;
 
 	/* Flow Director is enabled */
-	if (pf->flags & (I40E_FLAG_FDIR_ENABLED | I40E_FLAG_FDIR_ATR_ENABLED))
+	if (pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED))
 		settings->enable_fdir = true;
 
 	/* Ethtype and MACVLAN filters enabled for PF */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f57a8f8..d4bb482 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1239,7 +1239,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	u16 i;
 
 	/* make sure ATR is enabled */
-	if (!(pf->flags & I40E_FLAG_FDIR_ATR_ENABLED))
+	if (!(pf->flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
 
 	/* if sampling is disabled do nothing */
-- 
1.8.5.GIT
