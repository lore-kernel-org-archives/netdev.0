From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates 2013.01.30
Date: Wed, 30 Jan 2013 03:44:33 -0800
Message-ID: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15037 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213Ab3A3Loz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 06:44:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and e1000e.  The ixgbe patches are
a mix of fixes, cleanup and added functionality.  The first fix is for
traffic classes, where if the mapping has changed reset the NIC.  The other
ixgbe fix resolves an issue where the device lookup neglected to do a
pci_dev_put() to decrement the device reference count.

The ixgbe cleanup was done by Josh, where the auto-negotiation variables
were renamed/cleaned up and refactored.

Joseph added Tx encapsulation capability and Alex added the debug counters
for the new feature.

The remaining patches are from Bruce to do additional cleanup on e1000e as
well as bump the driver version.  Most notably is the cleanup to use the
kernel IEEE MII definitions where possible instead of the local MII
definitions.

The following are changes since commit d2ed273d30c5ffd14f6b5ec7ecc751d960f832fc:
  net: disallow drivers with buggy VLAN accel to register_netdevice()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbe: Add debug counters for Tx Encap CSUM

Amir Hanania (1):
  ixgbe: Reset the NIC if up2tc has changed

Bruce Allan (6):
  e1000e: cleanup defines.h
  e1000e: cleanup: group OR'ed bit settings with parens
  e1000e: cleanup some whitespace and indentation issues
  e1000e: update driver version string
  e1000e: resolve -Wunused-parameter compile warnings
  e1000e: use generic IEEE MII definitions

Greg Rose (1):
  ixgbe: Fix device ref count bug

Joseph Gasparakis (1):
  ixgbe: Adding Tx encapsulation capability

Josh Hay (3):
  ixgbe: rename autoneg variables
  ixgbe: removed unused variable from setup_link_speed
  ixgbe: autoneg variable refactoring

 drivers/net/ethernet/intel/e1000e/80003es2lan.c  |  28 ++--
 drivers/net/ethernet/intel/e1000e/82571.c        |  17 ++-
 drivers/net/ethernet/intel/e1000e/defines.h      | 128 +++-------------
 drivers/net/ethernet/intel/e1000e/e1000.h        |   1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c      |  40 ++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c      |  18 +--
 drivers/net/ethernet/intel/e1000e/mac.c          |  35 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c       |  66 ++++----
 drivers/net/ethernet/intel/e1000e/param.c        |   3 +-
 drivers/net/ethernet/intel/e1000e/phy.c          | 186 +++++++++++------------
 drivers/net/ethernet/intel/e1000e/ptp.c          |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  54 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |  16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  87 ++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h     |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |   7 +-
 21 files changed, 333 insertions(+), 390 deletions(-)

-- 
1.7.11.7
