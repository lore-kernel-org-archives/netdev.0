From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 0/1] Add PTP cross-timestamp to the PTP driver interface
Date: Thu,  2 Jul 2015 18:14:47 -0700
Message-ID: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de,
	christopher.s.hall@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25795 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199AbbGCBNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 21:13:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows system and device time ("cross-timestamp") to be performed 
by the driver. Currently, the cross-timestamping is performed in the
PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday() and the 
gettime64() callback provided by the driver. The cross-timestamp is best 
effort where the latency between the capture of system time 
(getnstimeofday()) and the device time (driver callback) may be significant.

This patch adds an additional callback getsynctime64(). Which will be called 
when the driver is able to perform a more accurate, implementation specific 
cross-timestamping.  For example, future network devices that implement 
PCIE PTM will be able to precisely correlate the device clock with the system 
clock with virtually zero latency between captures.  This added callback can 
be used by the driver to expose this functionality.

The callback, getsynctime64(), will only be called when defined and
n_samples == 1 because the driver returns only 1 cross-timestamp where 
multiple samples cannot be chained together.

This patch also adds to the capabilities ioctl (PTP_CLOCK_GETCAPS), allowing 
applications to query whether or not drivers implement the getsynctime 
callback, providing more precise cross timestamping.

Christopher Hall (1):
  Added additional callback to ptp_clock_info:

 drivers/ptp/ptp_chardev.c        | 29 +++++++++++++++++++++--------
 include/linux/ptp_clock_kernel.h |  8 ++++++++
 include/uapi/linux/ptp_clock.h   |  4 +++-
 3 files changed, 32 insertions(+), 9 deletions(-)

-- 
1.9.1
