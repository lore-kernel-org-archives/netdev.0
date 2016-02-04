From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 19/20] i40e: AQ Add external power class to get link status
Date: Thu,  4 Feb 2016 03:49:10 -0800
Message-ID: <1454586551-35919-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41087 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965773AbcBDLtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:21 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new External Device Power Ability field to the get_link_status data
structure, using space from the reserved field at the end of the struct.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 7 ++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index eab55ea..0e608d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1758,7 +1758,12 @@ struct i40e_aqc_get_link_status {
 	u8	config;
 #define I40E_AQ_CONFIG_CRC_ENA		0x04
 #define I40E_AQ_CONFIG_PACING_MASK	0x78
-	u8	reserved[5];
+	u8	external_power_ability;
+#define I40E_AQ_LINK_POWER_CLASS_1	0x00
+#define I40E_AQ_LINK_POWER_CLASS_2	0x01
+#define I40E_AQ_LINK_POWER_CLASS_3	0x02
+#define I40E_AQ_LINK_POWER_CLASS_4	0x03
+	u8	reserved[4];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_get_link_status);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 30b5a33..578b178 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1755,7 +1755,12 @@ struct i40e_aqc_get_link_status {
 	u8	config;
 #define I40E_AQ_CONFIG_CRC_ENA		0x04
 #define I40E_AQ_CONFIG_PACING_MASK	0x78
-	u8	reserved[5];
+	u8	external_power_ability;
+#define I40E_AQ_LINK_POWER_CLASS_1	0x00
+#define I40E_AQ_LINK_POWER_CLASS_2	0x01
+#define I40E_AQ_LINK_POWER_CLASS_3	0x02
+#define I40E_AQ_LINK_POWER_CLASS_4	0x03
+	u8	reserved[4];
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aqc_get_link_status);
-- 
2.5.0
