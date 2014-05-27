From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Tue, 27 May 2014 02:12:16 -0700
Message-ID: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbaE0JMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, ixgbe and i40evf.

Emil provides a fix for ixgbe so that non-fiber devices with MNG FW enabled
are able to link at 100Mbps.

Jacob provides several changes for ixgbe, most of which are PTP related.
Renames ixgbe_ptp_enable() to ixgbe_ptp_feature_enable() to better reflect
the functions purpose.  Extracts the hardware setup logic for the PTP
hardware bits from the ixgbe_ptp_set_ts_config() to enable future work for
the ixgbe_ptp_reset().  Maintain the hwstamp configuration through a reset
and extracts the creation of the PTP clock device from ptp_init() in order
to properly handle a suspend/resume cycle and only calls it if we don't
already have a ptp_clock pointer.

David provides a patch to expend the e1000e driver to turn on unicast
PROMISC when there is failure to write to a shared receive address register.
The fix update_phy_task() for 82579 is expanded to include newer PHYs as well
so that the dev_spec->eee_lp_ability has the correct value when going into
SX states.

Todd provides a e1000e fix an errata for 82574/82583 where it is possible
bad bits are read from SYSTIMH/L so check to see that the time is
incrementing at a reasonable rate and is a multiple of the time incremental
value.  Removes a redundant igb PHY power down register write.

Andi Kleen out of lines two write functions for e1000e to save 30k text size.

Tobias Klauser converts the e1000 and i40evf drivers to use the
is_broadcast_ether_addr() and is_multicast_ether_addr().

The following are changes since commit 3bea8eddfebe1c61ea824dd2880d4368791edc1f:
  Merge branch 'net-sysfs-docs'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Andi Kleen (1):
  e1000e: Out of line __ew32_prepare/__ew32

David Ertman (3):
  e1000e: Failure to write SHRA turns on PROMISC mode
  e1000e: Cleanup parenthesis around return value
  e1000e: Fix expand setting EEE link info to all affected parts

Emil Tantilov (1):
  ixgbe: fix linking at 100Mbps on copper devices with MNG FW enabled

Jacob Keller (6):
  ixgbe: rename ixgbe_ptp_enable to ixgbe_ptp_feature_enable
  ixgbe: extract the hardware setup from the ixgbe_ptp_set_ts_config
  ixgbe: allow ixgbe_ptp_reset to maintain current hwtstamp config
  ixgbe: extract PTP clock device from ptp_init
  ixgbe: separate the PTP suspend and stop actions
  ixgbe: avoid duplicate code in suspend and stop paths

Tobias Klauser (2):
  e1000: Use is_broadcast_ether_addr/is_multicast_ether_addr helpers
  i40evf: Use is_multicast_ether_addr helper

Todd Fujinaka (2):
  e1000e: 82574/82583 TimeSync errata for SYSTIM read
  igb: remove redundant PHY power down register write

 drivers/net/ethernet/intel/e1000/e1000_hw.c     |   4 +-
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   1 +
 drivers/net/ethernet/intel/e1000e/82571.c       |   1 +
 drivers/net/ethernet/intel/e1000e/e1000.h       |  33 +----
 drivers/net/ethernet/intel/e1000e/hw.h          |   3 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  61 +++++++--
 drivers/net/ethernet/intel/e1000e/mac.c         |   9 +-
 drivers/net/ethernet/intel/e1000e/mac.h         |   3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  69 +++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c      |  14 --
 drivers/net/ethernet/intel/igb/e1000_phy.h      |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  29 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    | 163 ++++++++++++++++++------
 15 files changed, 277 insertions(+), 117 deletions(-)

-- 
1.9.3
