From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 08/11] net: ixgbe: convert to timecounter adjtime.
Date: Sun, 21 Dec 2014 19:47:03 +0100
Message-ID: <5d83679d541974c164cfc415c0bb171e2b363f16.1418504889.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5fd4b52..47c29ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -261,18 +261,9 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct ixgbe_adapter *adapter =
 		container_of(ptp, struct ixgbe_adapter, ptp_caps);
 	unsigned long flags;
-	u64 now;
 
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
-
-	now = timecounter_read(&adapter->tc);
-	now += delta;
-
-	/* reset the timecounter */
-	timecounter_init(&adapter->tc,
-			 &adapter->cc,
-			 now);
-
+	timecounter_adjtime(&adapter->tc, delta);
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
 	ixgbe_ptp_setup_sdp(adapter);
-- 
1.7.10.4
