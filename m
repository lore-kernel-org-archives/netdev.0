From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 0/8] ethtool: support time stamping and phc clocks
Date: Sat, 17 Mar 2012 13:12:26 +0100
Message-ID: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45624 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030660Ab2CQMMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:43 -0400
Received: by wgbdr13 with SMTP id dr13so372868wgb.1
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Warning - for discussion only, not tested, barely compiled!

Support for SO_TIMESTAMPING of network packets and PTP Hardware Clocks
has been expanding over the last year or two.  In an ideal world,
every host would have exactly one PTP hardware clock, and every
Ethernet MAC would support SO_TIMESTAMPING on both the transmit and
receive paths.

However, since we do not yet have full coverage for these features,
user space programs need a way to discover what a given interface
supports in these two areas:

* PTP Hardware Clocks

  The relationship between the network interfaces and the (possibly
  multiple) PHC devices is not discoverable except by knowing what
  hardware you have got and carefully looking into the kernel log.

* SO_TIMESTAMPING

  - Receive software time stamps are implemented in the stack
    and thus work for all MAC hardware.
  - Transmit software time stamps are only supported by a dozen
    drivers or so.
  - Some special devices support Tx/Rx time stamping in hardware.
  - None of this is discoverable except by looking into the kernel
    sources.

This series is a draft idea of how to make the hardware and driver
capabilities known to user space via ethtool. Since the PHC code was
first merged, this has become the number one requested new feature.

Patch number 4 applies on top of my recent two igb/phc patches.

Thanks in advance for your comments,
Richard


Richard Cochran (8):
  phc: Add a method for obtaining the device index.
  ethtool: Introduce a method for getting time stamping capabilities.
  bfin_mac: Support the get_ts_info ethtool method.
  igb: Support the get_ts_info ethtool method.
  gianfar: Support the get_ts_info ethtool method.
  ixp4xx_eth: Support the get_ts_info ethtool method.
  dp83640: Support the get_ts_info ethtool method.
  davinci_emac: Support the get_ts_info ethtool method.

 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h    |    3 ++
 drivers/net/ethernet/adi/bfin_mac.c              |   20 ++++++++++++
 drivers/net/ethernet/freescale/gianfar.h         |    3 ++
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   29 +++++++++++++++++
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    2 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   31 +++++++++++++++++++
 drivers/net/ethernet/ti/davinci_emac.c           |   10 ++++++
 drivers/net/ethernet/xscale/ixp4xx_eth.c         |   29 +++++++++++++++++
 drivers/net/phy/dp83640.c                        |   31 +++++++++++++++++++
 drivers/ptp/ptp_clock.c                          |    6 ++++
 drivers/ptp/ptp_ixp46x.c                         |    3 ++
 include/linux/ethtool.h                          |   20 ++++++++++++
 include/linux/phy.h                              |    3 ++
 include/linux/ptp_clock_kernel.h                 |    9 +++++
 net/core/ethtool.c                               |   36 ++++++++++++++++++++++
 15 files changed, 235 insertions(+), 0 deletions(-)

-- 
1.7.2.5
