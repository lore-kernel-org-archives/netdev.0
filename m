From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/8][pull request] Intel Wired LAN Driver Updates 2015-05-04
Date: Mon,  4 May 2015 02:40:19 -0700
Message-ID: <1430732427-29984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	h-shimamoto@ct.jp.nec.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53718 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbbEDJks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 05:40:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, e100, e1000e and ixgbe.

Todd cleans up igb_enable_mas() since it should only be called for the
82575 silicon and has no clear return, so modify the function to void.

Jean Sacren found upon inspection that 'err' did not need to be
initialized, since it is immediately overwritten.

Alex Duyck provides two patches for e1000e, the first cleans up the
handling VLAN_HLEN as a part of max frame size.  Fixes the issue:
c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when changing
interface MTU").  The second fixes an issue where the driver was not
allowing jumbo frames to be enabled when CRC stripping was disabled,
however it was allowing CRC stripping to be disabled while jumbo frames
were enabled.

Jeff (me) fixes a warning found on PPC where the use of do_div() needed
to use u64 arg and not s64.

Mark provides three ixgbe patches, first to fix the Intel On-chip System
Fabric (IOSF) Sideband message interfaces, to serialize access using both
PHY bits in the SWFW_SEMAPHORE register.  Then fixes how semaphore bits
were released, since they should be released in reverse of the order that
they were taken.  Lastly updates ixgbe to use a signed type to hold
error codes, since error codes are negative, so consistently use signed
types when handling them.

v2: dropped the previous #6-#8 patches by Hiroshi Shimanoto based on
    feedback from Or Gerlitz (and David Miller) that it appears there
    needs to be further discussion on how this gets implemented.

The following are changes since commit 4256af62c44b40ffd1c218ad85fc8fd4234d1736:
  Merge branch 'via-rhine-rework'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (2):
  e1000e: Cleanup handling of VLAN_HLEN as a part of max frame size
  e1000e: Do not allow CRC stripping to be disabled on 82579 w/ jumbo
    frames

Jean Sacren (1):
  e100: don't initialize int object to zero

Jeff Kirsher (1):
  e1000e: fix call to do_div() to use u64 arg

Mark Rustad (3):
  ixgbe: Fix IOSF SB access issues
  ixgbe: Release semaphore bits in the right order
  ixgbe: Use a signed type to hold error codes

Todd Fujinaka (1):
  igb: simplify and clean up igb_enable_mas()

 drivers/net/ethernet/intel/e100.c                |   2 +-
 drivers/net/ethernet/intel/e1000e/82571.c        |   2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c      |  23 ++---
 drivers/net/ethernet/intel/e1000e/netdev.c       |  32 ++++---
 drivers/net/ethernet/intel/igb/igb_main.c        |  27 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  10 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 106 ++++++++++++++---------
 10 files changed, 123 insertions(+), 95 deletions(-)

-- 
2.1.0
