From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 04/11] net: bnx2x: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:46:59 +0100
Message-ID: <976abf89c833c376c2666def2c60a7de0f020026.1418504889.git.richardcochran@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the driver to use the new and improved method
for adjusting the offset of a timecounter.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 691f0bf..7b2cc40 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13265,14 +13265,10 @@ static int bnx2x_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 static int bnx2x_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
-	u64 now;
 
 	DP(BNX2X_MSG_PTP, "PTP adjtime called, delta = %llx\n", delta);
 
-	now = timecounter_read(&bp->timecounter);
-	now += delta;
-	/* Re-init the timecounter */
-	timecounter_init(&bp->timecounter, &bp->cyclecounter, now);
+	timecounter_adjtime(&bp->timecounter, delta);
 
 	return 0;
 }
-- 
1.7.10.4
