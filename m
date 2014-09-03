From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 0/2] Combine standard and phy timestamping logic
Date: Wed, 03 Sep 2014 11:53:46 -0400
Message-ID: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56401 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbaICQBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 12:01:05 -0400
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

Alexander Duyck (2):
      net-timestamp: Merge shared code between phy and regular timestamping
      net-timestamp: Make the clone operation stand-alone from phy timestamping


 include/linux/skbuff.h  |    2 +
 net/core/skbuff.c       |   86 ++++++++++++++++++++++++++++++++++++-----------
 net/core/timestamping.c |   43 ++----------------------
 3 files changed, 70 insertions(+), 61 deletions(-)

-- 
