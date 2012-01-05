From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/8][pull request] Intel Wired LAN Driver Updates
Date: Wed,  4 Jan 2012 22:23:32 -0800
Message-ID: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21235 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab2AEGXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 01:23:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, igb and
netdev/ixgbe.  There are 2 fixes and the remaining patches are
either add support or cleanup.

Here is a list of the new support added:
 - igb adds support for byte queue limits and basic runtime PM
 - FCoE adds ndo_get_fcoe_hbainfo() call

v2- Dropped e1000e patches while Bruce works on the suggested changes and
    added 2 e1000 patches from Florian.

The following are changes since commit 117ff42fd43e92d24c6aa6f3e4f0f1e1edada140:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Eric Dumazet (1):
  igb: Add support for byte queue limits.

Florian Fainelli (2):
  e1000: unmap ce4100_gbe_mdio_base_virt in e1000_remove
  e1000: cleanup CE4100 MDIO registers access

Jesse Brandeburg (1):
  e1000: fix lockdep splat in shutdown handler

Koki Sanagi (1):
  igb: reset PHY after recovering from PHY power down

Neerav Parikh (2):
  netdev: FCoE: Add new ndo_get_fcoe_hbainfo() call
  ixgbe: FCoE: Add support for ndo_get_fcoe_hbainfo() call

Yan, Zheng (1):
  igb: add basic runtime PM support

 drivers/net/ethernet/intel/e1000/e1000_hw.h   |    4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |   23 ++---
 drivers/net/ethernet/intel/igb/igb.h          |    5 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |   16 +++
 drivers/net/ethernet/intel/igb/igb_main.c     |  142 +++++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   83 ++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 include/linux/netdevice.h                     |   26 +++++
 9 files changed, 269 insertions(+), 38 deletions(-)

-- 
1.7.7.5
