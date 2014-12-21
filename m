From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 10/11] net: cpts: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:05 +0100
Message-ID: <90dc7fc7d7550d5164474ca9995628f50989dbb2.1418504889.git.richardcochran@gmail.com>
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

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 4a4388b..fbe42cb 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -157,14 +157,11 @@ static int cpts_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 
 static int cpts_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
-	s64 now;
 	unsigned long flags;
 	struct cpts *cpts = container_of(ptp, struct cpts, info);
 
 	spin_lock_irqsave(&cpts->lock, flags);
-	now = timecounter_read(&cpts->tc);
-	now += delta;
-	timecounter_init(&cpts->tc, &cpts->cc, now);
+	timecounter_adjtime(&cpts->tc, delta);
 	spin_unlock_irqrestore(&cpts->lock, flags);
 
 	return 0;
-- 
1.7.10.4
