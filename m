From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: dccp: ccids: lib: packet_history: use swap macro in
 tfrc_rx_hist_swap
Date: Sat, 28 Oct 2017 15:48:47 -0500
Message-ID: <20171028204847.GA12655@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway33.websitewelcome.com ([192.185.146.70]:28352 "EHLO
        gateway33.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751447AbdJ1Ust (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 16:48:49 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway33.websitewelcome.com (Postfix) with ESMTP id E380F22ED
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 15:48:48 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/dccp/ccids/lib/packet_history.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 08df7a3..876e185 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -149,10 +149,8 @@ static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
 {
 	const u8 idx_a = tfrc_rx_hist_index(h, a),
 		 idx_b = tfrc_rx_hist_index(h, b);
-	struct tfrc_rx_hist_entry *tmp = h->ring[idx_a];
 
-	h->ring[idx_a] = h->ring[idx_b];
-	h->ring[idx_b] = tmp;
+	swap(h->ring[idx_a], h->ring[idx_b]);
 }
 
 /*
-- 
2.7.4
