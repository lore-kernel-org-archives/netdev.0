From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-16
Date: Tue, 16 Feb 2016 21:34:06 -0800
Message-ID: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbcBQFeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf only.

Shannon adds flags to MAC allocation requests to signify that the MAC VLAN
filters should come from the shared resource pool.  Added a new "set switch
config" admin queue command and the new Cisco VXLAN-GPE cloud tunnel type
for the admin queue commands.  Added more detail to the NVM update debug
message in order to see the full ethtool request data.  Also added a few
more bits of netdev data into the debugfs output for dump VSI.

Pandi fixes the width of two datatypes which were being declared a different
size from what they are assigned.

Anjali fixes an issue where we were not doing write-back on interrupt
throttle for legacy case in x722.

Mitch adds a counter for ARQ overflows since sometimes an ever-growing
number indicates that something bad is happening.  Also added 20G speed for
Tx bandwidth calculations.

Jesse refactors the DCB function based on a community suggestion to change
the multi-level if statement into a switch statement.  Cleans up VF device
IDs in the PF, since it does not need to know them.

The following are changes since commit 4952cd3e7b47dfe8f7d6c69973b13eb487eb2bd0:
  tipc: refactor node xmit and fix memory leaks
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (1):
  i40e: fix write-back-on-itr to work with legacy itr

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 1.4.11 and i40evf to 1.4.7

Jesse Brandeburg (3):
  i40e: refactor DCB function
  i40e: remove VF device IDs from PF
  i40e: trivial: remove unnecessary local var

Mitch Williams (3):
  i40e: add counter for arq overflows
  i40e: add 20G speed for Tx bandwidth calculations
  i40evf: enable bus master after reset

Pandi Maharajan (1):
  i40e: Store lan_vsi_idx and lan_vsi_id in the right size

Shannon Nelson (7):
  i40e: AQ Shared resource flags
  i40e: AQ Add set_switch_config
  i40e: AQ Add VXLAN-GPE tunnel type
  i40e: AQ thermal sensor control struct
  i40e: Bump AQ minor version to 1.5 for new FW features
  i40e: add a little more to an NVM update debug message
  i40e: add netdev info to VSI dump

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 42 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  8 -----
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         | 15 +++++---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 24 ++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |  4 ---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  8 ++---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  5 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 18 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 +--
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 42 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  3 +-
 15 files changed, 138 insertions(+), 43 deletions(-)

-- 
2.5.0
