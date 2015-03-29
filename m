From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 15/23] ptp: mlx4: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:05 +0200
Message-ID: <7c34ca384b988374ad6609f176c8fb7646046d7a.1427662907.git.richardcochran@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33696 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbC2VM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 17:12:59 -0400
In-Reply-To: <cover.1427662906.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 90b5309..666e7bd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -164,7 +164,8 @@ static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
  * Read the timecounter and return the correct value in ns after converting
  * it into a struct timespec.
  **/
-static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp,
+			       struct timespec64 *ts)
 {
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
@@ -191,11 +192,11 @@ static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
  * wall timer value.
  **/
 static int mlx4_en_phc_settime(struct ptp_clock_info *ptp,
-			       const struct timespec *ts)
+			       const struct timespec64 *ts)
 {
 	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
 						ptp_clock_info);
-	u64 ns = timespec_to_ns(ts);
+	u64 ns = timespec64_to_ns(ts);
 	unsigned long flags;
 
 	/* reset the timecounter */
@@ -232,8 +233,8 @@ static const struct ptp_clock_info mlx4_en_ptp_clock_info = {
 	.pps		= 0,
 	.adjfreq	= mlx4_en_phc_adjfreq,
 	.adjtime	= mlx4_en_phc_adjtime,
-	.gettime	= mlx4_en_phc_gettime,
-	.settime	= mlx4_en_phc_settime,
+	.gettime64	= mlx4_en_phc_gettime,
+	.settime64	= mlx4_en_phc_settime,
 	.enable		= mlx4_en_phc_enable,
 };
 
-- 
1.7.10.4
