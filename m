From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Tue, 21 May 2013 15:03:08 -0700
Message-ID: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53264 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604Ab3EUWDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb and ixgbe.

Bruce Allan provide 2 minor cleanups for e1000e to resolve whitespace
issues and build warnings about unused parameters.

Carolyn provides a couple of fixes for igb, one being a fix for a
possible panic when the interface is down and receive traffic
arrives.  The second fix resolves an issue on newer parts which have
multiple checksum fields and set_ethtool was only checking to update
the first checksum of the NVM image.

Akeem provides majority of the changes in this patch set.  Akeem
provides a fix for e1000e on an issue reported from the community to
resolve the issue of unlocking swflag_mutex for 82574 and 82583
devices even if the hardware semaphore was successfully acquired.
The other patches from Akeem are against igb, where he adds support
SFP module discovery, LED blink mechanism for devices using cathodes,
LED support for i210/i211 parts and cleanup of a i2c function which
was not being used.

Matthew provides an update for igb to support a more accurate check
for a PTP RX hang.

Amir provides a patch for ixgbe to set the software prio_tc values at
initialization to the hardware setting to remove the need to reset the
device at the first time we call ixgbe_dcbnl_ieee_setets.

The following are changes since commit 1e18583adccfc122b5d6415cfe4bf1826c370f4e:
  ThunderLAN: remove is_eisa flag
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (6):
  e1000e: Release mutex lock only if it has been initially acquired
  igb: Changed LEDs blink mechanism to include designs using cathode
  igb: Support for SFP modules discovery
  igb: SerDes flow control setting
  igb: Implementation of i210/i211 LED support
  igb: Removed unused i2c function

Amir Hanania (1):
  IXGBE: Set the SW prio_tc values at initialization to the HW setting.

Bruce Allan (2):
  e1000e: cleanup whitespace
  e1000e: prevent warning from -Wunused-parameter

Carolyn Wyborny (2):
  igb: Fix set_ethtool function to call update nvm for entire image
  igb: Fix possible panic caused by Rx traffic arrival while interface
    is down

Matthew Vick (1):
  igb: Add update to last_rx_timestamp in Rx rings

 drivers/net/ethernet/intel/e1000e/80003es2lan.c    |  24 ++--
 drivers/net/ethernet/intel/e1000e/82571.c          |  30 ++---
 drivers/net/ethernet/intel/e1000e/ethtool.c        |  34 +++---
 drivers/net/ethernet/intel/e1000e/hw.h             |  34 +++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |  62 +++++------
 drivers/net/ethernet/intel/e1000e/netdev.c         |  55 +++++----
 drivers/net/ethernet/intel/e1000e/nvm.c            |   1 -
 drivers/net/ethernet/intel/e1000e/phy.c            |  22 ++--
 drivers/net/ethernet/intel/igb/e1000_82575.c       | 120 +++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  36 +++---
 drivers/net/ethernet/intel/igb/e1000_hw.h          |   2 +
 drivers/net/ethernet/intel/igb/e1000_i210.h        |   6 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c         |  45 ++++++--
 drivers/net/ethernet/intel/igb/e1000_phy.c         | 124 +++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_phy.h         |  20 ++++
 drivers/net/ethernet/intel/igb/igb.h               |  14 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  74 ++++++------
 drivers/net/ethernet/intel/igb/igb_main.c          |   9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |  23 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   3 +
 22 files changed, 526 insertions(+), 215 deletions(-)

-- 
1.7.11.7
