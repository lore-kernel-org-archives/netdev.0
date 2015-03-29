From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 22/23] ptp: pch: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:12 +0200
Message-ID: <d574fb31bfc7f1478c0d96e55c17cff699832106.1427662907.git.richardcochran@gmail.com>
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

The device has a 64 bit clock register, where each clock tick is 32
nanoseconds, and so with this patch the driver is ready for the year
2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_pch.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 2554872..3aa22ae 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -449,7 +449,7 @@ static int ptp_pch_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -467,7 +467,7 @@ static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_pch_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+			   const struct timespec64 *ts)
 {
 	u64 ns;
 	unsigned long flags;
@@ -518,8 +518,8 @@ static struct ptp_clock_info ptp_pch_caps = {
 	.pps		= 0,
 	.adjfreq	= ptp_pch_adjfreq,
 	.adjtime	= ptp_pch_adjtime,
-	.gettime	= ptp_pch_gettime,
-	.settime	= ptp_pch_settime,
+	.gettime64	= ptp_pch_gettime,
+	.settime64	= ptp_pch_settime,
 	.enable		= ptp_pch_enable,
 };
 
-- 
1.7.10.4
