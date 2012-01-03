From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Tue,  3 Jan 2012 11:19:05 -0800
Message-ID: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57343 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754680Ab2ACTTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 14:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, e1000e, igb and
netdev/ixgbe.  There are 2 fixes and the remaining patches are
either add support or cleanup.

Here is a list of the new support added:
 - igb adds support for byte queue limits and basic runtime PM
 - e1000e adds Receive Packet Steering (RPS)
 - FCoE adds ndo_get_fcoe_hbainfo() call

The following are changes since commit fa0f5aa74316c636427ac92dad0bc5714c34ca17:
  net_sched: qdisc_alloc_handle() can be too slow
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (5):
  e1000e: cleanup Rx checksum offload code
  e1000e: add Receive Packet Steering (RPS) support
  e1000e: re-enable alternate MAC address for all devices which support
    it
  e1000e: convert head, tail and itr_register offsets to __iomem
    pointers
  e1000e: pass pointer to ring struct instead of adapter struct

Eric Dumazet (1):
  igb: Add support for byte queue limits.

Jesse Brandeburg (1):
  e1000: fix lockdep splat in shutdown handler

Koki Sanagi (1):
  igb: reset PHY after recovering from PHY power down

Neerav Parikh (2):
  netdev: FCoE: Add new ndo_get_fcoe_hbainfo() call
  ixgbe: FCoE: Add support for ndo_get_fcoe_hbainfo() call

Yan, Zheng (1):
  igb: add basic runtime PM support

 drivers/net/ethernet/intel/e1000/e1000_main.c |    8 +-
 drivers/net/ethernet/intel/e1000e/defines.h   |    7 +
 drivers/net/ethernet/intel/e1000e/e1000.h     |   27 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c   |   10 +-
 drivers/net/ethernet/intel/e1000e/hw.h        |    9 +-
 drivers/net/ethernet/intel/e1000e/lib.c       |    7 +-
 drivers/net/ethernet/intel/e1000e/netdev.c    |  397 +++++++++++++++----------
 drivers/net/ethernet/intel/igb/igb.h          |    5 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |   16 +
 drivers/net/ethernet/intel/igb/igb_main.c     |  142 ++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   83 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 include/linux/netdevice.h                     |   26 ++
 14 files changed, 541 insertions(+), 204 deletions(-)

-- 
1.7.7.4
