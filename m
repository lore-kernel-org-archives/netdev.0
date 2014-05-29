From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: remove storm control
Date: Thu, 29 May 2014 08:10:10 -0700
Message-ID: <1401376216-12531-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42446 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932955AbaE2PKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:38 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The storm control features are not part of the hardware
and mistakenly were left in the code.  Remove them as
they are not needed any more.

Change-ID: I6e9277c8da2c52e69348a657bae25271449c2099
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 1 -
 drivers/net/ethernet/intel/i40e/i40e_register.h   | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h       | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_register.h | 4 ----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h     | 2 +-
 5 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 44fea89..239a2ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2568,7 +2568,6 @@ static void i40e_enable_misc_int_causes(struct i40e_hw *hw)
 	      I40E_PFINT_ICR0_ENA_PCI_EXCEPTION_MASK |
 	      I40E_PFINT_ICR0_ENA_GPIO_MASK          |
 	      I40E_PFINT_ICR0_ENA_TIMESYNC_MASK      |
-	      I40E_PFINT_ICR0_ENA_STORM_DETECT_MASK  |
 	      I40E_PFINT_ICR0_ENA_HMC_ERR_MASK       |
 	      I40E_PFINT_ICR0_ENA_VFLR_MASK          |
 	      I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index 1d40f42..25c9286 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -1340,8 +1340,6 @@
 #define I40E_PFINT_ICR0_GPIO_MASK (0x1 << I40E_PFINT_ICR0_GPIO_SHIFT)
 #define I40E_PFINT_ICR0_TIMESYNC_SHIFT 23
 #define I40E_PFINT_ICR0_TIMESYNC_MASK (0x1 << I40E_PFINT_ICR0_TIMESYNC_SHIFT)
-#define I40E_PFINT_ICR0_STORM_DETECT_SHIFT 24
-#define I40E_PFINT_ICR0_STORM_DETECT_MASK (0x1 << I40E_PFINT_ICR0_STORM_DETECT_SHIFT)
 #define I40E_PFINT_ICR0_LINK_STAT_CHANGE_SHIFT 25
 #define I40E_PFINT_ICR0_LINK_STAT_CHANGE_MASK (0x1 << I40E_PFINT_ICR0_LINK_STAT_CHANGE_SHIFT)
 #define I40E_PFINT_ICR0_HMC_ERR_SHIFT 26
@@ -1367,8 +1365,6 @@
 #define I40E_PFINT_ICR0_ENA_GPIO_MASK (0x1 << I40E_PFINT_ICR0_ENA_GPIO_SHIFT)
 #define I40E_PFINT_ICR0_ENA_TIMESYNC_SHIFT 23
 #define I40E_PFINT_ICR0_ENA_TIMESYNC_MASK (0x1 << I40E_PFINT_ICR0_ENA_TIMESYNC_SHIFT)
-#define I40E_PFINT_ICR0_ENA_STORM_DETECT_SHIFT 24
-#define I40E_PFINT_ICR0_ENA_STORM_DETECT_MASK (0x1 << I40E_PFINT_ICR0_ENA_STORM_DETECT_SHIFT)
 #define I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_SHIFT 25
 #define I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_MASK (0x1 << I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_SHIFT)
 #define I40E_PFINT_ICR0_ENA_HMC_ERR_SHIFT 26
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 71fbba9..d5e3f54 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -27,7 +27,7 @@
 #ifndef _I40E_TXRX_H_
 #define _I40E_TXRX_H_
 
-/* Interrupt Throttling and Rate Limiting (storm control) Goodies */
+/* Interrupt Throttling and Rate Limiting Goodies */
 
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
 #define I40E_MIN_ITR               0x0004  /* reg uses 2 usec resolution */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_register.h b/drivers/net/ethernet/intel/i40evf/i40e_register.h
index aa4a92e..7977205 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_register.h
@@ -1340,8 +1340,6 @@
 #define I40E_PFINT_ICR0_GPIO_MASK (0x1 << I40E_PFINT_ICR0_GPIO_SHIFT)
 #define I40E_PFINT_ICR0_TIMESYNC_SHIFT 23
 #define I40E_PFINT_ICR0_TIMESYNC_MASK (0x1 << I40E_PFINT_ICR0_TIMESYNC_SHIFT)
-#define I40E_PFINT_ICR0_STORM_DETECT_SHIFT 24
-#define I40E_PFINT_ICR0_STORM_DETECT_MASK (0x1 << I40E_PFINT_ICR0_STORM_DETECT_SHIFT)
 #define I40E_PFINT_ICR0_LINK_STAT_CHANGE_SHIFT 25
 #define I40E_PFINT_ICR0_LINK_STAT_CHANGE_MASK (0x1 << I40E_PFINT_ICR0_LINK_STAT_CHANGE_SHIFT)
 #define I40E_PFINT_ICR0_HMC_ERR_SHIFT 26
@@ -1367,8 +1365,6 @@
 #define I40E_PFINT_ICR0_ENA_GPIO_MASK (0x1 << I40E_PFINT_ICR0_ENA_GPIO_SHIFT)
 #define I40E_PFINT_ICR0_ENA_TIMESYNC_SHIFT 23
 #define I40E_PFINT_ICR0_ENA_TIMESYNC_MASK (0x1 << I40E_PFINT_ICR0_ENA_TIMESYNC_SHIFT)
-#define I40E_PFINT_ICR0_ENA_STORM_DETECT_SHIFT 24
-#define I40E_PFINT_ICR0_ENA_STORM_DETECT_MASK (0x1 << I40E_PFINT_ICR0_ENA_STORM_DETECT_SHIFT)
 #define I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_SHIFT 25
 #define I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_MASK (0x1 << I40E_PFINT_ICR0_ENA_LINK_STAT_CHANGE_SHIFT)
 #define I40E_PFINT_ICR0_ENA_HMC_ERR_SHIFT 26
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index a23c34e..af639d8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -27,7 +27,7 @@
 #ifndef _I40E_TXRX_H_
 #define _I40E_TXRX_H_
 
-/* Interrupt Throttling and Rate Limiting (storm control) Goodies */
+/* Interrupt Throttling and Rate Limiting Goodies */
 
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
 #define I40E_MIN_ITR               0x0004  /* reg uses 2 usec resolution */
-- 
1.9.3
