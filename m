From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: Update ptp_overflow check comment and jiffies
Date: Wed, 23 Jan 2013 14:44:39 -0800
Message-ID: <1358981090-5794-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430Ab3AWWpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:17 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes the comment on ptp_overflow_check to match up with what is
currently used as the parameters. Also change the jiffies check to use
time_is_after_jiffies macro.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 1a751c9..2e54e0c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -407,21 +407,21 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 
 
 /**
- * ixgbe_ptp_overflow_check - delayed work to detect SYSTIME overflow
- * @work: structure containing information about this work task
+ * ixgbe_ptp_overflow_check - watchdog task to detect SYSTIME overflow
+ * @adapter: private adapter struct
  *
- * this work function is scheduled to continue reading the timecounter
+ * this watchdog task periodically reads the timecounter
  * in order to prevent missing when the system time registers wrap
- * around. This needs to be run approximately twice a minute when no
- * PTP activity is occurring.
+ * around. This needs to be run approximately twice a minute.
  */
 void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter)
 {
-	unsigned long elapsed_jiffies = adapter->last_overflow_check - jiffies;
+	bool timeout = time_is_before_jiffies(adapter->last_overflow_check +
+					     IXGBE_OVERFLOW_PERIOD);
 	struct timespec ts;
 
 	if ((adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED) &&
-	    (elapsed_jiffies >= IXGBE_OVERFLOW_PERIOD)) {
+	    (timeout)) {
 		ixgbe_ptp_gettime(&adapter->ptp_caps, &ts);
 		adapter->last_overflow_check = jiffies;
 	}
-- 
1.7.11.7
