From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 02/11] ptp: bnx2x: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:07 +0200
Message-ID: <20b52ea4e69f1ad00e95673f75be2bcbc4630c62.1427835485.git.richardcochran@gmail.com>
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
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33976 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbbCaVI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:08:26 -0400
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to use ns_to_timespec64() and
timespec64_to_ns() instead of open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 765667c..1925296 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13282,14 +13282,12 @@ static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
-	u32 remainder;
 
 	ns = timecounter_read(&bp->timecounter);
 
 	DP(BNX2X_MSG_PTP, "PTP gettime called, ns = %llu\n", ns);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
@@ -13300,8 +13298,7 @@ static int bnx2x_ptp_settime(struct ptp_clock_info *ptp,
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 
 	DP(BNX2X_MSG_PTP, "PTP settime called, ns = %llu\n", ns);
 
-- 
1.7.10.4
