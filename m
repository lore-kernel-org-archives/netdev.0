From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 2/3] dp83640: use proper function to free transmit time stamping packets
Date: Fri, 21 Oct 2011 12:49:16 +0200
Message-ID: <966b346f5f73c0afc48f89686e9ed1f44457074b.1319193734.git.richard.cochran@omicron.at>
References: <cover.1319193734.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53783 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab1JUKtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 06:49:46 -0400
In-Reply-To: <cover.1319193734.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1319193734.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at> <cover.1319193734.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous commit enforces a new rule for handling the cloned packets
for transmit time stamping. These packets must not be freed using any other
function than skb_complete_tx_timestamp. This commit fixes the one and only
driver using this API.

The driver first appeared in v3.0.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/phy/dp83640.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index c588a16..13e5713 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1192,7 +1192,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 
 	case HWTSTAMP_TX_ONESTEP_SYNC:
 		if (is_sync(skb, type)) {
-			kfree_skb(skb);
+			skb_complete_tx_timestamp(skb, NULL);
 			return;
 		}
 		/* fall through */
@@ -1203,7 +1203,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 
 	case HWTSTAMP_TX_OFF:
 	default:
-		kfree_skb(skb);
+		skb_complete_tx_timestamp(skb, NULL);
 		break;
 	}
 }
-- 
1.7.2.5
