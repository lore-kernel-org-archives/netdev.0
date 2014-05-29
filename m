From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Use the new i40e_get_fd_cnt_all function in other places
Date: Thu, 29 May 2014 08:10:09 -0700
Message-ID: <1401376216-12531-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809AbaE2PKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:37 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We have a function to calculate this, so update the code to use the function.

Change-ID: Ia345b6fe6ec7f0b2dcf1199471b0d0f959ad3908
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 +---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 75bd99e..44fea89 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4712,8 +4712,7 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	    (pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return;
 	fcnt_prog = i40e_get_current_fd_count(pf);
-	fcnt_avail = pf->hw.fdir_shared_filter_count +
-					       pf->fdir_pf_filter_count;
+	fcnt_avail = i40e_get_fd_cnt_all(pf);
 	if (fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM)) {
 		if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
 		    (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1ecd9aa..5a22187 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -451,9 +451,7 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 
 		/* filter programming failed most likely due to table full */
 		fcnt_prog = i40e_get_current_fd_count(pf);
-		fcnt_avail = pf->hw.fdir_shared_filter_count +
-						       pf->fdir_pf_filter_count;
-
+		fcnt_avail = i40e_get_fd_cnt_all(pf);
 		/* If ATR is running fcnt_prog can quickly change,
 		 * if we are very close to full, it makes sense to disable
 		 * FD ATR/SB and then re-enable it when there is room.
-- 
1.9.3
