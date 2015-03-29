From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 07/23] ptp: tg3: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:11:57 +0200
Message-ID: <c2bdb1ebb6a079e158f3c60c82b37c1b111cc61b.1427662907.git.richardcochran@gmail.com>
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

The device appears to use a 64 bit nanoseconds register, and so with
this patch the driver should be ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 22b33da..d02d19b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6217,7 +6217,7 @@ static int tg3_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -6235,12 +6235,12 @@ static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int tg3_ptp_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+			   const struct timespec64 *ts)
 {
 	u64 ns;
 	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
 
-	ns = timespec_to_ns(ts);
+	ns = timespec64_to_ns(ts);
 
 	tg3_full_lock(tp, 0);
 	tg3_refclk_write(tp, ns);
@@ -6320,8 +6320,8 @@ static const struct ptp_clock_info tg3_ptp_caps = {
 	.pps		= 0,
 	.adjfreq	= tg3_ptp_adjfreq,
 	.adjtime	= tg3_ptp_adjtime,
-	.gettime	= tg3_ptp_gettime,
-	.settime	= tg3_ptp_settime,
+	.gettime64	= tg3_ptp_gettime,
+	.settime64	= tg3_ptp_settime,
 	.enable		= tg3_ptp_enable,
 };
 
-- 
1.7.10.4
