From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/13][pull request] Intel Wired LAN Driver Updates 2014-06-05
Date: Thu,  5 Jun 2014 03:12:48 -0700
Message-ID: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19636 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809AbaFEKNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jesse fixes an issue reported by Dave Jones where a couple of FD checks
ended up using bitwise OR where it should have been bitwise AND.

Neerav removes unused defines and macros for receive LRO.  Fix the driver
from allowing the user to set a larger MTU size that the hardware was
being configured to support.  Refactors send version which moves code in
two places into a small helper function.

Kamil modifies register diagnostics since register ranges can vary among
the different NVMs to avoid false test results.  So now we try to identify
the full range and use it for a register test and if we fail to define the
proper register range, we will only test the first register from that
group.  Then removes the check for large buffer since this was added in the
case this structure changed in the future, since the AQ definition is now
mature enough that this check is no longer necessary.

Mitch fixes i40evf driver to allocate descriptors in groups of 32 since the
hardware requires it.  Also fixes a crash when the ring size changed because
it would change the count before deallocating resources, causing the driver
to either free nonexistent buffers or leak leftover buffers.  Fixed the
driver to notify the VF for all types of resets so the VF can attempt a
graceful reinit.

Shannon refactors stats collection to create a unifying stats update routine
to call the various stat collection routines.  Removes rx_errors and
rx_missed stats since they were removed from the chip design.  Added
missing VSI statistics that the hardware offers but are not apart of the
standard netdev stats.

v2: dropped patch "i40e: Allow disabling of DCB via debugfs" from Neerav
    based on feedback from David Miller.

The following are changes since commit ebbe495f19d565bb39be31ca28126a222b6a66dd:
  ipv4: use skb frags api in udp4_hwcsum()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jesse Brandeburg (4):
  i40e: don't use OR to check a value
  i40e/i40evf: remove unused RX_LRO define
  i40e: clamp jumbo frame size
  i40e: refactor send version

Kamil Krawczyk (3):
  i40e: Rework register diagnostic
  i40e: remove check for large buffer
  i40e/i40evf: VEB structure added, GTIME macro update

Mitch Williams (3):
  i40evf: set descriptor multiple to 32
  i40evf: fix crash when changing ring sizes
  i40e: notify VF of all types of resets

Shannon Nelson (3):
  i40e: refactor stats collection
  i40e/i40evf: remove rx_errors and rx_missed
  i40e: add missing VSI statistics

 drivers/net/ethernet/intel/i40e/i40e_common.c      |   6 -
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |  50 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  19 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 404 +++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   7 -
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  16 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   7 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  16 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  20 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   8 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   3 +-
 14 files changed, 321 insertions(+), 252 deletions(-)

-- 
1.9.3
