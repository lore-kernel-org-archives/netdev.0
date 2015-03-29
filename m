From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 06/23] ptp: bnx2x: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:11:56 +0200
Message-ID: <df76e4e50c144a6861c698378c34e52b35e1fbaf.1427662907.git.richardcochran@gmail.com>
References: <cover.1427662906.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
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
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zha
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427662906.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9677431..765667c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13278,7 +13278,7 @@ static int bnx2x_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
@@ -13295,7 +13295,7 @@ static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int bnx2x_ptp_settime(struct ptp_clock_info *ptp,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts)
 {
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
@@ -13333,8 +13333,8 @@ static void bnx2x_register_phc(struct bnx2x *bp)
 	bp->ptp_clock_info.pps = 0;
 	bp->ptp_clock_info.adjfreq = bnx2x_ptp_adjfreq;
 	bp->ptp_clock_info.adjtime = bnx2x_ptp_adjtime;
-	bp->ptp_clock_info.gettime = bnx2x_ptp_gettime;
-	bp->ptp_clock_info.settime = bnx2x_ptp_settime;
+	bp->ptp_clock_info.gettime64 = bnx2x_ptp_gettime;
+	bp->ptp_clock_info.settime64 = bnx2x_ptp_settime;
 	bp->ptp_clock_info.enable = bnx2x_ptp_enable;
 
 	bp->ptp_clock = ptp_clock_register(&bp->ptp_clock_info, &bp->pdev->dev);
-- 
1.7.10.4
