From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/14][pull request] 10GbE Intel Wired LAN Driver Updates 2016-04-04
Date: Mon,  4 Apr 2016 17:58:51 -0700
Message-ID: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38979 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbcDEA7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 20:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Pavel Tikhomirov fixes a typo where we were incrementing transmit stats
instead of receive stats on the receive side.

Emil updates the ixgbevf driver to use bit operations for setting and
checking the adapter state.

Chas Williams adds the new NDO trust feature check so that the VF guest
has the ability to set the unicast address of the interface, if it is a
trusted VF.

Alex cleans up the driver to that the only time we add a PF entry to the
VLVF is either for VLAN 0 or if the PF has requested a VLAN that a VF
is already using.  Also adds support for generic transmit checksums,
giving the added advantage is that we can support inner checksum offloads
for tunnels and MPLS while still being able to transparently insert
VLAN tags.  Lastly, changed ixgbe so that we can use the ethtool
rx-vlan-filter flag to toggle receive VLAN filtering on and off.

Mark cleans up the ixgbe driver by making all op structures that do not
change constants.  Also fixed flow control for Xeon D KR backplanes, since
we cannot use auto-negotiation to determine the mode, we have to use
whatever the user configured.

Sowmini Varadhan updates ixgbe to use eth_platform_get_mac_address()
instead of the arch specific solution that was added by a previous
commit.

Don fixed an issue where it was possible that a system reset could occur
when we were holding the SWFW semaphore lock, which the next time the
driver loaded would see it incorrectly as locked.

v2: updated patch 8 of the series to include a minor flags issue where
    we had lost NETIF_F_HW_TC and we were setting NETIF_F_SCTP_CRC in
    two different areas, when we only needed/wanted it in one spot.

The following are changes since commit 833716e0ed026c1abc7dd0e85a6932b855a8e56b:
  Merge branch 'stmmac-GMAC4.x'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (5):
  ixgbe: Do not allow PF to add VLVF entry unless it actually needs it
  ixgbe: Avoid adding VLAN 0 twice to VLVF and VFTA
  ixgbe: Add support for generic Tx checksums
  ixgbevf: Add support for generic Tx checksums
  ixgbe: Add support for toggling VLAN filtering flag via ethtool

Amritha Nambiar (1):
  ixgbe: Extend cls_u32 offload to support UDP headers

Don Skidmore (1):
  ixgbe: Place SWFW semaphore in known valid state at probe

Emil Tantilov (1):
  ixgbevf: use bit operations for setting and checking resets

Mark Rustad (2):
  ixgbe: Make all unchanging ops structures const
  ixgbe: Fix flow control for Xeon D KR backplane

Pavel Tikhomirov (1):
  ixgbe: on recv increment rx.ring->stats.yields

Rostislav Pehlivanov (1):
  ixgbe: add a callback to set the maximum transmit bitrate

Sowmini Varadhan (1):
  ixgbe: use eth_platform_get_mac_address()

chas williams (1):
  ixgbe: Extend trust to allow guest to set unicast address

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  14 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 296 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c      |  40 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h    |   8 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  35 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |  31 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h     |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 106 +++++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   9 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 119 ++++-----
 17 files changed, 390 insertions(+), 327 deletions(-)

-- 
2.5.5
