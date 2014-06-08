From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e/i40evf: remove chatty reset messages
Date: Sun,  8 Jun 2014 07:33:53 -0700
Message-ID: <1402238037-20661-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64930 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbaFHOeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:07 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Both the PF side and the VF side of the VF reset process are too noisy.
We already warn the user that a reset is happening, and that is
sufficient.

Because some of these message are inside if statements, we have to
rejigger the brackets at the same time to keep our coding style
consistent.

Change-ID: Id175562fb0ec7c396d9de156b4890e136f52d5f4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  2 --
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 13 ++++---------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4502734..566eec1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5623,8 +5623,6 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	/* tell the firmware that we're starting */
 	i40e_send_version(pf);
 
-	dev_info(&pf->pdev->dev, "reset complete\n");
-
 end_core_reset:
 	clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
 }
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 590a9a4..e32b8c5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1486,15 +1486,12 @@ static void i40evf_reset_task(struct work_struct *work)
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if (rstat_val != I40E_VFR_VFACTIVE) {
-			dev_info(&adapter->pdev->dev, "Reset now occurring\n");
+		if (rstat_val != I40E_VFR_VFACTIVE)
 			break;
-		} else {
+		else
 			msleep(I40EVF_RESET_WAIT_MS);
-		}
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
-		dev_err(&adapter->pdev->dev, "Reset was not detected\n");
 		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
 		goto continue_reset; /* act like the reset happened */
 	}
@@ -1503,12 +1500,10 @@ static void i40evf_reset_task(struct work_struct *work)
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if (rstat_val == I40E_VFR_VFACTIVE) {
-			dev_info(&adapter->pdev->dev, "Reset complete, reinitializing\n");
+		if (rstat_val == I40E_VFR_VFACTIVE)
 			break;
-		} else {
+		else
 			msleep(I40EVF_RESET_WAIT_MS);
-		}
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		/* reset never finished */
-- 
1.9.3
