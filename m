From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 0/7] Extend socket timestamping API
Date: Wed, 12 Apr 2017 16:17:30 +0200
Message-ID: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751349AbdDLORm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds new options to the timestamping API that will be
useful for NTP implementations and possibly other applications.

The first patch specifies a timestamp filter for NTP packets, which is
handled in the second patch in drivers that can timestamp all packets.
There is no attempt to add the support to the phyter driver.

The third patch adds a new option to get information about
HW-timestamped packets. The fourth patch adds support for this option to
the drivers (currently only igb and e1000e).

The fifth patch fixes the code to not make a false software TX timestamp
when HW timestamping is enabled. The sixth patch depends on this fix.

The sixth patch adds a new option to allow outgoing packets to be looped
multiple times to the error queue in order to allow simultaneous SW and
HW timestamping. The seventh patch updates drivers that assumed SW
timestamping cannot be used together with HW timestamping.

Miroslav Lichvar (7):
  net: define receive timestamp filter for NTP
  net: ethernet: update drivers to handle HWTSTAMP_FILTER_NTP_ALL
  net: add option to get information about timestamped packets
  net: ethernet: update drivers to provide timestamping packet info
  net: don't make false software transmit timestamps
  net: allow simultaneous SW and HW transmit timestamping
  net: ethernet: update drivers to make both SW and HW TX timestamps

 Documentation/networking/timestamping.txt          | 20 +++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  1 +
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c         | 19 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  1 +
 drivers/net/ethernet/intel/igb/igb.h               |  7 ++--
 drivers/net/ethernet/intel/igb/igb_main.c          | 22 +++++++++--
 drivers/net/ethernet/intel/igb/igb_ptp.c           | 43 +++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  1 +
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  1 +
 drivers/net/ethernet/qlogic/qede/qede_ptp.c        |  1 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |  3 +-
 drivers/net/ethernet/sfc/ef10.c                    |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  7 ++--
 drivers/net/ethernet/ti/cpsw.c                     |  1 +
 drivers/net/ethernet/tile/tilegx.c                 |  1 +
 include/linux/skbuff.h                             | 25 ++++++++++++-
 include/uapi/asm-generic/socket.h                  |  2 +
 include/uapi/linux/errqueue.h                      |  8 ++++
 include/uapi/linux/net_tstamp.h                    |  7 +++-
 net/core/dev_ioctl.c                               |  1 +
 net/core/skbuff.c                                  | 16 ++++++--
 net/socket.c                                       | 20 +++++++++-
 28 files changed, 162 insertions(+), 55 deletions(-)

-- 
2.9.3
