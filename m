From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates 2014-07-25
Date: Fri, 25 Jul 2014 21:45:10 -0700
Message-ID: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57220 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaGZEpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, ixgbe and ixgbevf.

Mark provides all the changes for ixgbe and ixgbevf.  Converts some udelay()
calls to the preferred usleep_range().  Fixes a spurious release of the
semaphore in several functions when there was a failure to acquire the
semaphore in the first place.  Fixes a X540 semaphore error where an
incorrect check was treating success as failure and vice-versa.  Fixed
ixgbe_write_mbx() error when it was being called and there was no
mbx->ops.write method defined, so no error code was returned.  The
corresponding read function would explicitly return an error in such a
case as do other functions.  Cleans up unused (dead) code by removing it.
Finally make return values more direct, eliminating some gotos and
otherwise unneeded conditionals, which allows the removal of some local
variables.

David provides all the changes for e1000e.  Fix CRC errors with jumbo
traffic for 82579, i217 and i218 client parts to increase the gap
between the read and write pointers in the transmit FIFO.  Added code
to check and respond to previously ignored return values from NVM
access functions.  Added support for EEE in Sx states and fixed EEE in
S5 with runtime PM enabled.

The following are changes since commit ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f:
  ipv6: remove obsolete comment in ip6_append_data()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

David Ertman (5):
  e1000e: Fix CRC errors with jumbo traffic
  e1000e: Add code to check return values on NVM accesses
  e1000e: Add support for EEE in Sx states
  e1000e: Fix EEE in S5 w/ Runtime PM enabled
  e1000e: Fix Runtime PM blocks EEE link negotiation in S5

Mark Rustad (7):
  ixgbe: Convert some udelays to usleep_range
  ixgbe: Fix spurious release of semaphore in EEPROM access
  ixgbe: Correct X540 semaphore error
  ixgbe: Fix ixgbe_write_mbx error result
  ixgbe: Delete a bunch of dead code
  ixgbevf: Remove unused get_supported_physical_layer pointer
  ixgbe: Make return values more direct

 drivers/net/ethernet/intel/e1000e/defines.h     |   1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  20 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h     |   4 +
 drivers/net/ethernet/intel/e1000e/manage.c      |   5 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  55 ++-
 drivers/net/ethernet/intel/e1000e/nvm.c         |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 212 ++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  | 311 +++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 578 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c    |  39 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |  39 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c   |  24 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  32 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c    | 117 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    | 582 +++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  31 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |  20 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   | 216 ++++-----
 drivers/net/ethernet/intel/ixgbevf/vf.h         |   1 -
 19 files changed, 896 insertions(+), 1395 deletions(-)

-- 
1.9.3
