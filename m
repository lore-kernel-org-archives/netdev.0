From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 05/11] net: fec: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:00 +0100
Message-ID: <b125bd4e62d8208bd9c4bf32958c581f65dad8e5.1418504889.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/freescale/fec_ptp.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 992c8c3..1f9cf23 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -374,23 +374,9 @@ static int fec_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct fec_enet_private *fep =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
 	unsigned long flags;
-	u64 now;
-	u32 counter;
 
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
-
-	now = timecounter_read(&fep->tc);
-	now += delta;
-
-	/* Get the timer value based on adjusted timestamp.
-	 * Update the counter with the masked value.
-	 */
-	counter = now & fep->cc.mask;
-	writel(counter, fep->hwp + FEC_ATIME);
-
-	/* reset the timecounter */
-	timecounter_init(&fep->tc, &fep->cc, now);
-
+	timecounter_adjtime(&fep->tc, delta);
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 
 	return 0;
-- 
1.7.10.4
