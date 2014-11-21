From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 0/4] igb: auxiliary PHC functions for the i210.
Date: Fri, 21 Nov 2014 10:41:12 +0100
Message-ID: <cover.1416562191.git.rcochran@linutronix.de>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Jian Yu <jian.yu@ni.com>,
	Richard Cochran <rcochran@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:38926 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbaKUJlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 04:41:21 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so5964425wgg.8
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 01:41:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <rcochran@linutronix.de>

* ChangeLog
** V2
   - Add missing serialization in the reset function
   - Reset the auxiliary functions along with the rest
   - Guard against spurious SYS_WRAP interrupts (these occur in the
     82580 device from time to time)

This patch series adds three features: time stamping external events,
producing a periodic output signal, and an internal PPS event. The
i210 PCIe card has a 6 pin header with SDP0-3, making it easy to try
out this new functionality.

An earlier version of this series was posted way back in May, 2013,
but that version lacked a good way to assign functions to the pins. In
the mean time, the PHC core has a standard method to configure the
pins, and this series makes use of it.

Thanks,
Richard

Richard Cochran (4):
  igb: refactor time sync interrupt handling
  igb: serialize access to the time sync interrupt registers.
  igb: enable internal PPS for the i210.
  igb: enable auxiliary PHC functions for the i210.

 drivers/net/ethernet/intel/igb/igb.h      |    9 +
 drivers/net/ethernet/intel/igb/igb_main.c |  110 +++++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  254 ++++++++++++++++++++++++++++-
 3 files changed, 337 insertions(+), 36 deletions(-)

-- 
1.7.10.4
