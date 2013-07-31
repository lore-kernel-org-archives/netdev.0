From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 31 Jul 2013 02:59:22 -0700
Message-ID: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org
To: davem@davemloft.net, bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series contains updates to ixgbe and pci.

The first patch for ixgbe from Greg Rose is the second submission.  The
first submission of "ixgbe: Retain VLAN filtering in promiscuous + VT
mode" had a typo, which Joe Perches pointed out and is fixed in this
submission.

Alex updates the ixgbe driver to use the generic helper pci_vfs_assigned
instead of the driver specific function ixgbe_vfs_are_assigned.

Don Skidmore provides 4 patches for ixgbe, the first being a fix for
flow control ethtool reporting.  Originally ixgbe_device_supports_autoneg_fc()
was expected to be called by only copper devices, which lead to false
information being displayed via ethtool.  Two other patches add support
for fixed fiber for SFP+ devices and the addition of a quad-port x520
adapter.  The last patch simply bumps the driver version.

Emil Tantilov provides 3 fixes for ixgbe, two of which resolve
semaphore lock issues.  The third fix resolves several issues in the
previous implementation of the SFF data dumps of SFP+ modules.

The remaining ixgbe and pci patches are from Jacob Keller.  The pci
patches exposes bus speed, link speed and bus width so that drivers
can take advantage of this information.  In addition, adds a pci function
which obtains minimum link width and speed.  Jacob also provides the
ixgbe patch to incorporate the pci function. He provides a patch that
fixes a lockdep issue created due to ixgbe_ptp_stop always running
cancel_work_sync even if the work item had not been created properly with
INIT_WORK. This issue was found and reported by Stephen Hemminger.

-v2-
* fix patch 3 to be a bool function based on David Miller's feedback
* fix patch 4 debug message based on David Miller's feedback
* fix patch 8 moved the extern declarations to pci.h based on Bjorn
  Helgaas's feedback
* fix patch 11 update the error message to include encoding loss based
* fix patch 8/9/10 title based on Bjorn's feedback

The following are changes since commit 60ff779c4abba37a31bd8624ef45026f7fb1b70c:
  9p: client: remove unused code and any reference to "cancelled" function
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbe: Use pci_vfs_assigned instead of ixgbe_vfs_are_assigned

Don Skidmore (4):
  ixgbe: fix fc autoneg ethtool reporting.
  ixgbe: add new media type.
  ixgbe: bump version number
  ixgbe: add support for quad-port x520 adapter

Emil Tantilov (3):
  ixgbe: fix semaphore lock for I2C read/writes on 82598
  ixgbe: fix SFF data dumps of SFP+ modules
  ixgbe: clear semaphore bits on timeouts

Greg Rose (1):
  ixgbe: Retain VLAN filtering in promiscuous + VT mode

Jacob Keller (6):
  PCI: expose pcie_link_speed and pcix_bus_speed arrays
  PCI: move enum pcie_link_width into pci.h
  PCI: Add function to obtain minimum link width and speed
  ixgbe: call pcie_get_mimimum_link to check if device has enough
    bandwidth
  ixgbe: fix lockdep annotation issue for ptp's work item
  ixgbe: rename LL_EXTENDED_STATS to use queue instead of q

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |  34 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   | 240 +++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  90 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  94 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 167 +++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     | 470 ++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h     |  41 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   | 101 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  12 +
 drivers/pci/pci.c                                |  43 +++
 drivers/pci/pci.h                                |   3 +
 drivers/pci/probe.c                              |   4 +-
 include/linux/pci.h                              |  15 +
 include/linux/pci_hotplug.h                      |  13 -
 17 files changed, 1001 insertions(+), 347 deletions(-)

-- 
1.7.11.7
