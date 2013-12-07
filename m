From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: separate TSYNVALID and TSYNINDX fields in Rx descriptor
Date: Fri,  6 Dec 2013 18:17:10 -0800
Message-ID: <1386382643-29055-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64593 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758062Ab3LGCR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:27 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In order to get 1588 to work correctly the defines need a bit
of a tweak.

Change-Id: Ie50ce2a18e1593441f1560411e5a4f51c6d48aaa
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 5f81bd5..fdad028 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -500,7 +500,8 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_L2TAG1P_SHIFT	= 2,
 	I40E_RX_DESC_STATUS_L3L4P_SHIFT		= 3,
 	I40E_RX_DESC_STATUS_CRCP_SHIFT		= 4,
-	I40E_RX_DESC_STATUS_TSYNINDX_SHIFT	= 5, /* 3 BITS */
+	I40E_RX_DESC_STATUS_TSYNINDX_SHIFT	= 5, /* 2 BITS */
+	I40E_RX_DESC_STATUS_TSYNVALID_SHIFT	= 7,
 	I40E_RX_DESC_STATUS_PIF_SHIFT		= 8,
 	I40E_RX_DESC_STATUS_UMBCAST_SHIFT	= 9, /* 2 BITS */
 	I40E_RX_DESC_STATUS_FLM_SHIFT		= 11,
@@ -509,9 +510,13 @@ enum i40e_rx_desc_status_bits {
 };
 
 #define I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT   I40E_RX_DESC_STATUS_TSYNINDX_SHIFT
-#define I40E_RXD_QW1_STATUS_TSYNINDX_MASK	(0x7UL << \
+#define I40E_RXD_QW1_STATUS_TSYNINDX_MASK	(0x3UL << \
 					     I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT)
 
+#define I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT  I40E_RX_DESC_STATUS_TSYNVALID_SHIFT
+#define I40E_RXD_QW1_STATUS_TSYNVALID_MASK	(0x1UL << \
+					     I40E_RXD_QW1_STATUS_TSYNVALID_SHIFT)
+
 enum i40e_rx_desc_fltstat_values {
 	I40E_RX_DESC_FLTSTAT_NO_DATA	= 0,
 	I40E_RX_DESC_FLTSTAT_RSV_FD_ID	= 1, /* 16byte desc? FD_ID : RSV */
-- 
1.8.3.1
