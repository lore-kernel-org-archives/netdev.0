From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/7][pull request] Intel Wired LAN Driver Updates
Date: Wed,  2 May 2012 02:13:38 -0700
Message-ID: <1335950025-13294-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59017 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab2EBJOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 05:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000e and ixgbe.
Patch 4 & 5 integrate the hwmon interface for ixgbe as Ben Hutchings
has done for other drivers.

v2: dropped the ixgbe patch which added the sysfs interface

The following are changes since commit e4ae004b84b315dd4b762e474f97403eac70f76a:
  netem: add ECN capability
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (3):
  e1000e: workaround EEPROM configuration change on 82579
  e1000e: PHY initialization flow changes for 82577/8/9
  e1000e: fix .ndo_set_rx_mode for 82579

Don Skidmore (2):
  ixgbe: add support functions to access thermal data
  ixgbe: add hwmon interface to export thermal data

Greg Rose (2):
  ixgbe: Deny MACVLAN requests from VFs with admin set MAC
  ixgbe: Reset max_vfs to zero when user request is out of range

 drivers/net/ethernet/intel/Kconfig              |    8 +
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    1 +
 drivers/net/ethernet/intel/e1000e/82571.c       |    4 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |    2 +-
 drivers/net/ethernet/intel/e1000e/hw.h          |    6 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  339 ++++++++++++++++-------
 drivers/net/ethernet/intel/e1000e/mac.c         |   10 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |   12 +-
 drivers/net/ethernet/intel/ixgbe/Makefile       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   26 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  169 +++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |   13 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |    6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c  |  271 ++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   40 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    2 +
 19 files changed, 808 insertions(+), 120 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c

-- 
1.7.7.6
