From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/17] fm10k: pack TLV overlay structures
Date: Wed, 17 Jun 2015 05:55:00 -0700
Message-ID: <1434545704-112470-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14632 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756580AbbFQMzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:21 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds the __attribute__((packed)) indicator to some structures
which are overlayed onto a TLV message. These structures must be packed
as small as possible in order to correctly align when copied into the
mailbox buffer. Without doing so, the receiving mailbox code incorrectly
parses the values and we get invalid message responses from the switch
manager software.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index 7ab1db4..40a0dbc 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -81,26 +81,26 @@ struct fm10k_mac_update {
 	__le16	glort;
 	u8	flags;
 	u8	action;
-};
+} __packed;
 
 struct fm10k_global_table_data {
 	__le32	used;
 	__le32	avail;
-};
+} __packed;
 
 struct fm10k_swapi_error {
 	__le32				status;
 	struct fm10k_global_table_data	mac;
 	struct fm10k_global_table_data	nexthop;
 	struct fm10k_global_table_data	ffu;
-};
+} __packed;
 
 struct fm10k_swapi_1588_timestamp {
 	__le64 egress;
 	__le64 ingress;
 	__le16 dglort;
 	__le16 sglort;
-};
+} __packed;
 
 s32 fm10k_msg_lport_map_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
 extern const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[];
-- 
2.4.3
