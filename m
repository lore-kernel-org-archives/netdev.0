From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 01/11] ptp: blackfin: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:06 +0200
Message-ID: <adc87b0b1d93cf3286fa5f71d0f129b2a792f202.1427835485.git.richardcochran@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the driver to use ns_to_timespec64() and
timespec64_to_ns() instead of open coding the same logic.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 0c37aef..096531a 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -986,7 +986,6 @@ static int bfin_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 	struct bfin_mac_local *lp =
 		container_of(ptp, struct bfin_mac_local, caps);
@@ -997,8 +996,8 @@ static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 
 	spin_unlock_irqrestore(&lp->phc_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
+
 	return 0;
 }
 
@@ -1010,8 +1009,7 @@ static int bfin_ptp_settime(struct ptp_clock_info *ptp,
 	struct bfin_mac_local *lp =
 		container_of(ptp, struct bfin_mac_local, caps);
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 
 	spin_lock_irqsave(&lp->phc_lock, flags);
 
-- 
1.7.10.4
