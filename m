From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/10][pull request] Intel Wired LAN Driver Updates 2013.02.15
Date: Fri, 15 Feb 2013 02:03:59 -0800
Message-ID: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890Ab3BOKEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:04:14 -0500
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

v2: updated patches 4 & 5 based on feedback from Ben Hutchings and Eric
    Dumazet

The following are changes since commit 9754e293491e3a4e6c1ac020d25140b1ed3d9cd2:
  net: Don't write to current task flags on every packet received.
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
  igb: Refix sparse warning in igb_get_i2c_client

Emil Tantilov (1):
  ixgbe: refactor initialization of feature flags

 drivers/net/ethernet/intel/igb/e1000_82575.c  | 488 ++++++++++++++------------
 drivers/net/ethernet/intel/igb/igb.h          |  21 +-
 drivers/net/ethernet/intel/igb/igb_main.c     | 228 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  58 +--
 4 files changed, 495 insertions(+), 300 deletions(-)

-- 
1.7.11.7
