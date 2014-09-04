From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v4 0/3] Series short description
Date: Thu, 04 Sep 2014 13:30:29 -0400
Message-ID: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61966 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458AbaIDRis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 13:38:48 -0400
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

v3: Updated destructor handling and dealt with socket reference counting issues

v4: Split out combining destructors into a separate patch

Alexander Duyck (3):
      net-timestamp: Merge shared code between phy and regular timestamping
      net-timestamp: Make the clone operation stand-alone from phy timestamping
      net: merge cases where sock_efree and sock_edemux are the same function


 drivers/net/phy/dp83640.c |    6 ++-
 include/linux/skbuff.h    |    2 +
 include/net/sock.h        |    5 +++
 net/core/skbuff.c         |   79 +++++++++++++++++++++++++++++++++------------
 net/core/sock.c           |   10 +++++-
 net/core/timestamping.c   |   43 ++----------------------
 net/ipv4/udp.c            |    2 +
 7 files changed, 80 insertions(+), 67 deletions(-)

-- 
