From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 21 May 2014 05:00:58 -0700
Message-ID: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20362 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbaEUMBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Shannon makes minor changes to the AdminQ interface to bring it up to
date.  Removes the hard coding of stats struct size in ethtool, in prep
for adding data fields which are configuration dependent.

Catherine removes some unused and unneeded PCI bus defines.

Jesse fixes the copyright headers and finishes up the removal of the PTP
Tx work functionality which allows us to rely on the Tx timesync interrupt.

Mitch provides a number of fixes and cleanups for i40e/i40evf based on
suggestions from Ben Hutchings.  First is to use a macro parameter for
ethtool stats instead of just assuming that a valid netdev variable
exists.  Second is not to tell ethtool that the VF can do 10GbaseT, when
it really has no idea what its link speed is, so set the supported value
to 0 instead.  Make the ethtool_ops structure constant since it is
extremely unlikely to change at runtime.  Ethtool consistently reports
0 values for our ITR settings because we never actually use them, so
fix this by setting the default values to the specified default values.

Greg avoids a compile error by wrapping the call to i40e_alloc_vfs() in
CONFIG_PCI_IOV because the function itself is wrapped in the same
conditional compile block.

Alexander Gordeev updates the driver to use the new pci_enable_msi_range()
and pci_enable_msix_range() or pci_enable_msi_exact() and
pci_enable_msix_exact().

Jean Sacren provides a fix where the wrong error code was being passed to
i40e_open().

The following are changes since commit b6052af61a9e0dee236bcf4c69843126c0d28e4f:
  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Gordeev (1):
  i40evf: Use pci_enable_msix_range() instead of pci_enable_msix()

Catherine Sullivan (1):
  i40evf: Remove unused defines

Greg Rose (1):
  i40e: Check PCI_IOV config to avoid compile error

Jean Sacren (1):
  i40e: fix passing wrong error code to i40e_open()

Jesse Brandeburg (2):
  i40evf: Fix the headers and update copyright year.
  i40e: remove Tx work for ptp

Mitch Williams (7):
  i40e: add required include
  i40evf: Use macro param for ethtool stats
  i40evf: don't lie to ethtool
  i40evf: make ethtool_ops const
  i40e/i40evf: set proper default for ITR registers
  i40e/i40evf: control auto ITR through ethtool
  i40e: Don't disable SR-IOV when VFs are assigned

Shannon Nelson (2):
  i40evf: Update AdminQ interface
  i40e: remove hardcode of stats struct size in ethtool

 drivers/net/ethernet/intel/i40e/i40e.h             |  4 --
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 63 +++++++---------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  8 ++-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  1 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++-
 drivers/net/ethernet/intel/i40evf/Makefile         |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  5 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 27 ++++---
 drivers/net/ethernet/intel/i40evf/i40e_alloc.h     |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h     |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_register.h  |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_status.h    |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  3 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  5 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 12 +---
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  5 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  3 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 84 +++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 40 +++++------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  3 +
 26 files changed, 179 insertions(+), 146 deletions(-)

-- 
1.9.0
