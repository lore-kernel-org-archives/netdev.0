From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 10 Jan 2014 00:58:40 -0800
Message-ID: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61393 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbaAJI7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 03:59:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Most notable is Jacob's patch to add PTP support to i40e.

Mitch cleans up additional memcpy's and use struct assignment instead.
Then fixes long lines to appease checkpatch.pl.  Mitch then provides
a fix to keep us from spamming the log with confusing errors.  If you
use ip to change the MAC address of a VF while the VF driver is loaded,
closing the VF interface or unloading the VF driver will cause the VF
driver to remove the MAC filter for its original (now invalid) MAC
address.

Jesse cleans up macros which are no longer needed or used.

I (Jeff) cleanup function header comments to ensure Doxygen/kdoc works
correctly to generate documentation without warnings.

Anjali fixes a bug where ethtool set-channels would return failure when
configuring only one Rx queue.  Then fixes a bug where the driver was
erroneously exiting the driver unload path if one part of the unload
failed.

Shannon fixes if the IPV6EXADD but is set in the Rx descriptor status,
there was an optional extension header with an alternate IP address
detected and the hardware checksum was not handling the alternate IP
address correctly.  Then adjusts the ITR max and min values to match
the hardware max value and recommended min value.  Shannon makes sure
to clear the PXE mode after the adminq is initialized.

The following are changes since commit 11b57f90257c1d6a91cee720151b69e0c2020cf6:
  xen-netback: stop vif thread spinning if frontend is unresponsive
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (3):
  i40e: Update the Current NVM version Low value
  i40e: Setting queue count to 1 using ethtool is valid
  i40e: do not bail when disabling if Tx queue disable fails

Catherine Sullivan (2):
  i40e: Bump version
  i40e: Bump version

Jacob Keller (1):
  i40e: enable PTP

Jeff Kirsher (1):
  i40e: Cleanup Doxygen warnings

Jesse Brandeburg (1):
  i40e: drop unused macros

Mitch Williams (3):
  i40e: use assignment instead of memcpy
  i40e: fix long lines
  i40e: allow VF to remove any MAC filter

Shannon Nelson (5):
  i40e: check for possible incorrect ipv6 checksum
  i40e: adjust ITR max and min values
  i40e: clear qtx_head before enabling Tx queue
  i40e: call clear_pxe after adminq is initialized
  i40e: fix log message wording

 drivers/net/ethernet/intel/i40e/Makefile           |   2 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  26 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  28 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  23 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  35 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |   3 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  63 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   1 +
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 640 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  57 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   8 +-
 16 files changed, 859 insertions(+), 62 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_ptp.c

-- 
1.8.3.1
