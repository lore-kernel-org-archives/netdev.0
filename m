From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/2] b44: use netdev_alloc_skb instead of dev_alloc_skb
Date: Sat, 20 Feb 2010 21:55:26 +0100
Message-ID: <1266699326-1541-2-git-send-email-hauke@hauke-m.de>
References: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:59689 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756294Ab0BTVEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 16:04:53 -0500
In-Reply-To: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The conversion in bf0dcbd929faf036f1a4f2918090344d0e249cf5 missed the
new allocation in b44_rx.
This patch was used in OpenWRT for a long time.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/b44.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 71fa0be..bcb6a02 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -809,7 +809,7 @@ static int b44_rx(struct b44 *bp, int budget)
 			struct sk_buff *copy_skb;
 
 			b44_recycle_rx(bp, cons, bp->rx_prod);
-			copy_skb = dev_alloc_skb(len + 2);
+			copy_skb = netdev_alloc_skb(bp->dev, len + 2);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-- 
1.6.3.3

