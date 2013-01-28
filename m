From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Mon, 28 Jan 2013 01:04:15 -0800
Message-ID: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab3A1JEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, ixgbevf, igb and igbvf.
Majority of the patches are code cleanups of e1000e where code
is removed (Yeah!).  The other two e1000e patches are fixes.  The
first is to fix the maximum frame size for 82579 devices.  The second
fix is to resolve an issue with devices other than 82579 that suffer
from dropped transactions on platforms with deep C-states when
jumbo frames are enabled.

The ixgbevf patch is to ensure that the driver fetches the correct,
refreshed value for link status and speed when the values have changed.

The igb and igbvf patches are a solution to an issue Stefan Assmann
reported, where when the PF is up and igbvf is loaded, the MAC address
is not generated using eth_hw_addr_random().

The following are changes since commit a1b1add07fa794974573d93483d68e373edfe7bd:
  gro: Fix kcalloc argument order
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (11):
  e1000e: cleanup: remove e1000_set_d0_lplu_state()
  e1000e: cleanup: remove e1000_force_speed_duplex()
  e1000e: cleanup: rename e1000_get_cfg_done()
  e1000e: cleanup: remove e1000_get_phy_cfg_done()
  e1000e: cleanup: remove e1000_get_cable_length()
  e1000e: cleanup: remove e1000e_commit_phy()
  e1000e: correct maximum frame size on 82579
  e1000e: adjust PM QoS request
  e1000e: cleanup: remove unused #define
  e1000e: cleanup hw.h
  e1000e: cleanup: remove comments which are no longer applicable

Greg Rose (1):
  ixgbevf: Make sure link status and speed are fetched

Mitch A Williams (2):
  igb: Don't give VFs random MAC addresses
  igbvf: be sane about random MAC addresses

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |   2 +-
 drivers/net/ethernet/intel/e1000e/82571.c       |   4 +-
 drivers/net/ethernet/intel/e1000e/defines.h     |   9 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |  12 +--
 drivers/net/ethernet/intel/e1000e/ethtool.c     |   5 +-
 drivers/net/ethernet/intel/e1000e/hw.h          |  25 +++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   4 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  32 +++----
 drivers/net/ethernet/intel/e1000e/phy.c         | 114 +++++-------------------
 drivers/net/ethernet/intel/igb/igb_main.c       |   6 +-
 drivers/net/ethernet/intel/igbvf/netdev.c       |  24 +++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c    |   1 +
 12 files changed, 76 insertions(+), 162 deletions(-)

-- 
1.7.11.7
