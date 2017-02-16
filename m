From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 10GbE Intel Wired LAN Driver Updates 2017-02-16
Date: Thu, 16 Feb 2017 04:50:27 -0800
Message-ID: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18210 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753285AbdBPMuo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Tony updates the driver to advertise 2.5Gb and 5.0Gb if the adapter
supports it.

Stephen Hemminger renames our dcbnl_ops since it is global to
ixgbe_dcbnl_ops to avoid namespace issues.

Mark updates the driver version based on the recent changes.

Alex has the remainder of the changes, starting with consolidating
functions that represent logical steps in the receive process so we can
later update them more easily (and align with igb).  Modify the receive
path to only synchronize the length of the frame versus the entire buffer.
Provided performance improvements by adding support for
DMA_ATTR_SKIP_CPU_SYNC and DMA_ATTR_WEAK_ORDERING.  Also made additional
performance gains by batching the page count updates instead of doing
them one at a time.  Adjusted the receive path to use 3k buffers with
8k backing them in order to support build_skb with jumbo frames.  Made
additional driver improvements by using the length of the packet instead
of the DD status to determine if a new descriptor is ready to be
processed, which cuts down on reads.  To reduce code duplication, pulled
apart the receive path into separate functions.  Added support for
providing a buffer with headroom and tailroom to allow for shared info
for NET_SKB_PAD and NET_IP_ALIGN.

The following are changes since commit b973154a2278c6af0b0efefafb222e0189959659:
  atm: idt77252, use setup_timer and mod_timer
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (11):
  ixgbe: Add function for checking to see if we can reuse page
  ixgbe: Only DMA sync frame length
  ixgbe: Update driver to make use of DMA attributes in Rx path
  ixgbe: Update code to better handle incrementing page count
  ixgbe: Make use of order 1 pages and 3K buffers independent of FCoE
  ixgbe: Use length to determine if descriptor is done
  ixgbe: Break out Rx buffer page management
  ixgbe: Add support for padding packet
  ixgbe: Add private flag to control buffer mode
  ixgbe: Add support for build_skb
  ixgbe: Don't bother clearing buffer memory for descriptor rings

Mark Rustad (1):
  ixgbe: Update version to reflect added functionality

Stephen Hemminger (1):
  ixgbe: prefix Data Center Bridge ops struct

Tony Nguyen (1):
  ixgbe: Support 2.5Gb and 5Gb speed

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  47 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  63 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 589 +++++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |  10 +-
 5 files changed, 481 insertions(+), 230 deletions(-)

-- 
2.11.0
