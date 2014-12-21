From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 06/11] net: e1000e: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:01 +0100
Message-ID: <7455b879a8aab91f11c3082c2c8c1dc3ef71b96e.1418504889.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/e1000e/ptp.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index fb1a914..978ef9c 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -90,12 +90,9 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
 						     ptp_clock_info);
 	unsigned long flags;
-	s64 now;
 
 	spin_lock_irqsave(&adapter->systim_lock, flags);
-	now = timecounter_read(&adapter->tc);
-	now += delta;
-	timecounter_init(&adapter->tc, &adapter->cc, now);
+	timecounter_adjtime(&adapter->tc, delta);
 	spin_unlock_irqrestore(&adapter->systim_lock, flags);
 
 	return 0;
-- 
1.7.10.4
