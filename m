From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 3/5] be2net: Fix rx stats updation in non-lro path
Date: Wed, 10 Jun 2009 17:51:56 +0530
Message-ID: <20090610122156.GA16719@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52602 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754457AbZFJMWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:22:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx stats are not getting updated when an rx_compl with only one frag is rcvd in non-lro path.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6487eb4..5aadd71 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -743,7 +743,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 
 	if (pktsize <= rx_frag_size) {
 		BUG_ON(num_rcvd != 1);
-		return;
+		goto done;
 	}
 
 	/* More frags present for this completion */
@@ -765,6 +765,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 		memset(page_info, 0, sizeof(*page_info));
 	}
 
+done:
 	be_rx_stats_update(adapter, pktsize, num_rcvd);
 	return;
 }
-- 
1.6.0.4

