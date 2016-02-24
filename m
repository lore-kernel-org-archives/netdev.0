From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/20] igb: add conditions for I210 to generate periodic clock output
Date: Tue, 23 Feb 2016 20:26:18 -0800
Message-ID: <1456287984-10459-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Roland Hii <roland.king.guan.hii@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757428AbcBXE0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:34 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Hii <roland.king.guan.hii@intel.com>

In general case the maximum supported half cycle time of the synchronized
output clock is 70msec. Slower half cycle time than 70msec can be
programmed also as long as the output clock is synchronized to whole
seconds, useful specifically for generating a 1Hz clock.

Permitted values for the clock half cycle time are: 125,000,000 decimal,
250,000,000 decimal and 500,000,000 decimal (equals to 125msec, 250msec
and 500msec respectively).

Before this patch, only the half cycle time of less than or equal to 70msec
uses the I210 clock output function. This patch adds additional conditions
when half cycle time is equal to 125msec or 250msec or 500msec to use
clock output function.

Under other conditions, interrupt driven target time output events method
is still used to generate the desired clock output.

Signed-off-by: Roland Hii <roland.king.guan.hii@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index c44df87..22a8a29 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -525,7 +525,8 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 		ts.tv_nsec = rq->perout.period.nsec;
 		ns = timespec64_to_ns(&ts);
 		ns = ns >> 1;
-		if (on && ns <= 70000000LL) {
+		if (on && ((ns <= 70000000LL) || (ns == 125000000LL) ||
+			   (ns == 250000000LL) || (ns == 500000000LL))) {
 			if (ns < 8LL)
 				return -EINVAL;
 			use_freq = 1;
-- 
2.5.0
