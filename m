From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next 0/3] Drop get_headlen functions in favor of generic
 funciton
Date: Fri, 05 Sep 2014 14:09:45 -0400
Message-ID: <20140905180642.730.22292.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44923 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbaIESSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:18:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series replaces the igb_get_headlen and ixgbe_get_headlen functions
with a generic function named eth_get_headlen.

I have done some performance testing on ixgbe with 258 byte frames since
the calls are only used on frames larger than 256 bytes and have seen no
significant difference in CPU utilization.

---

Alexander Duyck (3):
      net: Add function for parsing the header length out of linear ethernet frames
      igb: use new eth_get_headlen interface
      ixgbe: use new eth_get_headlen interface


 drivers/net/ethernet/intel/igb/igb_main.c     |  109 -----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  116 -------------------------
 include/linux/etherdevice.h                   |    1 
 include/linux/skbuff.h                        |    2 
 include/net/flow_keys.h                       |    2 
 net/core/flow_dissector.c                     |   46 +++++++---
 net/ethernet/eth.c                            |   27 ++++++
 7 files changed, 66 insertions(+), 237 deletions(-)

-- 
