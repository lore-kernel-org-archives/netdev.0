From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 04/23] ptp: blackfin: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:11:54 +0200
Message-ID: <16553976013ee8597a5b90c5189be346263f33e3.1427662907.git.richardcochran@gmail.com>
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

The device uses 64 bit nanoseconds register, and so with this patch the
driver is ready for the year 2038.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index ec20611..0c37aef 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -983,7 +983,7 @@ static int bfin_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -1003,7 +1003,7 @@ static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int bfin_ptp_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+			   const struct timespec64 *ts)
 {
 	u64 ns;
 	unsigned long flags;
@@ -1039,8 +1039,8 @@ static struct ptp_clock_info bfin_ptp_caps = {
 	.pps		= 0,
 	.adjfreq	= bfin_ptp_adjfreq,
 	.adjtime	= bfin_ptp_adjtime,
-	.gettime	= bfin_ptp_gettime,
-	.settime	= bfin_ptp_settime,
+	.gettime64	= bfin_ptp_gettime,
+	.settime64	= bfin_ptp_settime,
 	.enable		= bfin_ptp_enable,
 };
 
-- 
1.7.10.4
