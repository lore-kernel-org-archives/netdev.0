From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8 v2][pull request] Intel Wired LAN Driver Updates
Date: Fri, 23 Sep 2011 09:12:39 -0700
Message-ID: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35014 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab1IWQS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 12:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe and PCI.  The PCI patch
is a small update to add a flag to indicate when a device has been
assigned by KVM.  The ixgbe patches consist of the following:

  - reconfigure SR-IOV init to take advantage of the new pci flag
  - DCB cleanups/fixes
  - add WOL support for x540
  - a few cleanup/fixes

 -v2 Fixed up comment in the PCI patch based on feedback from Ian Campbell

The following are changes since commit 9c9b1f24f2aa31a3cea94939edc551f68ebadc89:
  net/phy: add IC+ IP101A and support APS.
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Don Skidmore (1):
  ixgbe: cleanup X540 interrupt enablement

Emil Tantilov (3):
  ixgbe: avoid HW lockup when adapter is reset with Tx work pending
  ixgbe: add WOL support for X540
  ixgbe: remove global reset to the MAC

Greg Rose (2):
  pci: Add flag indicating device has been assigned by KVM
  ixgbe: Reconfigure SR-IOV Init

John Fastabend (2):
  ixgbe: DCB, do not call set_state() from IEEE mode
  ixgbe: dcb, set priority to traffic class mappings

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |   15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  145 +++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c     |   36 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h     |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |   57 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   13 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  141 ++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  207 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h   |    5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   10 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |   31 +---
 include/linux/pci.h                              |    2 +
 virt/kvm/assigned-dev.c                          |    2 +
 virt/kvm/iommu.c                                 |    4 +
 17 files changed, 443 insertions(+), 245 deletions(-)

-- 
1.7.6.2
