From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Tue, 30 Oct 2012 00:04:17 -0700
Message-ID: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8573 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143Ab2J3HOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:14:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf, igbvf, igb and
networking core (bridge).  Most notably is the addition of support
for local link multicast addresses in SR-IOV mode to the networking
core.

Also note, the ixgbe patch "ixgbe: Add support for pipeline reset" and
"ixgbe: Fix return value from macvlan filter function" is revised based
on community feedback.

The following are changes since commit a932657f51eadb8280166e82dc7034dfbff3985a:
  net: sierra: shut up sparse restricted type warnings
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Do not decrement budget in ixgbe_clean_rx_irq
  igb: Fix sparse warning in igb_ptp_rx_pktstamp

Carolyn Wyborny (1):
  igb: Update firmware version info for ethtool output.

Don Skidmore (1):
  ixgbe: Add support for pipeline reset

Emil Tantilov (1):
  ixgbe: clean up the condition for turning on/off the laser

Greg Rose (4):
  ixgbe: Fix return value from macvlan filter function
  ixgbe: Return success or failure on VF MAC filter set
  ixgbevf: Do not forward LLDP type frames
  igbvf: Check for error on dma_map_single call

Jiri Benc (1):
  ixgbe: reduce PTP rx path overhead

John Fastabend (1):
  net, ixgbe: handle link local multicast addresses in SR-IOV mode

Josh Hay (1):
  ixgbe: add/update descriptor maps in comments

Matthew Vick (1):
  igb: Enable auto-crossover during forced operation on 82580 and
    above.

 drivers/net/ethernet/intel/igb/e1000_defines.h    |  14 +++
 drivers/net/ethernet/intel/igb/e1000_mac.c        |   4 +
 drivers/net/ethernet/intel/igb/e1000_nvm.c        |  70 +++++++++++++
 drivers/net/ethernet/intel/igb/e1000_nvm.h        |  16 +++
 drivers/net/ethernet/intel/igb/e1000_phy.c        |  29 +++---
 drivers/net/ethernet/intel/igb/igb_main.c         |  76 +++++----------
 drivers/net/ethernet/intel/igb/igb_ptp.c          |   2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |  13 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    | 114 ++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  70 ++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 103 ++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |   5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   5 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   3 +
 include/linux/etherdevice.h                       |  19 ++++
 net/bridge/br_device.c                            |   2 +-
 net/bridge/br_input.c                             |  15 ---
 net/bridge/br_private.h                           |   1 -
 net/bridge/br_sysfs_br.c                          |   3 +-
 21 files changed, 419 insertions(+), 152 deletions(-)

-- 
1.7.11.7
