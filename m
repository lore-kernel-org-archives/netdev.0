From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Wed, 23 Apr 2014 04:15:12 -0700
Message-ID: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbaDWLPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf, e1000e, igb and i40e.

Jacob converts the ixgbe low_water into an array which allows the
algorithm to output different values for different TCs and we can
distinguish between them.  Removes vlan_filter_disable() and
vlan_filter_enable() in ixgbe so that we can do the work directly in
set_rx_mode().  Changes the setting of multicast filters only when
the interface is not in promiscuous mode for multicast packets in
ixgbe.  Improves MAC filter handling by adding mac_table API based
on work done for igb, which includes functions to add/delete MAC
filters.

Mark changes register reads in ixgbe to an out-of-line function since
register reads are slow.

Emil provides a ixgbevf patch to update the driver description since
it supports more than just 82599 parts now.

David provides several cleanup patches for e1000e which resolve some
checkpatch issues as well as changing occurrences of returning 0 or 1 in
bool functions to returning true false or true.

Carolyn provides several cleanup patches for igb which fix checkpatch
warnings.

Mitch provides a fix for i40evf where the driver would correctly allow
the virtual function link state to be controlled by 'ip set link', but
would not report it correctly back.  This is fixed by filling out
the appropriate field in the VF info struct.

The following are changes since commit fd0d192be6e814495aec91f357b5801afc3b6262:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (3):
  igb: Cleanups for messaging
  igb: Cleanups to fix braces location warnings
  igb: Cleanups to fix incorrect indentation

David Ertman (4):
  e1000e: Cleanup return values in ethtool
  e1000e: Cleanup to fix checkpatch missing blank lines
  e1000e: Cleanup checkpatch extra space
  e1000e: Cleanup use of deprecated DEFINE_PCI_DEVICE_TABLE

Emil Tantilov (1):
  ixgbevf: remove 82599 from the module description

Jacob Keller (4):
  ixgbe: convert low_water into an array
  ixgbe: remove vlan_filter_disable and enable functions
  ixgbe: change handling of multicast filters
  ixgbe: improve mac filter handling

Mark Rustad (1):
  ixgbe: Use out-of-line function for register reads

Mitch Williams (1):
  i40e: report VF link state correctly

 drivers/net/ethernet/intel/e1000e/e1000.h          |   8 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c        |  11 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |   1 +
 drivers/net/ethernet/intel/e1000e/netdev.c         |  19 +-
 drivers/net/ethernet/intel/e1000e/nvm.c            |   1 +
 drivers/net/ethernet/intel/e1000e/param.c          |   4 +
 drivers/net/ethernet/intel/e1000e/phy.c            |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   7 +
 drivers/net/ethernet/intel/igb/e1000_82575.c       |  24 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h       |  22 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  25 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h          |  50 ++--
 drivers/net/ethernet/intel/igb/e1000_mac.c         |  10 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c         |   1 +
 drivers/net/ethernet/intel/igb/e1000_nvm.h         |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c         |   3 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h        |   7 +-
 drivers/net/ethernet/intel/igb/igb.h               |   1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  24 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |  74 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |  18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |  27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  35 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |  15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      |   2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 319 +++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  49 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   2 +-
 32 files changed, 478 insertions(+), 292 deletions(-)

-- 
1.9.0
