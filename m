From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 10GbE Intel Wired LAN Driver Updates 2016-07-22
Date: Fri, 22 Jul 2016 23:49:37 -0700
Message-ID: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55381 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbcGWGuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Emil fixes the NACK check in ixgbevf_set_uc_addr_vf() for instances where
the index is not equal to zero.  Fixes an issue where mac->ops.setup_fc
can be NULL for backplanes which can cause the driver to crash on load.

Don fixes the second parameter of the LED functions, which is the index to
the LED we are interested in affecting.  Fixed variable to store register
reads to unsigned integer.  Adds support for the new x553 hardware into
ixgbevf.  Fixed a missing rtnl lock around ixgbevf_reinit_locked().
Fixed an issue where in ixgbevf_reset_subtask() was not verifying that
the port has been removed.  Cleans up the initial crosstalk fix, since
the SFP that indicates the presence of a SFP+ module changes between
hardware types.

Babu Moger fixes typo in freeing IRQ, since the array subscript increments
after the execution of the statement.

Wei Yongjun adds the missing destroy_workqueue() before returning from
ixgbe_init_module() in the error handling case.

Tony adds range checking for setting the MTU from the VF, where the PF can
return a NACK but this was not passed on to the VF, so propagate the
results from the PF to the VF so errors can be reported.  Consolidates
mailbox read and write functions, since the recent changes to
ixgbevf_write_msg_read_ack(), other functions are performing the same
operations done here.

Colin Ian King removes a redundant check on ret_val, since ret_val has
not changed since the previous check.

The following are changes since commit d95a93a9b71677a43f967a1b7986decab84b7765:
  Merge branch 'macsec-gro'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Babu Moger (1):
  ixgbe: Fix minor typo while freeing irq

Colin Ian King (1):
  ixgbe: remove redundant check on ret_val

Don Skidmore (7):
  ixgbevf: Correct parameter sent to LED function
  ixgbevf: bump version number
  ixgbe: Change register variable to unsigned
  ixgbevf: add VF support for new hardware
  ixgbevf: Add lock around ixgbevf_reinit_locked call
  ixgbevf: Protect ixgbevf_reset_subtask from remove event
  ixgbe: cleanup crosstalk fix

Emil Tantilov (2):
  ixgbevf: fix NACK check in ixgbevf_set_uc_addr_vf()
  ixgbe: fix setup_fc for x550em

Tony Nguyen (2):
  ixgbevf: Add range checking for setting MTU
  ixgbevf: Commonize mailbox write/read

Wei Yongjun (1):
  ixgbe: Add missing destroy_workqueue() on error in ixgbe_init_module()

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |  3 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   | 85 +++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 42 +---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  4 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 24 ++++--
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 96 +++++++++++------------
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  3 +-
 12 files changed, 160 insertions(+), 107 deletions(-)

-- 
2.5.5
