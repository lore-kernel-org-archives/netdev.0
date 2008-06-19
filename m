From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/4] e1000: disable TSO workaround on 82544
Date: Thu, 19 Jun 2008 17:18:36 -0400
Message-ID: <20080619211836.GC22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbYFSVSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:18:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It appears that the 82544 does not need the TSO workaround needed on
other chips.  This seems to resolve excessive messages that appear to be
Tx Unit Hangs when a system is under heavy stress.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/e1000/e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 59579b1..af6846d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3479,7 +3479,8 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (likely(tso)) {
-		tx_ring->last_tx_tso = 1;
+		if (likely(adapter->hw.mac_type != e1000_82544))
+			tx_ring->last_tx_tso = 1;
 		tx_flags |= E1000_TX_FLAGS_TSO;
 	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
-- 
1.5.2.1

