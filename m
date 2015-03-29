From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 21/23] ptp: ixp46x: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:11 +0200
Message-ID: <21312ff45557e5d460c6a24f54ca1150dda86b03.1427662907.git.richardcochran@gmail.com>
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

The device has a 64 bit clock register, where each clock tick is 16
nanoseconds, and so with this patch the driver is ready for the year
2038.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_ixp46x.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 604d340..934c139 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -175,7 +175,7 @@ static int ptp_ixp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -195,7 +195,7 @@ static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_ixp_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+			   const struct timespec64 *ts)
 {
 	u64 ns;
 	unsigned long flags;
@@ -248,8 +248,8 @@ static struct ptp_clock_info ptp_ixp_caps = {
 	.pps		= 0,
 	.adjfreq	= ptp_ixp_adjfreq,
 	.adjtime	= ptp_ixp_adjtime,
-	.gettime	= ptp_ixp_gettime,
-	.settime	= ptp_ixp_settime,
+	.gettime64	= ptp_ixp_gettime,
+	.settime64	= ptp_ixp_settime,
 	.enable		= ptp_ixp_enable,
 };
 
-- 
1.7.10.4
