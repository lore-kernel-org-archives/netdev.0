From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/19][pull request] Intel Wired LAN Driver Updates 2015-09-01
Date: Tue,  1 Sep 2015 18:13:44 -0700
Message-ID: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581AbbIBBOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, ixgbe and ixgbevf.

Anjali fixes a bug in i40e where the port is not receiving multicast or VLAN
tagged packets in promiscuous mode.  Which can occur when a software bridge
is created on top of the device.

Don adds support in ixgbe that indicates the presence of management firmware.
Added support for entering low power link up state on devices that support
it when the device is closing or suspending.  Updated the driver to report
unknown bus speed and width since IOSF does not report a PCIe bus speed or
width for X550 devices.  Also added the new bus type for integrated I/O
interface (IOSF).  Cleaned up of redundant code in ixgbe.

Mark adds support for UDP-encapsulation transmit checksum and for VXLAN
receive offloads.  Introduces a helper function to do the register access
and processing to avoid needless PHY access on copper PHYs.  Added support
for reporting 2.5G link speed.  Fixed warnings resulting from redundant
initializations of the get_bus_info field.

Maninder Singh updates the ixgbe driver to use kzalloc instead of kcalloc
for allocation of one thing.

Tom Barbette adds support for ethtool to change the rxfh indirection table
and/or key using ethtool interface.

Emil resolves an issue where users were not able to dynamically set number
of queues for 82598 via ethtool -L.

Alex Williamson removes bimodal SR-IOV disabling behavior since it is
confusing to users and results in a state where the PF is broken for other
uses unless the user sets sriov_numvfs to zero prior to unbinding the
device.

The following are changes since commit 63b6c13dbb7d3e36f031629f7e4e86dacfcab8cf:
  tun_dst: Remove opts_size
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alex Williamson (1):
  ixgbe: Remove bimodal SR-IOV disabling

Anjali Singhai Jain (1):
  i40e: Set defport behavior for the Main VSI when in promiscuous mode

Don Skidmore (8):
  ixgbe: add new function to check for management presence
  ixgbe: Assign set_phy_power dynamically where needed
  ixgbe: Add support for entering low power link up state
  ixgbe: add get_bus_info method for X550
  ixgbe: add new bus type for intergrated I/O interface (IOSF)
  ixgbe: Remove unused PCI bus types
  ixgbe: Remove second instance of lan_id variable
  ixgbe: cleanup to use cached mask value

Emil Tantilov (1):
  ixgbe: fix bounds checking in ixgbe_setup_tc for 82598

Maninder Singh (1):
  ixgbe: use kzalloc for allocating one thing

Mark Rustad (6):
  ixgbe: Check whether FDIRCMD writes actually complete
  ixgbe: Add support for UDP-encapsulated tx checksum offload
  ixgbe: Add support for VXLAN RX offloads
  ixgbe: Avoid needless PHY access on copper phys
  ixgbe: Add support for reporting 2.5G link speed
  ixgbe: Resolve "initialized field overwritten" warnings

Tom Barbette (1):
  ixgbe: support for ethtool set_rxfh

 drivers/net/ethernet/intel/i40e/i40e.h           |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  37 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  89 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  15 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  54 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 251 ++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |  75 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  55 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 182 +++++++++++++++-
 12 files changed, 633 insertions(+), 139 deletions(-)

-- 
2.4.3
