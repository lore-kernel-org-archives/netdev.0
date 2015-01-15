From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 04:19:21 -0800
Message-ID: <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbbAOMTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:35 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The netdev name at init time often defaults to eth0 but later gets changed
by UDEV, so printing it here is misleading.  This patch removes the name
from the log messages, and removes the use of __func__ as we're not using
that any more in the driver.

Change-ID: Iff95fb72e953f8440bf504af331c6a4b8f5e2d18
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index a152878..4f69a84 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -285,8 +285,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 		pf->last_rx_ptp_check = jiffies;
 		pf->rx_hwtstamp_cleared++;
 		dev_warn(&vsi->back->pdev->dev,
-			 "%s: clearing Rx timestamp hang\n",
-			 __func__);
+			 "clearing PTP Rx timestamp hang\n");
 	}
 }
 
@@ -632,7 +631,6 @@ static long i40e_ptp_create_clock(struct i40e_pf *pf)
  **/
 void i40e_ptp_init(struct i40e_pf *pf)
 {
-	struct net_device *netdev = pf->vsi[pf->lan_vsi]->netdev;
 	struct i40e_hw *hw = &pf->hw;
 	u32 pf_id;
 	long err;
@@ -644,9 +642,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		I40E_PRTTSYN_CTL0_PF_ID_SHIFT;
 	if (hw->pf_id != pf_id) {
 		pf->flags &= ~I40E_FLAG_PTP;
-		dev_info(&pf->pdev->dev, "%s: PTP not supported on %s\n",
-			 __func__,
-			 netdev->name);
+		dev_info(&pf->pdev->dev, "PTP not supported on this device\n");
 		return;
 	}
 
@@ -659,14 +655,13 @@ void i40e_ptp_init(struct i40e_pf *pf)
 	err = i40e_ptp_create_clock(pf);
 	if (err) {
 		pf->ptp_clock = NULL;
-		dev_err(&pf->pdev->dev, "%s: ptp_clock_register failed\n",
-			__func__);
+		dev_err(&pf->pdev->dev,
+			"PTP clock register failed: %ld\n", err);
 	} else {
 		struct timespec ts;
 		u32 regval;
 
-		dev_info(&pf->pdev->dev, "%s: added PHC on %s\n", __func__,
-			 netdev->name);
+		dev_info(&pf->pdev->dev, "PHC enabled\n");
 		pf->flags |= I40E_FLAG_PTP;
 
 		/* Ensure the clocks are running. */
@@ -711,7 +706,7 @@ void i40e_ptp_stop(struct i40e_pf *pf)
 	if (pf->ptp_clock) {
 		ptp_clock_unregister(pf->ptp_clock);
 		pf->ptp_clock = NULL;
-		dev_info(&pf->pdev->dev, "%s: removed PHC on %s\n", __func__,
+		dev_info(&pf->pdev->dev, "removed PHC from %s\n",
 			 pf->vsi[pf->lan_vsi]->netdev->name);
 	}
 }
-- 
1.9.3
