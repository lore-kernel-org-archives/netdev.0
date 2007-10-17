From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] zd1201: avoid null ptr access of skb->dev
Date: Wed, 17 Oct 2007 17:10:01 -0400
Message-ID: <1192655401262-git-send-email-linville@tuxdriver.com>
References: <20071017132740.eebaed9d.akpm@linux-foundation.org>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	zairasai@googlemail.com,
	"John W. Linville" <linville@tuxdriver.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4754 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625AbXJQVj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 17:39:27 -0400
In-Reply-To: <20071017132740.eebaed9d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->dev is not set until eth_type_trans is called...

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/zd1201.c        |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 935b144..d5c0c66 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -327,8 +327,8 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, 6), &data[datalen-8], 6);
 			memcpy(skb_put(skb, 2), &data[datalen-24], 2);
 			memcpy(skb_put(skb, len), data, len);
-			skb->dev->last_rx = jiffies;
 			skb->protocol = eth_type_trans(skb, zd->dev);
+			skb->dev->last_rx = jiffies;
 			zd->stats.rx_packets++;
 			zd->stats.rx_bytes += skb->len;
 			netif_rx(skb);
@@ -384,8 +384,8 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, 2), &data[6], 2);
 			memcpy(skb_put(skb, len), data+8, len);
 		}
-		skb->dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, zd->dev);
+		skb->dev->last_rx = jiffies;
 		zd->stats.rx_packets++;
 		zd->stats.rx_bytes += skb->len;
 		netif_rx(skb);
-- 
1.5.2.4

