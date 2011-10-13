From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/3] dp83640: use proper function to free transmit time stamping packets
Date: Thu, 13 Oct 2011 11:46:28 +0200
Message-ID: <d4208d065cae9f825a750d6520e5f641f76b5e39.1318498805.git.richard.cochran@omicron.at>
References: <cover.1318498805.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>, <stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61682 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab1JMJqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 05:46:38 -0400
Received: by bkbzt4 with SMTP id zt4so1192103bkb.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 02:46:37 -0700 (PDT)
In-Reply-To: <cover.1318498805.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1318498805.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at> <cover.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous commit enforces a new rule for handling the cloned packets
for transmit time stamping. These packets must not be freed using any other
function than skb_complete_tx_timestamp. This commit fixes the one and only
driver using this API.

The driver first appeared in v3.0.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@kernel.org>
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
