From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 08/22] ptp: gianfar: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:38 +0100
Message-ID: <847422212558973030233507b18bcc91166a7b3b.1426970294.git.richardcochran@gmail.com>
References: <cover.1426970294.git.richardcochran@gmail.com>
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
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorense
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1426970294.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device features a 64 bit nanoseconds register, and so with this
patch the driver is ready for the year 2038.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 77353366..04265a7 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -322,7 +322,8 @@ static int ptp_gianfar_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int ptp_gianfar_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_gianfar_gettime(struct ptp_clock_info *ptp,
+			       struct timespec64 *ts)
 {
 	u64 ns;
 	u32 remainder;
@@ -341,7 +342,7 @@ static int ptp_gianfar_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_gianfar_settime(struct ptp_clock_info *ptp,
-			       const struct timespec *ts)
+			       const struct timespec64 *ts)
 {
 	u64 ns;
 	unsigned long flags;
@@ -418,8 +419,8 @@ static struct ptp_clock_info ptp_gianfar_caps = {
 	.pps		= 1,
 	.adjfreq	= ptp_gianfar_adjfreq,
 	.adjtime	= ptp_gianfar_adjtime,
-	.gettime	= ptp_gianfar_gettime,
-	.settime	= ptp_gianfar_settime,
+	.gettime64	= ptp_gianfar_gettime,
+	.settime64	= ptp_gianfar_settime,
 	.enable		= ptp_gianfar_enable,
 };
 
@@ -440,7 +441,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 {
 	struct device_node *node = dev->dev.of_node;
 	struct etsects *etsects;
-	struct timespec now;
+	struct timespec64 now;
 	int err = -ENOMEM;
 	u32 tmr_ctrl;
 	unsigned long flags;
@@ -495,7 +496,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 		pr_err("ioremap ptp registers failed\n");
 		goto no_ioremap;
 	}
-	getnstimeofday(&now);
+	getnstimeofday64(&now);
 	ptp_gianfar_settime(&etsects->caps, &now);
 
 	tmr_ctrl =
-- 
1.7.10.4
