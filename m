From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] net: igb: fix the start time for periodic output signals
Date: Thu, 11 Jun 2015 14:51:30 +0200
Message-ID: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35726 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbFKMvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 08:51:35 -0400
Received: by wiga1 with SMTP id a1so74686874wig.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 05:51:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When programming the start of a periodic output, the code wrongly places
the seconds value into the "low" register and the nanoseconds into the
"high" register.  Even though this is backwards, it slipped through my
testing, because the re-arming code in the interrupt service routine is
correct, and the signal does appear starting with the second edge.

This patch fixes the issue by programming the registers correctly.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index e3b9b63..c3a9392c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -538,8 +538,8 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 			igb->perout[i].start.tv_nsec = rq->perout.start.nsec;
 			igb->perout[i].period.tv_sec = ts.tv_sec;
 			igb->perout[i].period.tv_nsec = ts.tv_nsec;
-			wr32(trgttiml, rq->perout.start.sec);
-			wr32(trgttimh, rq->perout.start.nsec);
+			wr32(trgttimh, rq->perout.start.sec);
+			wr32(trgttiml, rq->perout.start.nsec);
 			tsauxc |= tsauxc_mask;
 			tsim |= tsim_mask;
 		} else {
-- 
2.1.4
