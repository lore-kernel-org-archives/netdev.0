From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 4/4] ptp: clarify the clock_name sysfs attribute
Date: Sat, 22 Sep 2012 19:02:04 +0200
Message-ID: <149b5cc1b5813bb4052f8dff4cbe0b5be62d086e.1348332941.git.richardcochran@gmail.com>
References: <cover.1348332940.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45793 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab2IVRCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:02:25 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr14so3236265wib.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 10:02:24 -0700 (PDT)
In-Reply-To: <cover.1348332940.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348332940.git.richardcochran@gmail.com>
References: <cover.1348332940.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been some confusion among PHC driver authors about the
intended purpose of the clock_name attribute. This patch expands the
documation in order to clarify how the clock_name field should be
understood.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/ABI/testing/sysfs-ptp |    6 +++++-
 include/linux/ptp_clock_kernel.h    |    4 +++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-ptp b/Documentation/ABI/testing/sysfs-ptp
index d40d2b5..05aeedf 100644
--- a/Documentation/ABI/testing/sysfs-ptp
+++ b/Documentation/ABI/testing/sysfs-ptp
@@ -19,7 +19,11 @@ Date:		September 2010
 Contact:	Richard Cochran <richardcochran@gmail.com>
 Description:
 		This file contains the name of the PTP hardware clock
-		as a human readable string.
+		as a human readable string. The purpose of this
+		attribute is to provide the user with a "friendly
+		name" and to help distinguish PHY based devices from
+		MAC based ones. The string does not necessarily have
+		to be any kind of unique id.
 
 What:		/sys/class/ptp/ptpN/max_adjustment
 Date:		September 2010
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 56c71b2..f2dc6d8 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -42,7 +42,9 @@ struct ptp_clock_request {
  * struct ptp_clock_info - decribes a PTP hardware clock
  *
  * @owner:     The clock driver should set to THIS_MODULE.
- * @name:      A short name to identify the clock.
+ * @name:      A short "friendly name" to identify the clock and to
+ *             help distinguish PHY based devices from MAC based ones.
+ *             The string is not meant to be a unique id.
  * @max_adj:   The maximum possible frequency adjustment, in parts per billon.
  * @n_alarm:   The number of programmable alarms.
  * @n_ext_ts:  The number of external time stamp channels.
-- 
1.7.2.5
