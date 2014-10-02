From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates 2014-10-02
Date: Thu,  2 Oct 2014 03:16:25 -0700
Message-ID: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbaJBKQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k, igb, ixgbe and i40e.

Alex provides two updates to the fm10k driver.  First reduces the buffer
size to 2k for all page sizes, since most frames only have a 1500 MTU
so supporting a buffer size larger than this is somewhat wasteful.
Second fixes an issue where the number of transmit queues was not being
updated, so added the lines necessary to update the number of transmit
queues.

Rick Jones provides two patches to convert ixgbe, igb and i40e to use
dev_consume_skb_any().

Emil provides two patches for ixgbe, first cleans up a couple of wait
loops on auto-negotiation that were not needed.  Second fixes an issue
reported by Fujitsu/Red Hat, which consolidates the logic behind the
dynamically setting of TXDCTL.WTHRESH depending on interrupt throttle
rate (ITR) setting regardless of BQL.

Ethan Zhao provides a cleanup patch for ixgbe where he noticed a
duplicate define.

Bernhard Kaindl provides a patch for igb to remove a source of latency
spikes by not calling code that uses mdelay() for feeding a PHY stat
while being called with a spinlock held.

Todd bumps the igb version based on the recent changes.

The following are changes since commit d068b02cfdfc27f5962ec82ec5568b706f599edc:
  net: phy: add BCM7425 and BCM7429 PHYs
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  fm10k: Reduce buffer size when pages are larger than 4K
  fm10k: Correctly set the number of Tx queues

Bernhard Kaindl (1):
  igb: remove blocking phy read from inside spinlock

Emil Tantilov (2):
  ixgbe: remove wait loop on autoneg for copper devices
  ixgbe: fix setting of TXDCTL.WTRHESH when ITR is set to 0 and no BQL

Ethan Zhao (1):
  ixgbe: delete one duplicate marcro definition of IXGBE_MAX_L2A_QUEUES

Rick Jones (2):
  ixgbe: Convert the normal transmit complete path to
    dev_consume_skb_any()
  i40e/igb: Convert to dev_consume_skb_any()

Todd Fujinaka (1):
  igb: bump version to 5.2.15

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  8 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  6 +++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |  2 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h        |  5 ---
 drivers/net/ethernet/intel/igb/igb.h             |  1 -
 drivers/net/ethernet/intel/igb/igb_main.c        | 16 ++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  6 +---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     | 41 ------------------------
 10 files changed, 12 insertions(+), 77 deletions(-)

-- 
1.9.3
