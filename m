From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  00/11][pull request] Intel Wired LAN Driver Updates
Date: Tue, 29 Oct 2013 05:02:20 -0700
Message-ID: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48082 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547Ab3J2MCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to vxlan, net, ixgbe, ixgbevf, and i40e.

Joseph provides a single patch against vxlan which removes the burden
from the NIC drivers to check if the vxlan driver is enabled in the
kernel and also makes available the vxlan headrooms to the drivers.

Jacob provides majority of the patches, with patches against net, ixgbe
and ixgbevf.  His net patch adds might_sleep() call to napi_disable so
that every use of napi_disable during atomic context will be visible.
Then Jacob provides a patch to fix qv_lock_napi call in
ixgbe_napi_disable_all.  The other ixgbe patches cleanup
ixgbe_check_minimum_link function to correctly show that there are some
minor loss of encoding, even though we don't calculate it and remove
unnecessary duplication of PCIe bandwidth display.  Lastly, Jacob
provides 4 patches against ixgbevf to add ixgbevf_rx_skb in line with
how ixgbe handles the variations on how packets can be received, adds
support in order to track how many packets were cleaned during busy poll
as part of the extended statistics.

Wei Yongjun provides a fix for i40e to return -ENOMEN in the memory
allocation error handling case instead of returning 0, as done
elsewhere in this function.

The following are changes since commit cdfb97bc010d9e9d994eb68f2cbac3a8ada26104:
  net, mc: fix the incorrect comments in two mc-related functions
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (1):
  ixgbevf: Add zero_base handler to network statistics

Jacob Keller (8):
  net: add might_sleep() call to napi_disable
  ixgbe: fix qv_lock_napi call in ixgbe_napi_disable_all
  ixgbe: show <2% for encoding loss on PCIe Gen3
  ixgbe: remove unnecessary duplication of PCIe bandwidth display
  ixgbevf: add ixgbevf_rx_skb
  ixgbevf: have clean_rx_irq return total_rx_packets cleaned
  ixgbevf: implement CONFIG_NET_RX_BUSY_POLL
  ixgbevf: add BP_EXTENDED_STATS for CONFIG_NET_RX_BUSY_POLL

Joseph Gasparakis (1):
  vxlan: Have the NIC drivers do less work for offloads

Wei Yongjun (1):
  i40e: fix error return code in i40e_probe()

 drivers/net/ethernet/intel/i40e/i40e_main.c       |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  48 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  46 +++-----
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  98 +++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 132 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 103 +++++++++++++++--
 drivers/net/vxlan.c                               |   4 -
 include/linux/netdevice.h                         |   1 +
 include/net/vxlan.h                               |  11 ++
 9 files changed, 366 insertions(+), 81 deletions(-)

-- 
1.8.3.1
