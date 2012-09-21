From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/3] Two new PTP Hardware Clock features
Date: Fri, 21 Sep 2012 19:00:24 +0200
Message-ID: <cover.1348245523.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53214 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab2IURAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:00:40 -0400
Received: by weyx8 with SMTP id x8so2072211wey.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 10:00:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds two new features to the PHC code.

The first two patches let a user program find out the previously
dialed frequency adjustment. This is primarily useful when restarting
a PTP service, since without this information, the presumably correct
adjustment will bias the new frequency estimation.

The third patch makes the sysfs clock name come from the 'struct
device'. This idea was recently discussed on netdev as a way of taking
the guesswork out of the naming scheme.

Thanks,
Richard

Richard Cochran (3):
  ptp: remember the adjusted frequency
  ptp: provide the clock's adjusted frequency
  ptp: derive the device name from the parent device

 drivers/net/ethernet/freescale/gianfar_ptp.c |    3 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c     |    7 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    5 ++---
 drivers/net/phy/dp83640.c                    |    3 +--
 drivers/ptp/ptp_clock.c                      |   13 +++++++++++--
 drivers/ptp/ptp_ixp46x.c                     |    3 +--
 drivers/ptp/ptp_pch.c                        |    3 +--
 drivers/ptp/ptp_private.h                    |    2 ++
 drivers/ptp/ptp_sysfs.c                      |    2 +-
 include/linux/ptp_clock_kernel.h             |    8 +++++---
 10 files changed, 27 insertions(+), 22 deletions(-)

-- 
1.7.2.5
