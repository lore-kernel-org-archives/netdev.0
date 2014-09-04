From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 0/3] Drop get_headlen functions in favor of generic
 function
Date: Thu, 04 Sep 2014 19:13:28 -0400
Message-ID: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34898 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbaIDXV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 19:21:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series replaced igb_get_headlen and ixgbe_get_headlen with a generic
function named eth_get_headlen.

This is a first pass at this and has been compile tested only.  I'm mainly
looking for feedback on any issues with the approach I have taken or any
complains about the eth_get_headlen function or the changes to __skb_get_poff
in the first patch.

I'll try running this through some stress/performance testing tomorrow to
see how it compares to the original functions.

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
 net/core/flow_dissector.c                     |   41 ++++++---
 net/ethernet/eth.c                            |   27 ++++++
 7 files changed, 60 insertions(+), 238 deletions(-)

-- 
