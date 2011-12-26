From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 0/2] igb: ptp hardware clock
Date: Mon, 26 Dec 2011 13:26:07 +0100
Message-ID: <cover.1324901880.git.richardcochran@gmail.com>
Cc: e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46981 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795Ab1LZM0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 07:26:22 -0500
Received: by eekc4 with SMTP id c4so11023563eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 04:26:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* ChangeLog V2
   - Fixed wrong bit shifting in the 82576 code.
   - Explained the timestamp locking with a comment in the code.
   - Preserved the comments from the original timecompare implementation.
   - Added an additional test within the overflow counter code to fix
     a race condition. Details of the problem are given in the commit
     message.

This patch series implements a PHC driver for the Intel 82576 and
82580 devices, as part of the igb driver.

The first patch adds the PHC driver code as a new source module but
does not link it into the main igb driver. Because the system time
counter is not so very wide, the code implements an overflow counter
in software. Every read operation maintains the overflow counter, as
does a "delayed work" watchdog. Only the base clock operations are
implemented. The hardware does have some ancillary features, but these
can be easily added later.

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
 drivers/net/ethernet/intel/igb/igb.h      |   21 +-
 drivers/net/ethernet/intel/igb/igb_main.c |  167 +----------
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  486 +++++++++++++++++++++++++++++
 4 files changed, 505 insertions(+), 171 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

-- 
1.7.2.5
