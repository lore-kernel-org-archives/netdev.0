From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH v2 00/10] Make XPS usable within ixgbe
Date: Thu, 10 Jan 2013 10:56:03 -0800
Message-ID: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64433 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab3AJS5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:57:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series makes it so that the ixgbe driver can support
ATR even when the number of queues is less than the number of CPUs.  To do
this I have updated the kernel to support letting drivers set their own XPS
configuration.  To do this it was necessary to move the code out of the
sysfs specific code and into the dev specific regions.

It has been almost 6 months since the last time I released these patches.  I
have been meaning to get back to them but I just haven't had a chance to get
this work done until recently.

Only the core net patches are meant for acceptance at this time.  I will
submit the ixgbe patches through Jeff Kirsher's tree.  For this reason I have
tagged the ixgbe related patches as RFC.

---

rc2: Updated first patch to address changes from dev_pick_tx to netdev_pick_tx.
     Made it so that we only update XPS map on queue number change.
     Minor tweaks and cleanups to get caught up with recent changes in the tree.

Alexander Duyck (10):
      net: Split core bits of netdev_pick_tx into __netdev_pick_tx
      net: Add functions netif_reset_xps_queue and netif_set_xps_queue
      net: Rewrite netif_reset_xps_queue to allow for better code reuse
      net: Rewrite netif_set_xps_queues to address several issues
      net: Add support for XPS without sysfs being defined
      ixgbe: Define FCoE and Flow director limits much sooner to allow for changes
      ixgbe: Add function for setting XPS queue mapping
      ixgbe: Update ixgbe driver to use __netdev_pick_tx in ixgbe_select_queue
      ixgbe: Add support for displaying the number of Tx/Rx channels
      ixgbe: Add support for set_channels ethtool operation


 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  112 +++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   21 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   77 ++++--
 include/linux/netdevice.h                        |   13 +
 net/Kconfig                                      |    2 
 net/core/dev.c                                   |  289 ++++++++++++++++++++--
 net/core/net-sysfs.c                             |  160 ------------
 8 files changed, 454 insertions(+), 223 deletions(-)

-- 
