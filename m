From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 03/11] net: xgbe: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:46:58 +0100
Message-ID: <0297818b43ed776c92832369b37783beb58ed3d1.1418504889.git.richardcochran@gmail.com>
References: <cover.1418504883.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55420 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbaLUSrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 13:47:17 -0500
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to use the new and improved method
for adjusting the offset of a timecounter.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
index a1bf9d1c..f5acf4c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -171,15 +171,9 @@ static int xgbe_adjtime(struct ptp_clock_info *info, s64 delta)
 						   struct xgbe_prv_data,
 						   ptp_clock_info);
 	unsigned long flags;
-	u64 nsec;
 
 	spin_lock_irqsave(&pdata->tstamp_lock, flags);
-
-	nsec = timecounter_read(&pdata->tstamp_tc);
-
-	nsec += delta;
-	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc, nsec);
-
+	timecounter_adjtime(&pdata->tstamp_tc, delta);
 	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
 
 	return 0;
-- 
1.7.10.4
