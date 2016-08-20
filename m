From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Fix byte ordering in ARP NS code for X722
Date: Fri, 19 Aug 2016 23:19:43 -0700
Message-ID: <1471673991-117115-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6494 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752379AbcHTGTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:55 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes byte ordering problems found when enabling this feature
support. Without this patch, the feature will not work correctly. This
patch fixes the definitions to have the correct byte order.

Change-ID: Ic7489fbcbe2195df7be62ff5e359201b827cefe6
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 38 ++++++++++++----------
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 38 ++++++++++++----------
 2 files changed, 42 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 11cf1a5..5c4bf76 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -450,13 +450,15 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_cppm_configuration);
 /* Set ARP Proxy command / response (indirect 0x0104) */
 struct i40e_aqc_arp_proxy_data {
 	__le16	command_flags;
-#define I40E_AQ_ARP_INIT_IPV4	0x0008
-#define I40E_AQ_ARP_UNSUP_CTL	0x0010
-#define I40E_AQ_ARP_ENA		0x0020
-#define I40E_AQ_ARP_ADD_IPV4	0x0040
-#define I40E_AQ_ARP_DEL_IPV4	0x0080
+#define I40E_AQ_ARP_INIT_IPV4	0x0800
+#define I40E_AQ_ARP_UNSUP_CTL	0x1000
+#define I40E_AQ_ARP_ENA		0x2000
+#define I40E_AQ_ARP_ADD_IPV4	0x4000
+#define I40E_AQ_ARP_DEL_IPV4	0x8000
 	__le16	table_id;
-	__le32	pfpm_proxyfc;
+	__le32	enabled_offloads;
+#define I40E_AQ_ARP_DIRECTED_OFFLOAD_ENABLE	0x00000020
+#define I40E_AQ_ARP_OFFLOAD_ENABLE		0x00000800
 	__le32	ip_addr;
 	u8	mac_addr[6];
 	u8	reserved[2];
@@ -471,17 +473,19 @@ struct i40e_aqc_ns_proxy_data {
 	__le16	table_idx_ipv6_0;
 	__le16	table_idx_ipv6_1;
 	__le16	control;
-#define I40E_AQ_NS_PROXY_ADD_0		0x0100
-#define I40E_AQ_NS_PROXY_DEL_0		0x0200
-#define I40E_AQ_NS_PROXY_ADD_1		0x0400
-#define I40E_AQ_NS_PROXY_DEL_1		0x0800
-#define I40E_AQ_NS_PROXY_ADD_IPV6_0	0x1000
-#define I40E_AQ_NS_PROXY_DEL_IPV6_0	0x2000
-#define I40E_AQ_NS_PROXY_ADD_IPV6_1	0x4000
-#define I40E_AQ_NS_PROXY_DEL_IPV6_1	0x8000
-#define I40E_AQ_NS_PROXY_COMMAND_SEQ	0x0001
-#define I40E_AQ_NS_PROXY_INIT_IPV6_TBL	0x0002
-#define I40E_AQ_NS_PROXY_INIT_MAC_TBL	0x0004
+#define I40E_AQ_NS_PROXY_ADD_0		0x0001
+#define I40E_AQ_NS_PROXY_DEL_0		0x0002
+#define I40E_AQ_NS_PROXY_ADD_1		0x0004
+#define I40E_AQ_NS_PROXY_DEL_1		0x0008
+#define I40E_AQ_NS_PROXY_ADD_IPV6_0	0x0010
+#define I40E_AQ_NS_PROXY_DEL_IPV6_0	0x0020
+#define I40E_AQ_NS_PROXY_ADD_IPV6_1	0x0040
+#define I40E_AQ_NS_PROXY_DEL_IPV6_1	0x0080
+#define I40E_AQ_NS_PROXY_COMMAND_SEQ	0x0100
+#define I40E_AQ_NS_PROXY_INIT_IPV6_TBL	0x0200
+#define I40E_AQ_NS_PROXY_INIT_MAC_TBL	0x0400
+#define I40E_AQ_NS_PROXY_OFFLOAD_ENABLE	0x0800
+#define I40E_AQ_NS_PROXY_DIRECTED_OFFLOAD_ENABLE	0x1000
 	u8	mac_addr_0[6];
 	u8	mac_addr_1[6];
 	u8	local_mac_addr[6];
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 3114dcf..0045650 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -447,13 +447,15 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_cppm_configuration);
 /* Set ARP Proxy command / response (indirect 0x0104) */
 struct i40e_aqc_arp_proxy_data {
 	__le16	command_flags;
-#define I40E_AQ_ARP_INIT_IPV4	0x0008
-#define I40E_AQ_ARP_UNSUP_CTL	0x0010
-#define I40E_AQ_ARP_ENA		0x0020
-#define I40E_AQ_ARP_ADD_IPV4	0x0040
-#define I40E_AQ_ARP_DEL_IPV4	0x0080
+#define I40E_AQ_ARP_INIT_IPV4	0x0800
+#define I40E_AQ_ARP_UNSUP_CTL	0x1000
+#define I40E_AQ_ARP_ENA		0x2000
+#define I40E_AQ_ARP_ADD_IPV4	0x4000
+#define I40E_AQ_ARP_DEL_IPV4	0x8000
 	__le16	table_id;
-	__le32	pfpm_proxyfc;
+	__le32	enabled_offloads;
+#define I40E_AQ_ARP_DIRECTED_OFFLOAD_ENABLE	0x00000020
+#define I40E_AQ_ARP_OFFLOAD_ENABLE		0x00000800
 	__le32	ip_addr;
 	u8	mac_addr[6];
 	u8	reserved[2];
@@ -468,17 +470,19 @@ struct i40e_aqc_ns_proxy_data {
 	__le16	table_idx_ipv6_0;
 	__le16	table_idx_ipv6_1;
 	__le16	control;
-#define I40E_AQ_NS_PROXY_ADD_0		0x0100
-#define I40E_AQ_NS_PROXY_DEL_0		0x0200
-#define I40E_AQ_NS_PROXY_ADD_1		0x0400
-#define I40E_AQ_NS_PROXY_DEL_1		0x0800
-#define I40E_AQ_NS_PROXY_ADD_IPV6_0	0x1000
-#define I40E_AQ_NS_PROXY_DEL_IPV6_0	0x2000
-#define I40E_AQ_NS_PROXY_ADD_IPV6_1	0x4000
-#define I40E_AQ_NS_PROXY_DEL_IPV6_1	0x8000
-#define I40E_AQ_NS_PROXY_COMMAND_SEQ	0x0001
-#define I40E_AQ_NS_PROXY_INIT_IPV6_TBL	0x0002
-#define I40E_AQ_NS_PROXY_INIT_MAC_TBL	0x0004
+#define I40E_AQ_NS_PROXY_ADD_0		0x0001
+#define I40E_AQ_NS_PROXY_DEL_0		0x0002
+#define I40E_AQ_NS_PROXY_ADD_1		0x0004
+#define I40E_AQ_NS_PROXY_DEL_1		0x0008
+#define I40E_AQ_NS_PROXY_ADD_IPV6_0	0x0010
+#define I40E_AQ_NS_PROXY_DEL_IPV6_0	0x0020
+#define I40E_AQ_NS_PROXY_ADD_IPV6_1	0x0040
+#define I40E_AQ_NS_PROXY_DEL_IPV6_1	0x0080
+#define I40E_AQ_NS_PROXY_COMMAND_SEQ	0x0100
+#define I40E_AQ_NS_PROXY_INIT_IPV6_TBL	0x0200
+#define I40E_AQ_NS_PROXY_INIT_MAC_TBL	0x0400
+#define I40E_AQ_NS_PROXY_OFFLOAD_ENABLE	0x0800
+#define I40E_AQ_NS_PROXY_DIRECTED_OFFLOAD_ENABLE	0x1000
 	u8	mac_addr_0[6];
 	u8	mac_addr_1[6];
 	u8	local_mac_addr[6];
-- 
2.7.4
