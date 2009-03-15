From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: use hardware auto-padding.
Date: Sun, 15 Mar 2009 12:09:54 +0100
Message-ID: <20090315110954.GA17800@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, Mikael Pettersson <mikpe@it.uu.se>,
	Tim Durack <tdurack@gmail.com>, ivecera@redhat.com,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52201 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753027AbZCOLHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 07:07:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It shortens the code and fixes the current pci_unmap leak with
padded skb reported by Dave Jones.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b347340..352da2a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3363,13 +3363,6 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		opts1 |= FirstFrag;
 	} else {
 		len = skb->len;
-
-		if (unlikely(len < ETH_ZLEN)) {
-			if (skb_padto(skb, ETH_ZLEN))
-				goto err_update_stats;
-			len = ETH_ZLEN;
-		}
-
 		opts1 |= FirstFrag | LastFrag;
 		tp->tx_skb[entry].skb = skb;
 	}
@@ -3407,7 +3400,6 @@ out:
 err_stop:
 	netif_stop_queue(dev);
 	ret = NETDEV_TX_BUSY;
-err_update_stats:
 	dev->stats.tx_dropped++;
 	goto out;
 }
-- 
1.6.0.6

