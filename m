From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Thu, 24 Oct 2013 08:27:27 -0700
Message-ID: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32845 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab3JXP1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, igbvf, i40e, ixgbe and ixgbevf.

Dan Carpenter provides a patch for igbvf to fix a bug found by a static
checker.  If the new MTU is very large, then "new_mtu + ETH_HLEN +
ETH_FCS_LEN" can wrap and the check on the next line can underflow.

Wei Yongjun provides 2 patches, the first against igbvf adds a missing
iounmap() before the return from igbvf_probe().  The second against
i40e, removes the include <linux/version.h> because it is not needed.

Carolyn provides a patch for igb to fix a call to set the master/slave
mode for all m88 generation 2 PHY's and removes the call for I210
devices which do not need it.

Stefan Assmann provides a patch for igb to fix an issue which was broke
by:
   commit fa44f2f185f7f9da19d331929bb1b56c1ccd1d93
   Author: Greg Rose <gregory.v.rose@intel.com>
   Date:   Thu Jan 17 01:03:06 2013 -0800
   igb: Enable SR-IOV configuration via PCI sysfs interface
which breaks the reloading of igb when VFs are assigned to a guest, in
several ways.

Jacob provides a patch for ixgbe and ixgbevf.  First, against ixgbe,
cleans up ixgbe_enumerate_functions to reduce code complexity.  The
second, against ixgbevf, adds support for ethtool's get_coalesce and
set_coalesce command for the ixgbevf driver.

Yijing Wang provides a patch for ixgbe to use pcie_capability_read_word()
to simplify the code.

Emil provides a ixgbe patch to fix an issue where the logic used to
detect changes in rx-usecs was incorrect and was masked by the call to
ixgbe_update_rsc().

Don provides 2 patches for ixgbevf.  First creates a new function to set
PSRTYPE.  The second bumps the ixgbevf driver version.

The following are changes since commit b45bd46decd947eaa3497699d450e0851d247534:
  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Carolyn Wyborny (1):
  igb: Fix master/slave mode for all m88 i354 PHY's

Dan Carpenter (1):
  igbvf: integer wrapping bug setting the mtu

Don Skidmore (2):
  ixgbevf: Adds function to set PSRTYPE register
  ixgbevf: bump driver version

Emil Tantilov (1):
  ixgbe: fix rx-usecs range checks for BQL

Jacob Keller (2):
  ixgbe: cleanup ixgbe_enumerate_functions
  ixgbevf: implement ethtool get/set coalesce

Stefan Assmann (1):
  igb: fix driver reload with VF assigned to guest

Wei Yongjun (2):
  igbvf: add missing iounmap() on error in igbvf_probe()
  i40e: remove unused including <linux/version.h>

Yijing Wang (1):
  ixgbe: use pcie_capability_read_word() to simplify code

 drivers/net/ethernet/intel/i40e/i40e.h            |  1 -
 drivers/net/ethernet/intel/igb/e1000_phy.c        |  8 +--
 drivers/net/ethernet/intel/igb/igb_main.c         | 37 +++++------
 drivers/net/ethernet/intel/igbvf/netdev.c         |  8 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 19 ++----
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 81 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 ++++--
 9 files changed, 134 insertions(+), 50 deletions(-)

-- 
1.8.3.1
