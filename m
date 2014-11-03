From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e: Add condition to enter fdir flush and reinit
Date: Mon,  3 Nov 2014 06:56:29 -0800
Message-ID: <1415026599-16232-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44867 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603AbaKCO4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:54 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

When FD_SB/ATR are not enabled, do not allow flow director flush
and reinit.

Change-ID: Iafe261c1862992981615815551abd1ed9fada0a8
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 834c9ff..0eccd82 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5211,6 +5211,9 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	int flush_wait_retry = 50;
 	int reg;
 
+	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
+		return;
+
 	if (time_after(jiffies, pf->fd_flush_timestamp +
 				(I40E_MIN_FD_FLUSH_INTERVAL * HZ))) {
 		set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
@@ -5272,6 +5275,9 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
 	if (test_bit(__I40E_DOWN, &pf->state))
 		return;
 
+	if (!(pf->flags & (I40E_FLAG_FD_SB_ENABLED | I40E_FLAG_FD_ATR_ENABLED)))
+		return;
+
 	if ((pf->fd_add_err >= I40E_MAX_FD_PROGRAM_ERROR) &&
 	    (i40e_get_current_atr_cnt(pf) >= pf->fd_atr_cnt) &&
 	    (i40e_get_current_atr_cnt(pf) > pf->fdir_pf_filter_count))
-- 
1.9.3
