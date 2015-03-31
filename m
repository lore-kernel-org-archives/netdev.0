From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 07/11] ptp: igb: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:12 +0200
Message-ID: <eb1685a4a21390473413056ea6f65921005f91e0.1427835485.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35921 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbbCaVIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:08:38 -0400
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to use ns_to_timespec64() and
timespec64_to_ns() instead of open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 0348b7e..b3b60a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -290,7 +290,6 @@ static int igb_ptp_gettime_82576(struct ptp_clock_info *ptp,
 					       ptp_caps);
 	unsigned long flags;
 	u64 ns;
-	u32 remainder;
 
 	spin_lock_irqsave(&igb->tmreg_lock, flags);
 
@@ -298,8 +297,7 @@ static int igb_ptp_gettime_82576(struct ptp_clock_info *ptp,
 
 	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
@@ -328,8 +326,7 @@ static int igb_ptp_settime_82576(struct ptp_clock_info *ptp,
 	unsigned long flags;
 	u64 ns;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 
 	spin_lock_irqsave(&igb->tmreg_lock, flags);
 
-- 
1.7.10.4
