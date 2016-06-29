From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2016-06-29
Date: Wed, 29 Jun 2016 14:32:47 -0700
Message-ID: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42568 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbcF2VdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates and fixes to e1000e, igb, ixgbe and fm10k.  A
true smorgasbord of changes.

Jake cleans up some obscurity by not using the BIT() macro on bitshift
operation and also fixed the calculated index when looping through the
indir array.  Fixes the issue with igb's workqueue item for overflow
check from causing a surprise remove event.  The ptp_flags variable is
added to simplify the work of writing several complex MAC type checks
in the PTP code while fixing the workqueue.

Alex Duyck fixes the receive buffers alignment which should not be L1
cache aligned, but to 512 bytes instead.

Denys Vlasenko prevents a division by zero which was reported under
VMWare for e1000e.

Amritha fixes an issue where filters in a child hash table must be
cleared from the hardware before delete the filter links in ixgbe.

Bhaktipriya Shridhar simply replaces the deprecated create_workqueue()
with alloc_workqueue() for fm10k.

Tony corrects ixgbe ethtool reporting to show x550 supports hardware
timestamping of all packets.

Emil fixes an issue where MAC-VLANs on the VF fail to pass traffic due
to spoofed packets.

Andrew Lunn increases performance on some systems where syncing a buffer
for DMA is expensive.  So rather than sync the whole 2K receive buffer,
only synchronize the length of the frame.

The following are changes since commit 6f30e8b022c8e3a722928ddb1a2ae0be852fcc0e:
  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (1):
  fm10k: Align Rx buffers to 512B blocks

Amritha Nambiar (2):
  ixgbe: Fix deleting link filters for cls_u32 offloads
  ixgbe: Error handler for duplicate filter locations in hardware for
    cls_u32 offloads

Andrew Lunn (1):
  igb: Only DMA sync frame length

Bhaktipriya Shridhar (1):
  fm10k: Remove create_workqueue

Denys Vlasenko (1):
  e1000e: prevent division by zero if TIMINCA is zero

Emil Tantilov (1):
  ixgbe: fix spoofed packets with macvlans

Jacob Keller (7):
  fm10k: don't use BIT() macro where the value isn't a bitmask
  fm10k: fix incorrect index calculation in fm10k_write_reta
  igb: introduce ptp_flags variable and use it to replace IGB_FLAG_PTP
  igb: introduce IGB_PTP_OVERFLOW_CHECK flag
  igb: re-use igb_ptp_reset in igb_ptp_init
  igb: implement igb_ptp_suspend
  igb: call igb_ptp_suspend during suspend/resume cycle

Tony Nguyen (1):
  ixgbe: Correct reporting of timestamping for x550

 drivers/net/ethernet/intel/e1000e/netdev.c       |  3 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  5 +-
 drivers/net/ethernet/intel/igb/igb.h             |  7 +-
 drivers/net/ethernet/intel/igb/igb_main.c        | 12 ++--
 drivers/net/ethernet/intel/igb/igb_ptp.c         | 92 +++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  8 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 76 +++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h   |  4 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  1 +
 11 files changed, 148 insertions(+), 67 deletions(-)

-- 
2.5.5
