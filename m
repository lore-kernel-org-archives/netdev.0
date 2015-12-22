From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] fm10k: correctly pack TLV structures and explain reasoning
Date: Tue, 22 Dec 2015 06:02:04 -0800
Message-ID: <1450792932-96015-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbbLVODN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:13 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The TLV format for little endian structures is actually 4 byte aligned
copy. To this end, we need to add an additional __aligned(4) marker
along with __packed to ensure that these structures are actually 4 byte
aligned and packed correctly. Use of just __packed will not work as this
will result in 1byte alignment which is incorrect. Add a comment
explaining the reasoning behind why these structures need the special
treatment.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index a8fc512..3378592 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -74,6 +74,11 @@ enum fm10k_pf_tlv_attr_id_v1 {
 #define FM10K_MSG_UPDATE_PVID_PVID_SHIFT	16
 #define FM10K_MSG_UPDATE_PVID_PVID_SIZE		16
 
+/* The following data structures are overlayed directly onto TLV mailbox
+ * messages, and must not break 4 byte alignment. Ensure the structures line
+ * up correctly as per their TLV definition.
+ */
+
 struct fm10k_mac_update {
 	__le32	mac_lower;
 	__le16	mac_upper;
@@ -81,26 +86,26 @@ struct fm10k_mac_update {
 	__le16	glort;
 	u8	flags;
 	u8	action;
-} __packed;
+} __aligned(4) __packed;
 
 struct fm10k_global_table_data {
 	__le32	used;
 	__le32	avail;
-} __packed;
+} __aligned(4) __packed;
 
 struct fm10k_swapi_error {
 	__le32				status;
 	struct fm10k_global_table_data	mac;
 	struct fm10k_global_table_data	nexthop;
 	struct fm10k_global_table_data	ffu;
-} __packed;
+} __aligned(4) __packed;
 
 struct fm10k_swapi_1588_timestamp {
 	__le64 egress;
 	__le64 ingress;
 	__le16 dglort;
 	__le16 sglort;
-} __packed;
+} __aligned(4) __packed;
 
 s32 fm10k_msg_lport_map_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
 extern const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[];
-- 
2.5.0
