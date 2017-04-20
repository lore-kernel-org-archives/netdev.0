From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] 1GbE Intel Wired LAN Driver Updates 2017-04-20
Date: Thu, 20 Apr 2017 16:33:28 -0700
Message-ID: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8369 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947164AbdDTXdr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:33:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb/vf and ixgb.

Tobias Klauser cleans up e1000, ixgb and igbvf from having a local
function or structure for netdev stats.

Bernd Faust fixes an issue for 82579 devices, where the clock frequency
was being incorrectly set for these devices.  These devices only support
96MHz, so make sure they are set to use only that.

Yury Kylulin extends the work Jake and Alex did for ixgbe in MAC filter
handling into the igb driver.

Kim Tatt Chuah enables igb to wake up by packet and to read the necessary
Wake Up Status (WUS) and Wake Up Packet Memory (WUPM) registers.

The following are changes since commit 6905e5a5c8d552ace1d65cacb43499a0eb1e0b89:
  net/mlx5e: IPoIB, Fix error handling in mlx5_rdma_netdev_alloc()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Bernd Faust (1):
  e1000e: fix timing for 82579 Gigabit Ethernet controller

Kim Tatt Chuah (1):
  igb: Enable reading of wake up packet

Tobias Klauser (3):
  e1000: Omit private ndo_get_stats function
  ixgb: Omit private ndo_get_stats function
  igbvf: Use net_device_stats from struct net_device

Yury Kylulin (2):
  igb: improve MAC filter handling
  igb/igbvf: Add VF MAC filter request capabilities

 drivers/net/ethernet/intel/e1000/e1000_main.c  |  15 -
 drivers/net/ethernet/intel/e1000e/netdev.c     |   6 +
 drivers/net/ethernet/intel/igb/e1000_defines.h |  21 ++
 drivers/net/ethernet/intel/igb/e1000_mbx.h     |   4 +
 drivers/net/ethernet/intel/igb/igb.h           |  23 ++
 drivers/net/ethernet/intel/igb/igb_main.c      | 429 ++++++++++++++++++++-----
 drivers/net/ethernet/intel/igbvf/igbvf.h       |   3 +-
 drivers/net/ethernet/intel/igbvf/mbx.h         |   4 +
 drivers/net/ethernet/intel/igbvf/netdev.c      |  70 ++--
 drivers/net/ethernet/intel/igbvf/vf.c          |  41 +++
 drivers/net/ethernet/intel/igbvf/vf.h          |   1 +
 drivers/net/ethernet/intel/ixgb/ixgb_main.c    |  16 -
 12 files changed, 499 insertions(+), 134 deletions(-)

-- 
2.12.2
