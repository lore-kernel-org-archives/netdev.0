From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/17][pull request] Intel Wired LAN Driver Updates 2015-01-16
Date: Fri, 16 Jan 2015 05:28:49 -0800
Message-ID: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5721 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755256AbbAPN3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 08:29:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

This series is a little bit larger than normal because two of the patches are
version bumps.

Shannon provides tweaks to i40e and i40evf to keep the firmware, software
and silicon validation in line together by removing unused and
deprecated code, adding define for iSCSI and fix queue mask size.  Fix
i40e so we do not give up in the reset/rebuild process if DCB setup
fails, just handle it the same as in the probe setup.  Cleans up PTP
log messages by removing the use of __func__ as we are not using that
any longer and removes the netdev name, since that can change and can
be misleading.  Adds struct size checks to indirect and command
structs that were left out previously.  Added admin queue API updates
(LLDP control, OEM OCSD and OCBB commands).

Kevin increases ASQ timeout for scenarios with multi-function devices.

Carolyn fixes a problem where the interrupts descriptions from the MSIx
configuration were truncating the needed bus info, which makes it hard
to distinguish configurations from port to port.  Increased the string
buffer size in order to allow the full data to be displayed.

Sravanthi cleans up the dump stats string from debugfs.

Jacob updates i40e to only enable the PTP interrupt in PFs which have PTP
enabled, instead of blindly enabling the PTP interrupt flags for all PFs.
Also updated i40e so that we do not do Tx or Rx timestamps if we do not
have PTP enabled.  Added the same check against pf->ptp_rx as we have
in Rx timestamp code path because it is possible that the user can
configure only Tx hardware timestamping so we do not want to check for
Rx timestamp hang since the software won't be handling them.

Neerav updates the driver to disable firmware LLDP agent for NICs with
a firmware version lower than v4.3 and added a message when this happens.
Adds parsing and reporting of iSCSI capability for a given device or
function, as well as adding support for iSCSI partition type with DCB
in NPAR mode.

v2:
 - Dropped patch 10 "i40e: clean up PTP log messages" based on feedback
   from David Laight and David Miller
 - Split up the original patch 13 "i40e: AQ API updates for new commands"
   into 2 patches (now #12 & #13) based on feedback from Or Gerlitz

The following are changes since commit 919d9db9521862d01712d9be25cd6ebfcc353eed:
  netlink: Fix netlink_insert EADDRINUSE error
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (2):
  i40e: fix proc/int descriptions
  i40e: Add define for interrupt name string len

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e/i40evf versions

Jacob Keller (4):
  i40e: only enable PTP interrupt cause if PTP is enabled
  i40e: check I40E_FLAG_PTP before handling Tx or Rx timestamps
  i40e: use same check for Rx hang as for Rx timestamps
  i40e: when Rx timestamps disabled set specific mode

Jeff Kirsher (1):
  i40e: AQ API updates

Kevin Scott (1):
  i40e/i40evf: Increase ASQ timeout

Neerav Parikh (2):
  i40e: Issue "Stop LLDP" command for firmware older than v4.3
  i40e: Support for NPAR iSCSI partition with DCB

Shannon Nelson (4):
  i40e/i40evf: AdminQ updates ww36
  i40e: don't give up on DCB error after reset
  i40e: add more struct size checks
  i40e: AQ API updates for new commands

Sravanthi Tangeda (2):
  i40e: Dump Stats string removed from debugfs help command
  i40e/i40evf: Bump i40e and i40evf versions

 drivers/net/ethernet/intel/i40e/i40e.h             |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 152 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   5 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 120 +++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  44 ++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   2 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 108 +++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 13 files changed, 365 insertions(+), 81 deletions(-)

-- 
1.9.3
