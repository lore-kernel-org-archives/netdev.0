From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v2 0/3] Drop get_headlen functions in favor of
 generic function
Date: Fri, 05 Sep 2014 19:20:12 -0400
Message-ID: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59573 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbaIEX2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:28:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series replaces the igb_get_headlen and ixgbe_get_headlen functions
with a generic function named eth_get_headlen.

I have done some performance testing on ixgbe with 258 byte frames since
the calls are only used on frames larger than 256 bytes and have seen no
significant difference in CPU utilization.

v2: renamed __skb_get_poff to skb_get_poff
    renamed ___skb_get_poff to __skb_get_poff

---

Alexander Duyck (3):
      net: Add function for parsing the header length out of linear ethernet frames
      igb: use new eth_get_headlen interface
      ixgbe: use new eth_get_headlen interface


 drivers/net/ethernet/intel/igb/igb_main.c     |  109 -----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  116 -------------------------
 include/linux/etherdevice.h                   |    1 
 include/linux/skbuff.h                        |    4 +
 include/net/flow_keys.h                       |    2 
 net/core/filter.c                             |    2 
 net/core/flow_dissector.c                     |   46 +++++++---
 net/ethernet/eth.c                            |   27 ++++++
 8 files changed, 68 insertions(+), 239 deletions(-)

-- 
