From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 16/17] i40e: Only enable TC0 for NIC partition type
Date: Tue,  3 Mar 2015 01:44:23 -0800
Message-ID: <1425375864-25117-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63685 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755978AbbCCJoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:44:38 -0500
In-Reply-To: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index f9da8e8..31450f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4107,7 +4107,7 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 	if (pf->hw.func_caps.iscsi)
 		enabled_tc =  i40e_get_iscsi_tc_map(pf);
 	else
-		enabled_tc = pf->hw.func_caps.enabled_tcmap;
+		return 1; /* Only TC0 */
 
 	/* At least have TC0 */
 	enabled_tc = (enabled_tc ? enabled_tc : 0x1);
@@ -4157,11 +4157,11 @@ static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
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
