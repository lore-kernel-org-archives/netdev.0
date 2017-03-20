From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: remove redundant check for fd_tcp_rule when restoring filters
Date: Mon, 20 Mar 2017 16:47:07 -0700
Message-ID: <20170320234712.84157-9-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:28474 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755928AbdCTXrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:20 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

i40e_fdir_filter_restore re-adds all existing filters, which already
checks when adding a TCPv4 filter to disable ATR. We don't need to make
the check twice, so remove this redundant code.

Change-ID: Ia0b0690e23523915199d601494557def135c9d7f
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6e63459ceb65..221e1705c031 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5466,12 +5466,6 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 	if (vsi->type == I40E_VSI_FDIR) {
 		/* reset fd counters */
 		pf->fd_add_err = pf->fd_atr_cnt = 0;
-		if (pf->fd_tcp_rule > 0) {
-			pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
-			if (I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 exist\n");
-			pf->fd_tcp_rule = 0;
-		}
 		i40e_fdir_filter_restore(vsi);
 	}
 
-- 
2.12.0
