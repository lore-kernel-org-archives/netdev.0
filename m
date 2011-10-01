From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11 v2][pull request] Intel Wired LAN Driver Updates
Date: Fri, 30 Sep 2011 21:52:50 -0700
Message-ID: <1317444771-13962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50707 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1JAEwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Oct 2011 00:52:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e and ixgbe. The one
patch for e1000e makes function tables const, thanks to Stephen
Hemminger for reporting this.  The remaining patches are for ixgbe,
and the contain the following:

 - minor cleanups
 - add support for 82599 device and ethtool -E support
 - removal of a PHY which is not used in production silicon

v2- Updated patch 11 with the suggested changes from Ben Hutchings

The following are changes since commit 56fd49e399ce1d82200fad5b8924d4e35a587809:
  bna: Driver Version changed to 3.0.2.2
and are available in the git repository at
  git://github.com/Jkirsher/net-next.git

Emil Tantilov (8):
  ixgbe: prevent link checks while resetting
  ixgbe: clear the data field in ixgbe_read_i2c_byte_generic
  ixgbe: remove return code for functions that always return 0
  ixgbe: add support for new 82599 device
  ixgbe: send MFLCN to ethtool
  ixgbe: do not disable flow control in ixgbe_check_mac_link
  ixgbe: remove instances of ixgbe_phy_aq for 82598 and 82599
  ixgbe: allow eeprom writes via ethtool

Jacob Keller (1):
  ixgbe: fix driver version initialization in firmware

Jeff Kirsher (1):
  e1000e: make function tables const

Mika Lansirinne (1):
  ixgbe: get pauseparam autoneg

 drivers/net/ethernet/intel/e1000e/80003es2lan.c  |    8 +-
 drivers/net/ethernet/intel/e1000e/82571.c        |   20 +++---
 drivers/net/ethernet/intel/e1000e/e1000.h        |   28 ++++----
 drivers/net/ethernet/intel/e1000e/ich8lan.c      |   16 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    8 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |    7 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |    6 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   74 +++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   12 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   33 +++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |    1 +
 12 files changed, 125 insertions(+), 89 deletions(-)

-- 
1.7.6.2
