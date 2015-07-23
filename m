From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-07-23
Date: Thu, 23 Jul 2015 06:52:29 -0700
Message-ID: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbbGWNwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb, ixgbevf, i40e and i40evf.

Emil extends the reporting of the RSS key and hash table by adding support
for x550 VFs.

Jia-Ju Bai fixes a QoS issue in e1000e where the error handling lacked a
call to pm_qos_remove_request() to cleanup the QoS request made in
e1000_open().

Todd updates igb to report unsupported for ethtool coalesce settings
that are not supported.  Also updated the driver to use the ARRAY_SIZE()
macro.

Carolyn fixes and refactors the dynamic ITR code for i40e and i40evf
which would never change dynamically.  So update the switch() statement
to have a default case and switch on "new_latency_range" versus the
current ITR setting.

Shannon cleans up i40e code, where there were un-needed goto's.  Also
clean up error status messages that were causing some confusion in
PHY and FCoE setup error reports.

Mitch updates the virtual channel interface to prepare for the x722 device
and other future devices, so that the VF driver can report what its
capable of supporting to the PF driver.  Updates the i40evf driver to
handle resets like Core or EMP resets, where the device is reinitialized
and the VF will not get the same VSI.

Jesse updates the i40e and i40evf driver to use the kernel BIT() and
BIT_ULL() macros.

The following are changes since commit 045a0fa0c5f5ea0f16c009f924ea579634afbba8:
  ip_tunnel: Call ip_tunnel_core_init() from inet_init()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Carolyn Wyborny (1):
  i40e/i40evf: Fix and refactor dynamic ITR code

Emil Tantilov (1):
  ixgbevf: add support for reporting RSS key and hash table for X550

Jesse Brandeburg (1):
  i40e: use BIT and BIT_ULL macros

Jia-Ju Bai (1):
  e1000e: Cleanup qos request in error handling of e1000_open

Mitch Williams (6):
  i40e: add VF capabilities to virtual channel interface
  i40e/i40evf: add macros for virtual channel API version and device
    capability
  i40e: support virtual channel API 1.1
  i40evf: handle big resets
  i40evf: support virtual channel API version 1.1
  i40e: provide correct API version to older VF drivers

Shannon Nelson (2):
  i40e: clean up unneeded gotos
  i40e: clean up error status messages

Todd Fujinaka (3):
  igb: report unsupported ethtool settings in set_coalesce
  igb: use ARRAY_SIZE to replace calculating sizeof(a)/sizeof(a[0])
  igb: bump version to igb-5.3.0

 drivers/net/ethernet/intel/e1000e/netdev.c         |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  56 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 210 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_dcb.h         |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  84 ++--
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.h        |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  37 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 465 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 185 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  44 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  23 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  46 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   5 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 206 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 146 ++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  42 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  23 +-
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  16 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  51 ++-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  44 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 123 +++---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  51 ++-
 drivers/net/ethernet/intel/igb/e1000_phy.c         |  16 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  21 +
 drivers/net/ethernet/intel/igb/igb_main.c          |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |  51 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |   9 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  21 +-
 40 files changed, 1376 insertions(+), 712 deletions(-)

-- 
2.4.3
