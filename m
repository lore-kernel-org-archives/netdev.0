From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/8][pull request] Intel Wired LAN Driver Updates
Date: Wed, 27 Nov 2013 23:35:54 -0800
Message-ID: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37634 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab3K1Hgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, e1000 and ixgbe.

Akeem provides a igb fix where WOL was being reported as supported on
some ethernet devices which did not have that capability.

Carolyn provides a igb fix to add a call to dev_close if the queue
reinit fails in order to make it clear to the user that the device is
down.

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

The following are changes since commit 2c7a9dc1641664173211c4ebc5db510a08684c46:
  be2net: Avoid programming permenant MAC by BE3-R VFs
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Akeem G Abodunrin (1):
  igb: Fixed Wake On LAN support

Carolyn Wyborny (1):
  igb: Update queue reinit function to call dev_close when init of
    queues fails

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
 drivers/net/ethernet/intel/igb/igb_main.c     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  9 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h  |  1 -
 7 files changed, 39 insertions(+), 49 deletions(-)

-- 
1.8.3.1
