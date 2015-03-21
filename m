From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 21/22] ptp: pch: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:51 +0100
Message-ID: <534371c9d3ae8cbc27ebdea97bd4eda5cdbae477.1426970294.git.richardcochran@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37946 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbbCUVAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 17:00:51 -0400
In-Reply-To: <cover.1426970294.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
