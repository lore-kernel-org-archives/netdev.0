From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 5/6] r8169: do not account fragments as packets
Date: Fri, 15 Oct 2010 14:15:21 +0200
Message-ID: <1287144922-3297-5-git-send-email-sgruszka@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab0JOMNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 08:13:11 -0400
In-Reply-To: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only increase tx_{packets,dropped} statistics when transmit or drop
full skb, not just fragment.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f79ddb2..0ef49b4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4130,10 +4130,10 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, int n)
 
 			rtl8169_unmap_tx_skb(d, tx_skb, tp->TxDescArray + entry);
 			if (skb) {
+				tp->dev->stats.tx_dropped++;
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
-			tp->dev->stats.tx_dropped++;
 		}
 	}
 }
@@ -4443,12 +4443,12 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 			break;
 
 		dev->stats.tx_bytes += len;
-		dev->stats.tx_packets++;
 
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 
 		if (status & LastFrag) {
+			dev->stats.tx_packets++;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
-- 
1.7.1

