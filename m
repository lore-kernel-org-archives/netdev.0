From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/10][pull request] Intel Wired LAN Driver Updates 2014-11-11
Date: Tue, 11 Nov 2014 06:44:36 -0800
Message-ID: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3085 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbaKKOp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and ixgbe.

Kamil updated the i40e and i40evf driver to poll the firmware slower
since we were polling faster than the firmware could respond.

Shannon updates i40e to add a check to keep the service_task from
running the periodic tasks more than once per second, while still
allowing quick action to service the events.

Jesse cleans up the throttle rate code by fixing the minimum interrupt
throttle rate and removing some unused defines.

Mitch makes the early init admin queue message receive code more robust
by handling messages in a loop and ignoring those that we are not
interested in.  This also gets rid of some scary log messages that
really do not indicate a problem.

Don provides several ixgbe patches, first fixes an issue with x540
completion timeout where on topologies including few levels of PCIe
switching for x540 can run into an unexpected completion error.  Cleans
up the functionality in ixgbe_ndo_set_vf_vlan() in preparation for
future work.  Adds support for x550 MAC's to the driver.

v2:
 - Remove code comment in patch 01 of the series, based on feedback from
   David Liaght
 - Updated the "goto" to "break" statements in patch 06 of the series,
   based on feedback from Sergei Shtylyov
 - Initialized the variable err due to the possibility of use before
   being assigned a value in patch 07 of the series
 - Added patch "ixgbe: add helper function for setting RSS key in
   preparation of X550" since it is needed for the addition of X550 MAC
   support

The following are changes since commit 2e1af7d74f4f7b4d4c1b0fbf5da3b5f92d9c332f:
  mlx4: restore conditional call to napi_complete_done()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (5):
  ixgbe: fix X540 Completion timeout
  ixgbe: cleanup ixgbe_ndo_set_vf_vlan
  ixgbe: cleanup move setting PFQDE.HIDE_VLAN to support function.
  ixgbe: Add new support for X550 MAC's
  ixgbe: add helper function for setting RSS key in perperation of X550

Jesse Brandeburg (1):
  i40e: clean up throttle rate code

Kamil Krawczyk (1):
  i40e: poll firmware slower

Mitch Williams (2):
  i40evf: make early init processing more robust
  i40evf: don't use more queues than CPUs

Shannon Nelson (1):
  i40e: don't do link_status or stats collection on every ARQ

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  14 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   5 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   5 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  16 +--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  50 ++++----
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  65 +++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  50 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  37 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 122 +++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |   4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |  64 +++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 131 ++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |  45 +++++--
 23 files changed, 441 insertions(+), 209 deletions(-)

-- 
1.9.3
