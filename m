From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 14/23] ptp: ixgbe: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:04 +0200
Message-ID: <7ae91e10068ad59d0861f90248456406f56032b1.1427662907.git.richardcochran@gmail.com>
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
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
