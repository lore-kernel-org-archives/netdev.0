From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Wed, 26 Jun 2013 03:55:12 -0700
Message-ID: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12049 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab3FZKzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, e100, igb, and e1000e.

Alex provides a ixgbe patch to use the generic helper pci_vfs_assigned
instead of the ixgbe specific function ixgbe_vfs_are_assigned.

Greg provides 2 ixgbe patches, the first patch retains VLAN filtering
in promiscuous mode because using the new bridge FDB interface to allow
SR-IOV virtual function network devices to communicate with SW bridged
network devices the physical function is placed into promiscuous mode
and hardware VLAN filtering is disabled.  The second patch fixes a typo
where the code should use a bitwise "and" rather than a logical "and".

Andy Shevchenko provides an e100 patch to dump small buffers via %*ph.

Akeem provides three patches against igb.  The first resets the link when
a user enables/disables EEE when link is up.  The second changes register
read to "just-read" without returning a value for hardware to accurately
latch the register value.  His third patch adds rcu_lock to avoid possible
race conditions with igb_update_stats.

Mitch provides a igb patch to fix an issue where MSI-X interrupts are required
for SR-IOV operation/functionality.

Dean (from Redhat) provides a patch to resolve minor merger conflicts.

Wei Yang provides a e1000e patch to remove duplicate assignment of default
Rx/Tx ring size.

The following are changes since commit 8599b52e14a1611dcb563289421bee76751f1d53:
  bonding: add an option to fail when any of arp_ip_target is inaccessible
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (3):
  igb: Reset the link when EEE setting changed
  igb: Read register for latch_on without return value
  igb: Added rcu_lock to avoid race

Alexander Duyck (1):
  ixgbe: Use pci_vfs_assigned instead of ixgbe_vfs_are_assigned

Andy Shevchenko (1):
  e100: dump small buffers via %*ph

Dean Nelson (1):
  e1000e: restore call to pci_clear_master()

Greg Rose (2):
  ixgbe: Retain VLAN filtering in promiscuous + VT mode
  ixgbe: Fix typo

Mitch A Williams (1):
  igb: don't allow SR-IOV without MSI-X

Wei Yang (1):
  e1000e: Remove duplicate assignment of default rx/tx ring size

 drivers/net/ethernet/intel/e100.c              |  15 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c     |   6 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   |   9 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c      |  26 ++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  11 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 101 ++++++++++++++++---------
 8 files changed, 110 insertions(+), 70 deletions(-)

-- 
1.7.11.7
