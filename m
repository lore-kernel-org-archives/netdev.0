From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] i40e: Add protocols over MCTP to i40e_aq_discover_capabilities
Date: Sat,  3 Dec 2016 01:19:20 -0800
Message-ID: <20161203091930.14268-9-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Piotr Raczynski <piotr.raczynski@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18542 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751651AbcLCJUj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:39 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Piotr Raczynski <piotr.raczynski@intel.com>

Add logical_id to I40E_AQ_CAP_ID_MNG_MODE capability starting from major
version 2.

Change-ID: Idb29214b172ea5c70cbd45a99e6745c0215af7e4
Signed-off-by: Piotr Raczynski <piotr.raczynski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 8 ++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 4 ++++
 3 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 5cef393..e83e8e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3147,6 +3147,14 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 			break;
 		case I40E_AQ_CAP_ID_MNG_MODE:
 			p->management_mode = number;
+			if (major_rev > 1) {
+				p->mng_protocols_over_mctp = logical_id;
+				i40e_debug(hw, I40E_DEBUG_INIT,
+					   "HW Capability: Protocols over MCTP = %d\n",
+					   p->mng_protocols_over_mctp);
+			} else {
+				p->mng_protocols_over_mctp = 0;
+			}
 			break;
 		case I40E_AQ_CAP_ID_NPAR_ACTIVE:
 			p->npar_enable = number;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 671969c..bd1ffae 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -263,6 +263,10 @@ struct i40e_hw_capabilities {
 #define I40E_NVM_IMAGE_TYPE_UDP_CLOUD	0x3
 
 	u32  management_mode;
+	u32  mng_protocols_over_mctp;
+#define I40E_MNG_PROTOCOL_PLDM		0x2
+#define I40E_MNG_PROTOCOL_OEM_COMMANDS	0x4
+#define I40E_MNG_PROTOCOL_NCSI		0x8
 	u32  npar_enable;
 	u32  os2bmc;
 	u32  valid_functions;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index ca7afe5..515484c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -237,6 +237,10 @@ struct i40e_hw_capabilities {
 #define I40E_NVM_IMAGE_TYPE_UDP_CLOUD	0x3
 
 	u32  management_mode;
+	u32  mng_protocols_over_mctp;
+#define I40E_MNG_PROTOCOL_PLDM		0x2
+#define I40E_MNG_PROTOCOL_OEM_COMMANDS	0x4
+#define I40E_MNG_PROTOCOL_NCSI		0x8
 	u32  npar_enable;
 	u32  os2bmc;
 	u32  valid_functions;
-- 
2.9.3
