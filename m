From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] 10GbE Intel Wired LAN Driver Updates 2017-10-09
Date: Mon,  9 Oct 2017 11:39:50 -0700
Message-ID: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54649 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755211AbdJISkV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Emil fixes an issue where the semaphore bits could be stuck after a reset
or a crash, by adding the clearing of software resource bits in the
software/firmware synchronization register.  Added error checks when we
attempt to identify and initialize the PHY to prevent a crash.  Fixed a
few issues in the logic of ixgbe_clean_test_rings() which was exposed by
a previous commit that was causing a crash in ethtool diagnostics.

Bhumika Goyal fixes a couple of instances which were overlooked when we
made ixgbe_mac_operations constant.

Shannon Nelson fixes an issue to restore normal operations after the
last MACVLAN offload is removed, otherwise we get stuck in a single queue
operations.

The infamous Jesper Dangaard Brouer adds a counter which counts the
number of times the recycle fails and the real page allocator is invoked.

Alex updates the adaptive ITR algorithm to better support the needs of the
network.  This attempt to make it so that our ITR algorithm will try to
prevent either starving a socket buffer for memory in the case of
transmit, or overrunning an receive socket buffer on receive.  We should
function better with new features like XDP which can handle small packets
at high rates without needing to lock us into NAPI polling mode.

The following are changes since commit c49c777f9c87749b73bc888f097f8a4178382449:
  qed: Delete redundant check on dcb_app priority
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (1):
  ixgbe: Update adaptive ITR algorithm

Bhumika Goyal (1):
  ixgbe: declare ixgbe_mac_operations structures as const

Emil Tantilov (6):
  ixgbe: Clear SWFW_SYNC register during init
  ixgbe: add error checks when initializing the PHY
  ixgbe: split Tx/Rx ring clearing for ethtool loopback test
  ixgbe: fix use of uninitialized padding
  ixgbe: fix the FWSM.PT check in ixgbe_mng_present()
  ixgbe: fix crash when injecting AER after failed reset

Jesper Dangaard Brouer (1):
  ixgbe: add counter for times Rx pages gets allocated, not recycled

Shannon Nelson (1):
  ixgbe: restore normal RSS after last macvlan offload is removed

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   9 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  54 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 233 +++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |  19 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    |  14 +-
 7 files changed, 259 insertions(+), 89 deletions(-)

-- 
2.14.2
