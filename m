From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: set shared bit for multicast filters
Date: Wed, 17 Feb 2016 19:38:45 -0800
Message-ID: <1455766737-11911-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:4847 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424818AbcBRDjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:03 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the use of the new Shared MAC filter bit for multicast and broadcast
filters in order to make better use of the filters available from the
device.  The FW folks have assured me that setting this bit on older FW
will have no affect, so we don't need a version check.

Also fixed a stray indent problem nearby.

Also update copyright year.

Change-ID: I4c5826a32594382a7937a592a24d228588cee7aa
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 976b03f..edfea38 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -2435,6 +2435,7 @@ i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
 		(struct i40e_aqc_macvlan *)&desc.params.raw;
 	i40e_status status;
 	u16 buf_size;
+	int i;
 
 	if (count == 0 || !mv_list || !hw)
 		return I40E_ERR_PARAM;
@@ -2448,12 +2449,17 @@ i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
 	cmd->seid[1] = 0;
 	cmd->seid[2] = 0;
 
+	for (i = 0; i < count; i++)
+		if (is_multicast_ether_addr(mv_list[i].mac_addr))
+			mv_list[i].flags |=
+			       cpu_to_le16(I40E_AQC_MACVLAN_ADD_USE_SHARED_MAC);
+
 	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
 	if (buf_size > I40E_AQ_LARGE_BUF)
 		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, mv_list, buf_size,
-				    cmd_details);
+				       cmd_details);
 
 	return status;
 }
-- 
2.5.0
