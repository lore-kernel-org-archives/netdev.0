From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11 v2][pull request] Intel Wired LAN Driver Updates
Date: Tue, 11 Oct 2011 08:45:41 -0700
Message-ID: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52698 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694Ab1JKPpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e and igb.  This
version of the series contains the following changes:

- Added the e1000e bug fix patch
- Dropped the igb patch "igb: Use node specific allocations for
  the q_vectors and rings" based on feedback

Based on the feedback, I am working on re-working the igb patch that
was dropped in this series and will re-submit it later on.

The remain 10 igb patches are unchanged from the previous pull request
and are the continuation of the cleanups and refactoring that Alex has done.
After this series there are 4-5 more patches to complete the work
that Alex has done on igb.

The following are changes since commit 3ed6f6958c0ac21958285d8648f14d34da4bbcb3:
  ll_temac: convert to SKB paged frag API.
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
or
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (10):
  igb: push data into first igb_tx_buffer sooner to reduce stack usage
  igb: avoid unnecessary conversions from u16 to int
  igb: Consolidate all of the ring feature flags into a single value
  igb: Move ITR related data into work container within the q_vector
  igb: cleanup IVAR configuration
  igb: retire the RX_CSUM flag and use the netdev flag instead
  igb: leave staterr in place and instead us a helper function to check
    bits
  igb: fix recent VLAN changes that would leave VLANs disabled after
    reset
  igb: move TX hang check flag into ring->flags
  igb: add support for NETIF_F_RXHASH

Bruce Allan (1):
  e1000e: locking bug introduced by commit 67fd4fcb

 drivers/net/ethernet/intel/e1000e/e1000.h      |    1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |   21 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |    3 +
 drivers/net/ethernet/intel/igb/igb.h           |   50 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   14 +-
 drivers/net/ethernet/intel/igb/igb_main.c      |  595 ++++++++++++------------
 6 files changed, 347 insertions(+), 337 deletions(-)

-- 
1.7.6.4
