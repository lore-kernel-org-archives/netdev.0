From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e/i40evf: bundle more descriptors when allocating buffers
Date: Mon,  9 Oct 2017 15:38:35 -0700
Message-ID: <20171009223841.2557-9-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755519AbdJIWjH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:07 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Double the number of descriptors we'll bundle into one tail bump when
receiving. Empirical testing has shown that we reduce CPU utilization
and don't appear to reduce throughput or packet rate. 32 seems to be the
sweet spot, as it's half the default polling budget, so we'd essentially
reduce from 4 tail writes when polling down to 2. Increasing this up to
64 appears to have negative impacts as it may become possible that we
don't bump the tail each time we get polled, which could cause a long
delay between returning descriptors to the hardware.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index c3156aa3f709..ff57ae451524 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -208,7 +208,7 @@ static inline bool i40e_test_staterr(union i40e_rx_desc *rx_desc,
 }
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
-#define I40E_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+#define I40E_RX_BUFFER_WRITE	32	/* Must be power of 2 */
 #define I40E_RX_INCREMENT(r, i) \
 	do {					\
 		(i)++;				\
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 8f9830d7649a..8d26c85d12e1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -191,7 +191,7 @@ static inline bool i40e_test_staterr(union i40e_rx_desc *rx_desc,
 }
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
-#define I40E_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+#define I40E_RX_BUFFER_WRITE	32	/* Must be power of 2 */
 #define I40E_RX_INCREMENT(r, i) \
 	do {					\
 		(i)++;				\
-- 
2.14.2
