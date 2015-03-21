From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 01/22] ptp: introduce get/set time methods with explicit 64 bit seconds.
Date: Sat, 21 Mar 2015 21:59:31 +0100
Message-ID: <bf9d2da410f97686ebedbb233d01fbb5dad39db5.1426970294.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38284 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbCUVAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 17:00:00 -0400
In-Reply-To: <cover.1426970294.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting the PHC drivers over to the new methods is one step along the
way to making them ready for 2038.  Once all the drivers are up to date,
then the old methods will be removed.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/linux/ptp_clock_kernel.h |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 0d8ff3f..7d6f8e6 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -64,12 +64,18 @@ struct ptp_clock_request {
  * @adjtime:  Shifts the time of the hardware clock.
  *            parameter delta: Desired change in nanoseconds.
  *
- * @gettime:  Reads the current time from the hardware clock.
+ * @gettime:  Reads the current time from the hardware clock. (deprecated)
  *            parameter ts: Holds the result.
  *
- * @settime:  Set the current time on the hardware clock.
+ * @settime:  Set the current time on the hardware clock. (deprecated)
  *            parameter ts: Time value to set.
  *
+ * @gettime64:  Reads the current time from the hardware clock.
+ *              parameter ts: Holds the result.
+ *
+ * @settime64:  Set the current time on the hardware clock.
+ *              parameter ts: Time value to set.
+ *
  * @enable:   Request driver to enable or disable an ancillary feature.
  *            parameter request: Desired resource to enable or disable.
  *            parameter on: Caller passes one to enable or zero to disable.
@@ -106,6 +112,8 @@ struct ptp_clock_info {
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime)(struct ptp_clock_info *ptp, struct timespec *ts);
 	int (*settime)(struct ptp_clock_info *ptp, const struct timespec *ts);
+	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
+	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
 	int (*verify)(struct ptp_clock_info *ptp, unsigned int pin,
-- 
1.7.10.4
