From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11 v2][pull request] Intel Wired LAN Driver Updates
Date: Thu, 13 Oct 2011 00:15:01 -0700
Message-ID: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40611 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542Ab1JMHPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 03:15:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe and igb.  This
version of the series contains the following changes:

- ixgbe add FCoE stats, add protection from invalid DMA and fix
  check for change in FCoE priority
- igb version bump, fix sparse warnings and finish up the cleanup
  work of igb by Alex Duyck.

- v2: drop the "igb: move DMA Coalescing feature code into separate function."
  patch while Carolyn fixes the patch based on David Miller's comments.

The following are changes since commit 9687c637388f63b87fcc18eee6e65bcfca4f49ca:
  Merge branch 'for-davem' of git://git.infradead.org/users/linville/wireless-next
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
or
  git://github.com/Jkirsher/net-next.git

Akeem G. Abodunrin (1):
  igb: Loopback functionality supports for i350 devices

Alexander Duyck (5):
  igb: avoid unnecessarily creating a local copy of the q_vector
  igb: Make certain one vector is always assigned in igb_request_irq
  igb: Fix features that are currently 82580 only and should also be
    i350
  igb: Drop unnecessary write of E1000_IMS from igb_msix_other
  igb: Add workaround for byte swapped VLAN on i350 local traffic

Amir Hanania (1):
  ixgbe: Add FCoE DDP allocation failure counters to ethtool stats.

Carolyn Wyborny (1):
  igb: Version bump.

Emil Tantilov (1):
  igb: fix static function warnings reported by sparse

Greg Rose (1):
  ixgbe: Add protection from VF invalid target DMA

Mark Rustad (1):
  ixgbe: Correct check for change in FCoE priority

 drivers/net/ethernet/intel/igb/e1000_82575.c     |   38 +++--
 drivers/net/ethernet/intel/igb/e1000_defines.h   |    1 +
 drivers/net/ethernet/intel/igb/e1000_regs.h      |    1 +
 drivers/net/ethernet/intel/igb/igb.h             |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c        |  112 ++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |   12 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |   44 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h    |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  189 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    2 +
 12 files changed, 324 insertions(+), 84 deletions(-)

-- 
1.7.6.4
