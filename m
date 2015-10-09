From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: refactor code to remove indent
Date: Thu,  8 Oct 2015 18:32:51 -0700
Message-ID: <1444354374-24351-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23167 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755551AbbJIBdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:00 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

I found a code indent that was avoidable because a whole function is inside
an if block, reverse the if and move the code back a tab.

Change-ID: I9989c8750ee61678fbf96a3b0fd7bf7cc7ef300a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 82 +++++++++++++++--------------
 1 file changed, 42 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 12b90fa..c46d814 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5679,49 +5679,51 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
 		return;
 
-	if (time_after(jiffies, pf->fd_flush_timestamp +
-				(I40E_MIN_FD_FLUSH_INTERVAL * HZ))) {
-		/* If the flush is happening too quick and we have mostly
-		 * SB rules we should not re-enable ATR for some time.
-		 */
-		min_flush_time = pf->fd_flush_timestamp
-				+ (I40E_MIN_FD_FLUSH_SB_ATR_UNSTABLE * HZ);
-		fd_room = pf->fdir_pf_filter_count - pf->fdir_pf_active_filters;
+	if (!time_after(jiffies, pf->fd_flush_timestamp +
+				 (I40E_MIN_FD_FLUSH_INTERVAL * HZ)))
+		return;
 
-		if (!(time_after(jiffies, min_flush_time)) &&
-		    (fd_room < I40E_FDIR_BUFFER_HEAD_ROOM_FOR_ATR)) {
-			if (I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "ATR disabled, not enough FD filter space.\n");
-			disable_atr = true;
-		}
+	/* If the flush is happening too quick and we have mostly SB rules we
+	 * should not re-enable ATR for some time.
+	 */
+	min_flush_time = pf->fd_flush_timestamp +
+			 (I40E_MIN_FD_FLUSH_SB_ATR_UNSTABLE * HZ);
+	fd_room = pf->fdir_pf_filter_count - pf->fdir_pf_active_filters;
 
-		pf->fd_flush_timestamp = jiffies;
-		pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-		/* flush all filters */
-		wr32(&pf->hw, I40E_PFQF_CTL_1,
-		     I40E_PFQF_CTL_1_CLEARFDTABLE_MASK);
-		i40e_flush(&pf->hw);
-		pf->fd_flush_cnt++;
-		pf->fd_add_err = 0;
-		do {
-			/* Check FD flush status every 5-6msec */
-			usleep_range(5000, 6000);
-			reg = rd32(&pf->hw, I40E_PFQF_CTL_1);
-			if (!(reg & I40E_PFQF_CTL_1_CLEARFDTABLE_MASK))
-				break;
-		} while (flush_wait_retry--);
-		if (reg & I40E_PFQF_CTL_1_CLEARFDTABLE_MASK) {
-			dev_warn(&pf->pdev->dev, "FD table did not flush, needs more time\n");
-		} else {
-			/* replay sideband filters */
-			i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
-			if (!disable_atr)
-				pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
-			clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
-			if (I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
-		}
+	if (!(time_after(jiffies, min_flush_time)) &&
+	    (fd_room < I40E_FDIR_BUFFER_HEAD_ROOM_FOR_ATR)) {
+		if (I40E_DEBUG_FD & pf->hw.debug_mask)
+			dev_info(&pf->pdev->dev, "ATR disabled, not enough FD filter space.\n");
+		disable_atr = true;
+	}
+
+	pf->fd_flush_timestamp = jiffies;
+	pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+	/* flush all filters */
+	wr32(&pf->hw, I40E_PFQF_CTL_1,
+	     I40E_PFQF_CTL_1_CLEARFDTABLE_MASK);
+	i40e_flush(&pf->hw);
+	pf->fd_flush_cnt++;
+	pf->fd_add_err = 0;
+	do {
+		/* Check FD flush status every 5-6msec */
+		usleep_range(5000, 6000);
+		reg = rd32(&pf->hw, I40E_PFQF_CTL_1);
+		if (!(reg & I40E_PFQF_CTL_1_CLEARFDTABLE_MASK))
+			break;
+	} while (flush_wait_retry--);
+	if (reg & I40E_PFQF_CTL_1_CLEARFDTABLE_MASK) {
+		dev_warn(&pf->pdev->dev, "FD table did not flush, needs more time\n");
+	} else {
+		/* replay sideband filters */
+		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
+		if (!disable_atr)
+			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
+		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+		if (I40E_DEBUG_FD & pf->hw.debug_mask)
+			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
 	}
+
 }
 
 /**
-- 
2.4.3
