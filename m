From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Tue, 18 Mar 2014 20:41:58 -0700
Message-ID: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933563AbaCSDmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 23:42:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf, e1000e, ixgbe and ixgbevf.

Mitch adds support for the VF link state ndo which allows the PF driver
to control the virtual link state of the VF devices.  Added
support for viewing and modifying RSS hash options and RSS hash look-up
table programming through ethtool for i40evf.  Fixed complaint about
the use of min() where min_t() should be used in i40evf.

Anjali adds support for ethtool -k option for NTUPLE control for i40e.

Elizabeth cleans up and refactors i40e_open() to separate out the VSI
code into its own i40e_vsi_open().

Jesse enables the hardware feature head write back to avoid updating the
descriptor ring by marking each descriptor with a DD bit and instead
writes a memory location with an update to where the driver should clean
up to in i40e and i40evf.  Reduces context descriptors for i40e/i40evf
since we do not need context descriptors for every packet, only for
TSO or timesync.

Dan Carpenter fixes a potential array underflow in i40e_vc_process_vf_msg().

Dave fixes an e1000e hardware unit hang where the check for pending Tx work
when link is lost was mistakenly moved to be done only when link is first
detected to be lost.  Fixed a problem with poor network performance on
certain silicon in e1000e when configured for 100M HDX performance.

Carolyn adds register defines needed for time sync functions and the code
to call the updated defines.

Jacob adds the ixgbe function for writing PCI config word and checks
whether the adapter has been removed first.

Mark adds the bit __IXGBEVF_REMOVING to indicate that the module is being
removed because the __IXGBEVF_DOWN bit had been overloaded for this
purpose, but leads to trouble.  ixgbevf_down function can now prevent
multiple executions by doing test_and_set_bit on __IXGBEVF_DOWN.

v2:
- dropped patch Mitch's patch "i40evf: correctly program RSS HLUT table"
  based on feedback from Ben Hutchings so that Mitch can re-work the
  patch solution

The following are changes since commit 8cfad496c4257441710735ccef622f3829870164:
  ieee802154: properly unshare skbs in ieee802154 *_rcv functions
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Patch to enable Ethtool/netdev feature flag for NTUPLE control

Carolyn Wyborny (1):
  igb: Add register defines needed for time sync functions

Catherine Sullivan (1):
  i40e/i40evf: Bump build versions

Dan Carpenter (1):
  i40e: potential array underflow in i40e_vc_process_vf_msg()

David Ertman (2):
  e1000e: Fix Hardware Unit Hang
  e1000e: Fix Explicitly set Transmit Control Register

Elizabeth Kappler (1):
  i40e: Refactor and cleanup i40e_open(), adding i40e_vsi_open()

Jacob Keller (1):
  ixgbe: add ixgbe_write_pci_cfg_word with ixgbe_removed check

Jesse Brandeburg (2):
  i40e/i40evf: enable hardware feature head write back
  i40e/i40evf: reduce context descriptors

Mark Rustad (2):
  ixgbevf: Indicate removal state explicitly
  ixgbevf: Protect ixgbevf_down with __IXGBEVF_DOWN bit

Mitch Williams (3):
  i40e: support VF link state ndo
  i40evf: correctly program RSS HLUT table
  i40evf: use min_t

 drivers/net/ethernet/intel/e1000e/netdev.c         | 42 +++++++---
 drivers/net/ethernet/intel/i40e/i40e.h             |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 89 ++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 48 ++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 91 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 48 ++++++++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 23 +++---
 drivers/net/ethernet/intel/igb/e1000_defines.h     | 70 ++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_regs.h        |  9 +++
 drivers/net/ethernet/intel/igb/igb_ptp.c           |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |  6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  9 +++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 18 +++--
 16 files changed, 400 insertions(+), 71 deletions(-)

-- 
1.8.3.1
