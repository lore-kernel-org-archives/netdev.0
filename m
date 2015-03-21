From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 13/22] ptp: ixgbe: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:43 +0100
Message-ID: <cd43aa9e673a17626e0bd1c2d5ffb6bd8e879b58.1426970294.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37261 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbbCUVAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 17:00:30 -0400
In-Reply-To: <cover.1426970294.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index bd46f5d..75b9e93 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -279,7 +279,7 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
  * read the timecounter and return the correct value on ns,
  * after converting it into a struct timespec.
  */
-static int ixgbe_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ixgbe_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct ixgbe_adapter *adapter =
 		container_of(ptp, struct ixgbe_adapter, ptp_caps);
@@ -306,7 +306,7 @@ static int ixgbe_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
  * wall timer value.
  */
 static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts)
 {
 	struct ixgbe_adapter *adapter =
 		container_of(ptp, struct ixgbe_adapter, ptp_caps);
@@ -407,7 +407,7 @@ void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter)
 {
 	bool timeout = time_is_before_jiffies(adapter->last_overflow_check +
 					     IXGBE_OVERFLOW_PERIOD);
-	struct timespec ts;
+	struct timespec64 ts;
 
 	if (timeout) {
 		ixgbe_ptp_gettime(&adapter->ptp_caps, &ts);
@@ -874,8 +874,8 @@ static int ixgbe_ptp_create_clock(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.pps = 1;
 		adapter->ptp_caps.adjfreq = ixgbe_ptp_adjfreq;
 		adapter->ptp_caps.adjtime = ixgbe_ptp_adjtime;
-		adapter->ptp_caps.gettime = ixgbe_ptp_gettime;
-		adapter->ptp_caps.settime = ixgbe_ptp_settime;
+		adapter->ptp_caps.gettime64 = ixgbe_ptp_gettime;
+		adapter->ptp_caps.settime64 = ixgbe_ptp_settime;
 		adapter->ptp_caps.enable = ixgbe_ptp_feature_enable;
 		break;
 	case ixgbe_mac_82599EB:
@@ -890,8 +890,8 @@ static int ixgbe_ptp_create_clock(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.pps = 0;
 		adapter->ptp_caps.adjfreq = ixgbe_ptp_adjfreq;
 		adapter->ptp_caps.adjtime = ixgbe_ptp_adjtime;
-		adapter->ptp_caps.gettime = ixgbe_ptp_gettime;
-		adapter->ptp_caps.settime = ixgbe_ptp_settime;
+		adapter->ptp_caps.gettime64 = ixgbe_ptp_gettime;
+		adapter->ptp_caps.settime64 = ixgbe_ptp_settime;
 		adapter->ptp_caps.enable = ixgbe_ptp_feature_enable;
 		break;
 	default:
-- 
1.7.10.4
