From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] r8169: use dev_kfree_skb() instead of dev_kfree_skb_irq()
Date: Wed, 10 Jun 2009 10:55:53 +0200
Message-ID: <4A2F7519.8010403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Michael Tokarev <mjt@tls.msk.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41775 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626AbZFJI4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:56:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8169_tx_interrupt() is used from NAPI context, it can
directly free skbs. dev_kfree_skb_irq() is a leftover from
pre-NAPI times of this driver.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e94316b..007c881 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3379,7 +3379,7 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
 
 		if (status & LastFrag) {
-			dev_kfree_skb_irq(tx_skb->skb);
+			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
 		dirty_tx++;
