From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Sat, 21 Jan 2012 17:03:50 +0100
Message-ID: <cover.1327161325.git.richardcochran@gmail.com>
Cc: e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51795 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab2AUQEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 11:04:06 -0500
Received: by eaac11 with SMTP id c11so717072eaa.19
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2012 08:04:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* ChangeLog
** V4
   - Use standard kernel cyclecounter/timecounter infrastructure
     instead of a home grown counter overflow implementation.
** V3
   - Driver compiles even without CONFIG_PTP_1588_CLOCK.
   - Timestamping always works, even when PTP code missing or fails.
** V2
   - Fixed wrong bit shifting in the 82576 code.
   - Explained the timestamp locking with a comment in the code.
   - Preserved the comments from the original timecompare implementation.
   - Added an additional test within the overflow counter code to fix
     a race condition. Details of the problem are given in the commit
     message.

This patch series implements a PHC driver for the Intel 82576 and
82580 devices, as part of the igb driver.  Only the base clock
operations are implemented. The hardware does have some ancillary
features, but these can be easily added later.

The first patch adds the PHC driver code as a new source module but
does not link it into the main igb driver. Because the system time
counter is not so very wide, the code uses the overflow counter from
the cyclecounter/timecounter code. Every read operation maintains the
overflow counter, as does a "delayed work" watchdog. 

The second patch removes the timecompare code and links in the new
functions.

I have tested the 82580 with good results. However, I don't have the
82576 and so would appreciate testing and feedback.

Thanks,
Richard


Richard Cochran (2):
  igb: add PTP Hardware Clock code
  igb: offer a PTP Hardware Clock instead of the timecompare method

 drivers/net/ethernet/intel/igb/Makefile   |    2 +-
 drivers/net/ethernet/intel/igb/igb.h      |   20 ++-
 drivers/net/ethernet/intel/igb/igb_main.c |  167 +------------
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  388 +++++++++++++++++++++++++++++
 4 files changed, 407 insertions(+), 170 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

-- 
1.7.2.5
