From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates 2015-12-03
Date: Thu,  3 Dec 2015 03:07:08 -0800
Message-ID: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27448 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759775AbbLCLHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Mark cleans up ixgbe_init_phy_ops_x550em, since this was designed to
initialize function pointers only and moves the KR PHY reset to the
ixgbe_setup_internal_phy_t_x550em which was designed to detect which
mode the PHY operates in and set it up.  Added the new thermal alarm
type support used with newer X550EM_x devices.  Fixed both ixgbe and
ixgbevf to use a private work queue to avoid hangs, which would
possibly occur when creating and destroying many VFS repeatedly.
Updated ixgbe PTP implementation to accommodate X550EM_x devices,
which handle clocking differently.  Fixed specification violations
in the datasheet, which was reported by Dan Streetman.  Fixed ixgbe
to check for and handle IPv6 extended headers so that Tx checksum
offload can be done, which was reported by Tom Herbert.  Fixed ixgbe
link issue for some systems with X540 or X550 by only inhibiting the
turning PHY power off when manageability is present.

Alex Duyck refactors the MAC address configuration code, which in
turns fixes an issue where once 63 entries had been used, you could no
longer add additional filters.  Updated ixgbe to use __dev_uc_sync
which also resolved an issue in which you could not remove an FDB
address without having to reset the port.  Updated the ixgbe driver
to make use of all the free RAR entries for FDB use if needed.

v2: updated patch 13 to "Alex Duyck Approved" version, in the original
    submission, I had grabbed a previous version of the patch and did not
    catch it was superseded by a later version

The following are changes since commit 6f24e5d599896b5091af72e4b3edfce6307627f7:
  sfc: use ALIGN macro for aligning frame sizes
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (3):
  ixgbe: Refactor MAC address configuration code
  ixgbe: Use __dev_uc_sync and __dev_uc_unsync for unicast addresses
  ixgbe: Allow FDB entries access to more RAR filters

Mark Rustad (12):
  ixgbe: Prevent KR PHY reset in ixgbe_init_phy_ops_x550em
  ixgbe: Add support for newer thermal alarm
  ixgbe: Use private workqueue to avoid certain possible hangs
  ixgbevf: Use a private workqueue to avoid certain possible hangs
  ixgbevf: Minor cleanups
  ixgbe: Update PTP to support X550EM_x devices
  ixgbe: Correct spec violations by waiting after reset
  ixgbe: Wait for master disable to be set
  ixgbe: Save VF info and take references
  ixgbe: Handle extended IPv6 headers in Tx path
  ixgbe: Always turn PHY power on when requested
  ixgbevf: Handle extended IPv6 headers in Tx path

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  46 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  14 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 273 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      | 720 ++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  50 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  12 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  46 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  73 ++-
 12 files changed, 890 insertions(+), 361 deletions(-)

-- 
2.5.0
