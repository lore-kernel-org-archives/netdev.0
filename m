From: Roland Hii <roland.king.guan.hii@intel.com>
Subject: [PATCH] igb: add conditions for I210 to generate periodic clock output
Date: Mon, 11 Jan 2016 15:34:18 +0800
Message-ID: <1452497658-20050-1-git-send-email-roland.king.guan.hii@intel.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
1.9.1
