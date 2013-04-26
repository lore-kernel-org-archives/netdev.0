From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000e: fix numeric overflow in phc settime method
Date: Thu, 25 Apr 2013 21:57:04 -0700
Message-ID: <1366952231-16727-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53194 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab3DZE5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:16 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

The PTP Hardware Clock settime function in the e1000e driver
computes nanoseconds from a struct timespec. The code converts the
seconds field .tv_sec by multiplying it with NSEC_PER_SEC. However,
both operands are of type long, resulting in an unintended overflow.
The patch fixes the issue by using the helper function from time.h.

CC: stable <stable@vger.kernel.org>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ptp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index b477fa5..065f8c8 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -145,8 +145,7 @@ static int e1000e_phc_settime(struct ptp_clock_info *ptp,
 	unsigned long flags;
 	u64 ns;
 
-	ns = ts->tv_sec * NSEC_PER_SEC;
-	ns += ts->tv_nsec;
+	ns = timespec_to_ns(ts);
 
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->systim_lock, flags);
-- 
1.7.11.7
