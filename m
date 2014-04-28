From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Mon, 28 Apr 2014 06:52:23 -0700
Message-ID: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbaD1Nwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jacob provides a i40e patch to remove ptp_tx_work() because it conflicts
with the interrupt-based handler and will cause spurious warning messages
to be displayed in the kernel log.  Since the hardware can properly trigger
an interrupt, we do not need to poll for an available timestamp in a work
queue any more.

Greg provides two patches for i40e, first to retain the MAC filter list
when changing a port VLAN.  Second fixes an issue where the function to
set the VF MAC address was not taking the port VLAN filter into account
when setting/clearing/resetting the VF's host administered MAC address.

Mitch provides three patches for i40evf, first adds support for getting
and setting RSS hashing options, RSS LUT entries, and getting the number
of device channels from ethtool.  Fixes a panic that woudl occur in the VF
if the PF driver failed or was removed from the host kernel.

Shannon adds driver version string to the driver version command so that
can be passed down through the firmware to low-level NC-SI functions.

Neerav provides several patches, first redistributes queue vectors after
DCB reconfiguration because the total number of queues that are configured
for a VSI may change based on a change in the total number of TCs enabled
as a result of a change in the DCB configuration based on DCBX.  Second,
allows the driver probe to continue when querying DCB config fails.
Lastly, provides changes to retrieve and store missing link config
information that was not being cached in the struct i40e_link_status.

Kevin provides a couple of patches, first to change a int variable type
to u16 to avoid a typecheck failure.  Second to update a function
parameters to remove an argument which is no longer used.

The following are changes since commit a49eb42a341f1df8fa0f9dc4449f9dd4a3234a2f:
  sched, act: allow to clear all actions as well
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e: Do not enable NTUPLE feature control in MFP mode
  i40e: Do not expose fd-sb commands from debugfs

Catherine Sullivan (1):
  i40e/i40evf: Bump build version

Greg Rose (2):
  i40e: Retain MAC filters when changing port VLAN
  i40e: Use port VLAN in MAC/VLAN filter configuration

Jacob Keller (1):
  i40e: remove ptp_tx_work timestamp work item

Kevin Scott (2):
  i40e: Change variable type to avoid typecheck failure
  i40e: Update function formal parameters

Mitch A Williams (1):
  i40evf: support ethtool RSS options

Mitch Williams (2):
  i40evf: fix panic on PF driver fail
  i40evf: remove debugging message

Neerav Parikh (3):
  i40e: Redistribute queue vectors after DCB reconfiguration
  i40e: Don't stop driver probe when querying DCB config fails
  i40e/i40evf: Retrieve and store missing link config information

Shannon Nelson (1):
  i40e/i40evf: add driver version string to driver version command

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 -
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   6 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  19 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  36 ---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   3 -
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   4 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  11 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 316 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  15 +-
 12 files changed, 373 insertions(+), 68 deletions(-)

-- 
1.9.0
