From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Mon, 12 Mar 2012 21:03:38 -0700
Message-ID: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817Ab2CMEDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes/cleanups igb, ixgbe and net.
Majority of the patches are against ixgbe and this series is part
one of three to update ixgbe.

The following are changes since commit f124488e4713dc9afa2028553261b1d399286e68:
  bnx2x: code doesn't use stats for allocating Rx BDs
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (12):
  ixgbe: add support for byte queue limits
  net: Fix issue with netdev_tx_reset_queue not resetting queue from
    XOFF state
  net: Add memory barriers to prevent possible race in byte queue
    limits
  ixgbe: Do no clear Tx status bits since eop_desc provides enough info
  ixgbe: Reorder adapter contents for better cache utilization
  ixgbe: Address issues with Tx WHTRESH value not being set correctly
  ixgbe: Correct Adaptive Interrupt Moderation so that it will change
    values
  ixgbe: Default to queue pairs when number of queues is less than CPUs
  ixgbe: Drop unnecessary napi_schedule_prep and spare blank line from
    ixgbe_intr
  ixgbe: Allocate rings as part of the q_vector
  ixgbe: Add iterator for cycling through rings on a q_vector
  ixgbe: Simplify logic for ethtool loopback frame creation and testing

Jeff Kirsher (2):
  igb: fix ethtool offline test
  ixgbe: remove tie between NAPI work limits and interrupt moderation

 drivers/net/ethernet/intel/igb/igb_ethtool.c     |    7 +
 drivers/net/ethernet/intel/igb/igb_main.c        |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  115 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   71 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  547 +++++++++++-----------
 include/linux/netdevice.h                        |   50 ++-
 6 files changed, 409 insertions(+), 384 deletions(-)

-- 
1.7.7.6
