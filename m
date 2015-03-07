From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Avoid logs while adding/deleting FD-SB filters
Date: Sat,  7 Mar 2015 07:03:17 -0800
Message-ID: <1425740603-11280-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbbCGPDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:30 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

It is not necessary to print FD filter add/delete log with
normal debug settings because ethtool -n ethx shows all the FD-SB
filters on an interface. The log can still be turned on through higher
debug levels and it will continue to print a log if there was an error
in the add/delete process.

Change-ID: I67db2baf49e2075d2f537de40f7895e5b02cd610
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 7327952..64beea9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -228,7 +228,7 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 			 fd_data->pctype, fd_data->fd_id, ret);
 		err = true;
-	} else {
+	} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 		if (add)
 			dev_info(&pf->pdev->dev,
 				 "Filter OK for PCTYPE %d loc = %d\n",
@@ -303,7 +303,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 			 fd_data->pctype, fd_data->fd_id, ret);
 		err = true;
-	} else {
+	} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 		if (add)
 			dev_info(&pf->pdev->dev, "Filter OK for PCTYPE %d loc = %d)\n",
 				 fd_data->pctype, fd_data->fd_id);
@@ -376,7 +376,7 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 				 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
 				 fd_data->pctype, fd_data->fd_id, ret);
 			err = true;
-		} else {
+		} else if (I40E_DEBUG_FD & pf->hw.debug_mask) {
 			if (add)
 				dev_info(&pf->pdev->dev,
 					 "Filter OK for PCTYPE %d loc = %d\n",
-- 
1.9.3
