From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 21 Mar 2014 05:09:50 -0700
Message-ID: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45856 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965459AbaCUMKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, ixgbe, ixgbevf, i40e and i40evf.

Anjali provides a i40e/i40evf patch to add Energy Efficient Ethernet
Low Power Idle stats and a fix for i40e to change the string
"Side Band" to "Sideband" for consistency.

Mitch provides 2 patches for i40evf to fix if the driver encounters
an error while communicating with the PF driver, do not shut down the
admin queue unconditionally.  Add an error message when the admin
queue message never completes and fix formatting on another message
that was unnecessarily wrapped.

Mark provides a ixgbe patch and five ixgbevf patches.  Fix a possible
infinite recursion when an adapter is removed and registers all read
as all one's in ixgbe_clear_vmdq_generic() and ixgbe_clear_rar_generic().
Converts macros to static inline functions to align kernel coding standard
and prepare for adding Live Error Recovery (LER) to ixgbevf.  Change the
ethtool register test to use the normal register accessor functions and
eliminate macors used for calling register test functions to make error
exits more clear.  Checks all register reads for adapter removal by checking
the status register after any register read that returns all F's since the
status register will never return 0xFFFFFFFF unless the adapter is removed.

Jacob implements SIOCGHWTSTAMP ioctl for igb which enables user processes
to read the current hardware stamp config settings non-destructively.

Todd adds the initial register read and write for surprise removal (LER)
for igb.

Christian Engelmayer fixes an igb memory leak in the igb_get_module_eeprom()
error handling path.

Ken Ichikawa provides a fix for igb, specifically for 82575 hardware to
specify -1 to the phc_index for ethtool's get_ts_info, otherwise a wrong
value will be set to the phc_index.

Christopher Paasch fixes a null pointer dereference in igb and makes sure
to unset the HAS_MSIX flag when the driver falls back to MSI only.

The following are changes since commit a85ae0e97879f51bccd8511668b07d346d98b3eb:
  Merge branch 'bcmgenet-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e/i40evf: Add EEE LPI stats
  i40e: Fix a message string

Christian Engelmayer (1):
  igb: Fix memory leak in igb_get_module_eeprom()

Christoph Paasch (2):
  igb: Fix Null-pointer dereference in igb_reset_q_vector
  igb: Unset IGB_FLAG_HAS_MSIX-flag when falling back

Fujinaka, Todd (1):
  igb: add register rd/wr for surprise removal

Jacob Keller (1):
  igb: implement SIOCGHWTSTAMP ioctl

Ken ICHIKAWA (1):
  igb: specify phc_index of 82575 for get_ts_info

Mark Rustad (6):
  ixgbe: Break recursion in case of removal
  ixgbevf: Use static inlines instead of macros
  ixgbevf: Make the ethtool register test use accessors
  ixgbevf: Check register reads for adapter removal
  ixgbevf: Check for adapter removal on register writes
  ixgbevf: Additional adapter removal checks

Mitch Williams (2):
  i40evf: don't shut down admin queue on error
  i40evf: clean up init error messages

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |   5 +
 drivers/net/ethernet/intel/i40e/i40e_main.c       |  17 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h       |   5 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h     |   5 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   9 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h       |  21 +++-
 drivers/net/ethernet/intel/igb/igb.h              |   5 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |  14 ++-
 drivers/net/ethernet/intel/igb/igb_main.c         |  33 ++++-
 drivers/net/ethernet/intel/igb/igb_ptp.c          |  46 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |   3 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 141 ++++++++++++++--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   6 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  68 ++++++++++-
 drivers/net/ethernet/intel/ixgbevf/regs.h         |  12 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  33 ++++-
 16 files changed, 321 insertions(+), 102 deletions(-)

-- 
1.8.3.1
