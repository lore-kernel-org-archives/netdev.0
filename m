From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates 2015-04-10
Date: Fri, 10 Apr 2015 00:53:09 -0700
Message-ID: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199AbbDJHxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and documentation for igb,
ixgbe and ixgb.

Stephen cleans up documentation to igb, ixgbe and ixgb.

Don updates how bridge mode is stored to minimize obfuscation and
makes updates for future silicon easier.  Adds a new bridge mode
support function which gathers all the logic needed to configure
bridge modes.  Adds Source Address Prunning for VEPA bridge mode
for x550 devices.

Vasu adds specific FCoE offloads for x550 for DDP context programming
and increased DDP exchanges.

Alex Duyck cleans up the use of HW_VLAN_CTAG_FILTER in hw_features,
where the driver was actually ignoring the value of the bit and was
just assuming it was always set.  Also cleans up the use of rcu_barrier()
since the driver has not used call_rcu() to free the rings for some
time now.

The following are changes since commit c3d0dac6935e388547d7b7721e80b9c996eb90a1:
  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (2):
  ixgbe: Remove NETIF_F_HW_VLAN_CTAG_FILTER from hw_features
  ixgbe: Drop unnecessary call to rcu_barrier

Don Skidmore (3):
  ixgbe: Move bridge mode from flag to variable
  ixgbe: add new bridge mode support function.
  ixgbe: add support for X550 source_address_prunning

Stephen Hemminger (3):
  igb: doc don't refer to ifconfig
  ixgbe: fix documentation
  ixgb: remove references to ifconfig

Vasu Dev (1):
  ixgbe: adds x550 specific FCoE offloads

 Documentation/networking/igb.txt               |   4 +-
 Documentation/networking/ixgb.txt              |  12 +--
 Documentation/networking/ixgbe.txt             |  14 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c  | 122 +++++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h  |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 107 +++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  13 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c  |  29 ++++++
 10 files changed, 242 insertions(+), 68 deletions(-)

-- 
1.9.3
