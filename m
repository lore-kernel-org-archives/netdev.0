From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 09/11] ptp: mlx4: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:14 +0200
Message-ID: <3bf4379da9f79427e3fa4f3395b7d1b10bad8393.1427835485.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35991 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056AbbCaVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:08:43 -0400
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to use ns_to_timespec64() instead of
open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 666e7bd..8a083d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -170,15 +170,13 @@ static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp,
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
 	unsigned long flags;
-	u32 remainder;
 	u64 ns;
 
 	write_lock_irqsave(&mdev->clock_lock, flags);
 	ns = timecounter_read(&mdev->clock);
 	write_unlock_irqrestore(&mdev->clock_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, NSEC_PER_SEC, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
-- 
1.7.10.4
