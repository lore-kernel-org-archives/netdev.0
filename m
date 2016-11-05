From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver Updates 2016-11-04
Date: Sat,  5 Nov 2016 00:54:06 -0700
Message-ID: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751774AbcKEHyX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Don does cleanup and configuration for our X553 devices, related to LED,
auto-negotiation, flow control and SFP+ setup and config.  Adds the
(not secret) sauce for B0 hardware for X553 hardware.

Emil provides several fixes, first replaces the driver specific MDIO
defines for the more preferred equivalent kernel ones.  Provides a fix
for auto-negotiaion status, by reading a PHY register twice.  Introduces
ixgbe_link_operations structure to allow X550EM_a to override the
methods for MDIO access while X550EM_x provides methods to use I2C
combined access.

Mark fixes an issue where the driver was crashing when msix_entires
were not there because they were freed by a previous suspend or remove.

Sowmini Varadhan fixes an issue where an incorrect check for IPPROTO_UDP
in ixgbe_atr().  Then makes sure that the network and transport headers
in the paged data are available in the headlen bytes to calculate the
l4_proto.

The following are changes since commit 95ae31a9a95c1c27f4a260152e7b42e2254f26b5:
  Merge branch 'nfp-ring-reconfig-and-xdp-support'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Don Skidmore (6):
  ixgbe: Add X552 iXFI configuration helper function
  ixgbe: Add support to retrieve and store LED link active
  ixgbe: Update setup PHY link to unset all speeds
  ixgbe: Add X553 PHY FC autoneg support
  ixgbe: Add X553 FW ALEF support
  ixgbe: Correct X550 phy ID

Emil Tantilov (5):
  ixgbe: do not use ixgbe specific mdio defines
  ixgbe: fix link status check for copper X550em
  ixgbe: remove SFP ixfi support
  ixgbe: use link instead of I2C combined abstraction
  ixgbe: set device if before calling get_invariants

Mark Rustad (2):
  ixgbe: Handle previously-freed msix_entries
  ixgbevf: Handle previously-freed msix_entries

Sowmini Varadhan (2):
  ixgbe: ixgbe_atr() should access udp_hdr(skb) only for UDP packets
  ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has
    network/transport headers

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  62 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  34 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      | 240 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  70 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 751 ++++++++++++++++------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   9 +-
 13 files changed, 819 insertions(+), 374 deletions(-)

-- 
2.7.4
