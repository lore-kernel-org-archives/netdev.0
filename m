From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 10/11] ptp: stmmac: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:15 +0200
Message-ID: <93b0d362b29bf5ba1bc9c09b2e25e6958fb32511.1427835485.git.richardcochran@gmail.com>
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

This patch changes the driver to use ns_to_timespec64() instead of
open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 172f318..170a18b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -111,7 +111,6 @@ static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec64 *ts)
 	    container_of(ptp, struct stmmac_priv, ptp_clock_ops);
 	unsigned long flags;
 	u64 ns;
-	u32 reminder;
 
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
@@ -119,8 +118,7 @@ static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec64 *ts)
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &reminder);
-	ts->tv_nsec = reminder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
-- 
1.7.10.4
