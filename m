From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v2 0/2] Combine standard and phy timestamping logic
Date: Wed, 03 Sep 2014 19:38:29 -0400
Message-ID: <20140903233447.7517.52329.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20437 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933336AbaICXqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 19:46:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the core path for the phy timestamping logic
is shared between skb_tx_tstamp and skb_complete_tx_timestamp.  In addition
it provides a means of using the same skb clone type path in non phy
timestamping drivers.

The main motivation for this is to enable non-phy drivers to be able to
manipulate tx timestamp skbs for such things as putting them in lists or
setting aside buffer in the context block.

---

v2: Incorporated suggested changes from Willem de Bruijn and Eric Dumazet
     dropped uneeded comment
     restored order of hwtstamp vs swtstamp
     added destructor for skb
    Dropped usage of skb_complete_tx_timestamp as a kfree_skb w/ destructor

Alexander Duyck (2):
      net-timestamp: Merge shared code between phy and regular timestamping
      net-timestamp: Make the clone operation stand-alone from phy timestamping


 drivers/net/phy/dp83640.c |    6 ++--
 include/linux/skbuff.h    |    2 +
 net/core/skbuff.c         |   77 +++++++++++++++++++++++++++++++++------------
 net/core/timestamping.c   |   43 ++-----------------------
 4 files changed, 64 insertions(+), 64 deletions(-)

-- 
