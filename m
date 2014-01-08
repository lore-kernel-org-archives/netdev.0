From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Tue,  7 Jan 2014 22:07:21 -0800
Message-ID: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62026 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603AbaAHGId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Anjali adds more functionality to debugfs to assist development and
testing of admin queue commands.

Greg makes sure broadcast promiscuous is disabled by default, otherwise
VLAN tagged packets out of the assigned VLAN domain are received.  Also
provides a fix when the 8021q driver is loaded, so that VLAN 0 tagged
packets are accepted so that upper layers can interpret the priority
bits. Then provides a fix to let the VF to request the PF to set its
already assigned MAC address without generating an error.  Greg also
adds helper functions to enable or disable internal switch loopback
when VFs are created or destroyed via the sysfs interface.

Shannon provides most of the changes, where he adds code to ensure
that the hardware waits to make sure that the firmware is ready as well
after reset.  Also updates the code to use the new features in the
firmware.  Provides a fix while in MFP mode where resources are
reduced, so use a smaller range of test registers than when in SFP mode.
Moves the PF ID initialization code to earlier in the driver
initialization function since a few operations need the information
before the first PF reset is called.  Shannon adds a check for MAC
type before reading anything from the registers to ensure we dealing
with the correct MAC type.  Then reworks Shadow RAM read word/buffer
functions as to not block whole NVM resources for SR read operations.

Mitch lastly provides a fix to correctly setup ARQ descriptors in
the cleanup code.

Catherine bumps the driver version due to all the recent changes.

v2:
 - Added blank lines after local variable declarations to patch 01
   as suggested by David Miller
 - Used the suggested memset() line in patch 15 as suggested by David
   Miller

The following are changes since commit da7c224b1baaeb7543dc7663ae78716f9a6864c1:
  net: xfrm: xfrm_policy: silence compiler warning
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Expose AQ debugfs hooks

Catherine Sullivan (1):
  i40e: Bump version

Greg Rose (4):
  i40e: Do not enable broadcast promiscuous by default
  i40e: Stop accepting any VLAN tag on VLAN 0 filter set
  i40e: Allow VF to set already assigned MAC address
  i40e: Enable/Disable PF switch LB on SR-IOV configure changes

Kamil Krawczyk (1):
  i40e: remove redundant AQ enable

Mitch Williams (1):
  i40e: correctly setup ARQ descriptors

Shannon Nelson (7):
  i40e: Add code to wait for FW to complete in reset path
  i40e: update firmware api to 1.1
  i40e: Reduce range of interrupt reg in reg test
  i40e: move PF ID init from PF reset to SC init
  i40e: check MAC type before any REG access
  i40e: rework shadow ram read functions
  i40e: whitespace paren and comment tweaks

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  27 ++---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 126 +++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  51 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 114 +++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  29 ++---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  67 +++--------
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  22 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 100 +++++++++++++---
 10 files changed, 397 insertions(+), 156 deletions(-)

-- 
1.8.3.1
