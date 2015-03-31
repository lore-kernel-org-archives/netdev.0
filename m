From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 03/11] ptp: tg3: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:08 +0200
Message-ID: <676cc006f5439eaab3feeb49154c37c4d15141cb.1427835485.git.richardcochran@gmail.com>
References: <cover.1427835485.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37603 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbbCaVI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:08:29 -0400
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to use ns_to_timespec64() instead of
open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d02d19b..1270b18 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6220,7 +6220,6 @@ static int tg3_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
-	u32 remainder;
 	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
 
 	tg3_full_lock(tp, 0);
@@ -6228,8 +6227,7 @@ static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 	ns += tp->ptp_adjust;
 	tg3_full_unlock(tp);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
-- 
1.7.10.4
