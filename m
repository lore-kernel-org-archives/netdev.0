From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 0/4] Two new PTP Hardware Clock features
Date: Sat, 22 Sep 2012 19:02:00 +0200
Message-ID: <cover.1348332940.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45113 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab2IVRCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:02:16 -0400
Received: by weyx8 with SMTP id x8so2548946wey.19
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 10:02:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds two new features to the PHC code.

* ChangeLog
** V3
   - Use the correct parent device in the solarflare driver.
   - Expand the sysfs documentation of clock_name.
   - Also document the clock_name field in the header file.
** V2 
   - Preserves the clock_name attribute as it was meant to be, instead
     of making any changes to it.
   - Covers the registration API change in the brand new solarflare phc
     device, which was overlooked in V1.

The first two patches let a user program find out the previously
dialed frequency adjustment. This is primarily useful when restarting
a PTP service, since without this information, the presumably correct
adjustment will bias the new frequency estimation.

The third patch links the phc class device to its parent device within
the driver model and sysfs.

The fourth patch adds a bit more documentation of the sysfs clock_name
attribute. This should help clarify the naming scheme.

Thanks,
Richard


Richard Cochran (4):
  ptp: remember the adjusted frequency
  ptp: provide the clock's adjusted frequency
  ptp: link the phc device to its parent device
  ptp: clarify the clock_name sysfs attribute

 Documentation/ABI/testing/sysfs-ptp          |    6 +++++-
 drivers/net/ethernet/freescale/gianfar_ptp.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c     |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    3 ++-
 drivers/net/ethernet/sfc/ptp.c               |    3 ++-
 drivers/net/phy/dp83640.c                    |    2 +-
 drivers/ptp/ptp_clock.c                      |   11 +++++++++--
 drivers/ptp/ptp_ixp46x.c                     |    2 +-
 drivers/ptp/ptp_pch.c                        |    2 +-
 drivers/ptp/ptp_private.h                    |    1 +
 include/linux/ptp_clock_kernel.h             |   11 ++++++++---
 11 files changed, 33 insertions(+), 13 deletions(-)

-- 
1.7.2.5
