From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] e1000e: Add Support for 38.4MHZ frequency
Date: Sun, 30 Apr 2017 05:36:14 -0700
Message-ID: <20170430123614.67897-5-jeffrey.t.kirsher@intel.com>
References: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Cc: Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48630 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936445AbdD3MgV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 08:36:21 -0400
In-Reply-To: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Neftin <sasha.neftin@intel.com>

Add support for 38.4MHz frequency is required for PTP
on CannonLake. SYSTIM frequency adjustment attributes for TIMINCA are
get/set dependent on the hardware clock frequency for a different
types of adapters. 38.4MHz frequency supported by CannonLake
and active once time synchronisation mechanism was enabled
Changed abbreviation from Hz to HZ to be compliant checkpatch code style

Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
Reviewed-by: Raanan Avargil <raanan.avargil@intel.com>
Reviewed-by: Dima Ruinskiy <dima.ruinskiy@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  | 28 +++++++++--------
 drivers/net/ethernet/intel/e1000e/netdev.c | 49 +++++++++++++++++++-----------
 2 files changed, 48 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index f16d9826c66d..c7c994eb410e 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -379,18 +379,22 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca);
  * INCVALUE_n into the TIMINCA register allowing 32+8+(24-INCVALUE_SHIFT_n)
  * bits to count nanoseconds leaving the rest for fractional nonseconds.
  */
-#define INCVALUE_96MHz		125
-#define INCVALUE_SHIFT_96MHz	17
-#define INCPERIOD_SHIFT_96MHz	2
-#define INCPERIOD_96MHz		(12 >> INCPERIOD_SHIFT_96MHz)
-
-#define INCVALUE_25MHz		40
-#define INCVALUE_SHIFT_25MHz	18
-#define INCPERIOD_25MHz		1
-
-#define INCVALUE_24MHz		125
-#define INCVALUE_SHIFT_24MHz	14
-#define INCPERIOD_24MHz		3
+#define INCVALUE_96MHZ		125
+#define INCVALUE_SHIFT_96MHZ	17
+#define INCPERIOD_SHIFT_96MHZ	2
+#define INCPERIOD_96MHZ		(12 >> INCPERIOD_SHIFT_96MHZ)
+
+#define INCVALUE_25MHZ		40
+#define INCVALUE_SHIFT_25MHZ	18
+#define INCPERIOD_25MHZ		1
+
+#define INCVALUE_24MHZ		125
+#define INCVALUE_SHIFT_24MHZ	14
+#define INCPERIOD_24MHZ		3
+
+#define INCVALUE_38400KHZ	26
+#define INCVALUE_SHIFT_38400KHZ	19
+#define INCPERIOD_38400KHZ	1
 
 /* Another drawback of scaling the incvalue by a large factor is the
  * 64-bit SYSTIM register overflows more quickly.  This is dealt with
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 256a8a014583..b3679728caac 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3509,42 +3509,57 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca)
 	switch (hw->mac.type) {
 	case e1000_pch2lan:
 		/* Stable 96MHz frequency */
-		incperiod = INCPERIOD_96MHz;
-		incvalue = INCVALUE_96MHz;
-		shift = INCVALUE_SHIFT_96MHz;
-		adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHz;
+		incperiod = INCPERIOD_96MHZ;
+		incvalue = INCVALUE_96MHZ;
+		shift = INCVALUE_SHIFT_96MHZ;
+		adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHZ;
 		break;
 	case e1000_pch_lpt:
 		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
 			/* Stable 96MHz frequency */
-			incperiod = INCPERIOD_96MHz;
-			incvalue = INCVALUE_96MHz;
-			shift = INCVALUE_SHIFT_96MHz;
-			adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHz;
+			incperiod = INCPERIOD_96MHZ;
+			incvalue = INCVALUE_96MHZ;
+			shift = INCVALUE_SHIFT_96MHZ;
+			adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHZ;
 		} else {
 			/* Stable 25MHz frequency */
-			incperiod = INCPERIOD_25MHz;
-			incvalue = INCVALUE_25MHz;
-			shift = INCVALUE_SHIFT_25MHz;
+			incperiod = INCPERIOD_25MHZ;
+			incvalue = INCVALUE_25MHZ;
+			shift = INCVALUE_SHIFT_25MHZ;
 			adapter->cc.shift = shift;
 		}
 		break;
 	case e1000_pch_spt:
 		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
 			/* Stable 24MHz frequency */
-			incperiod = INCPERIOD_24MHz;
-			incvalue = INCVALUE_24MHz;
-			shift = INCVALUE_SHIFT_24MHz;
+			incperiod = INCPERIOD_24MHZ;
+			incvalue = INCVALUE_24MHZ;
+			shift = INCVALUE_SHIFT_24MHZ;
 			adapter->cc.shift = shift;
 			break;
 		}
 		return -EINVAL;
+	case e1000_pch_cnp:
+		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
+			/* Stable 24MHz frequency */
+			incperiod = INCPERIOD_24MHZ;
+			incvalue = INCVALUE_24MHZ;
+			shift = INCVALUE_SHIFT_24MHZ;
+			adapter->cc.shift = shift;
+		} else {
+			/* Stable 38400KHz frequency */
+			incperiod = INCPERIOD_38400KHZ;
+			incvalue = INCVALUE_38400KHZ;
+			shift = INCVALUE_SHIFT_38400KHZ;
+			adapter->cc.shift = shift;
+		}
+		break;
 	case e1000_82574:
 	case e1000_82583:
 		/* Stable 25MHz frequency */
-		incperiod = INCPERIOD_25MHz;
-		incvalue = INCVALUE_25MHz;
-		shift = INCVALUE_SHIFT_25MHz;
+		incperiod = INCPERIOD_25MHZ;
+		incvalue = INCVALUE_25MHZ;
+		shift = INCVALUE_SHIFT_25MHZ;
 		adapter->cc.shift = shift;
 		break;
 	default:
-- 
2.12.2
