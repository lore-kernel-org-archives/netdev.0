From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 21 Aug 2013 01:23:21 -0700
Message-ID: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2670 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab3HUIXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 04:23:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and e1000e.

Akeem provides 3 igb patches, the first resets the link when EEE is enabled
or disabled if the link is up.  His second patch changes a register read
which normally stores of the read value to "just-read" so that hardware
can accurately latch the register read.  Lastly, he adds rcu_lock to avoid
a possible race condition with igb_update_stats function.

Mitch provides a fix for SR-IOV, where MSI-X interrupts are required, so
make sure that MSI-X is enabled before allowing the user to turn on SR-IOV.

Alex's igb patch make it so that we limit the lower bound for max_frame_size
to the size of a standard Ethernet frame.  This allows for feature parity
with other Intel based drivers such as ixgbe.

Carolyn adds a SKU for a flashless i210 device and a fix for get_fw_version()
so that it works for all parts for igb.  In addition, she has 2 igb patches
to refactor NVM code to accommodate devices with no flash.  Lastly, she
adds code to check for the failure of pci_disable_link_state() to attempt
to work around a problem found with some systems.

Laura provides the remaining 2 igb patches.  One removing the hard-coded
value for the size of the RETA indirection table, and creates a macro instead
for the RETA indirection table.  The second adds the ethtool callbacks
necessary to change the RETA indirection table from userspace.

Bruce fixes a whitespace issue in a recent commit and resolves a jiffies
comparison warning by using time_after().

Li provides a fix for e1000e to avoid a kernel crash on shutdown by adding
one more check in e1000e_shutdown().  This is due to e1000e_shutdown()
trying to clear correctable errors on the upstream P2P bridge, when under
some cases we do not have the upstream P2P bridge.

The following are changes since commit 84ce22df92f5cf9ecb76d53f4bf5f6d504684540:
  net: davinci_mdio: use platform_{get,set}_drvdata()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (3):
  igb: Reset the link when EEE setting changed
  igb: Read register for latch_on without return value
  igb: Added rcu_lock to avoid race

Alexander Duyck (1):
  igb: Update MTU so that it is always at least a standard frame size

Bruce Allan (2):
  e1000e: cleanup whitespace in recent commit
  e1000e: resolve checkpatch JIFFIES_COMPARISON warning

Carolyn Wyborny (5):
  igb: Refactor of init_nvm_params
  igb: Refactor NVM read functions to accommodate devices with no flash
  igb: Add device support for flashless SKU of i210 device
  igb: Fix get_fw_version function for all parts
  e1000e: Add code to check for failure of pci_disable_link_state call

Laura Mihaela Vasilescu (2):
  igb: Add macro for size of RETA indirection table
  igb: Expose RSS indirection table for ethtool

Li Zhang (1):
  e1000e: Avoid kernel crash during shutdown

Mitch A Williams (1):
  igb: don't allow SR-IOV without MSI-X

 drivers/net/ethernet/intel/e1000e/ethtool.c    |   2 +-
 drivers/net/ethernet/intel/e1000e/hw.h         |   3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c     |  92 ++++++++++-----
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 117 ++++++++-----------
 drivers/net/ethernet/intel/igb/e1000_defines.h |  34 ++++--
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   3 +
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 155 ++++++++++++++++---------
 drivers/net/ethernet/intel/igb/e1000_i210.h    |   5 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c     |  80 +++++++++----
 drivers/net/ethernet/intel/igb/e1000_nvm.h     |   1 +
 drivers/net/ethernet/intel/igb/igb.h           |   5 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 106 ++++++++++++++++-
 drivers/net/ethernet/intel/igb/igb_main.c      | 105 ++++++++++-------
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   8 +-
 14 files changed, 476 insertions(+), 240 deletions(-)

-- 
1.8.3.1
