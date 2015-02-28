From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/18] i40e: Only enable TC0 for NIC partition type
Date: Sat, 28 Feb 2015 03:29:48 -0800
Message-ID: <1425122989-354-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbbB1LaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:01 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

In case of MFP mode the driver was returning incorrect number of TCs
for partitions that are not enabled for iSCSI. Though the driver does
not configure these TCs in the Tx scheduler for the NIC partitions;
it does use this map to setup the queue mappings.

This patch fixes this and keeps all the NIC partitions to the default
PF TC i.e. TC0.

Change-ID: Iede214c907e7bac1356e999049b9f642759512b3
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c9936cc..75b7475 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4133,7 +4133,7 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 	if (pf->hw.func_caps.iscsi)
 		enabled_tc =  i40e_get_iscsi_tc_map(pf);
 	else
-		enabled_tc = pf->hw.func_caps.enabled_tcmap;
+		return 1; /* Only TC0 */
 
 	/* At least have TC0 */
 	enabled_tc = (enabled_tc ? enabled_tc : 0x1);
@@ -4183,11 +4183,11 @@ static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
 		return i40e_dcb_get_enabled_tc(&pf->hw.local_dcbx_config);
 
-	/* MPF enabled and iSCSI PF type */
+	/* MFP enabled and iSCSI PF type */
 	if (pf->hw.func_caps.iscsi)
 		return i40e_get_iscsi_tc_map(pf);
 	else
-		return pf->hw.func_caps.enabled_tcmap;
+		return i40e_pf_get_default_tc(pf);
 }
 
 /**
-- 
1.9.3
