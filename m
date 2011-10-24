From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 1/2] dp83640: use proper function to free transmit time stamping packets
Date: Mon, 24 Oct 2011 19:55:31 +0200
Message-ID: <b506659c117f89701e8f45da962bcff7940d8176.1319478544.git.richard.cochran@omicron.at>
References: <cover.1319478544.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51247 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab1JXRzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:55:46 -0400
In-Reply-To: <cover.1319478544.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1319478544.git.richard.cochran@omicron.at>
References: <cover.1319478544.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit da92b194 introduced a new rule for handling the cloned packets
for transmit time stamping. These packets must not be freed using any other
function than skb_complete_tx_timestamp. This commit fixes the one and only
driver using this API.

The driver first appeared in v3.0.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@vger.kernel.org>
---
 drivers/net/phy/dp83640.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index edd7304..311f5cb 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1060,7 +1060,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 	struct dp83640_private *dp83640 = phydev->priv;
 
 	if (!dp83640->hwts_tx_en) {
-		kfree_skb(skb);
+		skb_complete_tx_timestamp(skb, NULL);
 		return;
 	}
 	skb_queue_tail(&dp83640->tx_queue, skb);
-- 
1.7.2.5
