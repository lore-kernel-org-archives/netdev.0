From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 00/10] Make XPS usable within ixgbe
Date: Fri, 29 Jun 2012 17:16:12 -0700
Message-ID: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5406 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363Ab2F3APy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:15:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series makes it so that the ixgbe driver can support
ATR even when the number of queues is less than the number of CPUs.  To do
this I have updated the kernel to support letting drivers set their own XPS
configuration.  To do this it was necessary to move the code out of the
sysfs specific code and into the dev specific regions.

I am still working out a few issues such as the fact that with routing I
only ever seem to be able to get the first queue that is mapped to the CPU
when XPS is enabled.

Also I am looking for input on if it is acceptable to only let the
set_channels/get_channels calls report/set the number of queues per traffic
class as I implemented the code this way to avoid any significant conflicts
between the DCB traffic classes code and these functions.

---

Alexander Duyck (10):
      ixgbe: Add support for set_channels ethtool operation
      ixgbe: Add support for displaying the number of Tx/Rx channels
      ixgbe: Update ixgbe driver to use __dev_pick_tx in ixgbe_select_queue
      ixgbe: Add function for setting XPS queue mapping
      ixgbe: Define FCoE and Flow director limits much sooner to allow for changes
      net: Add support for XPS without SYSFS being defined
      net: Rewrite netif_set_xps_queues to address several issues
      net: Rewrite netif_reset_xps_queue to allow for better code reuse
      net: Add functions netif_reset_xps_queue and netif_set_xps_queue
      net: Split core bits of dev_pick_tx into __dev_pick_tx


 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  112 +++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   10 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   48 +++-
 include/linux/netdevice.h                        |   15 +
 net/Kconfig                                      |    2 
 net/core/dev.c                                   |  283 ++++++++++++++++++++--
 net/core/net-sysfs.c                             |  160 ------------
 7 files changed, 428 insertions(+), 202 deletions(-)

-- 
Thanks,

Alex
