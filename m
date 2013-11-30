From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 0/7][pull request] Intel Wired LAN Driver Updates
Date: Sat, 30 Nov 2013 01:20:14 -0800
Message-ID: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56959 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988Ab3K3JUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Nov 2013 04:20:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, e1000 and ixgbe.

Akeem provides a igb fix where WOL was being reported as supported on
some ethernet devices which did not have that capability.

Yanjun provides a fix for e1000 which is similar to a previous fix
for e1000e commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is
being closed and reset simultaneously"), where the same issue was
observed on the older e1000 cards.

Vladimir Davydov provides 2 e1000 fixes.  The first fixes a lockdep
warning e1000_down() tries to synchronously cancel e1000 auxiliary
works (reset_task, watchdog_task, phy_info_task and fifo_stall_task)
which take adapter->mutex in their handlers.  The second patch is to
fix a possible race condition where reset_task() would be running
after adapter down.

John provides 2 fixes for ixgbe.  First turns ixgbe_fwd_ring_down
to static and the second disables NETIF_F_HW_L2FW_DOFFLOAD by default
because it allows upper layer net devices to use queues in the hardware
to directly submit and receive skbs.

Mark Rustad provides a single patch for ixgbe to make
ixgbe_identify_qsfp_module_generic static to resolve compile
warnings.

v2: Drop igb patch "igb: Update queue reinit function to call dev_close
    when init of queues fails" from Carolyn, so that the solution can
    be re-worked based on feedback from David Miller.

The following are changes since commit f1d8cba61c3c4b1eb88e507249c4cb8d635d9a76:
  inet: fix possible seqlock deadlocks
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Akeem G Abodunrin (1):
  igb: Fixed Wake On LAN support

John Fastabend (2):
  ixgbe: ixgbe_fwd_ring_down needs to be static
  ixgbe: turn NETIF_F_HW_L2FW_DOFFLOAD off by default

Mark Rustad (1):
  ixgbe: Make ixgbe_identify_qsfp_module_generic static

Vladimir Davydov (2):
  e1000: fix lockdep warning in e1000_reset_task
  e1000: fix possible reset_task running after adapter down

yzhu1 (1):
  e1000: prevent oops when adapter is being closed and reset
    simultaneously

 drivers/net/ethernet/intel/e1000/e1000.h      |  7 +++-
 drivers/net/ethernet/intel/e1000/e1000_main.c | 60 ++++++++++-----------------
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |  7 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  9 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h  |  1 -
 6 files changed, 38 insertions(+), 49 deletions(-)

-- 
1.8.3.1
