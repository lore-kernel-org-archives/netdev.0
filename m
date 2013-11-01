From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri,  1 Nov 2013 06:56:44 -0700
Message-ID: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab3KAN4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, igb, ixgbe and ixgbevf.

Hong Zhiguo provides a fix for e1000 where tx_ring and adapter->tx_ring
are already of type "struct e1000_tx_ring" so no need to divide by
e1000_tx_ring size in the idx calculation.

Emil provides a fix for ixgbevf to remove a redundant workaround related
to header split and a fix for ixgbe to resolve an issue where the MTA table
can be cleared when the interface is reset while in promisc mode.

Todd provides a fix for igb to prevent ethtool from writing to the iNVM
in i210/i211 devices.  This issue was reported by Marek Vasut <marex@denx.de>.

Anton Blanchard provides a fix for ixgbe to reduce memory consumption
with larger page sizes, seen on PPC.

Don provides a cleanup in ixgbe to replace the IXGBE_DESC_UNUSED macro with
the inline function ixgbevf_desc_unused() to make the logic a bit more
readable.

The following are changes since commit ba4865027c11d7ac8e5a33e0624dd415caab2027:
  ipv6: remove the unnecessary statement in find_match()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anton Blanchard (1):
  ixgbe: Reduce memory consumption with larger page sizes

Don Skidmore (1):
  ixgbe: cleanup IXGBE_DESC_UNUSED

Emil Tantilov (2):
  ixgbevf: remove redundant workaround
  ixgbe: fix inconsistent clearing of the multicast table

Fujinaka, Todd (1):
  igb: Don't let ethtool try to write to iNVM in i210/i211

Hong Zhiguo (1):
  e1000: fix wrong queue idx calculation

 drivers/net/ethernet/intel/e1000/e1000_main.c     |  3 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |  4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  4 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 15 +++++++--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 10 +++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 19 +++++--------------
 6 files changed, 27 insertions(+), 28 deletions(-)

-- 
1.8.3.1
