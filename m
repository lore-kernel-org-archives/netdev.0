From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2016-04-06
Date: Wed,  6 Apr 2016 20:29:25 -0700
Message-ID: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23097 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346AbcDGD3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Deepthi adds a debug message to display the MSIx vector count for hardware
capabilities.

Shannon removed the setting of debug_mask at startup to take care of an
issue where all the device capabilities getting printed when we had not
asked for it.  Moved the NVM status out of the admin queue structure,
since it should really stay with the other NVM data structures.

Akeem added the flush routine to the end of the reset flow to avoid
problems in the pass-through routines.

Jesse moves a local variable deeper into the depths of the driver
where the light is low and the context is great.  Then cleaned up
the tx_ring argument since it was not making good arguments.  Improved
performance by not "checking for FCoE" by re-ordering the FCoE checks.

Anjali adds the support for changing a VF from non-trusted to trusted
and vice-versa.

Mitch adds opcodes and structures to support RSS configuration by PF
driver on behalf of the VF driver.  Fixed how the VLAN feature flags
are set.

Kiran added defines for RSS, flow director, flexible payload and IPv6.

The following are changes since commit 58a01d4dc43e60208b70ce08604b5bcbb907f0d1:
  Merge branch 'mlxsw-dcb'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Akeem G Abodunrin (1):
  i40e: Move HW flush

Anjali Singhai Jain (1):
  i40e: Patch to support trusted VF

Deepthi Kavalur (1):
  i40e: Inserting a HW capability display info

Harshitha Ramamurthy (1):
  i40e/i40evf: Bump patch from 1.5.2 to 1.5.5

Jesse Brandeburg (3):
  i40e/i40evf: Move stack var deeper
  i40e/i40evf: Drop unused tx_ring argument
  i40e/i40evf: Faster RX via avoiding FCoE

Kiran Patil (1):
  i40e: Input set mask constants for RSS, flow director, and flex bytes

Mitch Williams (2):
  i40e: Add RSS configuration to virtual channel
  i40evf: properly handle VLAN features

Shannon Nelson (4):
  i40e: Leave debug_mask cleared at init
  i40e: Restrict VF poll mode to only single function mode devices
  i40e: Move NVM variable out of AQ struct
  i40e: Move NVM event wait check to NVM code

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      | 33 +-------------
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        | 12 +----
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 43 +++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 17 ++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 10 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 34 ++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    | 45 ++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 53 +++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 13 +++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      | 10 ++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 43 ++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  | 45 ++++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 29 ++++++------
 19 files changed, 311 insertions(+), 88 deletions(-)

-- 
2.5.5
