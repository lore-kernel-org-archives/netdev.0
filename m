From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/10][pull request] Intel Wired LAN Driver Updates
Date: Wed, 12 Mar 2014 19:31:20 -0700
Message-ID: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42803 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbaCMCb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, e1000e, ixgbe and ixgbevf.

Tom Herbert provides changes to e1000e, igb and ixgbe to call skb_set_hash()
to set the hash and its type in an skbuff.

Carolyn provides a fix for igb where using ethtool for EEE settings, which
was not working correctly.

Jacob provides some trivial cleanups and fixes for ixgbe which mainly
dealt with the file headers.

Julia Lawall provides a one fix for ixgbevf where the driver did not need
to adjust the power state on suspend, so the call to pci_set_power_state()
in the resume function was a no-op.

v2:
- dropped patches 4-6 from original series which implemented debugfs for
  igb from Carolyn based on feed back from David Miller and Or Gerlitz

The following are changes since commit 8a83d9396a4945dcaa129b14a725311e5846b2d5:
  Merge branch 'dev_kfree_skb_any'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (1):
  igb: Fix for devices using ethtool for EEE settings

Jacob Keller (4):
  ixgbe: move setting rx_pb_size into get_invariants
  ixgbe: add Linux NICS mailing list to contact info
  ixgbe: fixup header for ixgbe_set_rxpba_82598
  ixgbe: fix some multiline hw_dbg prints

Julia Lawall (1):
  ixgbevf: delete unneeded call to pci_set_power_state

Masanari Iida (1):
  ixgbe: Fix format string in ixgbe_fcoe.c

Tom Herbert (3):
  net: e1000e calls skb_set_hash
  net: igb calls skb_set_hash
  net: ixgbe calls skb_set_hash

 drivers/net/ethernet/intel/e1000e/netdev.c         |  2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h       |  1 +
 drivers/net/ethernet/intel/igb/igb.h               |  3 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c       | 45 ++++++++-----
 drivers/net/ethernet/intel/igb/igb_main.c          | 73 +++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     | 18 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     | 11 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |  3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  1 -
 29 files changed, 132 insertions(+), 51 deletions(-)

-- 
1.8.3.1
