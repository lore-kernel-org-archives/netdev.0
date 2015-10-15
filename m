From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-10-15
Date: Thu, 15 Oct 2015 02:39:47 -0700
Message-ID: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbbJOJmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and ixgbe.

Emil changes the ixgbe driver to disable LRO by default in favor or GRO.

Mark provides two changes for ixgbe, first fixes a semaphore issue when
a reset never completes, it is necessary to retake the semaphore before
returning.

Jesse fixes up a missing function header comment variable reference.  Then
enables ethtool priv flags to control flow director at runtime.

Neerav changes several i40e error messages to debug only since the
messages were printing when there was no functional issue and were meant
for debug only.

Catherine changes the i40e driver to make only X722 support 100M SGMII,
since it is the only device to actually support it.

Anjali modifies the i40e/i40evf driver to add writeback on ITR offload
support for X722 since the device has a way to work around the
descriptor writeback issue.

Mitch cleans up obsolete code.  Also reduces the i40evf init time by
shortening up the delays in the init task to aid in performance in
load/unload tests and mitigates DMAR errors in VF enable/disable tests.

Shannon modifies i40e to allow flow director sideband when the device
is in MFP mode and only has one partition enabled, since we still have
plenty of interrupts for managing the flow director activity.  Also
cleaned up flow director ATR control in debugfs since the priv flag
has been added to our ethtool interface.  Makes several general code
cleanups of redundant or unnecessary code for i40e.

The following are changes since commit f6bba8945e7cff591127be1f6992c3e466cfff4c:
  Merge branch 'mlx-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (2):
  i40e/i40evf: Add WB_ON_ITR offload support
  i40e: X722 is on the IOSF bus and does not report the PCI bus info

Catherine Sullivan (2):
  i40e: Remove 100M SGMII unless hw is X722
  i40e/i40evf: Bump i40e version to 1.3.28 and i40evf to 1.3.19

Emil Tantilov (1):
  ixgbe: disable LRO by default

Jesse Brandeburg (2):
  i40e: Add missing parameter comment to ndo_bridge_setlink
  i40e: use priv flags to control flow director

Kevin Scott (1):
  i40e: Store off PHY capabilities

Mark Rustad (2):
  ixgbe: Fix CS4227-related semaphore error on reset failure
  ixgbe: Check for setup_internal_link method

Mitch Williams (2):
  i40e: remove obsolete version check
  i40evf: speed up init

Neerav Parikh (1):
  i40e: Change some messages from info to debug only

Shannon Nelson (4):
  i40e: allow FD SB if MFP mode only has 1 partition
  i40e: remove FD atr control from debugfs
  i40e/i40evf: remove redundant declarations of a variable and a
    function
  i40e: remove unnecessary string copy operations

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   3 +
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  24 ----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  59 ++++++----
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 125 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  13 ++-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |  11 +-
 14 files changed, 153 insertions(+), 104 deletions(-)

-- 
2.4.3
