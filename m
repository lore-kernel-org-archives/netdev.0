From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e/i40evf: Some flow director HW definition fixes
Date: Fri, 14 Mar 2014 02:47:16 -0700
Message-ID: <1394790446-31591-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Kevin Scott <kevin.c.scott@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26976 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543AbaCNJrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:32 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

1) Fix a name of the error bit to correctly indicate the error.
2) Added a fd_id field in the 32 byte desc at the place(qw0) where it gets
reported in the programming error desc WB. In a normal data desc
the fd_id field is reported in qw3.

Change-ID: Ide9a24bff7273da5889c36635d629bc3b5212010
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 6 +++++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 181a825..5c902f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -458,6 +458,10 @@ union i40e_32byte_rx_desc {
 			union {
 				__le32 rss; /* RSS Hash */
 				__le32 fcoe_param; /* FCoE DDP Context id */
+				/* Flow director filter id in case of
+				 * Programming status desc WB
+				 */
+				__le32 fd_id;
 			} hi_dword;
 		} qword0;
 		struct {
@@ -698,7 +702,7 @@ enum i40e_rx_prog_status_desc_prog_id_masks {
 enum i40e_rx_prog_status_desc_error_bits {
 	/* Note: These are predefined bit offsets */
 	I40E_RX_PROG_STATUS_DESC_FD_TBL_FULL_SHIFT	= 0,
-	I40E_RX_PROG_STATUS_DESC_NO_FD_QUOTA_SHIFT	= 1,
+	I40E_RX_PROG_STATUS_DESC_NO_FD_ENTRY_SHIFT	= 1,
 	I40E_RX_PROG_STATUS_DESC_FCOE_TBL_FULL_SHIFT	= 2,
 	I40E_RX_PROG_STATUS_DESC_FCOE_CONFLICT_SHIFT	= 3
 };
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 092aace..7189d6f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -464,6 +464,10 @@ union i40e_32byte_rx_desc {
 			union {
 				__le32 rss; /* RSS Hash */
 				__le32 fcoe_param; /* FCoE DDP Context id */
+				/* Flow director filter id in case of
+				 * Programming status desc WB
+				 */
+				__le32 fd_id;
 			} hi_dword;
 		} qword0;
 		struct {
@@ -704,7 +708,7 @@ enum i40e_rx_prog_status_desc_prog_id_masks {
 enum i40e_rx_prog_status_desc_error_bits {
 	/* Note: These are predefined bit offsets */
 	I40E_RX_PROG_STATUS_DESC_FD_TBL_FULL_SHIFT	= 0,
-	I40E_RX_PROG_STATUS_DESC_NO_FD_QUOTA_SHIFT	= 1,
+	I40E_RX_PROG_STATUS_DESC_NO_FD_ENTRY_SHIFT	= 1,
 	I40E_RX_PROG_STATUS_DESC_FCOE_TBL_FULL_SHIFT	= 2,
 	I40E_RX_PROG_STATUS_DESC_FCOE_CONFLICT_SHIFT	= 3
 };
-- 
1.8.3.1
