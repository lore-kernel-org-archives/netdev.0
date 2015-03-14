From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queue 0/7][pull request] Intel Wired LAN Driver Updates 2015-03-13
Date: Fri, 13 Mar 2015 17:00:41 -0700
Message-ID: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19110 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbbCNAAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Don adds additional support for X550 MAC types, which require additional
steps around enabling and disabling Rx.  Also cleans up variable type
inconsistency.

I provide a patch to allow relaxed ordering to be enabled on SPARC
architectures.  Also cleans up ixgbevf whitespace and code comments to
align the driver with networking coding standard.  Lastly cleaned up
uses of memcpy() where ether_addr_copy() could have been used.

Alex removes some dead code in the ixgbe cleanup patch.

The following are changes since commit 2801be4a0ea4cd0965f9c12ff813a91892a8e157:
  Merge branch 'bcmgenet_xmit_more'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (1):
  ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since it doesn't do anything

Don Skidmore (3):
  ixgbe: add new wrapper for X550 support
  ixgbe: Clean up type inconsistency
  ixgbe: cleanup make ixgbe_set_ethertype_anti_spoofing_X550 static

Jeff Kirsher (3):
  ixgbe: enable relaxed ordering for SPARC
  ixgbevf: Fix code comments and whitespace
  ixgbevf: Use ether_addr_copy() instead of memcpy()

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  56 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  26 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  47 +++-
 drivers/net/ethernet/intel/ixgbevf/defines.h      | 285 +++++++++++-----------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  86 +++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  82 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 229 +++++++++--------
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |  43 ++--
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  93 ++++---
 drivers/net/ethernet/intel/ixgbevf/regs.h         | 105 ++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  63 +++--
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  15 +-
 19 files changed, 636 insertions(+), 536 deletions(-)

-- 
1.9.3
