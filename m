From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] i40e: remove and fix confusing define name
Date: Tue, 10 Dec 2013 02:22:33 -0800
Message-ID: <1386670961-20392-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18536 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab3LJKXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:13 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

I40E_ITR_NONE was being used as an ITRN register index by
accident because it was easily associated with the I40E_RX_ITR
and friends defines.

Change the name slightly in order to make it clear that
I40E_ITR_NONE is really associated with the DYN_CTL register
sets.

Change-Id: I04702c027c7495b90a8bf2db85d3e085a2c7d02a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index db55d99..faabf22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -49,10 +49,23 @@
 
 #define I40E_QUEUE_END_OF_LIST 0x7FF
 
-#define I40E_ITR_NONE  3
-#define I40E_RX_ITR    0
-#define I40E_TX_ITR    1
-#define I40E_PE_ITR    2
+/* this enum matches hardware bits and is meant to be used by DYN_CTLN
+ * registers and QINT registers or more generally anywhere in the manual
+ * mentioning ITR_INDX, ITR_NONE cannot be used as an index 'n' into any
+ * register but instead is a special value meaning "don't update" ITR0/1/2.
+ */
+enum i40e_dyn_idx_t {
+	I40E_IDX_ITR0 = 0,
+	I40E_IDX_ITR1 = 1,
+	I40E_IDX_ITR2 = 2,
+	I40E_ITR_NONE = 3	/* ITR_NONE must not be used as an index */
+};
+
+/* these are indexes into ITRN registers */
+#define I40E_RX_ITR    I40E_IDX_ITR0
+#define I40E_TX_ITR    I40E_IDX_ITR1
+#define I40E_PE_ITR    I40E_IDX_ITR2
+
 /* Supported Rx Buffer Sizes */
 #define I40E_RXBUFFER_512   512    /* Used for packet split */
 #define I40E_RXBUFFER_2048  2048
-- 
1.8.3.1
