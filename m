From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 08/23] ptp: fec: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:11:58 +0200
Message-ID: <256b6f98454f7be0f4e3d5a8e79ade9a798a416e.1427662907.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/freescale/fec_ptp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 4585895..b833993 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -390,7 +390,7 @@ static int fec_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
  * read the timecounter and return the correct value on ns,
  * after converting it into a struct timespec.
  */
-static int fec_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int fec_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct fec_enet_private *adapter =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
@@ -417,7 +417,7 @@ static int fec_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
  * wall timer value.
  */
 static int fec_ptp_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+			   const struct timespec64 *ts)
 {
 	struct fec_enet_private *fep =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
@@ -584,8 +584,8 @@ void fec_ptp_init(struct platform_device *pdev)
 	fep->ptp_caps.pps = 1;
 	fep->ptp_caps.adjfreq = fec_ptp_adjfreq;
 	fep->ptp_caps.adjtime = fec_ptp_adjtime;
-	fep->ptp_caps.gettime = fec_ptp_gettime;
-	fep->ptp_caps.settime = fec_ptp_settime;
+	fep->ptp_caps.gettime64 = fec_ptp_gettime;
+	fep->ptp_caps.settime64 = fec_ptp_settime;
 	fep->ptp_caps.enable = fec_ptp_enable;
 
 	fep->cycle_speed = clk_get_rate(fep->clk_ptp);
-- 
1.7.10.4
