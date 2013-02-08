From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Fri,  8 Feb 2013 02:39:08 -0800
Message-ID: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38916 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964773Ab3BHKja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 05:39:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbe.  Most of the changes
are against igb, except for one patch against ixgbe.

There are 3 igb fixes from Carolyn which were reported by Dan
Carpenter which resolve issues found in the get_i2c_client().  Alex
does some cleanup of the igb driver to match similar functionality
in ixgbe on transmit.  Alex also makes it so that we can enable the use
of build_skb for cases where jumbo frames are disabled.  The advantage
to this is that we do not have to perform a memcpy to populate the header
and as a result we see a significant performance improvement.

Akeem provides 4 patches to initialize function pointers and do a
re-factoring of the function pointers in igb_get_variants() to assist
with driver debugging.

The ixgbe patch comes from Emil to reshuffle the switch/case structure
of the flag assignment to allow for the flags to be set for each MAC
type separately. This is needed for new hardware that does not have feature
parity with older hardware.

The following are changes since commit b285109dde7b873b5dc671ef1b3ae3090f4bc72f:
  Merge branch 'tg3'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (4):
  igb: Initialize PHY function pointers
  igb: Initialize NVM function pointers
  igb: Intialize MAC function pointers
  igb: Refractoring function pointers in igb_get_invariants function

Alexander Duyck (2):
  igb: Support using build_skb in the case that jumbo frames are
    disabled
  igb: Update igb to use a path similar to ixgbe to determine when to
    stop Tx

Carolyn Wyborny (3):
  igb: Fix for improper exit in igb_get_i2c_client
  igb: Fix for improper allocation flag in igb_get_i2c_client
  igb: Fix for sparse warning in igb_get_i2c_client

Emil Tantilov (1):
  ixgbe: refactor initialization of feature flags

 drivers/net/ethernet/intel/igb/e1000_82575.c  | 488 ++++++++++++++------------
 drivers/net/ethernet/intel/igb/igb.h          |  21 +-
 drivers/net/ethernet/intel/igb/igb_main.c     | 230 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  58 +--
 4 files changed, 497 insertions(+), 300 deletions(-)

-- 
1.7.11.7
