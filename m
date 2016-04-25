From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver Updates 2016-04-25
Date: Mon, 25 Apr 2016 05:44:14 -0700
Message-ID: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139AbcDYMob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Emil provides several patches, starting with the consolidation of the
logic behind configuring spoof checking.  Fixed an issue which was
causing link issues for backplane devices because x550em_a/x devices
did not have a default value for mac->ops.setup_link.  Refactored the
ethtool stats to bring the logic closer to how ixgbe handles stats and
sets up per-queue stats for ixgbevf.

Mark adds a new register to wait for previous register writes to complete
before issuing a register read, which is needed when slower links are
in use.  Fixed the flow control setup for x550em_a, the incorrect
fc_setup function was being used.

Don added a workaround for empty SFP+ cage crosstalk, since on some
systems the crosstalk could lead to link flap on empty SFP+ cages.

Jake converts ixgbe and ixgbevf to use the BIT() macro.

Alex Duyck adds support for partial GSO segmentation in the case of
tunnels for ixgbe and ixgbevf.  Then preps for HyperV by moving the API
negotiation into mac_ops.

Arnd Bergmann provides a fix for the ARM compile warnings in linux-next
by converting the use of a udelay() to msleep().

The following are changes since commit 10d3be569243def8d92ac3722395ef5a59c504e6:
  tcp-tso: do not split TSO packets at retransmit time
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (2):
  ixgbe/ixgbevf: Add support for GSO partial
  ixgbevf: Move API negotiation function into mac_ops

Arnd Bergmann (1):
  ixgbe: use msleep for long delays

Don Skidmore (1):
  ixgbe: Add work around for empty SFP+ cage crosstalk

Emil Tantilov (5):
  ixgbe: consolidate the configuration of spoof checking
  ixgbe: set VLAN spoof checking unconditionally
  ixgbe: fix default mac->ops.setup_link for X550EM
  ixgbevf: refactor ethtool stats handling
  ixgbevf: add support for per-queue ethtool stats

Jacob Keller (3):
  ixgbe: use BIT() macro
  ixgbe: resolve shift of negative value warning
  ixgbevf: make use of BIT() macro to avoid shift of signed values

Mark Rustad (2):
  ixgbe: Add register wait for slow links
  ixgbe: Use correct FC setup function for x550em_a

Sridhar Samudrala (1):
  ixgbe: make 'action' field in struct ixgbe_fdir_filter a u64 value

 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |  75 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |  16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  70 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  14 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 259 ++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  86 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      | 168 ++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |  14 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h       |  24 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       | 230 +++++++++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  18 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 149 ++++++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c            |   5 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h            |   2 +-
 24 files changed, 661 insertions(+), 505 deletions(-)

-- 
2.5.5
