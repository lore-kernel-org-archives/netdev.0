From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH] Add PTP cross-timestamp to the PTP driver interface
Date: Thu, 25 Jun 2015 16:42:56 -0700
Message-ID: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, kevin.b.stanton@intel.com,
	christopher.s.hall@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16404 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbbFYXmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 19:42:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows system and device time ("cross-timestamp") to be performed 
by the driver. Currently, the timestamping is performed in the PTP_SYS_OFFSET 
ioctl.  It reads gettimeofday() and the gettime64() callback provided by the 
driver. The cross-timestamp is best effort ignoring the latency between the 
capture of system time (getnstimeofday()) and the device time 
(driver callback).

This patch adds an additional callback getsynctime64(). Which will be called 
when the driver is able to perform a more accurate, implementation specific 
cross-timestamp.  The ioctl code uses the callback when available.

Additionally, the callback, getsynctime64(), will only be called when 
n_samples == 1 because the driver returns only 1 cross-timestamp where 
multiple samples cannot be chained together.


Christopher Hall (1):
  Added additional callback to ptp_clock_info:

 drivers/ptp/ptp_chardev.c        | 30 +++++++++++++++++++++---------
 include/linux/ptp_clock_kernel.h |  3 +++
 2 files changed, 24 insertions(+), 9 deletions(-)

-- 
1.9.1
