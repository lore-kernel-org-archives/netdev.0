From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/14][pull request] Intel Wired LAN Driver Updates
Date: Wed, 24 Apr 2013 21:08:33 -0700
Message-ID: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15281 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab3DYEIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:08:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, igb and pci.

The ixgbe changes contains a fix to a possible divide by zero by bailing
out of the ixgbe_update_itr() function if the last interrupt timeslice is
zero.  In addition, support is added for the new OCP x520 adapter as well
as LX support for 82599 devices.  Jacob provides a patch to change
variable wol_supported to wol_enabled to better reflect what the code
is actually doing (i.e. checking if WoL is enabled).

Alex adds SRIOV helper function to pci that will determine if a PF
has any VFs that are currently assigned to a guest.

The remaining 8 patches are against igb and contain the following changes:
* implement SERDES loopback configuration for i210 devices by unsetting
  sigdetect bit, so as to fix Ethtool loopback test failure
* add support for the SMBI semaphore for I210/I211 devices
* implement the new generic pci_vfs_assigned helper function (Alex's PCI
  helper function)
* display warning when link speed is downgraded due to Smartspeed
* ensure that VLAN hardware filtering remains enabled when the device is
  in promiscuous mode and VT mode simultaneously
* cleanup dead code in igb
* bump the driver version

v2: updated the PCI patch to add SRIOV helper function to remove extern
    from the declaration of pci_vfs_assigned in pci.h and return 0 if
    SR-IOV is disabled which is inline with other PCI SR-IOV functions

The following are changes since commit 01f27fc085574b301248d4da241e9d5ebd61e5c9:
  Merge branch 'bnx2x'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: SERDES loopback sigdetect bit on i210 devices

Alexander Duyck (2):
  pci: Add SRIOV helper function to determine if VFs are assigned to
    guest
  igb: Use pci_vfs_assigned instead of igb_vfs_are_assigned

Carolyn Wyborny (2):
  igb: Remove id's that will not be productized for Linux.
  igb: Bump version of driver

Don Skidmore (3):
  ixgbe: fix possible divide by zero in ixgbe_update_itr
  ixgbe: add driver support for x520 OCP adapter.
  ixgbe: add SFP+ LX module support

Emil Tantilov (1):
  ixgbe: add WOL support for new subdevice ID

Greg Rose (1):
  igb: Retain HW VLAN filtering while in promiscuous + VT mode

Jacob Keller (1):
  ixgbe: rename wol_supported to more fitting wol_enabled

Koki Sanagi (1):
  igb: display a warning message when SmartSpeed works

Matthew Vick (2):
  igb: Add SMBI semaphore to I210/I211
  igb: Remove dead code path

 drivers/net/ethernet/intel/igb/e1000_82575.c     |   9 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h        |   3 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c      |  65 ++++++++-----
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   9 +-
 drivers/net/ethernet/intel/igb/igb_main.c        | 117 +++++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  16 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |  21 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   6 +-
 drivers/pci/iov.c                                |  41 ++++++++
 include/linux/pci.h                              |   5 +
 12 files changed, 212 insertions(+), 94 deletions(-)

-- 
1.7.11.7
