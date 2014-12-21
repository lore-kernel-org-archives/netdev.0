From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 07/11] net: igb: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:02 +0100
Message-ID: <bb15b44a539ec6da39812229b5fb0718bd6859f0.1418504889.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/igb/igb_ptp.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 794c139..1d27f2d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -256,14 +256,9 @@ static int igb_ptp_adjtime_82576(struct ptp_clock_info *ptp, s64 delta)
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
 	unsigned long flags;
-	s64 now;
 
 	spin_lock_irqsave(&igb->tmreg_lock, flags);
-
-	now = timecounter_read(&igb->tc);
-	now += delta;
-	timecounter_init(&igb->tc, &igb->cc, now);
-
+	timecounter_adjtime(&igb->tc, delta);
 	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
 
 	return 0;
-- 
1.7.10.4
