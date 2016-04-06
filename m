From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: Enable Geneve offload for FW API ver > 1.4 for XL710/X710 devices
Date: Tue,  5 Apr 2016 20:35:57 -0700
Message-ID: <1459913769-56510-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40669 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527AbcDFDgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:17 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch enables the Capability for XL710/X710 devices with FW API
version higher than 1.4 to do geneve Rx offload.

Change-ID: I9a8f87772c48d7d67dc85e3701d2e0b845034c0b
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 297fd39..fdcb50a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9158,6 +9158,12 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 					I40E_VLAN_ANY, false, true);
 			spin_unlock_bh(&vsi->mac_filter_list_lock);
 		}
+	} else if ((pf->hw.aq.api_maj_ver > 1) ||
+		   ((pf->hw.aq.api_maj_ver == 1) &&
+		    (pf->hw.aq.api_min_ver > 4))) {
+		/* Supported in FW API version higher than 1.4 */
+		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	} else {
 		/* relate the VSI_VMDQ name to the VSI_MAIN name */
 		snprintf(netdev->name, IFNAMSIZ, "%sv%%d",
-- 
2.5.5
