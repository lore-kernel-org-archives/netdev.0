From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: Add support for non-willing Apps
Date: Thu, 15 Oct 2015 14:43:17 -0700
Message-ID: <1444945404-30654-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28702 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbbJOVnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 17:43:32 -0400
In-Reply-To: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Bowers <gregory.j.bowers@intel.com>

Adds support for setting a new bit in the Set Local LLDP MIB AQ command
Type field.  When set to 1, the bit indicates to FW that Apps should be
treated as non-willing.  When 0, FW behaves as before.

Change-ID: I0d2101c1606c59c7188d3e6a0c7810e0f205233a
Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 7 +++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h       | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 02d5225..6584b6c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -2132,6 +2132,13 @@ I40E_CHECK_STRUCT_LEN(0x20, i40e_aqc_get_cee_dcb_cfg_resp);
 struct i40e_aqc_lldp_set_local_mib {
 #define SET_LOCAL_MIB_AC_TYPE_DCBX_SHIFT	0
 #define SET_LOCAL_MIB_AC_TYPE_DCBX_MASK	(1 << SET_LOCAL_MIB_AC_TYPE_DCBX_SHIFT)
+#define SET_LOCAL_MIB_AC_TYPE_DCBX_MASK	(1 << \
+					SET_LOCAL_MIB_AC_TYPE_DCBX_SHIFT)
+#define SET_LOCAL_MIB_AC_TYPE_LOCAL_MIB	0x0
+#define SET_LOCAL_MIB_AC_TYPE_NON_WILLING_APPS_SHIFT	(1)
+#define SET_LOCAL_MIB_AC_TYPE_NON_WILLING_APPS_MASK	(1 << \
+				SET_LOCAL_MIB_AC_TYPE_NON_WILLING_APPS_SHIFT)
+#define SET_LOCAL_MIB_AC_TYPE_NON_WILLING_APPS		0x1
 	u8	type;
 	u8	reserved0;
 	__le16	length;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 6f69576..9c4a457 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -475,6 +475,8 @@ struct i40e_dcbx_config {
 	u8  dcbx_mode;
 #define I40E_DCBX_MODE_CEE	0x1
 #define I40E_DCBX_MODE_IEEE	0x2
+	u8  app_mode;
+#define I40E_DCBX_APPS_NON_WILLING	0x1
 	u32 numapps;
 	u32 tlv_status; /* CEE mode TLV status */
 	struct i40e_dcb_ets_config etscfg;
-- 
2.4.3
