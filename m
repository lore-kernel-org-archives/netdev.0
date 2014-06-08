From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: fix rx descriptor status
Date: Sun,  8 Jun 2014 07:33:43 -0700
Message-ID: <1402238037-20661-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64912 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbaFHOeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:01 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As reported by Eric Dumazet, the driver is not masking the right
bits in the receive descriptor before it starts checking them.

This patch extends the mask to allow for the right bits to be
checked, and fixes the issue permanently via a define.

CC: Eric Dumazet <eric.dumazet@gmail.com>
Change-ID: I3274f7619057a950f468143e6d7e11b129f54655
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 10 ++++++----
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 10 ++++++----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 5a930b3..7fbbab4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -492,9 +492,6 @@ union i40e_32byte_rx_desc {
 	} wb;  /* writeback */
 };
 
-#define I40E_RXD_QW1_STATUS_SHIFT	0
-#define I40E_RXD_QW1_STATUS_MASK	(0x7FFFUL << I40E_RXD_QW1_STATUS_SHIFT)
-
 enum i40e_rx_desc_status_bits {
 	/* Note: These are predefined bit offsets */
 	I40E_RX_DESC_STATUS_DD_SHIFT		= 0,
@@ -511,9 +508,14 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_LPBK_SHIFT		= 14,
 	I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT	= 15,
 	I40E_RX_DESC_STATUS_RESERVED_SHIFT	= 16, /* 2 BITS */
-	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18
+	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18,
+	I40E_RX_DESC_STATUS_LAST /* this entry must be last!!! */
 };
 
+#define I40E_RXD_QW1_STATUS_SHIFT	0
+#define I40E_RXD_QW1_STATUS_MASK	(((1 << I40E_RX_DESC_STATUS_LAST) - 1) \
+					 << I40E_RXD_QW1_STATUS_SHIFT)
+
 #define I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT   I40E_RX_DESC_STATUS_TSYNINDX_SHIFT
 #define I40E_RXD_QW1_STATUS_TSYNINDX_MASK	(0x3UL << \
 					     I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4fc9835..9c901fd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -492,9 +492,6 @@ union i40e_32byte_rx_desc {
 	} wb;  /* writeback */
 };
 
-#define I40E_RXD_QW1_STATUS_SHIFT	0
-#define I40E_RXD_QW1_STATUS_MASK	(0x7FFFUL << I40E_RXD_QW1_STATUS_SHIFT)
-
 enum i40e_rx_desc_status_bits {
 	/* Note: These are predefined bit offsets */
 	I40E_RX_DESC_STATUS_DD_SHIFT		= 0,
@@ -511,9 +508,14 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_LPBK_SHIFT		= 14,
 	I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT	= 15,
 	I40E_RX_DESC_STATUS_RESERVED_SHIFT	= 16, /* 2 BITS */
-	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18
+	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18,
+	I40E_RX_DESC_STATUS_LAST /* this entry must be last!!! */
 };
 
+#define I40E_RXD_QW1_STATUS_SHIFT	0
+#define I40E_RXD_QW1_STATUS_MASK	(((1 << I40E_RX_DESC_STATUS_LAST) - 1) \
+					 << I40E_RXD_QW1_STATUS_SHIFT)
+
 #define I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT   I40E_RX_DESC_STATUS_TSYNINDX_SHIFT
 #define I40E_RXD_QW1_STATUS_TSYNINDX_MASK	(0x3UL << \
 					     I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT)
-- 
1.9.3
