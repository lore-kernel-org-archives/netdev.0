From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Don't check operational or sync bit for App TLV
Date: Thu,  5 Mar 2015 08:46:21 -0800
Message-ID: <1425573992-30955-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29925 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757941AbbCEQqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:53 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

In CEE mode the firmware does not set the operational status bit of
the application TLV status as returned from the "Get CEE DCBX Oper Cfg"
AQ command. This occurs whenever a DCBX configuration is changed.

This is a workaround to remove the check for the operational and sync bits
of the application TLV status till a firmware fix is provided.

Change-ID: I1a31ff2fcadcb06feb5b55776a33593afc6ea176
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 3ce4358..6e14667 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -459,7 +459,7 @@ static void i40e_cee_to_dcb_v1_config(
 	sync = (status & I40E_TLV_STATUS_SYNC) ? 1 : 0;
 	oper = (status & I40E_TLV_STATUS_OPER) ? 1 : 0;
 	/* Add APPs if Error is False and Oper/Sync is True */
-	if (!err && sync && oper) {
+	if (!err) {
 		/* CEE operating configuration supports FCoE/iSCSI/FIP only */
 		dcbcfg->numapps = I40E_CEE_OPER_MAX_APPS;
 
-- 
1.9.3
