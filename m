From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sat, 21 Jul 2012 16:08:49 -0700
Message-ID: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11129 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab2GUXJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

The following are changes since commit 186e868786f97c8026f0a81400b451ace306b3a4:
  forcedeth: spin_unlock_irq in interrupt handler fix
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: reset PHY in the link_up process to recover PHY setting after
    power down.

Alexander Duyck (8):
  ixgbe: Drop probe_vf and merge functionality into ixgbe_enable_sriov
  ixgbe: Change how we check for pre-existing and assigned VFs
  ixgbevf: Add lock around mailbox ops to prevent simultaneous access
  ixgbevf: Add support for PCI error handling
  ixgbe: Fix handling of FDIR_HASH flag
  ixgbe: Reduce Rx header size to what is actually used
  ixgbe: Use num_tcs.pg_tcs as upper limit for TC when checking based
    on UP
  ixgbe: Use 1TC DCB instead of disabling DCB for MSI and legacy
    interrupts

Don Skidmore (1):
  ixgbe: add support for new 82599 device

Greg Rose (1):
  ixgbevf: Fix namespace issue with ixgbe_write_eitr

John Fastabend (2):
  ixgbe: fix RAR entry counting for generic and fdb_add()
  ixgbe: remove extra unused queues in DCB + FCoE case

 drivers/net/ethernet/intel/igb/igb_main.c         |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c      |   12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |   41 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  140 +++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  151 ++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |    1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  164 +++++++++++++++++----
 10 files changed, 323 insertions(+), 209 deletions(-)

-- 
1.7.10.4
